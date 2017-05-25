local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

local firstMapId = 5;

function GameScene.create()
    local scene = GameScene.new()
    scene:createLayer()
    return scene
end

function getTextString(label)
	return label:getInputText();
end


function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function GameScene:playBgMusic()
end

-- create layer
function GameScene:createLayer()
	CLIENT_TYPE = 1;

	MapManager:launch();
	self:testMirFunc();
	self:addUI();
	self:initMouseEvent();
end

targetPoint = {x=0,y=0};
function GameScene:initMouseEvent()
	lastX = 0;
	lastY = 0;

	leftMove = false;
	rightMove = false;
	upMove = false;
	downMove = false;

	local xSpeed = 600;
	local ySpeed = 600;

	local function onMouseMove(event)
		local x = event:getCursorX();
		local y = event:getCursorY();

		if isTouchMove then
			if x < 50 then
				leftMove = true;
			else
				leftMove = false;
				--targetPoint.x = targetPoint.x - xSpeed;
			end

			if x > self.visibleSize.width-50 then
				rightMove = true;
				--targetPoint.x = targetPoint.x + xSpeed;
			else
				rightMove = false;
			end

			if y > self.visibleSize.height - 50 then
				upMove = true;
				--targetPoint.y = targetPoint.y + ySpeed;
			else
				upMove = false;
			end

			if y < 50 then
				downMove = true;
				--targetPoint.y = targetPoint.y - xSpeed;
			else
				downMove = false;
			end
		end

		--local position = FuncPack:pointToPosition(targetPoint);
		--self.controlLayer:updateMMap(position);

		lastX = x;
		lastY = y;
	end

	local function sceneUpdate(delta)
		if leftMove then
			targetPoint.x = targetPoint.x - xSpeed*delta;
			self:moveMap(targetPoint);
		end

		if rightMove then
			targetPoint.x = targetPoint.x + xSpeed*delta;
			self:moveMap(targetPoint);
		end

		if upMove then
			targetPoint.y = targetPoint.y + ySpeed*delta;
			self:moveMap(targetPoint);
		end

		if downMove then
			targetPoint.y = targetPoint.y - xSpeed*delta;
			self:moveMap(targetPoint);
		end
	end

	local function onTouchesBegan(touches, events)
        self:onTouchesBegan(touches, events);
    end

	self:scheduleUpdateWithPriorityLua(sceneUpdate,1);

	local listener = cc.EventListenerMouse:create();
    listener:registerScriptHandler(onMouseMove, cc.Handler.EVENT_MOUSE_MOVE)

	local listener2 = cc.EventListenerTouchAllAtOnce:create();
	listener2:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, self);
end

local xOffset = 1;
local yOffset = 1;
local portalList = {};
local monsterList = {};
local npcList = {};
local curMonIdx = 1;
local curMapIdx = 1;
function GameScene:onTouchesBegan(touches, events)
	local point = touches[1]:getLocation();
	local touchMapPoint = self.map:scenePointToMapPoint(point);
	local position = FuncPack:pointToPosition(touchMapPoint);
	local layer = self.map.layer:getMapTile(position.x, position.y);
	local bngIdx = layer:getBngIndex();
	local midIdx = layer:getMidIndex();
	local objIdx = layer:getObjIndex();
	local aniFrame = layer:getAniFrame();
	local aniTick = layer:getAniTick();
	print(tostringex(position).."  bng:"..tostring(bngIdx).."   midIdx:"
		..tostring(midIdx).."   objIdx:"..tostring(objIdx).."   aniframe:"
		..tostring(aniFrame).."   aniTick:"..tostring(aniTick));


	if isAddMonster then
		local objects = self.map:getObjectFromMap(position);
		if objects then
			for k,v in pairs(monsterList) do
				if v.x == position.x and v.y == position.y then
					self.map:removeObject(v.pid);
					monsterList[k] = nil;
				end
			end

			for k,v in pairs(npcList) do
				if v.x == position.x and v.y == position.y then
					self.map:removeObject(v.pid);
					npcList[k] = nil;
				end
			end
		else
			self:addMonster(position);
		end
	end

	if isAddPortal then
		if portalList[position.x.."_"..position.y] then
			portalList[position.x.."_"..position.y].effect:remove();
			portalList[position.x.."_"..position.y] = nil;
		else
			self:addPortal(position);
		end
	end

    return nil;
