#!/usr/bin/python3
import logging
import logging.handlers
import os.path
import sys

import pytz
import sqlalchemy.engine

import wedge.bl.ctl.usr as bl_usr
import wedge.core.engine
import wedge.model.ctl.usr as model_usr
import wedge.model.id.gpa as model_gpa

log = logging.getLogger(__name__)



class Clazz():
    
    def __init__(self):
        self.texto = "esto es un texto"

    def m1(self, p="esto un parametro"):
        print("hola")
        return None



if __name__ == "__main__":

    ctx = wedge.core.engine.create_context()
    if not ctx:
        sys.stderr.write("Error obteniendo contexto...")
        sys.exit(1)

    file = os.path.basename(__file__).split(".")[0]
    handler = logging.handlers.RotatingFileHandler(
            filename=f"{wedge.core.engine.WEDGE_HOME}/log/{file}.log",
            maxBytes=1024*1024*10, backupCount=5)

    logging.basicConfig(format="%(asctime)s %(module)s.%(funcName)s %(levelname)s %(message)s",
            level=logging.DEBUG, handlers=[handler])
    log.info("-----> Inicio")

    conn = ctx.engine.connect()
    usrBL = bl_usr.getBL()

    session = usrBL.Login(conn, "saulario", "123456", ctx)
    s1 = usrBL.CheckSession(conn, session.ses.sescod, ctx)

    eng = [ x.engine for x in s1.insList if x.insid == s1.ses.sesinsid ]
    eng:sqlalchemy.engine.Engine = eng[0] if eng else None

    with eng.connect() as c1:
        model_gpa.getDAL(None)
    

    conn.close()

    log.info("<----- Fin")
