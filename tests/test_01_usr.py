#!/usr/bin/python3
import datetime as dt
import unittest
import uuid


import wedge.api.usr as api_usr
import wedge.core.engine as engine
import wedge.model.ctl
import wedge.model.ctl.ses as model_ses


class TestUsr(unittest.TestCase):

    def test_Insert(self):
        req = api_usr.UsrRequest()
        req.usr = wedge.model.ctl.Usr()
        result = api_usr.getAction().Insert(self.ctl_con, req, self.session)

    def test_Update(self):
        req = api_usr.UsrRequest()
        req.data.usr = wedge.model.ctl.Usr()
        result = api_usr.getAction().Insert(self.ctl_con, req, self.session)

    def test_Login(self):
        action = api_usr.getAction()
        result = action.Login(self.ctl_con, "USUARIO", "123457")
        self.assertIsNone(result)

    def test_CheckSession(self):
        sesDAL = model_ses.SesDAL(engine.current_context.getCtlMetaData())
        ses = sesDAL.getEntity()
        ses.sescod = uuid.uuid4().hex
        ses.sesusrid = 1
        ses.sesinsid = 2
        ses.sesfcr = ses.sesful = dt.datetime.min
        ses.sesact = 1
        ses = sesDAL.Insert(self.ctl_con, ses)

        ses1 = api_usr.getAction().CheckSession(self.ctl_con, ses.sescod)


    @classmethod
    def setUpClass(cls) -> None:

        engine.create_context("tests/config_test.ini")

        # conexión a control
        cls.ctl_con = engine.current_context.getCtlEngine().connect()

        # Genera la sesión para poder hacer todos los tests
        cls.session = api_usr.getAction().Login(cls.ctl_con, "USUARIO", "123456")
        cls.session.ses.sesinsid = 1

        cls.id_con = engine.current_context.getEngine(cls.session).connect()


    @classmethod
    def tearDownClass(cls) -> None:
        cls.id_con.close()
        cls.ctl_con.close()