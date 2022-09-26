#!/usr/bin/python3
import configparser
import logging
import os, os.path

from typing import Union

import sqlalchemy
import sqlalchemy.engine


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
    """

    def __init__(self, **kwargs):
        self.engine:sqlalchemy.engine.Engine = None
        self.metadata:sqlalchemy.MetaData = None


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
    ctx.engine = sqlalchemy.create_engine(cp.get("CTL", "url"))
    ctx.metadata = sqlalchemy.MetaData(bind=ctx.engine)

    return ctx


class Session():
    """
    Sesión activa
    """
    
    def __init__(self, **kwargs):
        self.i18n:str = kwargs.get("i18n", None)


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