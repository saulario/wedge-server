# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

import types_pb2 as types__pb2
import usr_pb2 as usr__pb2


class ServiceStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.Login = channel.unary_unary(
                '/wedge.usr.Service/Login',
                request_serializer=usr__pb2.LoginRequest.SerializeToString,
                response_deserializer=usr__pb2.LoginResponse.FromString,
                )
        self.Delete = channel.unary_unary(
                '/wedge.usr.Service/Delete',
                request_serializer=usr__pb2.PKRequest.SerializeToString,
                response_deserializer=usr__pb2.DeleteResponse.FromString,
                )
        self.Insert = channel.unary_unary(
                '/wedge.usr.Service/Insert',
                request_serializer=types__pb2.Usr.SerializeToString,
                response_deserializer=types__pb2.Usr.FromString,
                )
        self.Read = channel.unary_unary(
                '/wedge.usr.Service/Read',
                request_serializer=usr__pb2.PKRequest.SerializeToString,
                response_deserializer=types__pb2.Usr.FromString,
                )
        self.Update = channel.unary_unary(
                '/wedge.usr.Service/Update',
                request_serializer=types__pb2.Usr.SerializeToString,
                response_deserializer=types__pb2.Usr.FromString,
                )


class ServiceServicer(object):
    """Missing associated documentation comment in .proto file."""

    def Login(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Delete(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Insert(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Read(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def Update(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_ServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'Login': grpc.unary_unary_rpc_method_handler(
                    servicer.Login,
                    request_deserializer=usr__pb2.LoginRequest.FromString,
                    response_serializer=usr__pb2.LoginResponse.SerializeToString,
            ),
            'Delete': grpc.unary_unary_rpc_method_handler(
                    servicer.Delete,
                    request_deserializer=usr__pb2.PKRequest.FromString,
                    response_serializer=usr__pb2.DeleteResponse.SerializeToString,
            ),
            'Insert': grpc.unary_unary_rpc_method_handler(
                    servicer.Insert,
                    request_deserializer=types__pb2.Usr.FromString,
                    response_serializer=types__pb2.Usr.SerializeToString,
            ),
            'Read': grpc.unary_unary_rpc_method_handler(
                    servicer.Read,
                    request_deserializer=usr__pb2.PKRequest.FromString,
                    response_serializer=types__pb2.Usr.SerializeToString,
            ),
            'Update': grpc.unary_unary_rpc_method_handler(
                    servicer.Update,
                    request_deserializer=types__pb2.Usr.FromString,
                    response_serializer=types__pb2.Usr.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'wedge.usr.Service', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class Service(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def Login(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/wedge.usr.Service/Login',
            usr__pb2.LoginRequest.SerializeToString,
            usr__pb2.LoginResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def Delete(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/wedge.usr.Service/Delete',
            usr__pb2.PKRequest.SerializeToString,
            usr__pb2.DeleteResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def Insert(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/wedge.usr.Service/Insert',
            types__pb2.Usr.SerializeToString,
            types__pb2.Usr.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def Read(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/wedge.usr.Service/Read',
            usr__pb2.PKRequest.SerializeToString,
            types__pb2.Usr.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def Update(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/wedge.usr.Service/Update',
            types__pb2.Usr.SerializeToString,
            types__pb2.Usr.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)
