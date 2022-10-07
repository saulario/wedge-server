#!/usr/bin/python3

import sqlalchemy.engine

import wedge.bl.ctl.usr as bl
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

    def __init__(self):
        self.context:engine.Context = None
        self.connection:sqlalchemy.engine.Connection = None

class UsrAction(BaseAction):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    @transaction
    def Login(self, username:str, password:str):
        return bl.getBL().Login(self.context.engine.connect(), username, password, self.context)