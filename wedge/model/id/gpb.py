#!/usr/bin/python3
import logging
import threading
import time

from typing import List, Union

from sqlalchemy import and_
from sqlalchemy.engine import Connection
from sqlalchemy.schema import Column, MetaData

import wedge.model.schema


log = logging.getLogger(__name__)


class Gpb(wedge.model.schema.Entity):
    """
    Relación entre países y las zonas horarias que contiene
    """
    def __init__(self):
        self.gpbid:int      = None
        self.gpbgpacod:str  = None
        self.gpbgtzid:int   = None


class GpbDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "gpb"):
        super().__init__(metadata, nombre, type=Gpb)

    def delete(self, conn:Connection, gpbid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.gpbid == gpbid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def insert(self, conn:Connection, entity:Gpb) -> Gpb:
        delattr(entity, "gpbid")
        result = super().insert(conn, entity)
        entity.gpbid = result[0]
        return entity

    def read(self, conn:Connection, gpbid:int, projection:Union[List[Column], None]=None) -> Union[Gpb,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.gpbid == gpbid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def update(self, conn:Connection, entity:Gpb) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        self._removeNullableCols(entity)
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.gpbid == entity.gpbid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount


###############################################################################
# singleton

_dal = None

def getDAL(metadata:MetaData) -> GpbDAL:
    global _dal
    if _dal is not None: return _dal
    with threading.Lock():
        _dal = GpbDAL(metadata)
        return _dal

