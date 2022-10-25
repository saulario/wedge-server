#!/usr/bin/python3
import configparser
import logging
import os, os.path

from typing import Dict, List, Tuple, Union

import sqlalchemy
import sqlalchemy.engine
import sqlalchemy.schema

import wedge.model.ctl
import wedge.model.ctl.ins as model_ins

log = logging.getLogger(__name__)


###############################################################################
#
WEDGE_VERSION   = 1
WEDGE_HOME      = f"{os.getenv('WEDGE_HOME', os.path.expanduser('~'))}/wedge/{WEDGE_VERSION}"


###############################################################################
# El objeto session contiene la información relativa al login del usuario y
# a la instancia en curso

class Session():
    """
    Sesión activa contiene la siguiente información
        1. Usuario
        2. Lista de instancias a las que está suscrito
        3. Instancia activa

    """    
    def __init__(self, **kwargs):
        """
        """
        self.usr:wedge.model.ctl.Usr = kwargs.get("usr", None)
        self.ses:wedge.model.ctl.Ses = kwargs.get("ses", None)
        self.insList:List[wedge.model.ctl.Ins] = kwargs.get("insList", [])
    
    def getInstanciaActiva(self) -> Union[int, None]:
        """
        Devuelve la instancia activa en la sesión. Solo debería ser None cuando se
        está creando un usuario inicialmente y aún no tiene suscripciones
            :return:    id de instancia
        """
        if self.ses is None or self.ses.sesinsid is None:
            return None
        return self.ses.sesinsid

###############################################################################
# El contexto se guarda como variable de módulo para ofrecer un pool de
# conexiones. Esto permite también evitar el pasar el contexto en todas las 
# llamadas a todas las funciones puesto que la información es accesible en
# todo momento

current_context = None

class Context():
    """
    Contexto de ejecución de la aplicación.
        * dbpool,   pool de conexiones a base e datos. El id=0 se corresponde
                    con la base de datos de control. El resto de ids se
                    corresponden con las instancias
    """
    def __init__(self, **kwargs):
        self.dbpool:Dict[int, Tuple[sqlalchemy.engine.Engine, sqlalchemy.schema.MetaData]] = {}

    def getCtlEngine(self) -> Union[sqlalchemy.engine.Engine, None ]:
        """
        Retorna el Engine correspondiente al id de instancia de la base de datos de control
            :return:        Engine o None
        """
        id = 0
        if not id in self.dbpool: return None
        return self.dbpool.get(id)[0]

    def getCtlMetaData(self) -> Union[sqlalchemy.schema.MetaData, None ]:
        """
        Retorna el MetaData correspondiente al id de instancia asociada a la sesión en curso.
            :return:        Engine o None
        """
        id = 0
        if not id in self.dbpool: return None
        return self.dbpool.get(id)[1]

    def getEngine(self, ses:Session) -> Union[sqlalchemy.engine.Engine, None ]:
        """
        Retorna el Engine correspondiente al id de instancia asociada a la sesión en curso.
            :param  ses:    Sesión en curso
            :return:        Engine o None
        """
        return self.getEngineById(ses.getInstanciaActiva())

    def getEngineById(self, id:int) -> Union[sqlalchemy.engine.Engine, None ]:
        """
        Retorna el Engine correspondiente al id de instancia asociada a la sesión en curso.
            :param  id:     Id de instancia
            :return:        Engine o None
        """
        if not id in self.dbpool: return None
        return self.dbpool.get(id)[0]

    def getMetaData(self, ses:Session) -> Union[sqlalchemy.schema.MetaData, None ]:
        """
        Retorna el MetaData correspondiente al id de instancia asociada a la sesión en curso.
            :param  ses:    Sesión en curso
            :return:        Engine o None
        """
        return self.getMetaDataById(ses.getInstanciaActiva())

    def getMetaDataById(self, id:int) -> Union[sqlalchemy.schema.MetaData, None ]:
        """
        Retorna el MetaData correspondiente al id de instancia asociada a la sesión en curso.
            :param  d:    Sesión en curso
            :return:        Engine o None
        """
        if not id in self.dbpool: return None
        return self.dbpool.get(id)[1]


def create_context(file:str = None) -> Union[Context, None]:
    """
    Crea un contexto a partir del fichero pasado como parámetro o del archivo por defecto
    y lo deja instanciado en current_context.
        :param file:    Nombre del fichero de configuración
        :return:        Context o None si no existe el fichero
    """
    global current_context

    ctx = None
    f = file or f"{WEDGE_HOME}/etc/config.ini"
    cp = configparser.ConfigParser()
    if not cp.read(f):
        return ctx

    ctx = Context()

    engine = sqlalchemy.create_engine(cp.get("CTL", "url"), isolation_level = "READ COMMITTED")
    metadata = sqlalchemy.MetaData(bind=engine)
    ctx.dbpool[0] = (engine, metadata)

    insDAL = model_ins.InsDAL(metadata)
    stmt = insDAL.Select(list(insDAL.t.c))
    
    with engine.connect() as con:
        result = insDAL.Query(con, stmt)
        for r in result:
            e = sqlalchemy.engine.create_engine(r.insurl, isolation_level = "READ COMMITTED")
            m = sqlalchemy.schema.MetaData(bind=e)
            ctx.dbpool[r.insid] = (e, m)

    current_context = ctx
    return ctx
