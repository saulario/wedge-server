#!/usr/bin/python3

import wedge.api.commons as commons
import wedge.bl.ctl.usr as bl



class UsrAction(commons.BaseAction):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    @commons.transaction
    def Login(self, username:str, password:str):
        return bl.getBL().Login(self.context.engine.connect(), username, password, self.context)