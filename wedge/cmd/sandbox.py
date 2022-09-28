#!/usr/bin/python3
import logging, logging.handlers
import sys

import wedge.bl.ctl.usr
import wedge.model.ctl.usr
import wedge.core.engine


log = logging.getLogger(__name__)


if __name__ == "__main__":

    ctx = wedge.core.engine.create_context()
    if not ctx:
        sys.stderr.write("Error obteniendo contexto...")
        sys.exit(1)

    file = (__file__.split("/")[-1]).split(".")[0]
    handler = logging.handlers.RotatingFileHandler(
            filename=f"{wedge.core.engine.WEDGE_HOME}/log/{file}.log",
            maxBytes=1024*1024*10, backupCount=5)

    logging.basicConfig(format="%(asctime)s %(module)s.%(funcName)s %(levelname)s %(message)s",
            level=logging.DEBUG, handlers=[handler])
    log.info("-----> Inicio")


    conn = ctx.engine.connect()
    usrBL = wedge.bl.ctl.usr.getBL()

    session = usrBL.login(conn, "saulario", "123456", ctx)

    s1 = usrBL.getSession(conn, session.ses.sescod, ctx)

    conn.close()

    log.info("<----- Fin")