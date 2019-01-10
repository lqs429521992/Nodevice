-------------------------------------------------------
--                      init.lua                     --
-------------------------------------------------------

-- 3秒后执行程序
print("[init.lua] Run program after 3 seconds.")
-- 执行 wifi_tst.lua 文件
tmr.create():alarm(3000, tmr.ALARM_SINGLE, 
    function()
        dofile("wifi.lua") 
    end
)