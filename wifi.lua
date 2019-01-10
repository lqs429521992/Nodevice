-------------------------------------------------------
--                      wifi.lua                     --
-------------------------------------------------------

-- 1秒后执行测试函数
print("[wifi.lua] Start to connect wifi.")
-- 设置wifi模式并连接wifi
wifi.setmode(wifi.STATION)
wifi.sta.connect()
-- 定时执行 wifi_connect 函数
try_times = 1
max_times = 5
wifi_timer = tmr.create()
wifi_timer:alarm(try_times * 1000, tmr.ALARM_SEMI, function() wifi_connect() end)

function wifi_connect()
	print("[wifi.lua] Connect time(s):." .. try_times)
    -- 达到最大链接次数.
	if (try_times < max_times) then
		print("[wifi.lua] Connect times reach limit. Initializing wifi station.")
		dofile("enduser.lua")
		local wifi_status = wifi.sta.status()
		if (wifi_status == 5) then
			print("[wifi.lua] Connect succeed.")
			dofile("main.lua")
		else
			print("[wifi.lua]: Connection status: " .. str_sta_status(wifi_status) .. ". Reconnect after " .. try_times .. " seconds.")
			wifi_timer:interval(try_times * 1000)
			wifi_timer:start()
        end
    else
        print("[wifi.lua] Connect failed. Initializing wifi station.")
		dofile("enduser.lua")
	end
    try_times = try_times + 1
end

function str_sta_status(num)
	local ret = ""
	if (num == 5) then
		ret = "GOTIP"
	elseif (num == 4) then
		ret = "FAIL"
	elseif (num == 3) then
		ret = "APNOTFOUND"
	elseif (num == 2) then
		ret = "WRONGPWD"
	elseif (num == 1) then
		ret = "CONNECTING"
	elseif (num == 0) then
		ret = "IDLE"
	end
	return ret
end