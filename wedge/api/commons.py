#!/usr/bin/python3
import importlib

from typing import Any

import wedge.core.engine as engine
import wedge.core.i18n


class ValidationError():
    """
    Mensaje de error en caso de que no pase la validación de datos para
    ejecutar una operación del API
    """

    def __init__(self):
        self.source = ""
        self.msgid = ""
        self.msg = ""
        self.exp = ""

    def set(self, i18n:str, msgid:str, source:str = ""):
        """
        Recibe el idioma, el id del mensaje y, eventualmente, el origen del error como -por ejemplo-
        el nombre del campo que se valida para facilitar la ubicación del cursor al devolver el 
        control al usuario.
        """
        module = f"wedge.core.i18n.{i18n}"
        lib = importlib.import_module(module) 

        self.source = source
        self.msgid = msgid
        m = getattr(lib, msgid)
        if m:
            self.msg = m.get("msg")
            self.exp = m.get("exp")
        return self
   

def validation(func):
    """
    Fuerza la validación para este método. Si no encuentra el método validador
    devuelve un validationError específico.
    """
    def wrapper(self, *args, **kwargs):

        session = [ x for x in args if isinstance(x, engine.Session) ][0]

        validator = getattr(self, f"_validate{func.__name__}", None)
        if not validator:
            return BaseResponse(None, ValidationError().set(session.usr.usri18, "G00001"))
        result = validator(*args, **kwargs)
        if result:
            return BaseResponse(None, result)

        return func(*args, **kwargs)

    return wrapper


class BaseAction():
    """
    Implementación común para todos los actions del API
    """
    def _defaultValidator(self, *args, **kwargs):
        """
        Por si no se ha encontrado el validador, aunque el buscador de validadores ya lo 
        tiene controlado. Para evitar un runtime exception.
        """
        return BaseResponse(None, ValidationError().set(wedge.core.i18n.DEFAULT_I18N, "G00001"))


class BaseRequest():
    """
    Tipo base para los datos de las peticiones
    """
    pass


class BaseResponse():
    """
    Tipo base para las respuestas de las peticiones
    """
    def __init__(self, data:Any, verr:ValidationError):
        self.data:Any = data
        self.verr:ValidationError = verr
