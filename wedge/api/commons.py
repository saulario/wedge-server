#!/usr/bin/python3

import sqlalchemy.schema

import wedge.core.engine as engine


def transaction(func):
    def wrapper(self, *args, **kwargs):
        self.context = engine.create_context()
        self.connection = self.context.engine.connect()
        with self.connection.begin():
            retval = func(self, *args, **kwargs)
        self.connection.close()
        return retval
    return wrapper    


class BaseAction():
    """
    Implementación común para todos los actions del API
    """
    
    def __init__(self, metadata:sqlalchemy.schema.MetaData):
        self._metadata = metadata