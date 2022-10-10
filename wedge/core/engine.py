#!/usr/bin/python3
import configparser
import logging
import os, os.path

from typing import Dict, List, Tuple, Union

import sqlalchemy
import sqlalchemy.engine

import wedge.model.ctl
import wedge.model.ctl.ins

log = logging.getLogger(__name__)


###############################################################################
#
WEDGE_VERSION   = 1
WEDGE_HOME      = f"{os.getenv('WEDGE_HOME', os.path.expanduser('~'))}/wedge/{WEDGE_VERSION}"


###############################################################################
#

class Context():
    """
    Contexto de ejecución de la aplicación.
        * dbpool,   pool de conexiones a base e datos. El id=0 se corresponde
                    con la base de datos de control. El resto de ids se
                    corresponden con las instancias
    """
    def __init__(self, **kwargs):
        self.dbpool:Dict[int, Tuple[sqlalchemy.engine.Engine, sqlalchemy.schema.MetaData]] = {}

def create_context(file:str = None) -> Union[Context, None]:
    """
    Crea un contexto a partir del fichero pasado como parámetro o del archivo por defecto
        :param file:    Nombre del fichero de configuración
        :return:        Context o None si no existe el fichero
    """
    ctx = None
    f = file or f"{WEDGE_HOME}/etc/config.ini"
    cp = configparser.ConfigParser()
    if not cp.read(f):
        return ctx

    ctx = Context()

    engine = sqlalchemy.create_engine(cp.get("CTL", "url"))
    metadata = sqlalchemy.MetaData(bind=ctx.engine)
    ctx.dbpool[0] = (engine, metadata)

    insDAL = wedge.model.ctl.ins.getDAL(metadata)
    stmt = insDAL.select(list(insDAL.t.c))
    
    with engine.connect() as con:
        result = insDAL.query(con, stmt)
        for r in result:
            e = sqlalchemy.engine.create_engine(r.insurl)
            m = sqlalchemy.schema.MetaData(bind=engine)
            ctx.dbpool[r.insid] = (e, m)

    return ctx

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

def Transaction(f):
    """
    Anotación para controlar transacciones
    """
    def wrapper(*args, **kwargs):
        return f(*args, **kwargs)
    return wrapper


class UserProfile():
    """
    Información del perfil del usuario
    """

    def __init__(self, **kwargs):
        pass