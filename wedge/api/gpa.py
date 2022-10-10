#!/usr/bin/python3

import wedge.api.commons as commons
import wedge.model.id as id

class GpaAction(commons.BaseAction):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def Read(gpacod:str) -> id.Gpa:
