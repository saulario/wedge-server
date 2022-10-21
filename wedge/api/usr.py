#!/usr/bin/python3
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

    def CheckSession(self, conn:sqlalchemy.engine.Connection, token:str) -> Union[engine.Session, None]:
        return bl_usr.getBL(self._metadata).CheckSession(conn, token)    

    def Login(self, conn:sqlalchemy.engine.Connection, username:str, password:str) -> Union[engine.Session, None]:
        return bl_usr.getBL(self._metadata).Login(conn, username, password)

    @commons.validation
    def Insert(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:
        response = UsrResponse()
        response.data = bl_usr.getBL(self._metadata).Insert(conn, data.usr, ses)
        return response

    def _validateInsert(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:

        usr = bl_usr.getBL(self._metadata).Read(conn, data.usr.usrid, ses)
        if usr:
            return UsrResponse(None, commons.ValidationError().set(ses.usr.usri18, "G00002", "usrid"))

        return self._validateUpdate(conn, data, ses)


    @commons.validation
    def Update(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:
        response = UsrResponse()
        response.data = bl_usr.getBL(self._metadata).Update(conn, data.usr, ses)
        return response

    def _validateUpdate(self, conn:sqlalchemy.engine.Connection, data:UsrRequest, ses:engine.Session) -> UsrResponse:





        return None
    

###############################################################################
# singleton

_action = None

def getAction(metadata:sqlalchemy.schema.MetaData) -> UsrAction:
    global _action
    if _action is not None: return _action
    with threading.Lock():
        _action = UsrAction(metadata)
        return _action