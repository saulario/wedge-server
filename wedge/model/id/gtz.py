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


class Gtz(wedge.model.schema.Entity):

    def __init__(self):
        self.gtzid:int      = None
        self.gtznom:str     = None


class GtzDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "gtz"):
        super().__init__(metadata, nombre, type=Gtz)

    def Delete(self, conn:Connection, gtzid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.gtzid == gtzid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def Insert(self, conn:Connection, entity:Gtz) -> Gtz:
        delattr(entity, "gtzid")
        result = super().insert(conn, entity)
        entity.gtzid = result[0]
        return entity

    def Read(self, conn:Connection, gtzid:int, projection:Union[List[Column], None]=None) -> Union[Gtz,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.gtzid == gtzid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def Update(self, conn:Connection, entity:Gtz) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        self._removeNullableCols(entity)        
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.gtzid == entity.gtzid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount


###############################################################################
# singleton

_dal = None

def getDAL(metadata:MetaData) -> GtzDAL:
    global _dal
    if _dal is not None: return _dal
    with threading.Lock():
        _dal = GtzDAL(metadata)
        return _dal        