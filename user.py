from flask.ext.login import UserMixin
from db import db
class User(UserMixin):

    def __init__(self, userid):
        self.id = userid
        self.db = db.connect_db()
        login_info = db.get_info(self.db, userid)
        self.name = login_info['username']
        self.password = login_info['password']
        
    def __repr__(self):
        return "%d/%s/%s" % (self.id, self.name, self.password)