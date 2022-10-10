#!/usr/bin/python3
import json
import logging

import flask
import flask_restful
import sqlalchemy.engine
import sqlalchemy.schema

import wedge.api.gpa as api_gpa
import wedge.api.usr as api_usr
import wedge.core.engine as engine


log = logging.getLogger(__name__)


app = flask.Flask(__name__)
api = flask_restful.Api(app)


###############################################################################
# Esta parte se tiene que refactorizar
#

def check_token(func):
    """
    Comprueba el token de session. La sesión la registra en g
    """
    def wrapper(*args, **kwargs):
        flask.g.session = None        
        token = flask.request.headers.get("X-Wedge-Session-Key")
        if not token:
            return None
        eng, md = engine.current_context.dbpool.get(0)
        ses = None
        with eng.connect() as conn:
            with conn.begin():
                ses = api_usr.getAction(md).CheckSession(conn, token)
                if ses:
                    flask.g.session = ses
        if not ses:
            return None
        return func(*args, **kwargs)

    return wrapper

def transaction(func):
    """
    Controla una transacción dentro del id seleccionado. Engine, metadata
    y connection quedan registrados en g
    """
    def wrapper(*args, **kwargs):
        ws = flask.g.session
        flask.g.id_engine, flask.g.id_metadata = engine.current_context.dbpool.get(ws.ses.sesinsid)
        with flask.g.id_engine.connect() as conn:
            with conn.begin():
                flask.g.id_connection = conn
                return func(*args, **kwargs)
            conn.close()
    return wrapper

class BaseResource(flask_restful.Resource):

    def delete(self, **kwargs):
        return self.dispatch(**kwargs)

    def get(self, **kwargs):
        return self.dispatch(**kwargs)

    def post(self, **kwargs):
        return self.dispatch(**kwargs)

    def put(self, **kwargs):
        return self.dispatch(**kwargs)

    def dispatch(self, **kwargs):
        """
        Invoca el método que se compone con el endpoing y con el verbo http
        """
        metodo = f"{flask.request.endpoint}_{flask.request.method}"
        retval = getattr(self, metodo, self.nullEndpoint)(**kwargs)
        return retval

    def nullEndpoint(self, **kwargs):
        """
        Fallback por si no encuentra mapeado el método
        """
        log.warn("Atención: método no mapeado...")
        return None

class UsrResource(BaseResource):
    
    def dispatch(self, **kwargs):
        getattr(self, flask.request.endpoint, self.nullEndpoint)(**kwargs)

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

    @check_token
    def usrrd(self, conn:sqlalchemy.engine.Connection, md:sqlalchemy.schema.MetaData, usrid:int):
        log.info("-----> Inicio")

        print(f"recibido id: {id}")

        log.info("<----- Fin")


class GpaResource(BaseResource):

    @check_token
    def gpacu(self, entty):
        pass

    @check_token
    @transaction
    def gpard_GET(self, gpacod:str):
        retval = api_gpa.getAction(flask.g.id_metadata).Read(flask.g.id_connection, gpacod, flask.g.session)
        return retval

    @check_token
    @transaction
    def gpard_DELETE(self, gpacod:str):
        print("hola delete " + gpacod)


###############################################################################
# Esta parte es propia del arranque del servicio
#

URL_BASE = "/wedge-api"

@app.before_first_request
def setup():
    """
    Inicialización de contexto y del pool de bases de ddatos
    """
    log.info("Inicializando el contexto...")
    engine.create_context()

api.add_resource(UsrResource, f"{URL_BASE}/usr",            endpoint="usrcu")
api.add_resource(UsrResource, f"{URL_BASE}/usr/<usrid>",    endpoint="usrrd")
api.add_resource(UsrResource, f"{URL_BASE}/usr/connect",    endpoint="usrconnect")
api.add_resource(UsrResource, f"{URL_BASE}/usr/login",      endpoint="usrlogin")

api.add_resource(GpaResource, f"{URL_BASE}/gpa",            endpoint="gpacu")
api.add_resource(GpaResource, f"{URL_BASE}/gpa/<gpacod>",   endpoint="gpard")
