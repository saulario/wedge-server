#!/usr/bin/python3
import logging
import threading

from typing import Union

import sqlalchemy.engine
import sqlalchemy.schema

import wedge.api.commons as commons
import wedge.core.engine as engine
import wedge.bl.ctl.usr as bl_usr


log = logging.getLogger(__name__)


class UsrAction(commons.BaseAction):

    def Login(self, conn:sqlalchemy.engine.Connection, username:str, password:str) -> Union[engine.Session, None]:
        return bl_usr.getBL(self._metadata).Login(conn, username, password)

    def CheckSession(self, conn:sqlalchemy.engine.Connection, token:str) -> Union[engine.Session, None]:
        return bl_usr.getBL(self._metadata).CheckSession(conn, token)


###############################################################################
# singleton

_action = None

def getAction(metadata:sqlalchemy.schema.MetaData) -> UsrAction:
    global _action
    if _action is not None: return _action
    with threading.Lock():
        _action = UsrAction(metadata)
        return _action