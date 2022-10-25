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


class Gpa(wedge.model.schema.Entity):

    def __init__(self):
        self.gpacod:str = None
        self.gpanom:str = None


class GpaDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "gpa"):
        super().__init__(metadata, nombre, type=Gpa)

    def Delete(self, conn:Connection, gpacod:str) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.gpacod == gpacod,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def Insert(self, conn:Connection, entity:Gpa) -> Gpa:
        result = super().insert(conn, entity)
        entity.gpacod = result[0]
        return entity

    def Read(self, conn:Connection, gpacod:str, projection:Union[List[Column], None]=None) -> Union[Gpa,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.gpacod == gpacod,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def Update(self, conn:Connection, entity:Gpa) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        self._removeNullableCols(entity)
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.gpacod == entity.gpacod,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
