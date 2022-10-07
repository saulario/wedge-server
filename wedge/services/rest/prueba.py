#!/usr/bin/python3
import json
import logging

import flask
import flask_restful

import wedge.api.usr


app = flask.Flask(__name__)
api = flask_restful.Api(app)


class UsrLogin(flask_restful.Resource):

    def post(self):

        r = flask.request
        action = wedge.api.usr.UsrAction()
        s = action.Login(r.form.get("username", None), r.form.get("password", None))

        return json.dumps(s, 
                default=lambda d: d.__dict__ if hasattr(d, "__dict__") else d, 
                ensure_ascii=False)


class UsrCheckSession(flask_restful.Resource):

    def post(self):
        return None

api.add_resource(UsrLogin, "/usr/login")
api.add_resource(UsrCheckSession, "/usr/checkSession")

if __name__ == "__main__":
    app.run(debug=True)