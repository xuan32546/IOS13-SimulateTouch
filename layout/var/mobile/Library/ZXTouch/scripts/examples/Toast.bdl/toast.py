

from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

device = zxtouch("127.0.0.1")

device.show_toast(TOAST_SUCCESS, "This is an success message toast", 1.5)
time.sleep(1.5)

device.show_toast(TOAST_ERROR, "This is an error message toast", 1.5)
time.sleep(1.5)

device.show_toast(TOAST_WARNING, "This is an warning message toast", 1.5)
time.sleep(1.5)

device.show_toast(TOAST_MESSAGE, "This is an normal message toast", 1.5)
time.sleep(1.5)

device.show_toast(TOAST_ERROR, "Toast can also be shown at bottom", 3, TOAST_BUTTOM)

device.disconnect()