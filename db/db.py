import sqlite3
import json
import hashlib

def connect_db():
    return sqlite3.connect('db/buildings.db')

def build_stub_building_obj(row):
    return {'id': row[0], 'name': row[1], 'architect': row[2], 'address': row[3], 'latitude': str(row[4]), 'longitude': str(row[5]) }

# latitude, longitude converted to strings because the json parser
# in android does not support getting floats
def build_full_building_obj(conn, row):
    return {'id': row[0], 'name': row[1], 'architect': row[2],
    'address': row[3], 'latitude': str(row[4]), 'longitude': str(row[5]),
    'date': row[6], 'description': row[7], 'keywords': get_keywords(conn, row[0]) }

def get_keywords(conn, uid):
    c = conn.cursor()
    ret = []
    res = c.execute('select keywords.name from keywords inner join keyword_map on keyword_map.building_id=' +  str(uid) + ' and keyword_map.keyword_id=keywords.id')
    for row in res:
        ret += row[0]
    return ret

def get_buildings_from_cursor(conn, res, full=True):
    ret = []
    for result in res:
        if full:
            ret.append(build_full_building_obj(conn, result))
        else:
            ret.append(build_stub_building_obj(result))
    return ret

def get_max_id(conn): # since we start at 0, we can use this to search for potential pictures when that's all we want
    c = conn.cursor()
    return { 'id': c.execute('select max(_id) from buildings').fetchone()[0] }

def search(conn, terms):
    c = conn.cursor()
    terms = terms.split()
    ids = []
    for row in c.execute("select building_id from keyword_map join keywords on keyword_map.keyword_id=keywords.id where upper(keywords.name) like {0}".format(json.dumps('%' + terms[0].upper() + '%'))):
        ids.append(row[0])
    for row in c.execute("select _id from building_info where upper(name) like {0} or upper(architect) like {0} or upper(address) like {0} or upper(date) like {0}".format(json.dumps('%' + terms[0].upper() + '%'))):
        ids.append(row[0])
    for term in terms[1:]:
        row_ids = []
        for row in c.execute("select building_id from keyword_map join keywords on keyword_map.keyword_id=keywords.id where upper(keywords.name) like {0}".format(json.dumps('%' + term.upper() + '%'))):
            row_ids.append(row[0])
        for row in c.execute("select _id from building_info where upper(name) like {0} or upper(architect) like {0} or upper(address) like {0} or upper(date) like {0}".format(json.dumps('%' + term.upper() + '%'))):
            row_ids.append(row[0])
        ids = [val for val in ids if val in row_ids]
    if len(ids) > 0:
        cmd = "select * from building_info where "
        for uid in ids:
            cmd += "_id=" + json.dumps(uid) + " or "
        return get_buildings_from_cursor(conn,c.execute(cmd[:-3]), False)
    else:
        return []


def get_building_by_id(conn, id):
    c = conn.cursor()
    return build_full_building_obj(conn, c.execute("select * from building_info where _id=" + json.dumps(id)).fetchone())

def get_closest_buildings(conn, latitude, longitude):
    c = conn.cursor()
    req = "select * from building_info where (latitude != 0 or longitude != 0) order by ((latitude-{0})*(latitude-{0}) + (longitude-{1}) * (longitude-{1})) asc limit 50"
    return get_buildings_from_cursor(conn, c.execute(req.format(json.dumps(latitude), json.dumps(longitude))))

def check_login(conn, username, password):
    c = conn.cursor()
    m = hashlib.md5()
    m.update(bytes("MRD" + password,'utf-8'))
    req = "select * from users where username={0} and password={1}"
    row = c.execute(req.format(json.dumps(username),json.dumps(m.hexdigest()))).fetchone()
    if row:
        return { 'id': row[0], 'username': row[1], 'password': row[2] }
    return None

def update_building(conn, architect, description, date, id, user_id):
    c = conn.cursor()
    data = c.execute("select * from building_info where _id=" + json.dumps(id)).fetchone()
    currData = [json.dumps(x) for x in data]
    currRev = c.execute("select current_rev from buildings where _id=" + json.dumps(id)).fetchone()[0]
    if architect:
        currData[2] = json.dumps(architect)
    if description:
        currData[7] = json.dumps(description)
    if date:
        currData[6] = json.dumps(date)
    c.execute("insert into data (last_rev,architect,address,latitude,longitude,date,description,edit_author) values ("
        + json.dumps(currRev) + "," + currData[2] + "," + currData[3] + "," + currData[4] + "," + currData[5] + "," + currData[6]
        + "," + currData[7] + "," + json.dumps(user_id)
        + ")")
    c.execute("update buildings set current_rev=" + str(c.lastrowid) + " where _id=" + json.dumps(id))
    conn.commit()

