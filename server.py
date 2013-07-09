from flask import Flask, render_template, request, jsonify, g, session
import simplejson
import db


app = Flask(__name__)

@app.before_request()
def before_request():
	g.db = db.connect_db()

@app.route("/")
def hello():
    return render_template("index.html")

@app.route("/find-by-name/<name>")
def find_by_name(name):
	return simplejson.dumps(db.get_building_by_name(g.db, name))

@app.route("/find-by-id/<id>")
def find_by_id(id):
	return simplejson.dumps(db.get_building_by_id(g.db, id))

@app.route("find-by-location/<latitude>/<longitude>")
def find_by_location(latitude, longitude):
	return simplejson.dumps(db.get_closest_buildings(g.db, latitude, longitude))

if __name__ == "__main__":
    app.run()