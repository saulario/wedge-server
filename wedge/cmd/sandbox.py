#!/usr/bin/python3
import datetime as dt
import uuid

import sqlalchemy

import wedge.core.engine
import wedge.core.i18n as i18n
import wedge.model.ctl.ses


if __name__ == "__main__":

    m1 = i18n.get_message(wedge.core.engine.Session(i18n="es_ES"), "G00001")
    m1 = i18n.get_message(wedge.core.engine.Session(i18n="es_ES"), "G00002")
    m1 = i18n.get_message(wedge.core.engine.Session(i18n="en_EN"), "G00001")

    engine = sqlalchemy.create_engine("postgresql+psycopg2://devel:devel@localhost:5432/wedge_ctl")
    metadata = sqlalchemy.MetaData(bind=engine)

    u = uuid.uuid4()

    conn = engine.connect()

    dal = wedge.model.ctl.ses.getDAL(metadata)
    e = wedge.model.ctl.ses.Ses()

    e.sesusrid = 1
    e.sesinsid = 1
    e.sesfcr = e.sesful = dt.datetime.utcnow()

    dal.insert(conn, e)

    conn.close()
