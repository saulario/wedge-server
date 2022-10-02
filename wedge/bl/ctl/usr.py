#!/usr/bin/python3
import datetime as dt
import logging
import threading

from typing import Union

import sqlalchemy.engine

from sqlalchemy import and_

import wedge.core.engine as engine
import wedge.model.ctl.ins as ctl_ins
import wedge.model.ctl.ses as ctl_ses
import wedge.model.ctl.usr as ctl_usr


log = logging.getLogger(__name__)


SESSION_LIFETIME = 3600         # Tiempo de vida de una sesión antes de expirar


# singleton
_bl = None

def getBL():
    global _bl
    if _bl is not None: return _bl
    with threading.Lock():
        _bl = UsrBL()
        return _bl


class UsrBL():

    def CheckSession(self, con:sqlalchemy.engine.Connection, token:str,
            context:engine.Context) -> Union[engine.Session, None]:
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
        log.info("-----> Inicio")
        log.info("\t(token): %s", token)

        if not token:
            log.info("<----- Salida, no hay datos")
            return None

        sesDAL = ctl_ses.getDAL(context.metadata)

        flimit = dt.datetime.utcnow() - dt.timedelta(seconds=SESSION_LIFETIME)
        sesDAL.invalidarSesionesCaducadas(con, flimit)
        ses = sesDAL.read(con, token, list(sesDAL.t.c))

        if not ses or not ses.sesact:
            log.info("<----- Salida, no hay sesión válida")
            return None

        ses.sesful = dt.datetime.utcnow()
        sesDAL.update(con, ses)

        usr = ctl_usr.getDAL(context.metadata).read(con, ses.sesusrid)
        insList = ctl_ins.getDAL(context.metadata).suscripciones(con, usr.usrid)
        retval = engine.Session(usr=usr, ses=ses, insList=insList)

        log.info("<----- Fin")
        return retval

    def Login(self, con:sqlalchemy.engine.Connection, username:str, password:str, 
            context:engine.Context) -> Union[engine.Session, None]:
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
        log.info("-----> Inicio")
        log.info("\t(username): %s", username)
        log.info("\t(password): %s", "*" * len(password or ""))

        retval = None
        if not username or not password:
            log.info("<----- Salida, no hay datos")
            return None

        usr = ctl_usr.getDAL(context.metadata).autenticar(con, username, password)
        if not usr:
            log.info("<----- Salida, no encontrado el usuario")
            return None

        sesDAL = ctl_ses.getDAL(context.metadata)
        sesDAL.invalidarSesionesUsuario(con, usr.usrid)

        insDAL = ctl_ins.getDAL(context.metadata)
        insList = insDAL.suscripciones(con, usr.usrid)

        ses = sesDAL.getEntity()
        ses.sesusrid = usr.usrid
        ses.sesinsid = insList[0].insid if len(insList) == 1 else None
        ses.sesfcr = ses.sesful = dt.datetime.utcnow()
        ses.sesact = 1
        ses = sesDAL.insert(con, ses)

        retval = engine.Session(usr=usr, ses=ses, insList=insList)

        log.info("<----- Fin")
        return retval