end

function GameScene:moveMap(targetPos)
	if self.map then
		self.controlLayer:updateMapPosition(targetPos);

		local position = FuncPack:pointToPosition(targetPos);
		self.controlLayer:updateMMap(position);
	end
end


function GameScene:addUI()
	--[[
	local x = et.MyTextField:create(self, "click point x", "fonts/blackSingle.ttf", 25);
	local y = et.MyTextField:create(self, "click point y", "fonts/blackSingle.ttf", 25);
	x:setStringPosition(200, 100);
	y:setStringPosition(200, 30);
	x:setLocalZOrder(100000);
	y:setLocalZOrder(100000);
	x:setColor(255, 100, 0)
	y:setColor(255, 255, 255)
	]]
	--[[
	local item = cc.MenuItemLabel:create(engine.initLabelEx("left",25))
    item:registerScriptTapHandler(function()
		local oldPos = hero:getPositionOfMap();
		--oldPos.x = oldPos.x - xOffset;
		self.map:changeObjectPos(hero:getID(), {x=oldPos.x - xOffset,y=oldPos.y});
		self.controlLayer:showMapTips({x=oldPos.x - xOffset,y=oldPos.y});
    end)

	local item2 = cc.MenuItemLabel:create(engine.initLabelEx("top",25))
    item2:registerScriptTapHandler(function()
		local oldPos = hero:getPositionOfMap();
		self.map:changeObjectPos(hero:getID(), {x=oldPos.x ,y=oldPos.y + yOffset});
		self.controlLayer:showMapTips({x=oldPos.x ,y=oldPos.y + yOffset});
    end)

	local item3 = cc.MenuItemLabel:create(engine.initLabelEx("right",25))
    item3:registerScriptTapHandler(function()
		local oldPos = hero:getPositionOfMap();
		self.map:changeObjectPos(hero:getID(), {x=oldPos.x + xOffset,y=oldPos.y});
		self.controlLayer:showMapTips({x=oldPos.x + xOffset,y=oldPos.y});
    end)

	local item4 = cc.MenuItemLabel:create(engine.initLabelEx("down",25))
    item4:registerScriptTapHandler(function()
		local oldPos = hero:getPositionOfMap();
		self.map:changeObjectPos(hero:getID(), {x=oldPos.x,y=oldPos.y - yOffset});
		self.controlLayer:showMapTips({x=oldPos.x,y=oldPos.y - yOffset});
    end)

	local x = -300;
	local y = -200;
	local dis = 50;
    local menu = cc.Menu:create(item, item2, item3,item4);
    item:setPosition(x - dis,y);
    item2:setPosition(x, y+dis);
	item3:setPosition(x + dis, y);
	item4:setPosition(x, y-dis);
    self:addChild(menu,1000000);]]

	local result = require("ui/Editor.lua").create();
	self.root = result["root"];
	self:addChild(result["root"], 100000000);
	--[[
	local leftBtn = result["root"]:getChildByName("leftBtn");
	leftBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			local oldPos = hero:getPositionOfMap();
			self.map:changeObjectPos(hero:getID(), {x=oldPos.x - xOffset,y=oldPos.y});
			self.controlLayer:showMapTips({x=oldPos.x - xOffset,y=oldPos.y});
        end
    end);

	local topBtn = result["root"]:getChildByName("topBtn");
	topBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			local oldPos = hero:getPositionOfMap();
			self.map:changeObjectPos(hero:getID(), {x=oldPos.x ,y=oldPos.y + yOffset});
			self.controlLayer:showMapTips({x=oldPos.x ,y=oldPos.y + yOffset});
        end
    end);

	local rightBtn = result["root"]:getChildByName("rightBtn");
	rightBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			local oldPos = hero:getPositionOfMap();
			self.map:changeObjectPos(hero:getID(), {x=oldPos.x + xOffset,y=oldPos.y});
			self.controlLayer:showMapTips({x=oldPos.x + xOffset,y=oldPos.y});
        end
    end);

	local downBtn = result["root"]:getChildByName("downBtn");
	downBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			local oldPos = hero:getPositionOfMap();
			self.map:changeObjectPos(hero:getID(), {x=oldPos.x,y=oldPos.y - yOffset});
			self.controlLayer:showMapTips({x=oldPos.x,y=oldPos.y - yOffset});
        end
    end);
	]]
	local posX = result["root"]:getChildByName("posX");
	local posY = result["root"]:getChildByName("posY");
	--local MonText = result["root"]:getChildByName("MonText");
	local InfoText = result["root"]:getChildByName("InfoText");
	local AiText = result["root"]:getChildByName("AiText");
	local ReviveText = result["root"]:getChildByName("ReviveText");
	local AlertAreaText = result["root"]:getChildByName("AlertAreaText");
	local campLabel = result["root"]:getChildByName("campLabel");

	local str = "1"--,MonsterBaseAI,100,100,,";
	--MonText:setString("6");
	AiText:setText("MonsterBaseAI");
	ReviveText:setText("1000");
	AlertAreaText:setText("10");
	campLabel:setText("2");

	local ChangePosBtn = result["root"]:getChildByName("ChangePosBtn");
	ChangePosBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			--local str = posText:getInputText();
			--local strList = split(str, ",");
			local x = tonumber(getTextString(posX));
			local y = tonumber(getTextString(posY));
			local mapPos = {x=x,y=y};
			targetPoint = FuncPack:PositionTopoint(mapPos);
			--self.controlLayer:updateMap();

			--add info
			InfoText:setString("切换位置成功:"..mapPos.x..","..mapPos.y);
			self:moveMap(targetPoint);
			--InfoText:setString(reason);
        end
    end);

	local AddMonBtn = result["root"]:getChildByName("AddMonBtn");
	AddMonBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			--local pos = hero:getPositionOfMap();
			if isAddMonster then
				AddMonBtn:setTitleText("开启怪物添加");
				isAddMonster = nil;
			else
				AddMonBtn:setTitleText("暂停怪物添加");
				isAddMonster = true;
			end
			--self:addMonster(pos);
        end
    end);

	local AddPortalBtn = result["root"]:getChildByName("AddPortalBtn");
	AddPortalBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			--local TargetMapIdText = result["root"]:getChildByName("TargetMapIdText");
			--local TargetMapPosText = result["root"]:getChildByName("TargetMapPosX");
			if isAddPortal then
				AddPortalBtn:setTitleText("开启门添加");
				isAddPortal = nil;
			else
				AddPortalBtn:setTitleText("暂停门添加");
				isAddPortal = true;
			end
		end
	end);

	local saveBtn = result["root"]:getChildByName("SaveBtn");
	saveBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			--save monster
			local filename = self.map:getConf().sz_monster_distribute;
			local file = io.open("res/"..filename, "w");
			file:write("id\tx\ty\tsz_aiScript\tstyle\treviveTime\talertArea\tsz_skill\tcamp\n");
			for k,v in pairs(monsterList) do
				v.sz_skill = v.sz_skill or "";
				file:write(k.."\t"..v.x.."\t"..v.y.."\t"..v.ai.."\t"..v.style.."\t"..v.reviveTime.."\t"..v.alertArea.."\t"..v.sz_skill.."\t"..v.camp.."\n");
			end
			file:close();

			--save portal
			local filename2 = self.map:getConf().sz_portal_conf;
			local file2 = io.open("res/"..filename2, "w");
			file2:write("id\tx\ty\tTargetMapId\tTargetX\tTargetY\n");

			local id = 1;
			for k,v in pairs(portalList) do
				--print("portal "..k..":"..tostringex(v));
				file2:write(id.."\t"..v.x.."\t"..v.y.."\t"..v.mapId.."\t"..v.targetX.."\t"..v.targetY.."\n");
				id = id + 1;
			end
			file2:close();

			--save npc
			local filename3 = self.map:getConf().sz_npc_conf;

			local file3 = io.open("res/"..filename3, "w");
			file3:write("id\tstyle\tx\ty\n");
			for k,v in pairs(npcList) do
				print(tostringex(v));
				file3:write(v.id.."\t"..v.style.."\t"..v.x.."\t"..v.y.."\n");
			end
			file3:close();

			InfoText:setString("res/"..filename..",".."res/"..filename2..",res/"..filename3.." 保存配置成功");
        end
    end);

	local changeMap = result["root"]:getChildByName("changeMap");
	changeMap:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:replaceMap(curMapIdx, nil, hero);
		end
	end);

	local beginMoveBtn = result["root"]:getChildByName("beginMoveBtn");
	beginMoveBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			if isTouchMove then
				beginMoveBtn:setTitleText("开启移动");
				isTouchMove = nil;
			else
				beginMoveBtn:setTitleText("暂停移动");
				isTouchMove = true;
			end
		end
	end);

