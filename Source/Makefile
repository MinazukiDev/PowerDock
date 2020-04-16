ARCHS = arm64 arm64e
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PowerDock
PowerDock_FILES = Tweak.xm
PowerDock_LIBRARIES = powercontroller

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += powerdock
include $(THEOS_MAKE_PATH)/aggregate.mk
