#!/usr/bin/python3
import datetime as dt
import logging
import random
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

    def delete(self, con:Connection, sescod:str) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.sescod == sescod,
        ))
        result = con.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def insert(self, con:Connection, entity:Ses) -> Ses:
        """
        Inserción generando una PK forzada
        """
        entity.sescod = uuid.uuid4().hex + "{:08x}".format(random.randrange(0, 4294967295)) 
        result = super().insert(con, entity)
        entity.sescod = result[0]
        return entity

    def invalidarSesionesCaducadas(self, con:Connection, flimit:dt.datetime) -> int:
        """
        Invalida todas las sesiones que pudiera tener abiertas el usuario antes de asignar
        un nuevo objeto sesión.
            :param  con:   Conexión a base de datos de control
            :param  flimit: Fecha límite
            :return:        Número de sesiones cerradas
        """
        log.debug("-----> Inicio")
        log.debug("\t(flimit): %s", flimit)

        ses = {
            "sesact" : 0
        }

        t1 = time.time()
        stmt = self.t.update(None).values(ses).where(and_(
                self.t.c.sesful < flimit,
                self.t.c.sesact == 1
            ))
        result = con.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })

        log.debug("<----- Fin")
        return result.rowcount        

    def invalidarSesionesUsuario(self, con:Connection, usrid:int) -> int:
        """
        Invalida todas las sesiones que pudiera tener abiertas el usuario antes de asignar
        un nuevo objeto sesión.
            :param  con:   Conexión a base de datos de control
            :param  usrid:  Id de usuario
            :return:        Número de sesiones cerradas
        """
        log.debug("-----> Inicio")
        log.debug("\t(usrid): %d", usrid)

        ses = {
            "sesact" : 0
        }

        t1 = time.time()        
        stmt = self.t.update(None).values(ses).where(and_(
                self.t.c.sesusrid == usrid,
                self.t.c.sesact == 1
            ))
        result = con.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })        

        log.debug("<----- Fin")
        return result.rowcount

    def read(self, con:Connection, sescod:str, projection:Union[List[Column], None]=None) -> Union[Ses,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.select(projection).where(and_(
                t.c.sescod == sescod,
        ))
        retval = self._execute_read(con, stmt)
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