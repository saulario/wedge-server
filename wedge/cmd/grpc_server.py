import concurrent.futures
import logging

import grpc

import wedge.api.ins

def serve():
    port = "50001"
    server = grpc.server(thread_pool=concurrent.futures.ThreadPoolExecutor(max_workers=20))
    wedge.api.ins.add_ServiceServicer_to_server(wedge.api.ins.Service(), server)
    port = server.add_insecure_port("[::]:" + port)
    server.start()
    server.wait_for_termination()

if __name__ == "__main__":
    logging.basicConfig()
    serve()