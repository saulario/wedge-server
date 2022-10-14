#!/usr/bin/python3
import unittest

import sqlalchemy.engine
import sqlalchemy.schema

import fixtures
import wedge.api.gpa as api_gpa
import wedge.api.usr as api_usr


class TestGpa(unittest.TestCase):

    def test_gpa_insert(self):
        gpaAction = api_gpa.getAction(self.id_md)
        data = {}
        data, result = gpaAction.Insert(self.id_con, data, self.session)
        print("hola tonto")


    @classmethod
    def setUpClass(cls) -> None:
        
        cls.ctl_eng = sqlalchemy.engine.create_engine(fixtures.CTL_URL)
        cls.ctl_md = sqlalchemy.schema.MetaData(bind=cls.ctl_eng)
        cls.ctl_con = cls.ctl_eng.connect()

        cls.id_eng = sqlalchemy.engine.create_engine(fixtures.ID_URL)
        cls.id_md = sqlalchemy.schema.MetaData(bind=cls.id_eng)
        cls.id_con = cls.id_eng.connect()

        cls.session = api_usr.getAction(cls.ctl_md).Login(cls.ctl_con, fixtures.USERNAME, fixtures.PASSWORD)

    @classmethod
    def tearDownClass(cls) -> None:
        cls.id_con.close()
        cls.ctl_con.close()