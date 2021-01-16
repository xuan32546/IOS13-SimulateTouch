from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

device = zxtouch("127.0.0.1")
device.show_toast(TOAST_WARNING, "Start matching \"examples\" string on this page", 1.5, TOAST_BUTTOM)
time.sleep(1.5)
result_tuple = device.image_match("/var/mobile/Library/ZXTouch/scripts/examples/Image Matching.bdl/examples_folder.jpg")
if not result_tuple[0]:
    device.show_toast(TOAST_ERROR, "Error happened while matching. Error: " + result_tuple[1], 1.5, TOAST_BUTTOM)
else:
    result_dict = result_tuple[1]
    if float(result_dict["width"]) != 0 and float(result_dict["height"]) != 0:
        device.show_toast(TOAST_SUCCESS, "X: " + result_dict["x"] + ". Y: " + result_dict["y"] + ". Width: " + result_dict["width"] + ". Height: " + result_dict["height"], 1.5, TOAST_BUTTOM)
device.disconnect()
