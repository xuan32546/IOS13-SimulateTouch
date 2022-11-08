from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

# from keyboard-test.py
device = zxtouch("192.168.0.19")
device.show_toast(TOAST_MESSAGE, "Opening Notes...", 2)
time.sleep(2)
device.show_toast(TOAST_MESSAGE, "Please select an input field! 3...", 1)
time.sleep(1)

device.show_toast(TOAST_MESSAGE, "Please select an input field! 2...", 1)
time.sleep(1)

device.show_toast(TOAST_MESSAGE, "Please select an input field! 1...", 1)
time.sleep(1)

# clipboard test
clipboard = "Clipboard Test"
device.set_clipboard_text(clipboard)
device.show_toast(TOAST_MESSAGE, "Copied {} to your clipboard!".format(clipboard), 2)
time.sleep(2)

device.show_toast(TOAST_MESSAGE, "Pasting clipboard...", 2)
device.paste_from_clipboard()
time.sleep(2)

clipboard = "Hello"
device.set_clipboard_text(clipboard)
device.show_toast(TOAST_MESSAGE, "Copied {} to your clipboard!".format(clipboard), 2)
time.sleep(2)

current_clipboard = device.get_text_from_clipboard()
device.show_toast(TOAST_WARNING, "Your clipboard content is: {}".format(current_clipboard), 2)
time.sleep(2)

device.disconnect()
