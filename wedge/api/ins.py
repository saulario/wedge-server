#!/usr/bin/python3
import logging

import ins_pb2_grpc

from ins_pb2_grpc import add_ServiceServicer_to_server

log = logging.getLogger(__name__)

class Service(ins_pb2_grpc.ServiceServicer):

    def Delete(self, request, context):
        """
        """
        return None

    def Insert(self, request, context):
        """
        """
        return None

    def Read(self, request, context=None):
        """
        """
        return ins_pb2_grpc.types__pb2.Ins()

    def Update(self, request, context):
        """
        """
        return None        
