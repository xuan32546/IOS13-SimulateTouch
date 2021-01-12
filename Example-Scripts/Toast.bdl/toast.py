import socket
import time

s = socket.socket()
s.connect(("127.0.0.1", 6000))  # connect to the tweak
time.sleep(0.1)  # please sleep after connection.

s.send("221;;This is an error message toast;;1.5".encode())
print(s.recv(1024))
time.sleep(1.5)
s.send("222;;This is a warning message toast;;1.5".encode())
print(s.recv(1024))
time.sleep(1.5)
s.send("223;;This is a normal message toast;;1.5".encode())
print(s.recv(1024))
time.sleep(1.5)
s.send("224;;This is a success message toast;;1.5".encode())
print(s.recv(1024))

s.close() 
