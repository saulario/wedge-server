#!/usr/bin/python3

import sqlalchemy

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

    def __init__(self, *args, **kwargs):
        self.context:engine.Context = None
        self.connection:sqlalchemy.engine.Connection = None