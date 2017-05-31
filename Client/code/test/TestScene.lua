local TestScene = class("TestScene",function()
    return BaseScene:create()
end)

local firstMapId = 1

function TestScene.create()
    local scene = TestScene.new()
    scene:createLayer()
    return scene
end


function TestScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function TestScene:playBgMusic()
end

-- create layer
function TestScene:createLayer()

	CLIENT_TYPE = 1;

	MapManager:launch();

	self:testMirFunc();
end

local xOffset = 1;
local yOffset = 1;
local monsterList = {};
function TestScene:addUI()
	local item = cc.MenuItemLabel:create(engine.initLabelEx("left",25))
    item:registerScriptTapHandler(function()
		engine.dispachEvent("UI_SHOW_TALKING_WINDOW", {talkId=1});
    end)

	local item2 = cc.MenuItemLabel:create(engine.initLabelEx("playShadow2",25))
    item2:registerScriptTapHandler(function()
		local point = hero:getPosition();
		hero:changeStatus(3);
		local a1 = cc.MoveTo:create(0.5, {x=point.x,y=point.y-64});
		local a2 = cc.MoveTo:create(0.5, {x=point.x,y=point.y});
		local actions = {a1, a2};
		--local aList = cc.RepeatForever:create(cc.Sequence:create(actions));
		hero:runActions(actions);

		hero:setShaderEnable(true);
    end)

	local item3 = cc.MenuItemLabel:create(engine.initLabelEx("right",25))
    item3:registerScriptTapHandler(function()
		local oldPos = hero:getPositionOfMap();
		self.map:changeObjectPos(hero:getID(), {x=oldPos.x + xOffset,y=oldPos.y});
		self.controlLayer:showMapTips({x=oldPos.x + xOffset,y=oldPos.y});
    end)

	local item4 = cc.MenuItemLabel:create(engine.initLabelEx("playShadow",25))
    item4:registerScriptTapHandler(function()
		--hero:changeStatus(3);
		local point = hero2:getPosition();

		local a1 = cc.MoveTo:create(0.5, {x=point.x,y=point.y+64});
		local a2 = cc.MoveTo:create(0.5, {x=point.x,y=point.y});
		local actions = {a1, a2};
		--local aList = cc.RepeatForever:create(cc.Sequence:create(actions));
		hero2:runActions(actions);

		hero2:setShaderEnable(true);
    end)

	local x = -300;
	local y = -200;
	local dis = 50;
    local menu = cc.Menu:create(item, item2, item3,item4);
    item:setPosition(x - dis,y);
    item2:setPosition(x, y+dis);
	item3:setPosition(x + dis, y);
	item4:setPosition(x, y-dis);
    self:addChild(menu,1000000);
end

