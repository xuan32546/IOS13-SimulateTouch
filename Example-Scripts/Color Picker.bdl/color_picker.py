import socket
import time

def pick_color(x, y):
    x = str(x)
    y = str(y)
    s.send(("223;;Pick color of coordinate (" + x + ", " + y + ");;1.5").encode())
    print(s.recv(1024))
    time.sleep(1.5)
    s.send(("23" + x + ";;" + y).encode())
    data_arr = s.recv(1024).decode().split(";;")
    if int(data_arr[0]) == 0:
        s.send(("224;;(" + x + ", " + y + ") in RGB: (" + data_arr[1] + ", " + data_arr[2] + ", " + data_arr[3].replace("\r\n", "") + ");;2").encode())
    else:
        s.send(("221;;Failed. Reason: " + data_arr[1].replace("\r\n", "") + ";;2").encode())
    print(s.recv(1024))

s = socket.socket()
s.connect(("127.0.0.1", 6000))  # connect to the tweak
time.sleep(0.1)  # please sleep after connection.

s.send("223;;Return to home screen;;2".encode())
print(s.recv(1024))
time.sleep(2)
pick_color(100, 100)
time.sleep(2)
pick_color(300, 700)


s.close() 
