ARCHS = arm64 armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CellularDataChangedAction
CellularDataChangedAction_FILES = Tweak.xm
CellularDataChangedAction_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