end

function GameScene:addPortal(pos)
	--local posX = self.root:getChildByName("posX");
	--local posY = self.root:getChildByName("posY");
	local InfoText = self.root:getChildByName("InfoText");
	local AiText = self.root:getChildByName("AiText");
	local ReviveText = self.root:getChildByName("ReviveText");
	local AlertAreaText = self.root:getChildByName("AlertAreaText");

	local TargetMapPosX = self.root:getChildByName("TargetMapPosX");
	local TargetMapPosY = self.root:getChildByName("TargetMapPosY");

	--local strList = split(TargetMapPosText:getInputText(), ",");
	local targetX = tonumber(getTextString(TargetMapPosX))--strList[1];
	local targetY = tonumber(getTextString(TargetMapPosY))---strList[2];
	local mapId = curMapIdx;

	if not targetX or not targetY then
		InfoText:setString("目标地图坐标没有填写");
		return;
	end

	local ret,reason = self:createPortal(pos.x, pos.y, mapId, targetX, targetY);
	if not ret then
		InfoText:setString(reason);
	else
		InfoText:setString("("..pos.x..","..pos.y..") 加入传送门成功("..tostring(targetX)..","..tostring(targetY)..") at "..curMapIdx);
		--print("加入传送门成功("..targetX..","..tostring(targetY)..") at "..curMapIdx);
	end
