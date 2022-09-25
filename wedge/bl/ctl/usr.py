#!/usr/bin/python3
import logging
import threading



import wedge.core.engine as engine


log = logging.getLogger(__name__)


# singleton
_bl = None


def getBL():
    global _bl
    if _bl is not None: return _bl
    with threading.Lock():
        _bl = UsrBL()
        return _bl


class UsrBL():

    def __init__(self):
        pass

    def login(self, username:str, password:str, context:engine.Context) -> engine.Session:
        """
        """
        print("hola")
        return engine.Session()


if __name__ == "__main__":
    bl = getBL()
    ctx = engine.Context()


    
    s = bl.login("perico", "palotes", ctx)
    print(s)
