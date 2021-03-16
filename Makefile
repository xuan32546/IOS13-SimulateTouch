# lipoplastic setup for armv6 + arm64 compilation
export ARCHS = arm64e arm64 armv7
export THEOS_DEVICE_IP = 192.168.0.5

SUBPROJECTS = appdelegate zxtouch-binary pccontrol

include /opt/theos/makefiles/common.mk
include $(FW_MAKEDIR)/aggregate.mk

after-install::
	install.exec "chown -R mobile:mobile /var/mobile/Library/ZXTouch && killall -9 SpringBoard;"