def add_building(conn, name, architect, address, latitude, longitude, date, description, keywords):
    c = conn.cursor()
    c.execute('insert into data (last_rev,architect,address,latitude,longitude,date,description) values (' +
        currRev + "," + json.dumps(architect) + "," + json.dumps(address) + "," + json.dumps(latitude) +
        json.dumps(longitude) + json.dumps(date) + json.dumps(description))
    c.execute("insert into buildings (current_rev, name) values ({0},{1})".format(c.lastrowid, name))
    building_id = c.lastrowid
    keywords = keywords.split() # any whitespace should just be made into separate tags
    keyword_ids = []
    for key in keywords:
        res = c.execute('select _id in keywords where name=' + json.dumps(key))
        if res:
            keyword_ids = res.fetchone()[0]
        else:
            c.execute('insert into keywords (name) values (' + json.dumps(key) + ')')
            c.execute('insert into keyword_map (building_id,keyword_id) values ('
                + str(building_id) + ',' + str(c.lastrowid) + ')')
    conn.commit()

def toggle_favorite(conn, uid, user_id):
    c = conn.cursor()
    uid = json.dumps(uid)
    user_id = json.dumps(user_id)
    if c.execute('select count(*) from favorites where b_id={0} and user_id={1}'.format(uid,user_id)).fetchone()[0] > 0: # we need to remove it
        c.execute('delete from favorites where b_id={0} and user_id={1}'.format(uid,user_id))
    else:
        c.execute('insert into favorites (b_id,user_id) values ({0},{1}'.format(uid,user_id))


def delete_building(conn, uid):
    c = conn.cursor()
    c.execute("delete from buildings where _id={0}".format(json.dumps(uid)))
    conn.commit()

def revert_buiding(conn, id, rev_id, current_user_id):
    c = conn.cursor()
    data = c.execute("select * from data where _id=" + json.dumps(rev_id)).fetchone()
    currRev = c.execute("select current_rev from buildings where _id=" + json.dumps(id)).fetchone()[0]
    c.execute('insert into data (last_rev,architect, address, latitude, longitude, date, description, edit_author) values ('
        + json.dumps(currRev) + ',' + json.dumps(data[2]) + ',' + json.dumps(data[3]) + ',' + json.dumps(data[4]) + ','
        + json.dumps(data[5]) + ',' + json.dumps(data[6]) + ',' + json.dumps(data[7]) + ',' + json.dumps(current_user_id) + ')')
    c.execute("update buildings set current_rev=" + str(c.lastrowid) + " where _id=" + json.dumps(id))
    conn.commit()


def get_info(conn, uid):
    c = conn.cursor()
    row = c.execute("select * from users where id=" + json.dumps(uid)).fetchone()
    if row:
        return { 'id': row[0], 'username': row[1], 'password': row[2], 'access_level': row[3] }

def add_user(conn, username, password):
    c = conn.cursor()
    row = c.execute("select id from users where username={0}".format(json.dumps(username))).fetchone()
    if row:
        return None
    m = hashlib.md5()
    m.update(bytes("MRD" + password,'utf-8'))
    c.execute("insert into users (username,password,access_level) values({0},{1},0)".format(json.dumps(username),json.dumps(m.hexdigest())))
    conn.commit()
    return c.execute("select id from users where username={0}".format(json.dumps(username))).fetchone()[0]

def delete_user(conn, uid):
    c = conn.cursor()
    c.execute("delete from users where id={0}".format(json.dumps(uid)))
    conn.commit()

def get_account_details(conn, username, curr_user_id):
    c = conn.cursor()
    res = c.execute('select * from users where username=' + json.dumps(username)).fetchone()
    if res[0] == curr_user_id:
        return { 'id': res[0], 'username': res[1], 'access_level': res[3], 'number_edits': res[4], 'email': res[5], 'real_name': res[6] }
    else:
        return { 'id': res[0], 'username': res[1], 'access_level': res[3], 'number_edits': res[4], 'real_name': res[6] }

def get_revisions(conn, b_id):
    c = conn.cursor()
    currRev = c.execute('select current_rev from buildings where _id=' + json.dumps(b_id)).fetchone()[0]
    ret = []
    while currRev != None:
        row = c.execute('select _id,last_rev from data where _id=' + json.dumps(currRev)).fetchone()
        ret.append(row[0])
        currRev = row[1]
    return ret