function TestScene:addMon(data)
	data.skill = {};
	data.item={};
	data.equip={};
	data.level = 1;
	data.exc = 0;

	local monster = ActorManager:createMonster(data);
	self.map:addObject(monster, {x=data.x, y=data.y});

	table.insert(monsterList, #monsterList+1, data);

	local InfoText = self.root:getChildByName("InfoText");
	InfoText:setString("加入怪物成功");
end

function TestScene:updateMap(position)
	self.controlLayer:setSceneScrollPosition(position);
	self.controlLayer.map:show();
end

local _x = 160;
local _y = 205;
function TestScene:addItemUI()
	local item = cc.MenuItemLabel:create(cc.Label:createWithTTF("setEffect","fonts/blackSingle.ttf",14))
    item:registerScriptTapHandler(function()
		local playerData2 =
		{
			camp = 1,
			pid=2224,
			name="hero2",
			style=6,
			sex=0,
			level=1,
			skill={{skillid=1,level=1},{skillid=5,level=1},{skillid=3,level=1}},
			item={},
			equip={}
		}

		local mon = ActorManager:createActor(playerData2);
		self.map:addObject(mon, {x=_x, y=_y});
		mon:appear();

		_x = _x + 1;
    end)

    local item2 = cc.MenuItemLabel:create(cc.Label:createWithTTF("setEffect2","fonts/blackSingle.ttf",14))
    item2:registerScriptTapHandler(function()
		asprite:setEffect(0);
    end)

	local item3 = cc.MenuItemLabel:create(cc.Label:createWithTTF("appear","fonts/blackSingle.ttf",14))
    item3:registerScriptTapHandler(function()
		for i=1,10 do
			local data = {id=1, isRun=0, dir=5};
			hero:executeScript("scriptCache", data);
		end

		for i=1,20 do
			local data = {id=2, skillName="slash", values=2};
			hero:executeScript("scriptCache", data);
		end
    end)

	local item4 = cc.MenuItemLabel:create(cc.Label:createWithTTF("attack","fonts/blackSingle.ttf",14))
    item4:registerScriptTapHandler(function()
		hero:slash(hero:getDir());

    end)

    local menu = cc.Menu:create(item, item2, item3,item4);
    item:setPosition(0,120);
    item2:setPosition(100,120);
	item3:setPosition(300, 120);
	item4:setPosition(-40, 120);
    self:addChild(menu,10000);

	print("---------------------item menu-------------------");
end

function TestScene:testMirFunc()
	self.controlLayer = ControlLayer:new();
	self.controlLayer:init();
	self:addChild(self.controlLayer, LayerzOrder.UI);

	local uiLayer = UILayer:new();
	self:addChild(uiLayer, 1);

	playerData =
    {
		pid = 1,
	    exc = 500,
		gold = 0,
		pid=1,
        name="今天就要嫁给你",
        style=1,
        sex=0,
        level=11,
        skill={{skillid=12,level=1,exp=0},{skillid=3,level=1,exp=0},{skillid=4,level=1,exp=0},{skillid=5,level=1,exp=0},{skillid=6,level=1,exp=0},{skillid=7,level=1,exp=0},
		{skillid=1,level=1,exp=0},{skillid=8,level=1,exp=0},{skillid=10,level=1,exp=0}},
		--
        item={},
        equip={}
		--{itemid=2,typeid=3},{itemid=3,typeid=4}{itemid=1,typeid=18},{itemid=2,typeid=3}
    }

    local playerData2 =
    {
		camp = 3,
		pid=2222,
        name="hero2",
        style=1,
        sex=0,
        level=1,
        skill={{skillid=1,level=1},{skillid=5,level=1},{skillid=3,level=1}},
        item={},
        equip={}
    }

    hero = ActorManager:createActor(playerData, 1)--hero:stand();
	--hero:appear();

	TraceError("hero: "..tostring(hero));

	local item = ItemManager:getItem({itemid=20, typeid=4});
	hero:addItem(item);

	local scriptCache = ScriptCache:create();
	hero:addScript("scriptCache", scriptCache);

	for i=#EquipmentConf - 10,#EquipmentConf do
		local _time = FuncPack:gettime();
		item = ItemManager:getItem({itemid=i, typeid=54});
		hero:addItem(item);

		TraceError("create 1 item for "..(FuncPack:gettime()-_time));
	end

	self:initMap(firstMapId, function(map)
		print("init map end");
		local npc = ActorManager:createActor(playerData2);
		self.map:addObject(hero, {x=170, y=200});
		self.map:addObject(npc, {x=170, y=206});

		--uiLayer:setPlayer(hero);
		self.controlLayer:setMap(self.map);
		self.controlLayer:updateMap();

		uiLayer:setPlayer(hero);
		Account:setCurrActor(hero);

		self.controlLayer:updateMap();

		--local pos = hero:getPosition();

		engine.dispachEvent("UPDATE_BottomUI", hero);

		local treeTile = self.map.layer:getMapTile(272, 78);
		local bngIndex = treeTile:getBngIndex();
		local midIndex = treeTile:getMidIndex();
		local objIndex = treeTile:getObjIndex();
		print("bng:"..bngIndex.."  mid:"..midIndex.."  obj:"..objIndex.."   objindex:"..treeTile:getObjFileIndex());

		--self.controlLayer:showMapTips(hero:getPositionOfMap(), hero);

		self:initMonster(self.map);

		engine.dispachEvent("SHOW_MESSAGE", {content="+------------------------------------------------+",type="+"});
		engine.dispachEvent("SHOW_MESSAGE", {content="+------------------------------------------------+",type="+"});
		engine.dispachEvent("SHOW_MESSAGE", {content="+------------------------------------------------+",type="+"});
		engine.dispachEvent("SHOW_MESSAGE", {content="+------------欢迎来到传奇世界------------+",type="+"});
		engine.dispachEvent("SHOW_MESSAGE", {content="+------------------------------------------------+",type="+"});
		engine.dispachEvent("SHOW_MESSAGE", {content="+------------------------------------------------+",type="+"});
		engine.dispachEvent("SHOW_MESSAGE", {content="+------------------------------------------------+",type="+"});

		------------------------

    end);
end

function TestScene:initMonster(map)
	local conf = map:getConf();
	local monsterConf = readTabFile(conf.sz_monster_distribute);

	if not monsterConf then
		return "";
	end

	local index = 0;
	for k,v in pairs(monsterConf) do
		v.pid = 100000 + index;
		v.skill = {};
		v.item={};
        v.equip={};
		v.level = 1;
		v.exc = 0;

		local monster = ActorManager:createMonster(v);
		map:addObject(monster, {x=v.x, y=v.y});

		table.insert(monsterList, #monsterList+1, {x=v.x, y=v.y, style=v.style, ai=v.sz_aiScript,reviveTime=v.reviveTime, alertArea=v.alertArea, sz_skill=v.sz_skill});

		index = index + 1;
	end
end

function TestScene:initMap(worldid, callfunc)
	self.map = MapManager:getMap(worldid, callfunc);
	print(worldid.." :"..tostring(self.map));
	self.map:addTo(self, LayerzOrder.MAP);
end

function TestScene:mir()
	AsyncLoadMirFile:start();

	--self:addChild(mirLoader);

	local function func(object)
		print("object:"..tostring(object));
		--hero:setPosition(100, 100);
	end

	local function process_packet(sprite)
		local pos = hero:getPosition();
		sprite:setPosition(200, 400);
		local success = sprite:runStateAni(8);
		self:addChild(sprite);
	end


	local starttime = os.time();
	AsyncLoadMirFile:readMirSpriteX("data/Hum.wzl", 0, 0, function(sprite)
		sprite:setPosition(200, 400);
		sprite:runStateAni(8);
		self:addChild(sprite);
	end)

	AsyncLoadMirFile:readMirSpriteX("data/Hum.wzl", 0, 4800, function(sprite)
		sprite:setPosition(300, 500);
		sprite:runStateAni(4);
		self:addChild(sprite);
	end)

	AsyncLoadMirFile:readMirSpriteX("data/Hum.wzl", 0, 0, function(sprite)
		sprite:setPosition(300, 400);
		sprite:runStateAni(4);
		self:addChild(sprite);
	end)
end

function test(animate)
	local animation = animate:getAnimation();

	for i=1, 4 do
		local animationframe = animation:getFrames()[i]
		local spriteFrame = animationframe:getSpriteFrame();
		local offsetStr = spriteFrame:getOffset();

		print(i.."   offsetStr:"..tostringex(offsetStr));
	end


	engine.readASprite(1);


end

function TestScene:enterMap(mapid, mapPos, actor)
	self:initMap(mapid, function(map)
		map:addObject(actor, mapPos);

		self.controlLayer:setMap(map);
		self.controlLayer:updateMap();
		self.map = map;
    end);
end

function TestScene:replaceMap(newMapid, mapPos, actor)
	if self.map then
		self.map:removeObject(actor:getID());
		MapManager:destroyMap(self.map:getID());
	end

	self.controlLayer:setMap(nil);
	self:enterMap(newMapid, mapPos, actor);
end



return TestScene
