import sqlite3
import json

def connect_db():
    return sqlite3.connect('db/buildings.db')

def build_stub_building_obj(row):
    courseid = row[0]
    title = row[3]
    code = row[9] + row[6]
    departmentCode = row[9]
    return {'id': courseid, 'title': title, 'code': code, 'departmentCode': departmentCode}

def build_full_building_obj(row):
    courseid = row[0]
    title = row[3]
    code = row[9] + row[6]
    departmentCode = row[9]
    
    return {'id': courseid, 'title': title, 'code': code, 'departmentCode': departmentCode}

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
	return get_buildings_from_cursor(c.execute("select * from buildings"))

def get_buildings_by_name(conn, name):
	c = conn.cursor()
	return get_buildings_from_cursor(c.execute("select * from buildings where upper(name) like '%" + json.dumps(name.upper())  + "%'" ), False)

def get_building_by_id(conn, id):
	c = conn.cursor()
	return build_full_building_obj(c.execute("select * from buildings where _id=" + json.dumps(id)).next())

def get_closest_buildings(conn, latitude, longitude):
	c = conn.cursor()
	req = "select * from buildings order by ((latitude-{0})*(latitude-{0}) + (longitude-{1}) * (longitude-{1})) desc limit 50"
	return get_buildings_from_cursor(c.execute(req.format(json.dumps(latutide), json.dumps(longitude)))