end

function GameScene:addMonster(pos)
	local posX = self.root:getChildByName("posX");
	local posY = self.root:getChildByName("posY");
	local InfoText = self.root:getChildByName("InfoText");
	local AiText = self.root:getChildByName("AiText");
	local ReviveText = self.root:getChildByName("ReviveText");
	local AlertAreaText = self.root:getChildByName("AlertAreaText");
	local campLabel = self.root:getChildByName("campLabel");

	local ret = self.map:hasObstacle(pos);

	if ret == 1 then
		InfoText:setString("x:"..pos.x..",y:"..pos.y.." 有障碍物");
	elseif ret then
		local isHasOther = false;
		for k,v in pairs(ret) do
			if v:getID() ~= hero:getID() then
				isHasOther = true;
				break;
			end
		end

		if isHasOther then
			InfoText:setString("x:"..pos.x..",y:"..pos.y.." 有其他怪物");
		else
			local canWalk = self.map:getCanWalk(pos);

			if canWalk then
				local style = tonumber(curMonIdx);
				local ai = getTextString(AiText);
				local reviveTime = tonumber(getTextString(ReviveText))
				local alertArea = tonumber(getTextString(AlertAreaText));
				local camp = tonumber(getTextString(campLabel));

				--table.insert(monsterList, #monsterList+1, );
				self:addObject({x=pos.x,y=pos.y, style=tonumber(style), ai=ai,reviveTime=tonumber(reviveTime), alertArea=alertArea,camp=camp});
			else
				InfoText:setString("x:"..pos.x..",y:"..pos.y.." 有障碍物");
			end
		end
	else
		local style = tonumber(curMonIdx);
		local ai = getTextString(AiText);
		local reviveTime = tonumber(getTextString(ReviveText))
		local alertArea = tonumber(getTextString(AlertAreaText));
		local camp = tonumber(getTextString(campLabel));

		--table.insert(monsterList, #monsterList+1, );
		self:addObject({x=pos.x,y=pos.y, style=tonumber(style), ai=ai,reviveTime=tonumber(reviveTime), alertArea=alertArea, camp=camp});
	end
end

function GameScene:addObject(data)
	if data.style > #ActorConf then
		data.style = data.style - #ActorConf;
		self:addNPC(data);
	else
		self:addMon(data);
	end
end

function GameScene:addMon(data)
	data.skill = {};
	data.item={};
	data.equip={};
	data.level = 1;
	data.exc = 0;

	local monster = ActorManager:createMonster(data);
	data.pid = monster:getID();
	table.insert(monsterList, #monsterList+1, data);

	self.map:addObject(monster, {x=data.x, y=data.y});

	local InfoText = self.root:getChildByName("InfoText");
	InfoText:setString("加入怪物成功");
end

function GameScene:addNPC(v)
	v.skill = {};
	v.item={};
	v.equip={};
	v.level = 1;
	v.exc = 0;

	local monster = ActorManager:createNPC(v);
	local ret = self.map:addObject(monster, {x=v.x, y=v.y});

	if ret then
		table.insert(npcList, #npcList+1, {id=#npcList+1,
			x=v.x, y=v.y, style=v.style, isNPC=true,pid=monster:getID()});
	else
		print("add npc failed");
	end
end

function GameScene:updateMap(position)
	self.controlLayer:setSceneScrollPosition(position);
	self.controlLayer.map:show();
end

function GameScene:addItemUI()
	local item = cc.MenuItemLabel:create(cc.Label:createWithTTF("stand","fonts/blackSingle.ttf",14))
    item:registerScriptTapHandler(function()
		--hero:getDamage(1, 10, "magicShield");
		playerData.pid = playerData.pid + 1;
		hero2 = ActorManager:createActor(playerData)
		local scriptCache = ScriptCache:create();
		hero2:addScript("scriptCache", scriptCache);

		hero2:executeScript("scriptCache", {id=4});

		self.map:addObject(hero2, {x=201, y=201});
    end)

    local item2 = cc.MenuItemLabel:create(cc.Label:createWithTTF("climb","fonts/blackSingle.ttf",14))
    item2:registerScriptTapHandler(function()
		local data = {id=1, isRun=0, dir=5};
		hero2:executeScript("scriptCache", data);
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

local uiLayer = nil;
function GameScene:testMirFunc()
	self.controlLayer = ControlLayer:new();
	self.controlLayer:init();
	self:addChild(self.controlLayer, LayerzOrder.UI);

	uiLayer = UILayer:new();
	self:addChild(uiLayer, 1);

	playerData =
    {
		hairId = 65,
	    exc = 500,
		gold = 0,
		pid=1,
        name="hero",
        style=1,
        sex=0,
        level=1,
        skill={{skillid=9,level=1},{skillid=8,level=1},{skillid=4,level=1},{skillid=5,level=1},{skillid=3,level=1},{skillid=6,level=1}},
		--
        item={},
        equip={}
		--{itemid=2,typeid=3},{itemid=3,typeid=4}{itemid=1,typeid=18},{itemid=2,typeid=3}
    }

    local playerData2 =
    {
		pid=2,
        name="hero2",
        style=1,
        sex=0,
        level=1,
        skill={{skillid=1,level=1},{skillid=5,level=1},{skillid=3,level=1}},
        item={},
        equip={}
    }

    hero = ActorManager:createActor(playerData)--hero:stand();
	--hero:appear();

	local scriptCache = ScriptCache:create();
	hero:addScript("scriptCache", scriptCache);

	local item = ItemManager:getItem({itemid=20, typeid=4});
	hero:addItem(item);

	for i=21,51 do
		--item = ItemManager:getItem({itemid=i, typeid=i});
		--hero:addItem(item);
	end

	self:enterMap(firstMapId, {x=50,y=70}, hero);

	--[[
	self:initMap(firstMapId, function(map)
		print("init map end");
		self.map:addObject(hero, {x=50, y=70});

		--uiLayer:setPlayer(hero);
		self.controlLayer:setMap(self.map);
		self.controlLayer:updateMap();

		uiLayer:setPlayer(hero);
		Account:setCurrActor(hero);

		self.controlLayer:updateMap();

		--local pos = hero:getPosition();

		local item = ItemManager:getItem({itemid=20, typeid=4});
		self.map:addItem(item, {x=200, y=200});

		engine.dispachEvent("UPDATE_BottomUI", hero);

		local treeTile = self.map.layer:getMapTile(272, 78);
		local bngIndex = treeTile:getBngIndex();
		local midIndex = treeTile:getMidIndex();
		local objIndex = treeTile:getObjIndex();
		print("bng:"..bngIndex.."  mid:"..midIndex.."  obj:"..objIndex.."   objindex:"..treeTile:getObjFileIndex());

		self.controlLayer:updateMap();

		self:initMonster(self.map);
		self:initPortal(self.map);
    end);]]
end

function GameScene:initMonster(map)
	lastMapLabel = nil;
	lastMonLabel = nil;
	--init mon List
	local monList = self.root:getChildByName("monList");
	local mapList = self.root:getChildByName("mapList");
	monList:removeAllItems();
	mapList:removeAllItems();

	for k, v in pairs(ActorConf) do
		local name = v.id..":"..v.sz_name;

		local label = ccui.Text:create();
		label:setString(name);
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			curMonIdx = v.id;

			if lastMonLabel then
				lastMonLabel:setColor({r=255, g=255, b=255});
			end

			lastMonLabel = label;
			label:setColor({r=255, g=0, b=0});
		end);

		monList:insertCustomItem(label, v.id-1);
	end

	for k, v in pairs(MapConf) do
		local name = v.id..":"..v.sz_name;

		local label = ccui.Text:create();
		label:setString(name);
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			curMapIdx = v.id;

			if lastMapLabel then
				lastMapLabel:setColor({r=255, g=255, b=255});
			end

			lastMapLabel = label;
			label:setColor({r=255, g=0, b=0});
		end);

		mapList:insertCustomItem(label, v.id-1);
	end

	monsterList = {};

	local conf = map:getConf();
	local monsterConf = readTabFile(conf.sz_monster_distribute);

	if monsterConf then
		for k,v in pairs(monsterConf) do
			v.skill = {};
			v.item={};
			v.equip={};
			v.level = 1;
			v.exc = 0;

			local monster = ActorManager:createMonster(v);
			map:addObject(monster, {x=v.x, y=v.y});

			table.insert(monsterList, #monsterList+1, {pid=monster:getID(),
				x=v.x, y=v.y, style=v.style, ai=v.sz_aiScript,
				reviveTime=v.reviveTime, alertArea=v.alertArea,
				sz_skill=v.sz_skill, camp=v.camp});
		end
	end

	--sz_npc_conf
	local mapNpcConf = _readTabFile(conf.sz_npc_conf);

	if mapNpcConf then
		for k,v in pairs(mapNpcConf) do
			self:addNPC(v, map);
		end
	end

	--add npc
	for k,v in pairs(npcConf) do
		local name = (#ActorConf + v.id)..":"..v.sz_name.."(npc)";

		local label = ccui.Text:create();
		label:setString(name);
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			curMonIdx = (#ActorConf + v.id);

			if lastMonLabel then
				lastMonLabel:setColor({r=255, g=255, b=255});
			end

			lastMonLabel = label;
			label:setColor({r=255, g=0, b=0});
		end);

		monList:insertCustomItem(label, #ActorConf + v.id-1);
	end
end

function GameScene:initPortal(map)
	lastDoorLabel = nil;
	local doorList = self.root:getChildByName("doorList");
	doorList:removeAllItems();
	local count = map.layer:getPortalCount();

	for i=1, count do
		local pos = map.layer:getPortal(i-1);
		--print("portal point:("..pos.x..","..pos.y..")");

		local name = "("..pos.x..","..pos.y..")";

		local label = ccui.Text:create();
		label:setString(name);
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			if lastDoorLabel then
				lastDoorLabel:setColor({r=255, g=255, b=255});

				local posX = self.root:getChildByName("posX");
				local posY = self.root:getChildByName("posY");
				posX:setText(pos.x);
				posY:setText(pos.y);
			end

			lastDoorLabel = label;
			label:setColor({r=255, g=0, b=0});
		end);


		doorList:insertCustomItem(label, i - 1);
	end

	portalList = {};

	local conf = map:getConf();
	local portalConf = _readTabFile(conf.sz_portal_conf);

	if not portalConf then
		return "";
	end

	for k,v in pairs(portalConf) do
		local name = "("..v.x..","..v.y..") from conf";

		local label = ccui.Text:create();
		label:setString(name);
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			if lastDoorLabel then
				lastDoorLabel:setColor({r=255, g=255, b=255});

				local posX = self.root:getChildByName("posX");
				local posY = self.root:getChildByName("posY");
				posX:setText(v.x);
				posY:setText(v.y);
			end

			lastDoorLabel = label;
			label:setColor({r=255, g=0, b=0});
		end);


		doorList:insertCustomItem(label, count + k - 1);

		self:createPortal(v.x, v.y, v.TargetMapId, v.TargetX, v.TargetY);
	end
