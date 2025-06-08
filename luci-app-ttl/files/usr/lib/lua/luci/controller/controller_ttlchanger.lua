module("luci.controller.controller_ttlchanger", package.seeall)

function index()
    entry({"admin", "modem", "ttlchanger"}, cbi("model_ttlchanger"), _("TTL Settings"), 100)
end

