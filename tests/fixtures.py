#/usr/bin/python3

import sqlalchemy.engine
import sqlalchemy.exc

TEST_URL = "postgresql+psycopg2://test:test@localhost"
CTL_URL = f"{TEST_URL}/test_ctl"
ID_URL = f"{TEST_URL}/test_id0"

USERNAME = "USUARIO"
PASSWORD = "123456"

def drop_databases():
    """
    Borra las bases de datos de tests
    """
    eng = sqlalchemy.engine.create_engine(f"{TEST_URL}/template1", isolation_level = "AUTOCOMMIT")
    eng.execute("drop database if exists test_ctl")
    eng.execute("drop database if exists test_id0")
    

def create_databases():
    """
    Crea las bases de datos con los scripts de volcado
    """
    drop_databases()
    eng = sqlalchemy.engine.create_engine(f"{TEST_URL}/template1", isolation_level = "AUTOCOMMIT")
    eng.execute("create database test_ctl owner test encoding 'utf-8' locale 'C' template template0")
    eng.execute("create database test_id0 owner test encoding 'utf-8' locale 'C' template template0")

    eng = sqlalchemy.engine.create_engine(CTL_URL, isolation_level = "AUTOCOMMIT")

    lines = ""
    with open("scripts/ctl/dump.sql", "r") as file:
        for line in file.readlines():
            if not line or line.startswith("--") or line.startswith("SET"): continue
            lines += line.replace("\n", "")
    
    for line in lines.split(";"):
        if not line: continue
        #print(line)
        eng.execute(line)

    eng = sqlalchemy.engine.create_engine(CTL_URL)
    eng.execute("insert into cli(clinom) values('CLIENTE 1 DE TEST')")
    eng.execute(f"insert into ins(insnom, inscliid, insurl) values('INSTANCIA 1 DE TEST', '1', '{TEST_URL}/test_id0')")
    eng.execute(f"insert into ins(insnom, inscliid, insurl) values('INSTANCIA 2 DE TEST', '1', '{TEST_URL}/test_id0')")
    eng.execute("""insert into usr(usrcod, usrnom, usrpwd, usrfcr, usri18, usreml, usract) values(
        'USUARIO', 'USUARIO 1 DE TEST', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
        '2022-01-01 00:01:00', 'es_ES', 'usuario@nomail.com', 1
    )""")
    eng.execute("""insert into sus(sususrid, susinsid, susfcr, susact) values(
        1, 1, '2022-01-01 00:01:00', 1
    )""")
    eng.execute("""insert into sus(sususrid, susinsid, susfcr, susact) values(
        1, 2, '2022-01-01 00:01:00', 1
    )""")


    lines = ""
    eng = sqlalchemy.engine.create_engine(ID_URL, isolation_level = "AUTOCOMMIT")
    with open("scripts/instance/dump.sql", "r") as file:
        for line in file.readlines():
            if not line or line.startswith("--") or line.startswith("SET"): continue
            lines += line.replace("\n", "")

    for line in lines.split(";"):
        if not line: continue
        #print(line)
        eng.execute(line)