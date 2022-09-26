#!/usr/bin/python3
import hashlib
import logging
import threading

import sqlalchemy.engine

from sqlalchemy import and_

import wedge.core.engine as engine
import wedge.model.ctl.ses
import wedge.model.ctl.usr


log = logging.getLogger(__name__)


# singleton
_bl = None

def getBL():
    global _bl
    if _bl is not None: return _bl
    with threading.Lock():
        _bl = UsrBL()
        return _bl


class UsrBL():

    def login(self, ctlConn:sqlalchemy.engine.Connection, username:str, password:str, 
            context:engine.Context) -> engine.Session:
        """
        Abre una sesión si autentica el usuario. Si algo falla devuelve la sesión a nulo
        sin dar mayor explicación
            :param  ctlConn:    Conexión a base de datos de control
            :param  username:   Usuario
            :param  password:   Contraseña
            :param  context:    Contexto de ejecución
            :return:            Sesión iniciada
        """
        log.info("-----> Inicio")
        log.info("\t((username): %s", username)
        log.info("\t((password): %s", "*" * len(password or ""))

        retval = None
        if not username or not password:
            log.info("<----- Salida, no hay datos")
            return None

        usr = wedge.model.ctl.usr.getDAL(context.metadata).autenticar(ctlConn, username, password)
        if not usr:
            log.info("<----- Salida, no encontrado el usuario")
            return None

        sesDAL = wedge.model.ctl.ses.getDAL(context.metadata)
        sesDAL.invalidarSesiones(ctlConn, usr.usrid)


        log.info("<----- Fin")
        return retval