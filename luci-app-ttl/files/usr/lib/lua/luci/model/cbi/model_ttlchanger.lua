local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

local config_file = "/etc/nftables.d/10-custom-filter-chains.nft"
local m = Map("ttlchanger", "TTL Settings", "Configure IPv4 TTL and IPv6 Hop Limit manipulation through nftables.")

-- Ensure config section exists with correct field name
if not uci:get_first("ttlchanger", "ttl") then
    uci:section("ttlchanger", "ttl", nil, { mode = "off", value = "64" })
    uci:commit("ttlchanger")
end

local s = m:section(TypedSection, "ttl", "")
s.anonymous = true

local mode = s:option(ListValue, "mode", "TTL Mode")
mode.default = "ttl"
mode:value("off", "Off")
mode:value("ttl", "Set TTL")

local ttl_value = s:option(Value, "value", "Set TTL Value")
ttl_value.datatype = "uinteger"
ttl_value.default = "65"
ttl_value:depends("mode", "ttl")

local html_table = s:option(DummyValue, "_html_table", "")
html_table.rawhtml = true
html_table.value = [[
<table class="table table-striped">
  <tr>
    <td><strong>Reboot</strong></td>
    <td>
      <form method="post">
        <input class="cbi-button cbi-button-apply" type="submit" name="cbi.reboot" value="Reboot Now" aria-label="Reboot Now" />
      </form>
    </td>
  </tr>
</table>
]]

if luci.http.formvalue("cbi.reboot") then
    sys.call("/sbin/reboot")
end

function m.on_commit(map)
    local mode_val = uci:get("ttlchanger", "@ttl[0]", "mode") or "off"
    local ttl_val = tonumber(uci:get("ttlchanger", "@ttl[0]", "value")) or 65

    local function get_chain(name, rule)
        return string.format([[ 
chain %s {
  type filter hook %s priority 300; policy accept;
  counter%s
}
]], name, name:match("prerouting") and "prerouting" or "postrouting", rule and (" " .. rule) or "")
    end

    local ttl_rule = (mode_val == "ttl") and ("ip ttl set " .. ttl_val) or nil
    local hop_rule = (mode_val == "ttl") and ("ip6 hoplimit set " .. ttl_val) or nil

    local new_rules = table.concat({
        get_chain("mangle_prerouting_ttl64", ttl_rule),
        get_chain("mangle_postrouting_ttl64", ttl_rule),
        get_chain("mangle_prerouting_hoplimit64", hop_rule),
        get_chain("mangle_postrouting_hoplimit64", hop_rule)
    }, "\n")

    local original = fs.readfile(config_file) or ""
    local result = {}
    local skip = false
    for line in original:gmatch("[^\r\n]+") do
        if line:match("^chain mangle_.*ttl") or line:match("^chain mangle_.*hoplimit") then
            skip = true
        elseif skip and line:match("^}") then
            skip = false
        elseif not skip then
            table.insert(result, line)
        end
    end

    local updated = table.concat(result, "\n")
    if updated ~= "" and not updated:match("\n$") then
        updated = updated .. "\n"
    end

    fs.writefile(config_file, updated .. "\n" .. new_rules .. "\n")
    sys.call("/etc/init.d/nftables restart")
end

return m
