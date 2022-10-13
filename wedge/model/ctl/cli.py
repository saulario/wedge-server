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


class Cli(wedge.model.schema.Entity):

    def __init__(self):
        self.cliid:int      = None
        self.clinom:str     = None


class CliDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "cli"):
        super().__init__(metadata, nombre, type=Cli)

    def Delete(self, conn:Connection, cliid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.cliid == cliid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def Insert(self, conn:Connection, entity:Cli) -> Cli:
        delattr(entity, "cliid")
        result = super().insert(conn, entity)
        entity.cliid = result[0]
        return entity

    def Read(self, conn:Connection, cliid:int, projection:Union[List[Column], None]=None) -> Union[Cli,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.cliid == cliid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def Update(self, conn:Connection, entity:Cli) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.cliid == entity.cliid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount


###############################################################################
# singleton

_dal = None

def getDAL(metadata:MetaData) -> CliDAL:
    global _dal
    if _dal is not None: return _dal
    with threading.Lock():
        _dal = CliDAL(metadata)
        return _dal
