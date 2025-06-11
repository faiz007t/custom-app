include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Faiz <faiz007t>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/speedtest
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ookla Speedtest CLI
  URL:=https://www.speedtest.net/apps/cli
  DEPENDS:=+libc
endef

define Package/speedtest/description
  Command line interface for testing network speed using Ookla's Speedtest servers.
  This package provides the official CLI binary for OpenWrt systems.
endef

define Build/Prepare
    mkdir -p $(PKG_BUILD_DIR)
    $(CP) ./files/* $(PKG_BUILD_DIR)/
    $(if $(wildcard $(PKG_BUILD_DIR)/usr/bin/speedtest), \
        chmod +x $(PKG_BUILD_DIR)/usr/bin/speedtest, \
        $(error Missing speedtest binary in files directory))
endef

define Build/Configure
    # No configuration needed for prebuilt binary
endef

define Build/Compile
    # Empty section for prebuilt binary
endef

define Package/speedtest/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/speedtest $(1)/usr/bin/
endef

$(eval $(call BuildPackage,speedtest))
