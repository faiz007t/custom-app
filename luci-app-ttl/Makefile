# Define the package information
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ttl
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=faisal971 <support@serverplp.com>
PKG_LICENSE:=GPL-3.0

LUCI_TITLE:=TTL Settings
LUCI_DESCRIPTION:=This LuCI app provides TTL changer functionality in a web interface.
LUCI_DEPENDS:=+luci +nftables

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  PKGARCH:=all
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  $(LUCI_DESCRIPTION)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
  $(CP) -r ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
