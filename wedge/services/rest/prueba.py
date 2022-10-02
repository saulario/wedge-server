#!/usr/bin/python3

import flask
import flask_restful

import wedge.core.engine as engine

app = flask.Flask(__name__)
api = flask_restful.Api(app)

todos = {}

class UsrLogin(flask_restful.Resource):

    def post(self):
        return engine.Session()

class UsrCheckSession(flask_restful.Resource):

    def post(self):
        return engine.Session()

api.add_resource(UsrLogin, "/usr/login")
api.add_resource(UsrCheckSession, "/usr/checkSession")

if __name__ == "__main__":
    app.run(debug=True)