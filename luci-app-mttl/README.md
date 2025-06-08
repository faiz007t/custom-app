**Package Name**: `luci-app-mttl`

**Version**: `1.0`

**Description**:
The `luci-app-mttl` is a LuCI application for OpenWRT that allows users to modify the TTL (Time-To-Live) of outgoing packets using `nftables`. This package provides a web interface for managing TTL values for network traffic, giving administrators the ability to set a custom TTL on packets passing through the router.

### Features:

* **Change TTL**: Modify the TTL value for outgoing network traffic.
* **Web Interface**: Easy-to-use graphical interface through LuCI to manage TTL settings.
* **nftables Integration**: Uses `nftables` to apply TTL changes to network traffic efficiently.

### Dependencies:

* `luci`: The LuCI framework for the OpenWRT web interface.
* `nftables`: A user-space utility for managing `nftables` (netfilter) configurations.

### Developed by:

* **DotyCat**
  Website: [dotycat.com](https://dotycat.com)

### Usage:

1. Install the package through the OpenWRT interface or using the command line.
2. Access the TTL Changer application in the `Applications` section of LuCI.
3. Set the desired TTL value for your network traffic.
4. Apply the settings to modify the TTL for packets passing through the router.

