from flask import Flask, render_template, request, jsonify, g, session, app, Response, redirect, abort, send_from_directory
from flask.ext.login import LoginManager, login_required, login_user, logout_user, current_user 
import os
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
def index():
    return render_template("index.html")

@app.route("/alt")
def alt_index():
    return render_template("indexAlt.html")

@app.route('/images/<uid>', methods=['POST'])
@login_required
def add_image(uid):
    if current_user.get_access() == 0:
        return abort(401)
    img_num = [ x for x in os.listdir('.\static\images') if x.startswith('bldg{0}x'.format(uid))]
    img_num = len(img_num)
    target = os.path.join('.\static\images', 'bldg{0}x{1}.jpg'.format(uid,img_num))
    print(target)
    try:
        if request.files['file'].filename.rsplit('.',1)[1].upper() == 'JPG':
            request.files['file'].save(target)
        else:
            return abort(415)
    except Exception as e:
        print("Image Error {0}".format(str(e)))
        return abort(500)
    return simplejson.dumps({ 'message': 'OK' })

@app.route('/num_images/<uid>')
def num_images(uid):
    img_num = [ x for x in os.listdir('./static/images') if x.startswith('bldg{0}x'.format(uid))]
    img_num = len(img_num)
    return simplejson.dumps({ 'images': img_num })

@app.route("/username")
def username():
    return simplejson.dumps({ 'username': (current_user.get_name() if current_user.get_id() else '') })

@app.route("/find-by-name/<name>")
def find_by_name(name):
    return simplejson.dumps(db.get_buildings_by_name(g.db, name))

@app.route("/search/<terms>")
def search(terms):
    return simplejson.dumps(db.search(g.db, terms))

@app.route("/max-id")
def get_max_id():
    return simplejson.dumps(db.get_max_id(g.db))

@app.route("/find-by-id/<uid>", methods=['GET','DELETE'])
def find_by_id(uid):
    if request.method == 'GET':
        return simplejson.dumps(db.get_building_by_id(g.db, uid))
    elif request.method == 'DELETE':
        if current_user.get_id() and current_user.get_access() > 0:
            db.delete_building(g.db, uid)
            return simplejson.dumps({'message': 'OK'})
        else:
            return simplejson.dumps({'message': 'Inadequate permissions'})

@app.route("/find-by-location/<latitude>/<longitude>")
def find_by_location(latitude, longitude):
    return simplejson.dumps(db.get_closest_buildings(g.db, latitude, longitude))

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        print("username: {0}".format(username))        
        login_info = db.check_login(g.db, username, password)
        if login_info:
            user = User(login_info['id'])
            login_user(user)
            return simplejson.dumps({'message': 'OK'})
        else:
            return abort(401)
    else:
        return abort(401)

@app.route("/logout")
@login_required
def logout():
    logout_user()
    return Response('''<p>You have been logged out!''')

@app.route("/favorites/<id>")
@login_required
def add_favorite(id):
    db.toggle_favorite(g.db,id,current_user.get_id())
    return simplejson.dumps({'message': 'OK'})


@app.route("/edit", methods=['POST'])
@login_required
def edit_building():
    if current_user.get_access() > 0:
        db.update_building(g.db, request.form['architect'], request.form['description'],
            request.form['date'], request.form['id'], current_user.get_id())
        return simplejson.dumps({'message': 'OK'})
    return simplejson.dumps({'message': 'Inadequate permissions'})

@app.route("/add", methods=['POST'])
@login_required
def add_building():
    if current_user.get_access() > 0:
        db.add_building(g.db, request.form['name'], request.form['architect'],
            request.form['state'], request.form['city'], request.form['region'], request.form['address'],
            request.form['latitude'], request.form['longitude'], request.form['date'], request.form['description'], request.form['keywords'])
        return simplejson.dumps({'message': 'OK'})
    return simplejson.dumps({'message': 'Inadequate permissions'})

@app.route("/register", methods=["POST"])
def register():
    username = request.form['username']
    password = request.form['password']
    if len(password) < 8:
        return simplejson.dumps({ 'message': 'Your password must be at least 8 characters long!'})
    uid = db.add_user(g.db, username, password)
    if uid:
        login_user(User(uid))
        return simplejson.dumps({ 'message': 'OK'})
    return simplejson.dumps({ 'message': 'Username already exists!'})

# callback to relaad the user object        
@login_manager.user_loader
def load_user(userid):
    return User(userid)

@app.route("/users/<name>")
def get_user(name):
    return simplejson.dumps(db.get_account_details(g.db, name, current_user.get_id()))

@app.route("/revert/<b_id>/<rev_id>")
@login_required
def revert(b_id, rev_id):
    db.revert_building(g.db, b_id, rev_id, current_user.get_id())
    return simplejson.dumps({'response': 'OK'})

@app.route("/history/<b_id>")
def history(b_id):
    return simplejson.dumps(db.get_revisions(g.db,b_id))

if __name__ == "__main__":
    app.debug = True
    app.secret_key = "the cake is a lie, and I don't trust the pie either."
    app.run()
