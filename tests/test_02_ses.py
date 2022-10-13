#!/usr/bin/python3
import unittest

import sqlalchemy.engine
import sqlalchemy.schema

import fixtures

class TestUsr(unittest.TestCase):

    def test_01(self):
        pass

    def test_02(self):
        pass

    @classmethod
    def setUpClass(cls) -> None:

        cls.ctl_eng = sqlalchemy.engine.create_engine(fixtures.CTL_URL)
        cls.ctl_md = sqlalchemy.schema.MetaData(bind=cls.ctl_eng)
        cls.ctl_con = cls.ctl_eng.connect()

        cls.id_eng = sqlalchemy.engine.create_engine(fixtures.ID_URL)
        cls.id_md = sqlalchemy.schema.MetaData(bind=cls.id_eng)
        cls.id_con = cls.id_eng.connect()

    @classmethod
    def tearDownClass(cls) -> None:
        cls.id_con.close()
        cls.ctl_con.close()