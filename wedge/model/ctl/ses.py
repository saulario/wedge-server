#!/usr/bin/python3
import logging
import threading
import time
import uuid

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
        _dal = SesDAL(metadata)
        return _dal


class Ses(wedge.model.schema.Entity):

    def __init__(self):
        self.sescod:str = None


class SesDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "ses"):
        super().__init__(metadata, nombre, type=Ses)

    def delete(self, conn:Connection, sescod:str) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.sescod == sescod,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def insert(self, conn:Connection, entity:Ses) -> Ses:
        entity.sescod = str(uuid.uuid4())
        result = super().insert(conn, entity)
        entity.sescod = result[0]
        return entity

    def read(self, conn:Connection, sescod:int, projection:Union[List[Column], None]=None) -> Union[Ses,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.sescod == sescod,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def update(self, conn:Connection, entity:Ses) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.sescod == entity.sescod,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount