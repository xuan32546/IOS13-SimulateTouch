

from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time
from zxtouch.touchtypes import *

device = zxtouch("127.0.0.1")

device.show_toast(TOAST_WARNING, "Touching point (400, 400)", 1.5)
device.touch(TOUCH_DOWN, 1, 400, 400)
time.sleep(1.5)

device.show_toast(TOAST_WARNING, "Moving to point (400, 600)", 1.5)
device.touch(TOUCH_MOVE, 1, 400, 600)
time.sleep(1.5)

device.show_toast(TOAST_WARNING, "Touch up", 1.5)
device.touch(TOUCH_UP, 1, 400, 600)
time.sleep(1.5)

device.show_toast(TOAST_WARNING, "Touching point (100, 100)", 1.5)
device.touch(TOUCH_DOWN, 1, 100, 100)
time.sleep(0.1)
device.touch(TOUCH_UP, 1, 100, 100)
time.sleep(1.4)

device.show_toast(TOAST_WARNING, "Multitouching...Point (300, 300) and (500, 500)", 2.5)
device.touch_with_list([{"type": TOUCH_DOWN, "finger_index": 1, "x": 300, "y": 300}, {"type": TOUCH_DOWN, "finger_index": 2, "x": 500, "y": 500}])
time.sleep(1)
device.touch_with_list([{"type": TOUCH_UP, "finger_index": 1, "x": 300, "y": 300}, {"type": TOUCH_UP, "finger_index": 2, "x": 500, "y": 500}])


device.disconnect()