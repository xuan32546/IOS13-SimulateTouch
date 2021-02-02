

from zxtouch.client import zxtouch
from zxtouch.toasttypes import *
import time

current_time = str(int(time.time()))
DEBUG_IMAGE_PATH = "/var/mobile/Library/ZXTouch/scripts/Debug/OCR-debug-image-" + current_time + ".jpg"
OUTPUT_PATH = "/var/mobile/Library/ZXTouch/scripts/Debug/OCR-output-string-" + current_time + ".txt"


device = zxtouch("127.0.0.1")
device.show_toast(TOAST_SUCCESS, "Recognizing.... Supported languages: " + "".join(device.get_supported_ocr_languages(1)[1]), 15)

ocr_string_list = device.ocr((0,0,0,0), debug_image_path=DEBUG_IMAGE_PATH, recognition_level=1)
ocr_string = "\n".join(map(str, ocr_string_list[1]))

f = open(OUTPUT_PATH, "w")
f.write(ocr_string)
f.close()

device.run_shell_command("chown mobile:mobile \"" + OUTPUT_PATH + "\"")

device.show_toast(TOAST_HIDE, "", 0)
device.show_alert_box("Success", "Please refresh script list. Debug image path: " + DEBUG_IMAGE_PATH + ". Output Path: " + OUTPUT_PATH, 99)
device.disconnect()
