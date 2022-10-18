#!/usr/bin/python3
import datetime as dt
import hashlib
import logging
import threading
import time

from typing import List, Union

from sqlalchemy import and_
from sqlalchemy.engine import Connection
from sqlalchemy.schema import Column, MetaData

import wedge.model.schema


log = logging.getLogger(__name__)


class Usr(wedge.model.schema.Entity):

    def __init__(self):
        self.usrid:int          = None
        self.usrcod:str         = None
        self.usrnom:str         = None
        self.usrpwd:str         = None
        self.usrfcr:dt.datetime = None
        self.usri18:str         = None
        self.usract:int         = None


class UsrDAL(wedge.model.schema.BaseDAL):

    def __init__(self, metadata, nombre = "usr"):
        super().__init__(metadata, nombre, type=Usr)

    def Autenticar(self, conn:Connection, username:str, password:str) -> Union[Usr, None]:
        """
        Autentica un usuario.
            :param  conn:       Conexión a base de datos de control
            :param  username:   Usuario
            :param  password:   Contraseña
            :return:            Usr sin password
        """
        log.debug("-----> Inicio")
        log.debug("\t(username): %s", username)
        log.debug("\t(password): %s", "*" * len(password or ""))
        
        t1 = time.time()
        retval = None

        stmt = self.Select().where(and_(
                self.t.c.usrcod == username,
                self.t.c.usrpwd == hashlib.sha256(password.encode("utf-8")).hexdigest(),
                self.t.c.usract == 1,
            ))
        result = self.Query(conn, stmt)
        
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })

        if len(result) != 1:
            log.info("<----- Salida, no encontrado el usuario")
            return retval

        retval = wedge.model.schema.Entity.fromProxy(result[0], self._type)
        delattr(retval, "usrpwd")

        log.debug("<----- Fin")
        return retval

    def Delete(self, conn:Connection, usrid:int) -> int:
        """
        Borrado por PK
        """
        t1 = time.time()
        t = self._t
        stmt = t.delete(None).where(and_(
                t.c.usrid == usrid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount
    
    def Insert(self, conn:Connection, entity:Usr) -> Usr:
        delattr(entity, "usrid")
        result = super().Insert(conn, entity)
        entity.usrid = result[0]
        return entity

    def Read(self, conn:Connection, usrid:int, projection:Union[List[Column], None]=None) -> Union[Usr,None]:
        """
        Lectura por PK
        """
        t1 = time.time()
        t = self._t
        stmt = self.Select(projection).where(and_(
                t.c.usrid == usrid,
        ))
        retval = self._execute_read(conn, stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def Update(self, conn:Connection, entity:Usr) -> int:
        """
        Actualización por PK
        """
        t1 = time.time()
        t = self._t
        self._removeNullableCols(entity)        
        stmt = t.update(None).values(entity.__dict__).where(and_(
                t.c.usrid == entity.usrid,
        ))
        result = conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return result.rowcount


###############################################################################
# singleton

_dal = None

def getDAL(metadata:MetaData) -> UsrDAL:
    global _dal
    if _dal is not None: return _dal
    with threading.Lock():
        _dal = UsrDAL(metadata)
        return _dal        