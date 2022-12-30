#!/usr/bin/python3

import logging

import grpc

import ins_pb2
import ins_pb2_grpc


def run():
    with grpc.insecure_channel("localhost:50001") as channel:
        stub = ins_pb2_grpc.ServiceStub(channel=channel)
        b = stub.Read(ins_pb2.PKRequest(insid=12345))
        print(b)


if __name__ == "__main__":
    logging.basicConfig()
    run()