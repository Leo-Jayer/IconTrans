TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e

# Dopamine rootless 支持
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = IconFadePrefs

IconFadePrefs_FILES = IconFadePrefsRootListController.m
IconFadePrefs_FRAMEWORKS = UIKit
IconFadePrefs_PRIVATE_FRAMEWORKS = Preferences
IconFadePrefs_INSTALL_PATH = /Library/PreferenceBundles
IconFadePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
