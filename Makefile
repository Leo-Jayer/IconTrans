TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e

# Dopamine rootless 支持
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IconFade

IconFade_FILES = Tweak.xm
IconFade_CFLAGS = -fobjc-arc
IconFade_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

# 安装后重启 SpringBoard
after-install::
	install.exec "sbreload"

# 子项目：设置面板
SUBPROJECTS += iconfadeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
