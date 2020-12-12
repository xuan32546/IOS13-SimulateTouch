import socket
import time

# touch event types
TOUCH_UP = 0
TOUCH_DOWN = 1
TOUCH_MOVE = 2
SET_SCREEN_SIZE = 9

# you can copy and paste these methods to your code
def formatSocketData(type, index, x, y):
    return '{}{:02d}{:05d}{:05d}'.format(type, index, int(x*10), int(y*10))

def horizontalSwipe():
    x = 300
    s.send(("101" + formatSocketData(TOUCH_DOWN, 7, x, 1000)).encode())  # touch down "10" at the beginning means "perform touch event". The third digit("1") is the data count.
    # the above code is equal to s.send(("1011070300010000").encode())
    time.sleep(0.01) # if you run this script on your computer, change sleep time to 0.2. (This is weird that python sleeps much longer on iOS than it should)
    while x <= 600:
        s.send(("101" + formatSocketData(TOUCH_MOVE, 7, x, 1000)).encode())  # move our finger 7 to the right
        x += 5
        time.sleep(0.01)

    while x >= 100:
        s.send(("101" + formatSocketData(TOUCH_MOVE, 7, x, 1000)).encode())  # move our finger 7 to the left
        x -= 5
        time.sleep(0.01)

    s.send(("101" + formatSocketData(TOUCH_UP, 7, x, 1000)).encode())  # release finger

if __name__ == '__main__':
    s = socket.socket()
    s.connect(("192.168.0.19", 6000))  # connect to the tweak
    time.sleep(0.1)  # please sleep after connection.

    #horizontalSwipe() # preform swipe
    #s.send("11com.apple.springboard".encode())
    #time.sleep(1)
    #############   shell access as root    ##############
    s.send("14".encode())  # 13 at head means the task id is 13 (run shell command). The shell command here is "killall Prefernces", which kills the settings app.
    time.sleep(8)
    s.send("15".encode())
    s.close()
