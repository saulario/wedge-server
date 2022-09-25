#!/usr/bin/python3
import logging
import os, os.path


log = logging.getLogger(__name__)

###############################################################################
#
WEDGE_VERSION   = 1
WEDGE_HOME      = os.getenv("WEDGE_HOME", os.path.expanduser("~")) 




###############################################################################
#

class Context():
    """
    Contexto de ejecución de la aplicación
    """

    def __init__(self, **kwargs):
        pass


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