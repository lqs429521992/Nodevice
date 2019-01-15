---------------------【1.配置信息】-----------------------
client_id=wifi.sta.getmac()
device_type='relay'
cl=nil
-- [1.2 GPIO配置]
pin_led = 0
pin_relay=1
gpio.mode(pin_led,gpio.OUTPUT)
gpio.mode(pin_relay,gpio.OUTPUT)
gpio.write(pin_led,gpio.LOW)
gpio.write(pin_relay,gpio.LOW)

---------------------【2.设备连接】-----------------------
function TcpClient()
    cl = net.createConnection(net.TCP, 0)
    cl:connect(8282, "xn--55qy30c09ad7hkw0e.online")
    cl:on("receive", function(sck, c)
        recv=cjson.decode(c)
        if (recv.obj.id==client_id and recv.obj.type==device_type) then
            if(recv.data.switch=='on') then
                gpio.write(pin_relay,gpio.HIGH)
            else
                if(recv.data.switch=='trig') then
                    if(recv.data.delay==nil) then
                        recv.data.delay==1
                    end
                    gpio.write(pin_relay,gpio.HIGH)
                    tmr.delay(recv.data.delay*1000000)
                    gpio.write(pin_relay,gpio.LOW)
                else
                    gpio.write(pin_relay,gpio.LOW)
                end
            end
            data={}
            data.switch=recv.data.switch
            Send(data,recv.ori)
        end
    end)
    
    cl:on("disconnection", function(sck, c)
    end)
end

function Send(data,ori)
    send={}
    send.ori={}
    send.obj={}
    send.ori.id=client_id
    send.ori.type=device_type
    send.ori.prot='tcp'
    send.obj.id=ori.id
    send.obj.type=ori.type
    send.obj.prot=ori.prot
    send.data=data
    ok, json=pcall(cjson.encode, send)
    if ok then
        cl:send(json)
    else
        print("failed to encode!")
    end
end

function Start()
    print("WiFi Connected, IP is "..wifi.sta.getip())
    TcpClient()
    heartbeat_data={}
    heartbeat_ori={}
    heartbeat_ori.id=client_id
    heartbeat_ori.type=device_type
    heartbeat_ori.prot='heartbeat'
    --[topic 定时上传数据]
    print("start")
    tmr.alarm(0, 1000, 0, function()
        gpio.write(pin_led,gpio.LOW)
        Send(heartbeat_data,heartbeat_ori)
    print("send heartbeat")
    end)
    tmr.alarm(1, 60000, 1, function()    --等待连接上
        if cl~=nil then
            Send(heartbeat_data,heartbeat_ori)
        end
    end)
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    print("WiFi Connected")
    gpio.write(pin_led,gpio.LOW)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    print("WiFi Disconnect")
    gpio.write(pin_led,gpio.HIGH)
    wifi.sta.autoconnect(1)
end)

Start()
