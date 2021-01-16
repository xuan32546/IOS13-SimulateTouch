from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

device = zxtouch("127.0.0.1")
device.show_toast(TOAST_MESSAGE, "Picking color from 100, 100 after 1.5 seconds...", 1.5)
time.sleep(1.5)
result_tuple = device.pick_color(100, 100)
if not result_tuple[0]:
    device.show_toast(TOAST_MESSAGE, "Error while getting color. Error info: " + result_tuple[1], 1.5)
else:
    result_dict = result_tuple[1]
    device.show_toast(TOAST_MESSAGE, "Red: " + result_dict["red"] + ". Green: " + result_dict["green"] + ". Blue: " + result_dict["blue"], 1.5)
device.disconnect()