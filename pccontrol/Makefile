export THEOS_DEVICE_IP = 192.168.0.19


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = pccontrol

pccontrol_FILES = Tweak.xm SocketServer.xm Touch.xm Screen.xm Task.xm Process.xm AlertBox.xm Common.xm Record.xm Play.xm Window.xm
pccontrol_CFLAGS = -Wno-error -Wno-module-import-in-extern-c
pccontrol_FRAMEWORKS = UIKit
pccontrol_ARCHS = arm64 arm64e

pccontrol_PRIVATE_FRAMEWORKS = IOKit
pccontrol_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

