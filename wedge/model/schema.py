#!/usr/bin/python3
import logging
import time

from sqlalchemy import Table
from sqlalchemy.engine import Connection
from sqlalchemy.sql import expression


log = logging.getLogger(__name__)


SLOW_QUERY_LIMIT = 15


class Entity():
    """
    Una entidad representa un estado persistente de base de datos. Se genera
    dinácamente desde los metadatos de una tabla o bien desde el resultado
    de una consulta
    """

    @staticmethod
    def fromProxy(proxy, type):
        """
        Construye una entidad a partir de un proxy
        param:      proxy: ResultProxy
        returns:    entity: obtenido el resultproxy
        """
        if proxy is None:
            return
        e = type()
        for key in proxy.iterkeys():
            setattr(e, key, proxy[key])
        return e


    @staticmethod
    def fromTable(table):
        """
        Construye una entidad a partir de los metadatos de una tabla
        param:      table: Tabla
        returns:    entity: obtenida a partir de los metadatos
        """
        if table is None:
            return
        e = Entity()
        for c in table.c:
            setattr(e, c.key, None)
        return e


class BaseDAL():
    """
    Clase base para los artefactos de acceso a base de datos
    """

    def __init__(self, metadata, nombre:str, type=Entity):
        """
        Reconstruye un objeto tabla por instrospección a partir de los
        metadatos del engine de base de datos
            :param: metadata:   metadatos
            :param: nombre:     nombre de la tabla que se reconstruye
            :param: type:       Tipo que retorna, por defecto Entity
        """
        self._metadata = metadata
        self._t = Table(nombre, metadata, autoload = True)
        self._type = type

        #marcamos como solo lectura los campos de autoincremento
        for colum in self._t.c:
            if colum.autoincrement != False:
                self._t._columns[colum.name].server_default="fnord"

    def comprobarValores(self, entity:Entity):
        """
        Para poder implementar en subclases el método de comprobación de valores sin
        tener que rehacer el insert
        """
        return entity

    def insert(self, conn:Connection, entity:Entity):
        """
        Inserta una fila en base de datos. No recupera las claves generadas, en caso
        necesario hay que especializar el método. En este caso devuelve la entidad
        persistida por coherencia con los métodos especializados.
            :param  conn:   conexión a base de datos (`:class:sqlalchemy.core.Connection`)
            :param  entity: entidad a persistir (`:class:bl.schema.Entity`)
            :return:        entidad persistida (`:class:bl.schema.Entity`)
        """
        t1 = time.time()
        stmt = self._t.insert(None).values(entity.__dict__)
        conn.execute(stmt)
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return entity

    def queryEntities(self, conn:Connection, stmt):
        """
        Devuelve un array de entidades recuperadas en una consulta
            :param  conn:       conexión a base de datos
            :param  stmt:       consulta a ejecutar
            :param  projection: proyección para la consutla
        """
        t1 = time.time()
        retval = []
        results = conn.execute(stmt).fetchall()
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        for result in results:
            retval.append(Entity.fromProxy(result, self._type))
        tt = time.time() - t1
        if tt >= SLOW_QUERY_LIMIT:
            log.warning(f"\t(SLOWQUERY)\t(tt): {round(tt,3)}\t(rows): {len(retval)}\t(stmt): {stmt}")
        return retval

    def query(self, conn:Connection, stmt):
        """
        Devuelve una consulta como un resultProxy
            :param  conn:   conexi├│n a base de datos (`:class:sqlalchemy.engine.Connection`)
            :param  stmt:   consulta para ser ejecutada (`:class:sqlalchemy.sql.expression.select`)
            :return:        `list(:class:sqlalchemy.engine.result.RowProxy)`
        """
        t1 = time.time()
        retval =  conn.execute(stmt).fetchall()
        log.debug("\t(DBACCESS)\t(tt): %(t).2f\t\t(stmt): %(stmt)s", { "t" : (time.time() - t1), "stmt" : stmt })
        return retval

    def _execute_read(self, conn:Connection, stmt:expression.select):
        """
        Devuelve una fila leída con una sentencia preparada. Se asume que
        se lee por PK y devuelve un valor único
        """
        return Entity.fromProxy(conn.execute(stmt).fetchone(), self.type)

    def select(self, projection=None):
        """
        Devuelve una instrucción select para la tabla. Se puede especificar la proyección.
        Si no se especifica da un aviso en el log
        """
        stmt = self._t.select()
        if projection is not None:
            stmt = stmt.with_only_columns(projection)
        else:
            log.info(f"\t(FULLTABLE)\t\t\t(stmt): {stmt}")
        return stmt

    @property
    def t(self):
        """
        Devuelve una referencia a la tabla
        """
        return self._t

    def getTable(self):
        """
        Devuelve una referencia a la tabla
        """
        return self._t

    def getEntity(self):
        """
        Devuelve una entidad vacía para la tabla asociada al artefacto
        """
        return Entity.fromTable(self._t)
