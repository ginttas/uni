import socket
import pickle
import selectors
import types
import random

def divide_chunks(l, n):
    size = n - 1
    for i in range(0, len(l), size):
        res = l[i:i + size]
        if len(res) != size:
            res += bytes(size - len(res))
        res += bytes(1)
        yield bytearray(res)

def accept_wrapper(sock, sel):
    conn, addr = sock.accept()
    print(f"Accepted connection from {addr}")
    conn.setblocking(False)
    data = types.SimpleNamespace(addr=addr, my_data_bin = bytes(0))
    events = selectors.EVENT_READ
    sel.register(conn, events, data=data)

def service_connection(key, mask, sel, buff_size):
    sock = key.fileobj
    data = key.data
    try:
        if mask & selectors.EVENT_READ:
            recv_data = sock.recv(buff_size)
            if recv_data:
                data.my_data_bin += recv_data[:-1]
                if recv_data[-1] == 1:
                    arr = pickle.loads(data.my_data_bin)
                    print(f"Just got {arr} from {data.addr}, will send arr soon!")
                    res = [random.uniform(-1, 1) * arr[2] + arr[1] for i in range(arr[0])]
                    bin_message = pickle.dumps(res)
                    chunks = [i for i in divide_chunks(bin_message, buff_size)]
                    chunks[-1][-1] = 1
                    for i in chunks:
                        sock.send(i)
                    data.my_data_bin = bytes(0)
            else:
                print(f"Disconnected from {data.addr}")
                sel.unregister(sock)
                sock.close()
    except ConnectionError:
        sel.unregister(sock)


def start_server(host = "127.0.0.1", port = 65432, buff_size = 8):
    # https://docs.python.org/3/library/selectors.html
    # Selector contains list of file objects
    # Function select returns object that is ready for action
    # For KeyboardInterrupt to work timeout was set to 1.
    # If timeout wouldn't be set then select would block until some object is ready
    sel = selectors.DefaultSelector()
    # Init socket with:
    # AF_INET - Internet address family for IPv4
    # SOCK_STREAM - Socket type for TCP
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((host, port))
    sock.listen()
    sock.setblocking(False)
    # EVENT_READ - object is available for read
    sel.register(sock, selectors.EVENT_READ, data=None)
    try:
        while True:
            events = sel.select(timeout = 1)
            for key, mask in events:
                if key.data is None:
                    # If new connection
                    accept_wrapper(key.fileobj, sel)
                else:
                    # If existing connection
                    service_connection(key, mask, sel, buff_size)
    except KeyboardInterrupt:
        print("Caught keyboard interrupt, exiting")
    finally:
        sel.close()

start_server()