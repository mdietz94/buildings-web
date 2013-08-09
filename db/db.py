import sqlite3
import json
import hashlib

def connect_db():
    return sqlite3.connect('db/buildings.db')

def build_stub_building_obj(row):
    return {'id': row[0], 'name': row[1], 'architect': row[2], 'latitude': str(row[8]), 'longitude': str(row[9]) }

# latitude, longitude converted to strings because the json parser
# in android does not support getting floats
def build_full_building_obj(conn, row):
    c = conn.cursor()
    country = c.execute('select name from countries where id=' + str(row[3])).fetchone()[0]
    return {'id': row[0], 'name': row[1], 'architect': row[2], 'country': country, 'state': row[4], 'city': row[5], 'region': row[6],
    'address': row[7], 'latitude': str(row[8]), 'longitude': str(row[9]), 'date': row[10], 'description': row[11], 'keywords': get_keywords(conn, row[0]) }

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

def get_buildings_by_name(conn, name):
    c = conn.cursor()
    return get_buildings_from_cursor(conn, c.execute("select * from buildings where upper(name) like '%" + name.upper()  + "%' order by length(description)  desc limit 50" ), False)

def search(conn, terms):
    c = conn.cursor()
    return get_buildings_from_cursor(conn, c.execute("select * from buildings where upper(name) like {0} or upper(architect) like {0} or upper(state) like {0} or upper(city) like {0} or upper(date) like {0} order by length(description)  desc limit 50".format(json.dumps('%' + terms.upper() + '%')) ), False)

def get_building_by_id(conn, id):
    c = conn.cursor()
    return build_full_building_obj(conn, c.execute("select * from buildings where _id=" + json.dumps(id)).fetchone())

def get_closest_buildings(conn, latitude, longitude):
    c = conn.cursor()
    req = "select * from buildings where (latitude != 0 or longitude != 0) order by ((latitude-{0})*(latitude-{0}) + (longitude-{1}) * (longitude-{1})) asc limit 50"
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

def update_building(conn, architect, description, name, date, id):
    c = conn.cursor()
    req = "update buildings set architect={0},description={1},name={2},date={3} where _id={4}"
    c.execute(req.format(json.dumps(architect), json.dumps(description), json.dumps(name), json.dumps(date),json.dumps(id)))
    conn.commit()

def add_building(conn, name, architect, state, city, region, address, latitude, longitude, date, description, keywords):
    c = conn.cursor()
    req = "insert into buildings (name, architect, country, state, city, region, address, latitude, longitude, date, description, keywords) values ({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11})"
    keywords = ";".join(keywords.split()) # any whitespace should just be made into separate tags
    c.execute(req.format(json.dumps(name),json.dumps(architect),json.dumps('United States'),json.dumps(state),json.dumps(city),json.dumps(region),json.dumps(address),json.dumps(latitude),json.dumps(longitude),json.dumps(date),json.dumps(description),json.dumps(keywords)))
    conn.commit()

def delete_building(conn, uid):
    c = conn.cursor()
    c.execute("delete from buildings where _id={0}".format(json.dumps(uid)))
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
