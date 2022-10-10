#!/usr/bin/python3


import flask

import wedge.core.engine



app = flask.Flask(__name__)


@app.before_first_request
def setup():
    """
    Inicialización de contexto y conexiones a bases de datos
    """
    flask.current_app.wc_context = wedge.core.engine.create_context()






@app.route("/")
def root():
    return ""





if __name__ == "__main__":
    app.run(debug=True)