from flask import Flask, render_template, request, jsonify, g, session, app, Response, redirect, abort
from flask.ext.login import LoginManager, login_required, login_user, logout_user 


import simplejson
from db import db
from user import *
import json


app = Flask(__name__)

login_manager = LoginManager()
login_manager.setup_app(app)
login_manager.login_view = "login"

@app.before_request
def before_request():
    g.db = db.connect_db()

@app.route("/")
@login_required
def hello():
    return render_template("index.html")

@app.route("/find-by-name/<name>")
def find_by_name(name):
    return simplejson.dumps(db.get_buildings_by_name(g.db, name))

@app.route("/find-by-id/<id>")
def find_by_id(id):
    return simplejson.dumps(db.get_building_by_id(g.db, id))

@app.route("/find-by-location/<latitude>/<longitude>")
def find_by_location(latitude, longitude):
    return simplejson.dumps(db.get_closest_buildings(g.db, latitude, longitude))

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']        
        login_info = db.check_login(g.db, username, password)
        if login_info:
            user = User(login_info['id'])
            login_user(user)
            return redirect("/")
        else:
            return abort(401)
    else:
        return render_template("login.html")

@app.route("/logout")
@login_required
def logout():
    logout_user()
    return Response('''<p>You have been logged out!''')

@app.route("/register", methods=["GET","POST"])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db.add_user(g.db, username, password)
        return redirect("/login")
    else:
        return render_template("register.html")

# handle login failed
@app.errorhandler(401)
def page_not_found(e):
    return Response('<p>Login failed</p>')

# callback to relaad the user object        
@login_manager.user_loader
def load_user(userid):
    return User(userid)

if __name__ == "__main__":
    app.debug = True
    app.secret_key = "the cake is a lie, and I don't trust the pie either."
    app.run()
