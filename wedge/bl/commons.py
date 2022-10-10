#!/usr/bin/python3

import sqlalchemy.schema

class BaseBL():

    def __init__(self, metadata:sqlalchemy.schema.MetaData):
        self._metadata = metadata