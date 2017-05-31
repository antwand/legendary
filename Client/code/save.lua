--[[监听：
    local eventDispatcher = self:getEventDispatcher()
    local listener = nil

    local function handleBuyGoods(event)
        cclog("handleBuyGoods")
    end
    listener = cc.EventListenerCustom:create("HandleKey.kDidBuyGoods", handleBuyGoods)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
广播：
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local event = cc.EventCustom:new("HandleKey.kDidBuyGoods")
    eventDispatcher:dispatchEvent(event)
    ]]

require "../../../mysql/tools"

local conf = readTabFile("../res/conf/equip/equipment.tab")