end

function GameScene:createPortal(x, y, mapId, targetX, targetY)
	if portalList[x.."_"..y] then
		return false, "has already portal";
	end

	local effect = EffectManager:getEffect(67);
	effect:runAction("1");
	effect:setPosition(x*TILE_WIDTH, y*TILE_HEIGHT);
	effect:addTo(self.map.layer, LayerzOrder.SKILL);

	portalList[x.."_"..y] = {x=x,y=y,mapId=mapId, targetX=targetX, targetY=targetY, effect=effect}

	return true;
end

function GameScene:initMap(worldid, callfunc)
	self.map = MapManager:getMap(worldid, callfunc);
	self.map:addTo(self, LayerzOrder.MAP);
end

function GameScene:mir()
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

	--mirLoader:asyncReadMirActionSprite("data/Hum.wzl", 0, 600, 3);
	--mirLoader:asyncReadMirActionSprite("data/Hum.wzl", 0, 1200, 3);
	--mirLoader:asyncReadMirActionSprite("data/Weapon.wzl", 0, 1200, 3);
	--sprite:setPosition(200, 200);
	--sprite:runStateAni(4);
	--self:addChild(sprite);
	--[[
	local animation = v:getAnimation();
		local animationframe = animation:getFrames()[1]
		local spriteFrame = animationframe:getSpriteFrame();
		local offsetStr = spriteFrame:getOffset();
		self.sprite:setSpriteFrame(spriteFrame);
	]]
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

