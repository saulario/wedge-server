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
        _dal = InsDAL(metadata)
        return _dal


class Ins(wedge.model.schema.Entity):

    def __init__(self):
        self.insid:int = None


class InsDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "ins"):
        super().__init__(metadata, nombre, type=Ins)

    def delete(self, conn:Connection, insid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.insid == insid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def insert(self, conn:Connection, entity:Ins) -> Ins:
        delattr(entity, "insid")
        result = super().insert(conn, entity)
        entity.insid = result[0]
        return entity

    def read(self, conn:Connection, insid:int, projection:Union[List[Column], None]=None) -> Union[Ins,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.insid == insid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def update(self, conn:Connection, entity:Ins) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.insid == entity.insid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
