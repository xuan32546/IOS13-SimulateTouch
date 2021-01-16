from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

device = zxtouch("127.0.0.1")


# screen size
result_tuple = device.get_screen_size()
if not result_tuple[0]:
    device.show_toast(TOAST_ERROR, "Cannot get screen size. Error " + result_tuple[1], 2)
    device.disconnect()
    exit(0)

device.show_toast(TOAST_SUCCESS, "Screen width: " + str(int(float(result_tuple[1]["width"]))) + ". Height: " + str(int(float(result_tuple[1]["height"]))), 2)
time.sleep(2)

# screen orientation and scale
result_tuple = device.get_screen_orientation()
if not result_tuple[0]:
    device.show_toast(TOAST_ERROR, "Cannot get screen orientation. Error " + result_tuple[1], 2)
    device.disconnect()
    exit(0)

result_tuple_scale = device.get_screen_scale()
if not result_tuple_scale[0]:
    device.show_toast(TOAST_ERROR, "Cannot get screen scale. Error " + result_tuple[1], 2)
    device.disconnect()
    exit(0)

device.show_toast(TOAST_SUCCESS, "Screen orientation: " + str(int(float(result_tuple[1][0]))) + ". Screen scale: " + str(int(float(result_tuple_scale[1][0]))), 2)
time.sleep(2)

# device info
result_tuple = device.get_device_info()
if not result_tuple[0]:
    device.show_toast(TOAST_ERROR, "Cannot get device info. Error " + result_tuple[1], 2)
    device.disconnect()
    exit(0)

device.show_toast(TOAST_SUCCESS, "Name: " + result_tuple[1]["name"] + ". Model: " + result_tuple[1]["model"] + ". System: iOS " + result_tuple[1]["system_version"], 2)
time.sleep(2)

# battery info
result_tuple = device.get_battery_info()
if not result_tuple[0]:
    device.show_toast(TOAST_ERROR, "Cannot get battery info. Error " + result_tuple[1], 2)
    device.disconnect()
    exit(0)

device.show_toast(TOAST_SUCCESS, "Battery Level: " + result_tuple[1]["battery_level"] + "%. Battery state: " + result_tuple[1]["battery_state_string"], 2)
time.sleep(2)

device.show_toast(TOAST_WARNING, "If you need more, please contact me on Github or Discord", 3)
time.sleep(3)