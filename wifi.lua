-------------------------------------------------------
--                      wifi.lua                     --
-------------------------------------------------------
pin_led = 0
gpio.write(pin_led,gpio.LOW)
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
	print("[wifi.lua] Connect time(s):" .. try_times)
    gpio.write(pin_led,gpio.HIGH)
    tmr.delay(100000)
	gpio.write(pin_led,gpio.LOW)
	tmr.delay(100000)
	gpio.write(pin_led,gpio.HIGH)
    -- 达到最大链接次数.
	if (try_times < max_times) then
		local wifi_status = wifi.sta.status()
		if (wifi_status == 5) then
			print("[wifi.lua] Connect succeed.")
			dofile("main.lua")
		else
			wifi_timer:interval(2000)
			wifi_timer:start()
        end
	else
        print("[wifi.lua] Connect failed. Initializing wifi station.")
		dofile("enduser.lua")
	end
    try_times = try_times + 1
end
