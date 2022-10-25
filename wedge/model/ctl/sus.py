#!/usr/bin/python3
import datetime as dt
import logging
import threading
import time

from typing import List, Union

from sqlalchemy import and_
from sqlalchemy.engine import Connection
from sqlalchemy.schema import Column, MetaData

import wedge.model.ctl.ins
import wedge.model.schema


log = logging.getLogger(__name__)


class Sus(wedge.model.schema.Entity):

    def __init__(self):
        self.susid:int          = None
        self.sususrid:int       = None
        self.susinsid:int       = None
        self.susfcr:dt.datetime = None
        self.susact:int         = None


class SusDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "sus"):
        super().__init__(metadata, nombre, type=Sus)

    def Delete(self, conn:Connection, susid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.susid == susid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def Insert(self, conn:Connection, entity:Sus) -> Sus:
        delattr(entity, "susid")
        result = super().Insert(conn, entity)
        entity.susid = result[0]
        return entity

    def Read(self, conn:Connection, susid:int, projection:Union[List[Column], None]=None) -> Union[Sus,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.Select(projection).where(and_(
                t.c.susid == susid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def Update(self, conn:Connection, entity:Sus) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        self._removeNullableCols(entity)        
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.susid == entity.susid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
