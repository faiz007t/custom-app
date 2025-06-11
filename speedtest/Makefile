include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_ARCH:=$(ARCH)
PKG_MAINTAINER:=Faiz <faiz007t>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/speedtest
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ookla Speedtest CLI
  URL:=https://www.speedtest.net/apps/cli
  DEPENDS:=+libc +libstdcpp
endef

define Package/speedtest/description
  Official Ookla Speedtest CLI for OpenWrt (aarch64_cortex-a53)
endef

define Build/Prepare
    if [ "$(ARCH)" != "aarch64" ]; then \
        echo "Binary built for aarch64, current ARCH: $(ARCH)"; \
        exit 1; \
    fi
    mkdir -p $(PKG_BUILD_DIR)
    $(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Package/speedtest/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/speedtest $(1)/usr/bin/
endef

$(eval $(call BuildPackage,speedtest))
