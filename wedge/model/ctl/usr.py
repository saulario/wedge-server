#!/usr/bin/python3
import logging
import threading
import time

from typing import List, Union

from sqlalchemy import and_
from sqlalchemy.engine import Connection
from sqlalchemy.schema import Column

import wedge.model.schema

log = logging.getLogger(__name__)


# singleton
_dal = None


def getDAL(metadata):
    global _dal
    if _dal is not None: return _dal
    with threading.Lock():
        _dal = UsrDAL(metadata)
        return _dal


class Usr(wedge.model.schema.Entity):

    def __init__(self):
        self.usrid:int = None


class UsrDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "usr"):
        super().__init__(metadata, nombre, type=Usr)

    def delete(self, conn:Connection, usrid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.usrid == usrid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def insert(self, conn:Connection, entity:Usr) -> Usr:
        delattr(entity, "usrid")
        result = super().insert(conn, entity)
        entity.usrid = result[0]
        return entity

    def read(self, conn:Connection, usrid:int, projection:Union[List[Column], None]=None) -> Union[Usr,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.usrid == usrid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def update(self, conn:Connection, entity:Usr) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.usrid == entity.usrid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount