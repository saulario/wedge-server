#!/usr/bin/python3
import datetime as dt

import sqlalchemy

import wedge.model.ctl.account


if __name__ == "__main__":
    engine = sqlalchemy.create_engine("postgresql+psycopg2://ctl:Cursomania@localhost:5432/wedge_ctl")
    metadata = sqlalchemy.MetaData(bind=engine)

    conn = engine.connect()

    accountDAL = wedge.model.ctl.account.getDAL(metadata)
    account = wedge.model.ctl.account.Account()
    account.id = 0
    account.username = "Nombre del usuario"
    account.email = "saulario@elusuario.com"
    account.password = "password"
    account.active = 1
    account.creation_date = dt.datetime.utcnow()

    ac1 = accountDAL.insert(conn, account)

    ac2 = accountDAL.read(conn, 2)
    ac2.id = 2
    ac2.username = "saulario " + dt.datetime.utcnow().isoformat()
    result = accountDAL.update(conn, ac2)

    conn.close()
