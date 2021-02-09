

from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

device = zxtouch("127.0.0.1")

device.show_toast(TOAST_MESSAGE, "Start searching for 200-255, 200-255, 200-255 in 1 seconds", 1.5)
time.sleep(1)

result = device.search_color((0, 0, 0, 0), 200, 255, 200, 255, 200, 255)

device.show_toast(TOAST_SUCCESS, "found! x: {}, y: {}, rgb:({},{},{})".format(result[1]["x"], result[1]["y"], result[1]["red"], result[1]["green"], result[1]["blue"]), 1.5)

device.disconnect()