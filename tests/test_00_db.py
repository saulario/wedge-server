#!/usr/bin/python3
import unittest

import sqlalchemy.engine

import fixtures
import wedge.core.engine as engine


class TestDB(unittest.TestCase):

    def testConnections(self):
        con = None
        try:
            con = engine.current_context.getEngineById(0).connect()
            con.close()
        except:
            self.assertIsNotNone(con)
        try:
            con = engine.current_context.getEngineById(1).connect()
            con.close()
        except:
            self.assertIsNotNone(con)

    @classmethod
    def setUpClass(cls) -> None:
        fixtures.create_databases()
        engine.create_context("tests/config_test.ini")
