#!/usr/bin/python3
import json
import logging

import flask
import flask_restful

import wedge.api.usr


app = flask.Flask(__name__)
api = flask_restful.Api(app)


class UsrLoginXX(flask_restful.Resource):

    def post(self):

        r = flask.request
        action = wedge.api.usr.UsrAction()
        s = action.Login(r.form.get("username", None), r.form.get("password", None))

        return json.dumps(s, 
                default=lambda d: d.__dict__ if hasattr(d, "__dict__") else d, 
                ensure_ascii=False)


class UsrCheckSessionXX(flask_restful.Resource):

    def post(self):
        return None

class BaseResource(flask_restful.Resource):

    def get(self):
        return self.dispatch()

    def post(self):
        return self.dispatch()

    def dispatch(self):
        return None

    def nullEndpoint(self):
        return None

class UsrResource(BaseResource):

    def dispatch(self):
        getattr(self, flask.request.endpoint, self.nullEndpoint)()

    def usrlogin(self):
        pass

    def usrconnect(self):
        pass
        
class UsrLogin(UsrResource):
    pass

class UsrConnect(UsrResource):
    pass

api.add_resource(UsrLogin, "/usr/login")
api.add_resource(UsrConnect, "/usr/connect")






if __name__ == "__main__":
    app.run(debug=True)