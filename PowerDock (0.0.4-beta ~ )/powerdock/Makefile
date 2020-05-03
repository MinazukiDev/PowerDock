ARCHS = arm64 arm64e
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PowerDock
PowerDock_FILES = PDListController.m MTableCell.m
PowerDock_INSTALL_PATH = /Library/PreferenceBundles
PowerDock_FRAMEWORKS = UIKit
PowerDock_PRIVATE_FRAMEWORKS = Preferences
PowerDock_LIBRARIES = powercontroller

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PowerDock.plist$(ECHO_END)
