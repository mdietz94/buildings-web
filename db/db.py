import sqlite3
import json
def connect_db():
    return sqlite3.connect('db/buildings.db')

def build_stub_building_obj(row):
    uid = row[0]
    name = row[1]
    return {'id': row[0], 'name': row[1] }

def build_full_building_obj(row):
    return {'id': row[0], 'name': row[1], 'architect': row[2], 'country': row[3], 'state': row[4], 'city': row[5], 'region': row[6],
    'address': row[7], 'latitude': row[8], 'longitude': row[9], 'date': row[10], 'description': row[11], 'keywords': row[12] }

def get_buildings_from_cursor(res, full=True):
    ret = []
    for result in res:
        if full:
            ret.append(build_full_building_obj(result))
        else:
            ret.append(build_stub_building_obj(result))
    return ret

def get_all_buildings(conn):
    c = conn.cursor()
    return get_buildings_from_cursor(c.execute("select * from buildings"), False)

def get_buildings_by_name(conn, name):
    c = conn.cursor()
    return get_buildings_from_cursor(c.execute("select * from buildings where upper(name) like '%" + name.upper()  + "%'" ), False)

def get_building_by_id(conn, id):
    c = conn.cursor()
    return build_full_building_obj(c.execute("select * from buildings where _id=" + json.dumps(id)).fetchone())

def get_closest_buildings(conn, latitude, longitude):
    c = conn.cursor()
    req = "select * from buildings where latitude != 0 or longitude != 0 order by ((latitude-{0})*(latitude-{0}) + (longitude-{1}) * (longitude-{1})) desc limit 50"
    return get_buildings_from_cursor(c.execute(req.format(json.dumps(latitude), json.dumps(longitude))))
