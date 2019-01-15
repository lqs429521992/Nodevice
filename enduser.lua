-------------------------------------------------------
--                   enduser.lua                     --
-------------------------------------------------------

print("[enduser.lua] Establishing AP...")

wifi.setmode(wifi.STATIONAP)
wifi_cfg = {
	ssid = "Nodevice_" .. node.chipid(),
	auth = wifi.OPEN,
	hidden = false,
	save = false
}

ip_cfg = {
	ip = "192.168.4.1",
	netmask = "255.255.255.0",
	gateway = "192.168.4.1"
}

wifi.ap.setip(ip_cfg)
wifi.ap.config(wifi_cfg)

enduser_setup.manual(false)

tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() start_enduser() end)

function setup_ok()
	tmr.create():alarm(10000, tmr.ALARM_SINGLE, function() dofile("main.lua") end)
end

function setup_error(err, str)
end

function start_enduser()
	enduser_setup.start(
		function()
			setup_ok()
		end,
		function(err, str)
			setup_error(err, str)
		end,
		print
	)
end
