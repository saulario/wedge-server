#!/usr/bin/python3
import importlib
from typing import Dict, Union

import wedge.core.engine

def get_message(session:wedge.core.engine.Session, id:str) -> Union[Dict, None]:
    """
    Obtiene un mensaje internacionalizado
        session:    Sesión activa
        :return:    Mensaje o None
    """
    m = importlib.import_module(f"wedge.core.i18n.{session.i18n}")
    return getattr(m, id, None)