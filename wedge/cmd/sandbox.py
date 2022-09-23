#!/usr/bin/python3
import datetime as dt
import uuid

import sqlalchemy

import wedge.model.ctl.ses


if __name__ == "__main__":
    engine = sqlalchemy.create_engine("postgresql+psycopg2://ctl:123456@localhost:5432/wedge_ctl")
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
