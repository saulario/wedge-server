#!/usr/bin/python3
import json
import logging

import flask
import flask_restful

import wedge.api.usr as api_usr
import wedge.core.engine as engine


log = logging.getLogger(__name__)


app = flask.Flask(__name__)
api = flask_restful.Api(app)


@app.before_first_request
def setup():
    """
    Inicialización de contexto y del pool de bases de ddatos
    """
    log.info("Inicializando el contexto...")
    engine.create_context()


def check_token(func):
    """
    Comprueba el token de session
    """
    def wrapper(*args, **kwargs):
        flask.g.wedge_session = None        
        token = flask.request.headers.get("X-Wedge-Session-Key")
        if not token:
            return None
        eng, md = engine.current_context.dbpool.get(0)
        ses = None
        with eng.connect() as conn:
            with conn.begin():
                ses = api_usr.getAction(md).CheckSession(conn, token)
                if ses:
                    flask.g.wedge_session = ses
        if not ses:
            return None
        func(*args, **kwargs)

    return wrapper


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
        log.info("-----> Inicio")
        eng, md = engine.current_context.dbpool.get(0)

        username = flask.request.form.get("username")
        password = flask.request.form.get("password")

        with eng.connect() as conn:
            with conn.begin():
                ses = api_usr.getAction(md).Login(conn, username, password)

        log.info("<----- Fin")
        return ses


    @check_token
    def usrconnect(self):
        log.info("-----> Inicio")

        print("hola tonto")

        log.info("<----- Fin")

        
class UsrLogin(UsrResource):
    pass

class UsrConnect(UsrResource):
    pass

api.add_resource(UsrLogin, "/usr/login")
api.add_resource(UsrConnect, "/usr/connect")






if __name__ == "__main__":
    app.run(debug=True)