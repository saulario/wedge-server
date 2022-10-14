#!/usr/bin/python3
import json
import logging
import threading

from typing import Union

import sqlalchemy.engine
import sqlalchemy.schema

import wedge.api.commons as commons
import wedge.bl.id.gpa as bl_gpa
import wedge.core.engine as engine
import wedge.model.id


log = logging.getLogger(__name__)


class GpaAction(commons.BaseAction):

    def Read(self, conn:sqlalchemy.engine.Connection, gpacod:str, session:engine.Session) -> Union[wedge.model.id.Gpa, None]:
        retval = bl_gpa.getBL(self._metadata).Read(conn, gpacod, session)
        return json.dumps(retval, default=lambda d: d.__dict__ if hasattr(d, "__dict__") else d, ensure_ascii=False)

    def _InsertValidator(self, conn:sqlalchemy.engine.Connection, data, session:engine.Session):
        print("Estoy dentro del validator")
        return None, None

    @commons.validation
    def Insert(self, conn:sqlalchemy.engine.Connection, data, session:engine.Session):
        return None, None

    def _UpdateValidator(self, conn:sqlalchemy.engine.Connection, data, session:engine.Session):
        print("Estoy dentro del validator")
        return None, None

    @commons.validation
    def Update(self, conn:sqlalchemy.engine.Connection, data, session:engine.Session):
        pass


###############################################################################
# singleton

_action = None

def getAction(metadata:sqlalchemy.schema.MetaData) -> GpaAction:
    global _action
    if _action is not None: return _action
    with threading.Lock():
        _action = GpaAction(metadata)
        return _action