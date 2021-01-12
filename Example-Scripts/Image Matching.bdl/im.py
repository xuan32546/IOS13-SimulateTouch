import socket
import time

s = socket.socket()
s.connect(("127.0.0.1", 6000))  # connect to the tweak
time.sleep(0.1)  # please sleep after connection.

s.send("223;;Opening Settings;;2".encode())
print(s.recv(1024))
time.sleep(0.1)
s.send("11com.apple.Preferences".encode())
print(s.recv(1024))
time.sleep(2)
s.send("224;;Start image matching and searching for the VPN icon;;1".encode())
print(s.recv(1024))
time.sleep(1)
s.send("222;;Please do not touch your screen until it finishes...;;20".encode())
print(s.recv(1024))
s.send("21/Library/Application Support/zxtouch/vpn.jpg;;8;;0.8;;0.8".encode())
data_arr = s.recv(1024).decode().split(";;")

if int(data_arr[0]) == 0 and float(data_arr[1]) != 0 or float(data_arr[2]) != 0 or float(data_arr[3]) != 0 or float(data_arr[4]) != 0:
    s.send(("224;;Icon found!Coordinates - X: " + data_arr[1] + ". Y: " + data_arr[2] + ";;3").encode())
else:
    s.send("221;;Match Failed;;1".encode())

s.close() 
