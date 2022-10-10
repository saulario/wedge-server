#!/Gpa/bin/python3
import datetime as dt
import logging
import threading

from typing import Union

import sqlalchemy.engine

import wedge.core.engine as engine
import wedge.model.id.gpa as idgpa

log = logging.getLogger(__name__)


# singleton
_bl = None

def getBL():
    global _bl
    if _bl is not None: return _bl
    with threading.Lock():
        _bl = GpaBL()
        return _bl


class GpaBL():

    def Delete(self, con:sqlalchemy.engine.Connection, gpacod:str, session:engine.Session) -> int:
        return idgpa.getDAL().delete(con, gpacod)

    def Insert(self, con:sqlalchemy.engine.Connection, gpa:idgpa.Gpa, session:engine.Session) -> idgpa.Gpa:
        return idgpa.getDAL().insert(con, gpa)

    def Read(self, con:sqlalchemy.engine.Connection, gpacod:str, session:engine.Session) -> Union[idgpa.Gpa, None]:
        gpaDAL = idgpa.getDAL()
        return gpaDAL.read(con, gpacod, list(gpaDAL.t.c))

    def Update(self, con:sqlalchemy.engine.Connection, gpa:idgpa.Gpa, session:engine.Session) -> int:
        return idgpa.getDAL().update(con, gpa)