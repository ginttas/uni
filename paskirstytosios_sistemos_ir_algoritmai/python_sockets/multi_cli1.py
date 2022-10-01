from os import close
import sys
import socket
import selectors
from time import sleep
import types

sel = selectors.DefaultSelector()


HOST = "127.0.0.1"
PORT = 65432

print(f"Starting connection to {(HOST, PORT)}")
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#sock.setblocking(False)
sock.connect((HOST, PORT))
events = selectors.EVENT_READ | selectors.EVENT_WRITE
time = 0

while(1):
    my_input = input()
    if(my_input == "q"): break
    if(my_input == "r"):
        res = sock.recv(1024)
        print(res)
    elif(len(my_input) != 0):
        msg = bytes(my_input, "utf-8")
        ret = sock.send(msg)

sock.close()