include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Faiz <faiz007t>
PKG_LICENSE:=GPL-2.0
PKG_ARCH:=$(ARCH)

include $(INCLUDE_DIR)/package.mk

define Package/speedtest
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ookla Speedtest CLI
  URL:=https://www.speedtest.net/apps/cli
  DEPENDS:=+libc +libstdcpp
endef

define Package/speedtest/description
  Official Ookla Speedtest CLI (aarch64_cortex-a53 optimized)
endef

define Build/Prepare
    @echo "Verifying architecture..."
    if [ "$(ARCH)" != "aarch64" ]; then \
        echo "Binary built for aarch64, current ARCH: $(ARCH)"; \
        exit 1; \
    fi
    
    mkdir -p $(PKG_BUILD_DIR)
    $(CP) ./files/* $(PKG_BUILD_DIR)/
    
    @echo "Validating binary..."
    if [ ! -x "$(PKG_BUILD_DIR)/usr/bin/speedtest" ]; then \
        echo "Missing executable binary in files directory"; \
        exit 1; \
    fi
endef

define Build/Configure
    # No configuration needed for prebuilt binary
endef

define Build/Compile
    # Empty section for prebuilt binary
endef

define Build/Clean
    $(RM) -r $(PKG_BUILD_DIR)
    $(RM) -r $(BUILD_DIR)/$(PKG_NAME)
endef

define Package/speedtest/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/speedtest $(1)/usr/bin/
endef

$(eval $(call BuildPackage,speedtest))
