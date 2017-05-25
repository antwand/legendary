
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("MainSceneBg.jpg")
        :move(display.center)
        :addTo(self)

    -- add play button
    local playButton = cc.MenuItemImage:create("PlayButton.png", "PlayButton.png")
        :onClicked(function()
            self:getApp():enterScene("PlayScene")
        end)
    cc.Menu:create(playButton)
        :move(display.cx, display.cy - 200)
        :addTo(self)

	local rootNode = cc.CSLoader:createNode("OperateUI.csb");
	self.rootNode = rootNode;
	self:addChild(rootNode);

	local input = rootNode:getChildByName("input");

	local label = input:getVirtualRenderer();
end

return MainScene
