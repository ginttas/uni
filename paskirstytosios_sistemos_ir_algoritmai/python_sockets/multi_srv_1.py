from asyncio import events
import sys
import socket
import selectors
import types

import pandas
import time

global my_log
global sel
sel = selectors.DefaultSelector()
my_log = pandas.DataFrame(columns = ["time", "sender", "message"])


# -1 - Idle
#  1 - Read (Prep to accept time)

def accept_wrapper(sock):
    #print("accept_wrapper")
    conn, addr = sock.accept()
    #print(f"Accepted connection from {addr}")
    conn.setblocking(False)
    data = types.SimpleNamespace(addr=addr, int=b"", outb=b"", my_time = 0)
    events = selectors.EVENT_READ | selectors.EVENT_WRITE
    sel.register(conn, events, data=data)

def service_connection(key, mask):
    global my_log
    global sel
    sock = key.fileobj
    data = key.data
    try:
        if mask & selectors.EVENT_READ:
            recv_data = sock.recv(1024)
            if recv_data:
                print(recv_data)
                data.outb += recv_data
                my_log.loc[len(my_log.index)] = [time.time(), data.addr, data.outb]
            else:
                #print(f"Closing connection to {data.addr}")
                sel.unregister(sock)
                sock.close()

        if mask & selectors.EVENT_WRITE:
            if data.outb:
                print(my_log)
                sent = sock.send(b"TEST")
                #print(f"Echoing {data.outb!r} to {data.addr}")
                #sent = sock.send(data.outb)
                data.outb = data.outb[sent:]
    except ConnectionError:
        # https://stackoverflow.com/questions/65057745/how-do-i-handle-a-disconnect-with-python-sockets-connectionreseterror
        #print(f"Unable to reach client with socket {data.addr}")
        sel.unregister(sock)

def start_srv(host, port):
    lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    lsock.bind((host, port))
    lsock.listen()
    #print(f"Listening on {(host, port)}")
    lsock.setblocking(False)
    sel.register(lsock, selectors.EVENT_READ, data=None)

    try:
        while True:
            events = sel.select(timeout=1)
            for key, mask in events:
                if key.data is None:
                    accept_wrapper(key.fileobj)
                else:
                    service_connection(key, mask)
    except KeyboardInterrupt:
        print("Caught keyboard interrupt, exiting")
    finally:
        sel.close()


HOST = "127.0.0.1"
PORT = 65432

start_srv(HOST, PORT)