function GameScene:enterMap(mapid, mapPos, hero)
	self:initMap(mapid, function(map)
		mapPos = mapPos or map:getRandomPosition();
		--self.map:addObject(hero, mapPos);
		map.layer:setShowTileDetail(true);
		--uiLayer:setPlayer(hero);

		self.controlLayer:setMap(map);
		self.controlLayer:updateMap();

		--uiLayer:setPlayer(hero);
		--Account:setCurrActor(hero);

		--local pos = hero:getPosition();

		--local item = ItemManager:getItem({itemid=20, typeid=4});
		--self.map:addItem(item, {x=200, y=200});

		engine.dispachEvent("UPDATE_BottomUI", hero);

		--local treeTile = self.map.layer:getMapTile(272, 78);
		--local bngIndex = treeTile:getBngIndex();
		--local midIndex = treeTile:getMidIndex();
		--local objIndex = treeTile:getObjIndex();
		--print("bng:"..bngIndex.."  mid:"..midIndex.."  obj:"..objIndex.."   objindex:"..treeTile:getObjFileIndex());

		self.controlLayer:updateMap();

		self.map = map;
		self:initMonster(self.map);
		self:initPortal(self.map);

		--uiLayer:registInput();

		local mapPos = FuncPack:PositionTopoint(mapPos);
		self:moveMap(mapPos);
		targetPoint = mapPos;
    end);
end

function GameScene:replaceMap(newMapid, mapPos, actor)
	if self.map then
		self.map:removeObject(actor:getID());
		MapManager:destroyMap(self.map:getID());

		self.map = nil;
	end

	--uiLayer:unRegistInput();
	self.controlLayer:setMap(nil);
	self:enterMap(newMapid, mapPos, actor);
end



return GameScene
