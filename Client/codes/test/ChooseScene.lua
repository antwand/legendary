local ChooseScene = class("ChooseScene",function()
    return cc.Scene:create()
end)

function ChooseScene.create()
    local scene = ChooseScene.new()
    scene:createLayer()
    return scene
end


function ChooseScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function ChooseScene:playBgMusic()
end

function ChooseScene:createLayer()
	local item = cc.MenuItemLabel:create(engine.initLabelEx("MapEditor",25))
    item:registerScriptTapHandler(function()
		local scene = require("test/GameScene.lua")
		local gameScene = scene.create()

		if cc.Director:getInstance():getRunningScene() then
			cc.Director:getInstance():replaceScene(gameScene)
		else
			cc.Director:getInstance():runWithScene(gameScene)
		end
    end)

	local item2 = cc.MenuItemLabel:create(engine.initLabelEx("LoginScene",25))
    item2:registerScriptTapHandler(function()
		local scene = require("scene.LoadResScene.lua")
		local gameScene = scene.create()

		if cc.Director:getInstance():getRunningScene() then
			cc.Director:getInstance():replaceScene(gameScene)
		else
			cc.Director:getInstance():runWithScene(gameScene)
		end
    end)

	local item3 = cc.MenuItemLabel:create(engine.initLabelEx("TestSingerPlayer",25))
    item3:registerScriptTapHandler(function()
		local scene = require("test/TestScene.lua")
		local gameScene = scene.create()

		if cc.Director:getInstance():getRunningScene() then
			cc.Director:getInstance():replaceScene(gameScene)
		else
			cc.Director:getInstance():runWithScene(gameScene)
		end
    end)

    local menu = cc.Menu:create(item, item2, item3);
    item:setPosition(0, 0);
    item2:setPosition(0, -50);
	item3:setPosition(0, 50);
    self:addChild(menu);
end


return ChooseScene
