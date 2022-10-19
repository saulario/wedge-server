#!/usr/bin/python3
import datetime as dt
import unittest
import uuid

import sqlalchemy.engine
import sqlalchemy.schema

import fixtures
import wedge.api.usr
import wedge.model.ctl.ses


class TestUsr(unittest.TestCase):

    def test_Login(self):
        action = wedge.api.usr.getAction(self.ctl_md)
        result = action.Login(self.ctl_con, "USUARIO", "123456")
        self.assertIsNotNone(result)
        self.assertIsNotNone(result.ses)
        self.assertIsNone(result.ses.sesinsid)
        self.assertIsNotNone(result.usr)
        self.assertEqual(len(result.insList), 2)

    def test_CheckSession(self):
        sesDAL = wedge.model.ctl.ses.getDAL(self.ctl_md)
        ses = sesDAL.getEntity()
        ses.sescod = uuid.uuid4().hex
        ses.sesusrid = 1
        ses.sesinsid = 2
        ses.sesfcr = ses.sesful = dt.datetime.min
        ses.sesact = 1
        ses = sesDAL.Insert(self.ctl_con, ses)

        action = wedge.api.usr.getAction(self.ctl_md)
        ses1 = action.CheckSession(self.ctl_con, ses.sescod)


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