include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/speedtest
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ookla Speedtest
  DEPENDS:=+libc
endef

define Package/speedtest/description
  Installs the Ookla Speedtest CLI binary.
endef

# Empty Build/Compile section removed entirely
# (No compilation needed for prebuilt binary)

define Package/speedtest/install$
^I$(INSTALL_DIR) $(1)/usr/bin$
^I$(INSTALL_BIN) ./files/usr/bin/speedtest $(1)/usr/bin/$
endef$

$(eval $(call BuildPackage,speedtest))
