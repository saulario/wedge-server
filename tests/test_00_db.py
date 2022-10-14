#!/usr/bin/python3
import unittest

import sqlalchemy.engine

import fixtures


class TestDB(unittest.TestCase):

    def test_Connections(self):
        eng = sqlalchemy.engine.create_engine(fixtures.CTL_URL)
        con = eng.connect()
        con.close()

        eng = sqlalchemy.engine.create_engine(fixtures.ID_URL)
        con = eng.connect()
        con.close()

    @classmethod
    def setUpClass(cls) -> None:
        fixtures.create_databases()


