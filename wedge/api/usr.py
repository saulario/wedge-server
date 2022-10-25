#!/usr/bin/python3
import datetime as dt
import logging
import threading

from typing import Union

import sqlalchemy.engine
import sqlalchemy.schema

import wedge.api.commons as commons
import wedge.core.engine as engine
import wedge.bl.ctl.usr as bl_usr
import wedge.model.ctl as model_ctl


log = logging.getLogger(__name__)


class UsrRequest(commons.BaseRequest):

    def __init__(self):
        super().__init__()
        self.usr:model_ctl.Usr = None


class UsrResponse(commons.BaseResponse):
    pass


class UsrAction(commons.BaseAction):

    def ComprobarSesion(self, conn:sqlalchemy.engine.Connection, token:str) -> Union[engine.Session, None]:
        return bl_usr.getBL().ComprobarSesion(conn, token)    

    def Login(self, conn:sqlalchemy.engine.Connection, username:str, password:str) -> Union[engine.Session, None]:
        return bl_usr.getBL().Login(conn, username, password)

    @commons.validation
    def Insert(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:
        response = UsrResponse()
        response.data = bl_usr.getBL().Insert(conn, data.usr, ses)
        return response

    def _validateInsert(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:

        if not hasattr(data, "usr") or data.usr is None:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00000", "usr"))

        usr = bl_usr.getBL().Read(conn, data.usr.usrid, ses)
        if usr:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00002", "usrid"))

        return self._validateUpdate(conn, data, ses)

    @commons.validation
    def Update(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:
        response = UsrResponse()
        response.data = bl_usr.getBL().Update(conn, data.usr, ses)
        return response

    def _validateUpdate(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:

        #TODO generalizar validadores

        data.usr.usrcod = data.usr.usrcod.strip().upper() if data.usr.usrcod is not None else ""
        if not data.usr.usrcod:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00003", "usrcod"))

        if not bl_usr.getBL().UsuarioDisponible(conn, data.usr):
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G10001", "usrcod"))

        data.usr.usrnom = data.usr.usrnom.strip() if data.usr.usrnom is not None else ""
        if not data.usr.usrnom:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00003", "usrnom"))

        data.usr.usrpwd = data.usr.usrpwd.strip() if data.usr.usrpwd is not None else ""
        if not data.usr.usrpwd:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00003", "usrpwd"))

        try:
            data.usr.usrfcr = dt.datetime.fromisoformat(data.usr.usrfcr)
        except (TypeError, ValueError):
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00005", "usrfcr"))

        data.usr.usri18 = data.usr.usri18.strip() if data.usr.usri18 is not None else ""
        if not data.usr.usri18:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00003", "usri18"))

        try:
            data.usr.usract = int(data.usr.usract)
        except ValueError:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usract, "G00003", "usract"))

        return None
    

###############################################################################
# singleton

_action = None

def getAction() -> UsrAction:
    global _action
    if _action is not None: return _action
    with threading.Lock():
        _action = UsrAction()
        return _action