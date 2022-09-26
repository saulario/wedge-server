#!/usr/bin/python3
import datetime as dt

import wedge.bl.ctl.usr
import wedge.core.engine


if __name__ == "__main__":



    ctx = wedge.core.engine.create_context()
    conn = ctx.engine.connect()

    wedge.bl.ctl.usr.getBL().login(conn, "saulario", "1234567", ctx)




    conn.close()
