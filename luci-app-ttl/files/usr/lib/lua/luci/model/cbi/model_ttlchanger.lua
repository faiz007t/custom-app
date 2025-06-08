local fs  = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

local config_file = "/etc/nftables.d/10-custom-filter-chains.nft"
local m = Map("ttlchanger", "TTL Settings", "Configure IPv4 TTL and IPv6 Hop Limit manipulation through nftables.")

-- Ensure config section exists with correct field name and default values (mode = "on", value = 64)
if not uci:get_first("ttlchanger", "on") then
    uci:section("ttlchanger", "on", nil, { mode = "on", value = "64" })
    uci:commit("ttlchanger")
end

local s = m:section(TypedSection, "on", "")
s.anonymous = true

-- TTL Mode Option
local mode = s:option(ListValue, "mode", "TTL Mode")
mode.default = "on"
mode:value("off", "Off")
mode:value("on", "On")

-- Set TTL Value Option
local ttl_value = s:option(Value, "value", "Set TTL Value")
ttl_value.datatype = "uinteger"
ttl_value.default = "64"
ttl_value:depends("mode", "on")

function m.on_commit(map)
    local mode_val = uci:get("ttlchanger", "@on[0]", "mode") or "on"
    local ttl_val

    if mode_val == "on" then
        ttl_val = 64
        uci:set("ttlchanger", "@on[0]", "value", 64)
        uci:commit("ttlchanger")
    else
        math.randomseed(os.time())
        ttl_val = math.random(1, 150)
        uci:set("ttlchanger", "@on[0]", "value", ttl_val)
        uci:commit("ttlchanger")
    end

    local function get_chain(name, rule)
        return string.format([[
chain %s {
  type filter hook %s priority 300; policy accept;
  counter%s
}
]], name, name:match("prerouting") and "prerouting" or "postrouting", rule and (" " .. rule) or "")
    end

    local ttl_rule = "ip ttl set " .. ttl_val
    local hop_rule = "ip6 hoplimit set " .. ttl_val

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
    sys.call("/sbin/reboot")  -- Automatically reboot after applying TTL changes
end

return m
