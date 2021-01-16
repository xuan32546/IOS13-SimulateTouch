from zxtouch.client import zxtouch

device = zxtouch("127.0.0.1")
device.show_alert_box("ZXTouch Demo", "This is an AlertBox and will disappear in 3 seconds", 3)
device.disconnect()