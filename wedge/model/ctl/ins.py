#!/usr/bin/python3
import logging
import threading
import time

from typing import List, Union

import sqlalchemy

from sqlalchemy import and_
from sqlalchemy.engine import Connection
from sqlalchemy.schema import Column

import wedge.model.ctl.sus as sus
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

    def suscripciones(self, con:Connection, sususrid:int) -> List[Ins]:
        """
        Devuelve las suscripciones a instancias activas asociadas a un usuario. Sustituye la URL por
        una instancia de engine de la base de datos.
            :param  con:        Conexión a base de datos
            :param  sususrid:   Id. de Usuario
            :return:            Lista de instancias
        """
        log.debug("-----> Inicio")
        log.debug("\t(sususrid): %d", sususrid)


        sus_t = sus.getDAL(self._metadata).t

        stmt = self.t.select().join(sus_t).where(and_(
            sus_t.c.sususrid == sususrid,
            sus_t.c.susact == 1,
        ))
        result = self.queryEntities(con, stmt)
        for r in result:
            setattr(r, "engine", sqlalchemy.create_engine(r.insurl))
            delattr(r, "insurl")

        log.debug("<----- Fin")
        return result