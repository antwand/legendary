local LoadResScene = nil
local LoadResScene = class("LoadResScene",function()
    return cc.Scene:create()
end)

function LoadResScene.create()
    local scene = LoadResScene.new()
    scene:createLayer();
    return scene
end

function LoadResScene:ctor()
    self.plistData = {};
end

function LoadResScene:createLayer()
    local size = cc.Director:getInstance():getVisibleSize();

    local loadBack = engine.initSprite("load_back.png");
    loadBack:setEdging(2, cc.c3b(0,100,0),loadBack:getContentSize());
    loadBack:setPosition(size.width/2, size.height/2);
    self:addChild(loadBack);

    local sp = engine.initSprite("load_bar.png");
    self.loadBar = cc.ProgressTimer:create(sp)
    self.loadBar:setPosition(size.width/2, size.height/2);
    self.loadBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.loadBar:setMidpoint({x=0, y=0.5})
    self.loadBar:setBarChangeRate({x=1, y=0});
    self:addChild(self.loadBar);

    self.loadBar:setPercentage(0);
    self:loadRes();

    local function sceneUpdate(delta)
        self:update(delta);
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    self.sceneUpdate = scheduler:scheduleScriptFunc(sceneUpdate, 1, false);
end

function LoadResScene:playBgMusic()
end

function LoadResScene:update(delta)
    local percent = 1;--AsyncLoadFile.getTaskProgress(threadid);--g_rsyncLoader:getLoadingPercent();

    if percent >= 1 then
		local scheduler = cc.Director:getInstance():getScheduler();
        scheduler:unscheduleScriptEntry(self.sceneUpdate);

        self:startGame();
    end

    self:updateProcessBar(percent);
end

function LoadResScene:updateProcessBar(percent)
    self.loadBar:setPercentage(percent*100);

    --local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    --eventDispatcher:removeEventListener(self.loadResListener);
end

function LoadResScene:loadRes()
    --[[resList =
	{
		"xfile/common",
		--"xfile/objects1",
		--"xfile/SmTiles",
		--"xfile/hum1_0",
		--"xfile/mon3",
		--"xfile/magic2",
		--"xfile/Tiles",
		--"xfile/objects1",
		--"xfile/weapon1"
	}

	threadid = AsyncLoadFile.LoadFile(resList, function(success)
		TraceError("load success");
	end);]]
end

local currIndex = 0;
function LoadResScene:startGame()
    --g_rsyncLoader:release();

	local scene = require("scene.LoginScene")
    local loginScene = scene.create()
    loginScene:playBgMusic()

	cc.Director:getInstance():replaceScene(loginScene)


	--[[
	client = Client:new();

	local data =
	{
		actorsInfo =
		{
			{
				pid = 1,
				name="hero",
				style=1,
				sex=0,
				level=1,
				skill={{skillid=2,level=1},{skillid=1,level=1},{skillid=4,level=1},{skillid=5,level=1}},
				item={},
				equip={{itemid=2,typeid=2}},
				worldid = 1,
				worldpos = {x=178,y=234}
			}
		},
	}

	Account:init(data);

	local scene = require("scene.MainScene")
	local mainScene = scene:create();
	cc.Director:getInstance():replaceScene(mainScene);

	mainScene:enterScene(1)

	Account:selActor(1);
	]]
	--test new sprite init
	--[[
	local asprite = nil;

	local item = cc.MenuItemLabel:create(cc.Label:createWithTTF("test","fonts/Marker Felt.ttf",20))
    item:registerScriptTapHandler(function()
		asprite = engine.readASprite(13);
		asprite:setPosition(400, 400);
		asprite:addTo(self, 0);


		local action = cc.MoveTo:create(10, {x=800,y=600});
		--asprite:runActions({action});
		--asprite:runAction("1");
    end)

	local item2 = cc.MenuItemLabel:create(cc.Label:createWithTTF("test2","fonts/Marker Felt.ttf",20))
    item2:registerScriptTapHandler(function()
		asprite:runAction("1");
    end)

    local menu = cc.Menu:create(item, item2);
    item:setPosition(200,300);
	item2:setPosition(260,300);

    self:addChild(menu);]]
end

return LoadResScene
