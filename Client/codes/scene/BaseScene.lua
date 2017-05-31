BaseScene = class("BaseScene",function()
    return cc.Scene:create()
end)

function BaseScene.create()
    local scene = BaseScene.new()
    scene:createLayer()
    return scene
end

function BaseScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function BaseScene:createLayer()
	self:initMessageWindow();
	--self:initModelDialog();
end

function BaseScene:initMessageWindow()
	local rootNode = require("ui/BaseUI/MessageWindow.lua").create();
    local window = rootNode['root'];
	self.window = window;
	self:addChild(window, 2);

	local size = cc.Director:getInstance():getWinSize();
	window:setPosition(size.width/2 - 492/2, size.height/2 - 202/2);
	window:setVisible(false);

	local Button = self.window:getChildByName("Button")
	Button:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			window:setVisible(false);
		end
	end);
end

function BaseScene:showMessage(str)
	local content = self.window:getChildByName("content")
	content:setString(str);
	self.window:setVisible(true);
end
