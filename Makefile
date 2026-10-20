TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTube Premium Logo

PremiumYTLogo_FILES = PremiumYTLogo.x
PremiumYTLogo_CFLAGS = -fobjc-arc -IHeaders -Wno-deprecated-declarations
PremiumYTLogo_FRAMEWORKS = UIKit Foundation

ifeq ($(LIVECONTAINER),1)
PremiumYTLogo_LOGOS_DEFAULT_GENERATOR = internal
PremiumYTLogo_LDFLAGS += -Wl,-install_name,@rpath/PremiumYTLogo.dylib
endif

include $(THEOS_MAKE_PATH)/tweak.mk
