local GameScene = nil

local MainScene = class("MainScene",function()
    return BaseScene:create()
end)

function MainScene.create()
    local scene = MainScene.new()
	scene:init();
    GameScene = scene;
    return scene
end

function MainScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.map = nil;
end

function MainScene:playBgMusic()
end

function MainScene:init()
	self:initUILayer();
	self:initControlLayer();

    --加载地图资源
    MapManager:launch();
end

function MainScene:initControlLayer()
    if not self.controlLayer then
        self.controlLayer = ControlLayer:new();
		self.controlLayer.mainScene = self;
        self:addChild(self.controlLayer, LayerzOrder.UI);
	else
		self:removeChild(self.controlLayer);

		self.controlLayer = ControlLayer:new();
        self:addChild(self.controlLayer, LayerzOrder.UI);
    end
end

function MainScene:initUILayer()
	if not self.uiLayer then
		self.uiLayer = UILayer:new();
		self:addChild(self.uiLayer, LayerzOrder.UI);
	else
		self:removeChild(self.uiLayer);

		self.uiLayer = UILayer:new();
		self:addChild(self.uiLayer, LayerzOrder.UI);
	end
end

function MainScene:enterMap(mapid, mapPos, actor, others, mapItemsData)
	self:initMap(mapid, function(map)
		self.map:addObject(actor, mapPos, true);

		for k,v in pairs(others) do
			--TraceError("v: "..tostringex(v));
			local actor = ActorManager:createActor(v);
			self.map:addObject(actor, {x=v.x, y=v.y});
		end

		for k,v in pairs(mapItemsData) do
			local item = ItemManager:getItem(v);
			self.map:addItem(item, v.position);
		end

		self.uiLayer:setPlayer(actor);

		--init
		self.controlLayer:init();
		self.controlLayer:setMap(self.map);
		self.controlLayer:updateMap();

		if not self.controlLayer.backToChrSelScene then
			TraceError("not exists self.controlLayer.backToChrSelScene");
		end

		engine.dispachEvent("UPDATE_BottomUI", actor);

		actor:idle();
    end);
end

function MainScene:replaceMap(newMapid, mapPos, actor, others, mapItemsData)
	if self.map then
		actor:stopAllActions();
		actor:stopScripts();

		self.map:removeObject(actor:getID());
		MapManager:destroyMap(self.map:getID());
	end

	--clear old event
	client:clearMessageCallBack();
	engine.clearEventListener();

	--respawn new ui controller
	self:initUILayer();
	self:initControlLayer();
	self:enterMap(newMapid, mapPos, actor, others, mapItemsData);
end

function MainScene:initMap(worldid, callfunc)
	self.map = MapManager:getMap(worldid, callfunc);
	self.map:addTo(self, LayerzOrder.MAP);
end

return MainScene
