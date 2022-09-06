#!/usr/bin/python3
import logging
import threading
import time

from types import Union

from sqlalchemy import and_
from sqlalchemy.engine import Connection

import wedge.model.schema

log = logging.getLogger(__name__)


# singleton
_dal = None


def getDAL(metadata):
    global _dal
    if _dal is not None: return _dal
    with threading.Lock():
        _dal = UsuDAL(metadata)
        return _dal


class Usu(wedge.model.schema.Entity):

    def __init__(self):
        self.usucod:int = None
        self.usuver:int = 0


class UsuDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "usu"):
        super().__init__(metadata, nombre, type=Usu)

    def delete(self, conn:Connection, usucod:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.usucod == usucod,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount

    def read(self, conn:Connection, usucod:int, projection=None) -> Union[Usu,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.usucod == usucod,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def update(self, conn:Connection, entity:Usu) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.usucod == entity.usucod,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount