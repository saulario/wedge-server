#!/Gpa/bin/python3
import datetime as dt
import logging
import threading

from typing import Union

import sqlalchemy.engine
import sqlalchemy.schema

import wedge.bl.commons
import wedge.core.engine as engine
import wedge.model.id.gpa as model_gpa


log = logging.getLogger(__name__)


class GpaBL(wedge.bl.commons.BaseBL):

    def Delete(self, con:sqlalchemy.engine.Connection, gpacod:str, session:engine.Session) -> int:
        return model_gpa.getDAL(self._metadata).delete(con, gpacod)

    def Insert(self, con:sqlalchemy.engine.Connection, gpa:model_gpa.Gpa, session:engine.Session) -> model_gpa.Gpa:
        return model_gpa.getDAL(self._metadata).insert(con, gpa)

    def Read(self, con:sqlalchemy.engine.Connection, gpacod:str, session:engine.Session) -> Union[model_gpa.Gpa, None]:
        gpaDAL = model_gpa.getDAL(self._metadata)
        return gpaDAL.read(con, gpacod, list(gpaDAL.t.c))

    def Update(self, con:sqlalchemy.engine.Connection, gpa:model_gpa.Gpa, session:engine.Session) -> int:
        return model_gpa.getDAL(self._metadata).update(con, gpa)


###############################################################################
# singleton
#

_bl = None

def getBL(metadata:sqlalchemy.schema.MetaData) -> GpaBL:
    global _bl
    if _bl is not None: return _bl
    with threading.Lock():
        _bl = GpaBL(metadata)
        return _bl