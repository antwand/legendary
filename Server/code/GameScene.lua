require "include.lua"

local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()
    local scene = GameScene.new()
    scene:createLayer()
    return scene
end


function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function GameScene:playBgMusic()
end

-- create layer
function GameScene:createLayer()
	local function sceneUpdate(delta)
		GCCenter.update(delta);
	end

	self:scheduleUpdateWithPriorityLua(sceneUpdate,1)
end

function GameScene:initUI()
    local visibleSize = cc.Director:getInstance():getVisibleSize();
    local msgLabel = cc.Label:createWithTTF("","fonts/simhei.ttf",20);
    msgLabel:setAlignment(0,0);
	msgLabel:setAnchorPoint(0, 0);
	msgLabel:setWidth(visibleSize.width);
	msgLabel:setHeight(visibleSize.height);
	msgLabel:setPosition(0, 0);
    self.msgLabel = msgLabel;
    self:addChild(msgLabel);

	FuncPack:registShowUI(self.msgLabel);
end

function GameScene:showMessage(str)
    local oldStr = self.msgLabel:getString();
	local newStr = oldStr..str.."\n";
	self.msgLabel:setString(newStr);
end

--game logical
function GameScene:getActorInfo(data)
end

return GameScene
