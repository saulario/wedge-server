#!/usr/bin/python3
import datetime as dt
import logging
from pyexpat import model
import threading
from tkinter import E

from typing import Union

import sqlalchemy.engine
import sqlalchemy.schema

from sqlalchemy import and_

import wedge.bl.commons
import wedge.core.engine as engine
import wedge.model.ctl.ins as model_ins
import wedge.model.ctl.ses as model_ses
import wedge.model.ctl.usr as model_usr


log = logging.getLogger(__name__)


SESSION_LIFETIME = 3600         # Tiempo de vida de una sesión antes de expirar


class UsrBL(wedge.bl.commons.BaseBL):

    def ComprobarUsuarioDisponible(self, con:sqlalchemy.engine.Connection, usr:model_usr.Usr) -> bool:
        """
        Comprueba si un usuario está disponible. El código no puede estar utilizado en ningún otro id
        de usuario sin importar si está activo o no.
            :param  con:    Conexión a base de datos
            :param  usr:    Entidad usr
        """
        log.debug("-----> Inicio")
        log.debug(f"\t(usrcod): %s", usr.usrcod)
        log.debug(f"\t(usrid) : %s", usr.usrid)

        if not usr.usrcod:
            return False
        
        usrDAL = model_usr.getDAL(self._metadata)
        stmt = usrDAL.Select([ usrDAL.t.c.usrid ]).where(and_(
            usrDAL.t.c.usrid != usr.usrid,
            usrDAL.t.c.usrcod == usr.usrcod
        ))
        result = usrDAL.Query(con, stmt)

        retval = False if result else True

        log.debug("<----- Fin")
        return retval

    def ComprobarSesion(self, con:sqlalchemy.engine.Connection, token:str) -> Union[engine.Session, None]:
        """
        Recupera una sesión si el token es válido. Si algo falla devuelve la sesión a nulo
        sin dar mayor explicación. Se realizan las siguientes tareas.
                1.  Invalida cualquier sesión anterior al LIFETIME
                2.  Recupera la sesión si corresponde
                3.  Actualiza la fecha de última utilización
            :param  con:        Conexión a base de datos
            :param  token:      Identificador de sesión
            :param  context:    Contexto de ejecución
        """
        log.debug("-----> Inicio")
        log.debug("\t(token): %s", token)

        if not token:
            log.debug("<----- Salida, no hay datos")
            return None

        sesDAL = model_ses.getDAL(self._metadata)

        flimit = dt.datetime.utcnow() - dt.timedelta(seconds=SESSION_LIFETIME)
        sesDAL.InvalidarSesionesCaducadas(con, flimit)
        ses = sesDAL.Read(con, token, list(sesDAL.t.c))

        if not ses or not ses.sesact:
            log.debug("<----- Salida, no hay sesión válida")
            return None

        ses.sesful = dt.datetime.utcnow()
        sesDAL.Update(con, ses)

        usr = model_usr.getDAL(self._metadata).Read(con, ses.sesusrid)
        insList = model_ins.getDAL(self._metadata).Suscripciones(con, usr.usrid)
        retval = engine.Session(usr=usr, ses=ses, insList=insList)

        log.debug("<----- Fin")
        return retval

    def Login(self, con:sqlalchemy.engine.Connection, username:str, password:str) -> Union[engine.Session, None]:
        """
        Abre una sesión si autentica el usuario. Si algo falla devuelve la sesión a nulo
        sin dar mayor explicación. Se realizan las siguientes tareas
                1. Invalida las sesiones que pudieran estar activas para este usuario
                2. Recupera todas las instancias a las que está suscrito y le instancia el engine
                3. Genera una nueva sesión. Si sólo tiene una instancia la asigna automáticamente

            :param  con:        Conexión a base de datos
            :param  username:   Usuario
            :param  password:   Contraseña
            :param  context:    Contexto de ejecución
            :return:            Sesión iniciada
        """
        log.debug("-----> Inicio")
        log.debug("\t(username): %s", username)
        log.debug("\t(password): %s", "*" * len(password or ""))

        retval = None
        if not username or not password:
            log.debug("<----- Salida, no hay datos")
            return None

        usr = model_usr.getDAL(self._metadata).Autenticar(con, username, password)
        if not usr:
            log.debug("<----- Salida, no encontrado el usuario")
            return None

        sesDAL = model_ses.getDAL(self._metadata)
        sesDAL.InvalidarSesionesUsuario(con, usr.usrid)

        insDAL = model_ins.getDAL(self._metadata)
        insList = insDAL.Suscripciones(con, usr.usrid)

        ses = sesDAL.getEntity()
        ses.sesusrid = usr.usrid
        ses.sesinsid = insList[0].insid if len(insList) == 1 else None
        ses.sesfcr = ses.sesful = dt.datetime.utcnow()
        ses.sesact = 1
        ses = sesDAL.Insert(con, ses)

        retval = engine.Session(usr=usr, ses=ses, insList=insList)

        log.debug("<----- Fin")
        return retval

    def Delete(self, con:sqlalchemy.engine.Connection, usrid:int, session:engine.Session) -> int:
        return model_usr.getDAL(self._metadata).Delete(con, usrid)

    def Insert(self, con:sqlalchemy.engine.Connection, usr:model_usr.Usr, session:engine.Session) -> model_usr.Usr:
        return model_usr.getDAL(self._metadata).Insert(con, usr)

    def Read(self, con:sqlalchemy.engine.Connection, usrid:int, session:engine.Session) -> Union[model_usr.Usr, None]:
        usrDAL = model_usr.getDAL(self._metadata)
        return usrDAL.Read(con, usrid, list(usrDAL.t.c))

    def Update(self, con:sqlalchemy.engine.Connection, usr:model_usr.Usr, session:engine.Session) -> int:
        return model_usr.getDAL(self._metadata).Update(con, usr)


###############################################################################
# singleton

_bl = None

def getBL(metadata:sqlalchemy.schema.MetaData) -> UsrBL:
    global _bl
    if _bl is not None: return _bl
    with threading.Lock():
        _bl = UsrBL(metadata)
        return _bl