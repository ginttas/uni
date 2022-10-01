import socket
import pickle

def divide_chunks(l, n):
    size = n - 1
    for i in range(0, len(l), size):
        res = l[i:i + size]
        if len(res) != size:
            res += bytes(size - len(res))
        res += bytes(1)
        yield bytearray(res)

def read_input():
    print("Įveskite skaičių kiekį: ", end="")
    n = int(input())
    print("Įveskite vidurkį: ", end="")
    mean = int(input())
    print("Įveskite standartinį nuokrypį: ", end="")
    std = int(input())
    message = [n, mean, std]
    return(message)

def start_client(host = "127.0.0.1", port = 65432, buff_size = 8):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        while(True):
            message = read_input()
            bin_message = pickle.dumps(message)
            chunks = [i for i in divide_chunks(bin_message, buff_size)]
            chunks[-1][-1] = 1
            for i in chunks:
                send_bytes = s.send(i)
            res = bytes(0)
            end = False
            while not end:
                val = s.recv(buff_size)
                res += val[:-1]
                if val[-1] == 1: end = True
            arr = pickle.loads(res)
            print(arr)

start_client()