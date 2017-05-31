ControlLayer = class("ControlLayer", function()
    return cc.Node:create();
end)

function ControlLayer:ctor()
end

function ControlLayer:init()
	self:initEvent();
	--self:initUI();

	local function sceneUpdate(delta)
		self:update(delta)
	end

	self:scheduleUpdateWithPriorityLua(sceneUpdate,1)
	self:registMultiTouch();
end

function ControlLayer:initEvent()
	self:initLogicalEvent();

	if client then
		self:initConnectEventListener();
	else
		print("no client can be connected");
	end
end

function ControlLayer:initUI()
	self.testLabel = engine.initLabel("test");
	self.testLabel:setHorizontalAlignment(0);
	self.testLabel:setContentSize(800, 300);
	self.testLabel:setPosition(200, 560);
	self:addChild(self.testLabel);

	--[[
	local item = cc.MenuItemLabel:create(cc.Label:createWithTTF("attack","fonts/Marker Felt.ttf",20))
    item:registerScriptTapHandler(function()
		local hero = Account:getCurrActor();
		hero:changeStatus(5);
    end)

    local item2 = cc.MenuItemLabel:create(cc.Label:createWithTTF("stand","fonts/Marker Felt.ttf",20))
    item2:registerScriptTapHandler(function()
		local hero = Account:getCurrActor();
		hero:slash(hero:getDir());
    end)

    local menu = cc.Menu:create(item, item2);
    item:setPosition(200,200);
    item2:setPosition(300,200);
    self:addChild(menu);]]
end

function ControlLayer:initMMap()
	engine.dispachEvent("UI_INIT_MMAP", {mmapId=self.map:getConf().mmapId,mapId=self.map:getID()});
	engine.dispachEvent("UI_INIT_BIG_MMAP", {mmapId=self.map:getConf().big_mmapId,mapId=self.map:getID()});
end

function ControlLayer:updateMMap(position)
	engine.dispachEvent("UI_UPDATE_MMAP", {mapPos=position, mapSize=self.map.mapSize,isUser=true});
	engine.dispachEvent("UI_UPDATE_BIG_MMAP", {mapPos=position, mapSize=self.map.mapSize,isUser=true});
end

function ControlLayer:updateTestLabel(touches)
	local point = touches[1]:getLocation();
end

function ControlLayer:updateMap()
	local actor = Account:getCurrActor();
    if actor then
        local position = actor:getPosition();
		self:updateMapPosition(position);

		local mapPos = actor:getPositionOfMap();
		self:updateMMap(mapPos);
    end

	--print(debug.traceback());
end

function ControlLayer:setMonitor(target)
	self.target = target;
end

function ControlLayer:updateMapPosition(point)
	if self.map and point then
		self:setSceneScrollPosition(point);
		self.map:show();
	end
end

function ControlLayer:setMap(map)
    self.map = map;

	if map then
		self:initMMap();
	end
end

function ControlLayer:addActorWithPosition(pos)
	--self.uiLayer:getPlayer();

	self.map:addObject(currActor, pos);
	self:updateMap();
end

function ControlLayer:checkMoveMap()
    local actor = Account:getCurrActor();

	--print("actor:"..tostring(actor));
    if actor and actor:checkMove() == true then
        self:setSceneScrollPosition(actor:getPosition());
    end
end

function ControlLayer:update(delta)
	if not self.map then
		return;
	end

    local objectsLayer = self.map:getActorsGroup();
    for k,v in pairs(objectsLayer) do
		local pos = v:getPositionOfMap();

        if v:isDie() == false then
			if pos then
				v:setZOrder(-pos.y + LayerzOrder.ACTOR);
				v:update(delta);
			end
		else
			v:setZOrder(-pos.y + LayerzOrder.DIE);
        end
    end

    self:checkMoveMap();

	TimerManager:update(dt);

    self.map:clearObjList();
end

function ControlLayer:initConnectEventListener()
	--链接中断
	client:addConnectEventListener(NETWORK_EVENT_CLOSE, function()
		Account:release();
		self:destroy();
		self:jumpToLoginScene();
	end);

	client:registMessageCallBack("ACTOR_BACK_TO_CHASEL_SCENE", function(data)
		TraceError("ACTOR_BACK_TO_CHARSEL_SCENE:"..tostringex(data));
		self:backToChrSelScene();
	end);

	client:registMessageCallBack("BC_GAME_ERROR", function(data)
		local pid = data.pid;
		local actor = ActorManager:getActor(pid);

		actor:unLockActorStatus();
		actor:stopAllActions();
		actor:stopScripts();
		actor:die();
	end);

	client:registMessageCallBack("BC_ACTOR_HEAL", function(data)
		if data.ret == 1 then
			local curHp = data.curHp;
			local curMp = data.curMp;
			local pid = data.pid;

			local actor = ActorManager:getActor(pid);
			if actor then
				actor:setHp(curHp);
				actor:setMp(curMp);
			end
		end
	end);

	client:registMessageCallBack("BC_ACTOR_SEND_MESSAGE", function(data)
		local content = data.content;
		local ty = data.type;

		engine.dispachEvent("SHOW_MESSAGE", {content=content, type=ty});
	end);

	client:registMessageCallBack("BC_ACTOR_ADD_NPC", function(data)
		local content = data.content;
		--local npc = ActorManager:createNPC(content);

		engine.dispachEvent("ADD_NPC", {content=content});
	end);


	client:registMessageCallBack("BC_ADD_SKILL", function(data)
		local actor = ActorManager:getActor(data.pid);
		if actor then
			local skillInfo = data.skillInfo;
			local skill = SkillManager:addSkill(skillInfo)
			actor:addSkill(skill);

			engine.dispachEvent("UI_UPDATE_SKILL");
		else
			TraceError("BC_ADD_SKILL no found actor "..data.pid);
		end
	end);

	client:registMessageCallBack("BC_DEL_SKILL", function(data)
		local actor = ActorManager:getActor(data.pid);
		if actor then
			local skillid = data.skillid;
			actor:delSkill(skillid);
		else
			TraceError("BC_ADD_SKILL no found actor "..data.pid);
		end
	end);

	client:registMessageCallBack("BC_ACTOR_DIE", function(data)
		local actor = ActorManager:getActor(data.pid);
		if actor then
			if not actor:isDie() then
				actor:die();
			end
		else
			TraceError("BC_ACTOR_DIE no found actor "..data.pid);
		end
	end);

	client:registMessageCallBack("BC_MON_APPEAR", function(data)
		local monData = data.monData;
		local mon = ActorManager:createActor(monData);

		if mon then
			local map = MapManager:getMap(monData.worldid);
			if map and not mon:getMap() then
				map:addObject(mon, monData.worldpos);
				mon:executeScript("scriptCache", {id=4});
			else
				TraceError("BC_MON_APPEAR failed for map no found"..monData.worldid);
			end

			if data.masterId then
				mon.masterId = data.masterId;
			end
		end
	end);

	client:registMessageCallBack("BC_EXECUTE_CODE", function(data)
		local func = loadstring(data.code);
		func();
	end);

	client:registMessageCallBack("BC_ACTOR_ADD_EXC", function(data)
		--TraceError("BC_ACTOR_ADD_EXC:"..tostringex(data));
		local actor = ActorManager:getActor(data.pid);
		if actor then
			actor:addExc(data.exc);
			--actor:executeScript("scriptCache", data);

			engine.dispachEvent("SHOW_NOTICE", {content="获得经验"..data.exc, type="system"});
		end
	end);

	client:registMessageCallBack("BC_ACTOR_CALL_PET", function(data)
		local actor = ActorManager:getActor(data.actorData.pid);

		if not actor then
			local actorData = data.actorData;
			local newActor = ActorManager:createActor(actorData);
			local map = MapManager:getMap(actorData.worldid);

			if map ~= nil then
				newActor:appear();
				map:addObject(newActor, actorData.worldpos);
			end
		else
			TraceError(data.actorData.pid.." actor already exists, no need to update");
		end
	end);

	client:registMessageCallBack("BC_ACTOR_CHANGE_POSE", function(data)
		--print("BC_ACTOR_CHANGE_POSE:"..tostringex(data));

		local actor = ActorManager:getActor(data.pid);
		if actor then
			data.id = 3;
			actor:executeScript("scriptCache", data);
		end
	end);

	--状态技能关闭诸如魔法盾之类的
	client:registMessageCallBack("BC_BUFFSPELL_CLOSE", function(data)
		local actor = ActorManager:getActor(data.fromid);

		if actor then
			actor:stopSkill(data.skillName);
		else
			TraceError("no found actor:"..fromid.." in BC_BUFFSPELL_CLOSE");
		end
	end);

	--新玩家
	client:registMessageCallBack("BC_UPDATE_NEW_ACTOR", function(data)
		--print("new actor:"..tostringex(data.actorData.pid));
		--local actor = ActorManager:getActor(data.actorData.pid);
		local actorData = data.actorData;
		local actor = ActorManager:createActor(actorData);

		if actor then
			local map = MapManager:getMap(actorData.worldid);

			if map ~= nil then
				map:addObject(actor, actorData.worldpos);
				actor:unLockActorStatus();
				actor:stopAllActions();
				actor:idle();
			end

			for k,v in pairs(actor.parts) do
				local equip = actorData[k];
				if not equip then
					actor:unLoadPartForType(k);
				end
			end

			for k,v in pairs(actorData.equip) do
				local newEquip = ItemManager:getItem(v);
				local oldEquip = actor:getEquip(newEquip:getType());
				local extraContent = 0;

				if k == 6 or k == 8 then
					extraContent = 1;
				end

				if not oldEquip or oldEquip ~= newEquip then
					actor:loadPart(newEquip, extraContent);
				end
			end
		else
			TraceError(actorData.pid.." actor can not be found");
		end
	end);

	--角色离开
	client:registMessageCallBack("BC_ACTOR_LEAVE", function(data)
		local actor = ActorManager:getActor(data.pid);
		TraceError("BC_ACTOR_LEAVE: "..tostringex(data));
		if actor then
			local acPos = actor:getPositionOfMap();
			local map = actor:getMap();
			map:removeObject(data.pid);
		else
			print("BC_ACTOR_LEAVE: no exists actor "..data.pid);
		end
	end);

	--同步机器人移动
	client:registMessageCallBack("BC_ROBOT_MOVE", function(data)
		--print("BC_ROBOT_MOVE:"..tostringex(data));
		local actor = ActorManager:getActor(data.pid);
		local mapPos = actor:getPositionOfMap();

		if FuncPack:isEqualPoint(mapPos,data.pos) == false then
			local map = actor:getMap();
			map:removeObject(actor:getID());
			map:addObject(actor, data.pos);
		end

		--pid=object:getID(), isRun=isRun, dir=dir,pos=object:getPosition();
		data.id = 1;
		actor:executeScript("scriptCache", data);
	end);

	--普通玩家移动
	client:registMessageCallBack("BC_REMOVE_MAP_ITEM", function(data)
		local point = data.point;
		local itemid = data.itemid;
		local map = MapManager:getMap(data.mapid);

		if map then
			local item = map:removeItem(point);

			if item and item:getID() ~= itemid then
				TraceError("BC_REMOVE_MAP_ITEM not match:"..item:getID().."~="..itemid);
			end
		end
	end);

	--普通玩家移动
	client:registMessageCallBack("BC_ACTOR_MOVE", function(data)
		local pid = data.pid;
		local actor = ActorManager:getActor(pid);

		if actor then
			local mapPos = actor:getPositionOfMap();

			if data.pos and FuncPack:getStepBetweenPos(mapPos, data.pos) >= 1 then  --如果移动的位置离当前位置超过2才强制位移，防止延迟导致的同步问题
				local map = actor:getMap();

				if map then
					map:changeObjectPos(actor:getID(), data.pos);

					actor:unLockActorStatus();
					actor:stopAllActions();
					--actor:stopScripts();
					actor:idle();
				else
					TraceError("no found actor "..pid..":"..actor:getName().." 's map");
				end
			end

			data.id = 1;

			if actor:isDie() then
				actor:revive();
			end

			actor:executeScript("scriptCache", data);
		else
			--print("2   BC_ACTOR_MOVE:"..tostringex(data));
			--找不到角色的信息则需要发送信息给服务器请求该玩家的数据
			--[[
			client:sendMessageWithRecall("CLIENT_REQUEST_ACTOR_DATA", {pid=pid}, function(requestData)
				local actorData = requestData.actorData;
				local actor = ActorManager:createActor(actorData);
				local map = MapManager:getMap(actorData.worldid);

				if map ~= nil then
					map:addObject(actor, data.pos);

					if actor:isDie() then
						actor:revive();
					end

					data.id = 1;
					actor:executeScript("scriptCache", data);
				else
					print("CLIENT_REQUEST_ACTOR_DATA actor "..pid.." is not in the map "..actorData.worldid);
				end
			end);
			]]

			client:sendMessage("CLIENT_REQUEST_ACTOR_DATA", {pid=pid})
		end
	end);

	client:registMessageCallBack("BC_ADD_BUFF", function(data)
		TraceError("BC_ADD_BUFF:"..tostringex(data));
		local buff = SkillManager:getBuff(data.buffid);
		local actor = ActorManager:getActor(data.pid);
		buff:attachTo(actor);
	end);

	client:registMessageCallBack("BC_SHOW_DAMAGE", function(data)
		engine.dispachEvent("SHOW_DAMAGE", data);
	end);

	--攻击
	client:registMessageCallBack("BC_ACTOR_ATTACK", function(data)
		--print("BC_ACTOR_ATTACK:"..tostringex(data));
		local fromid = data.fromid;
		local fromObj = ActorManager:getActor(fromid);

		--TraceError("BC_ACTOR_ATTACK:"..tostringex(data));
		if fromObj then
			data.id = 2;

			if fromObj:isDie() then
				fromObj:revive();
			end

			fromObj:executeScript("scriptCache", data);
		else
			--向服务器请求该玩家的基础数据
			--[[
			client:sendMessageWithRecall("CLIENT_REQUEST_ACTOR_DATA", {pid=fromid}, function(requestData)
				local actorData = requestData.actorData;
				local actor = ActorManager:createActor(actorData);
				local map = MapManager:getMap(actorData.worldid);
				TraceError("BC_ACTOR_ATTACK request actor data in map"..actorData.worldid);
				if map ~= nil then
					map:addObject(actor, actorData.worldpos);

					if actor:isDie() then
						actor:revive();
					end

					data.id = 2;

					actor:executeScript("scriptCache", data);
				else
					print("CLIENT_REQUEST_ACTOR_DATA actor "..pid.." is not in the map "..actorData.worldid);
				end
			end);]]

			--TraceError("BC_ACTOR_ATTACK:   CLIENT_REQUEST_ACTOR_DATA")
			client:sendMessage("CLIENT_REQUEST_ACTOR_DATA", {pid=data.pid})

			--TraceError("BC_ACTOR_ATTACK :actor id "..fromid.." no found");
		end
	end);

	--移出装备
	client:registMessageCallBack("BC_ACTOR_REMOVE_EQUIP", function(data)
		local ret = data.ret;
		if ret == 1 then
			local grid = data.grid;
			local etype = data.etype;
			local pid = data.pid;
			local actor = ActorManager:getActor(pid);
			local item = actor:getEquip(etype);

			if item and actor then
				engine.dispachEvent("REMOVE_EQUIP", {etype=etype,pid=pid});
				engine.dispachEvent("ADD_ITEM", {item=item,playerid=pid, index=grid});
			end
		else
			TraceError("unEquip "..data.etype.." error code:"..data.error);
		end
	end);

	--使用装备
	client:registMessageCallBack("BC_ACTOR_USE_ITEM", function(data)
		--TraceError("BC_ACTOR_USE_ITEM message:"..tostringex(data));
		if data.ret == 1 then
			local gridIndex = data.gridIndex;
			local equipData = data.equipData;
			--local equip = ItemManager:getItem(equipData);

			if equipData then
				engine.dispachEvent("REMOVE_ITEM", {pid=data.pid,itemId = equipData.itemid});
				engine.dispachEvent("USE_EQUIP", {pid=data.pid,eda=equipData, extraContent=data.extraContent})
			end
		else
			TraceError(" USE equip error:"..tostringex(data.error));
		end
	end);

	--为某个人物增加道具
	client:registMessageCallBack("BC_ACTOR_ADD_ITEM", function(data)
		--TraceError("receive BC_ACTOR_ADD_ITEM message");
		local item = ItemManager:getItem(data.itemData);
		if not item then
			TraceError("cannot find or create new item:"..tostringex(data.itemData));
			return;
		end

		local actor = ActorManager:getActor(data.pid);
		engine.dispachEvent("ADD_ITEM",{item=item,playerid=data.pid, index=data.index});
	end);

	--为人物增加道具群
	client:registMessageCallBack("BC_ACTOR_ADD_ITEMS", function(data)
		--TraceError("receive BC_ACTOR_ADD_ITEMS message");
		local _time = FuncPack:gettime();
		local actor = ActorManager:getActor(data.pid);

		for index, data in pairs(data.itemsData) do
			local item = ItemManager:getItem(data);

			if not item then
				TraceError("cannot find or create new item:"..tostringex(data.itemData));
				return;
			end

			actor:addItem(item, index);
		end

		if Account:getCurrActor():getID() == data.pid then
			engine.dispachEvent("UPDATE_BAG");
		end
	end);

	--创建道具
	client:registMessageCallBack("CREATE_ITEM", function(data)
		local itemData = data.itemData;

		ItemManager:addEquip(itemData);
	end);

	--移出道具
	client:registMessageCallBack("REMOVE_ITEM", function(data)
		local itemId = data.itemId;
		local pid = data.pid;

		engine.dispachEvent("REMOVE_ITEM",{pid=pid,itemId=itemId});
	end);

	--角色移动同步,此消息会暂停所有角色的行为
	client:registMessageCallBack("BC_ACTOR_MOVE_STOP", function(data)
		TraceError("BC_ACTOR_MOVE_STOP:"..tostringex(data));
		engine.dispachEvent("ACTOR_MOVE_STOP", data);
	end);

	--同步地图位置
	client:registMessageCallBack("BC_SYNCHRONIZE_POSITION", function(msg)
		local data = msg.data;

		for k,v in pairs(data) do
			local actor = ActorManager:getActor(v.pid);
			local currPos = actor:getPositionOfMap();
			if (currPos.x ~= v.pos.x or currPos.y ~= v.pos.y) and actor:getLockBehavior() ~= true then
				engine.dispachEvent("ACTOR_MOVE_STOP",v);
			end
		end
	end);

	--交换物体背包位置
	client:registMessageCallBack("BC_CHANGE_ITEM_POS", function(data)
		if data.ret == 1 then
			local grid1 = data.grid1;
			local grid2 = data.grid2;
			local pid = data.pid;

			engine.dispachEvent("CHANGE_ITEM_POSITION", {grid1=grid1,grid2=grid2,pid=pid});
		else

		end
	end);

	--掉落物体BC_THROW_ITEM
	client:registMessageCallBack("BC_THROW_ITEM", function(data)
		TraceError("BC_THROW_ITEM message");
		local items = data.items;

		for k,v in pairs(items) do
			--local itemData = v.itemData;
			--local pos = v.pos;
			engine.dispachEvent("MAP_THROW_ITEM", v);
		end
	end);


	--切换地图
	client:registMessageCallBack("BC_CHANGE_OBJECT_POS", function(data)
		--TraceError("BC_CHANGE_MAP message:"..tostringex(data));
		local actor = ActorManager:getActor(data.pid);
		if actor then
			engine.dispachEvent("CHANGE_OBJECT_POS", data);
			--TraceError("pid:"..data.pid.."    actor2:"..tostring(actor2));
		else
			--[[
			client:sendMessageWithRecall("CLIENT_REQUEST_ACTOR_DATA", {pid=data.pid}, function(requestData)
				local actorData = requestData.actorData;
				local actor = ActorManager:createActor(actorData);

				engine.dispachEvent("CHANGE_OBJECT_POS", data);
			end);]]

			--TraceError("BC_CHANGE_OBJECT_POS:   CLIENT_REQUEST_ACTOR_DATA")
			client:sendMessage("CLIENT_REQUEST_ACTOR_DATA", {pid=data.pid})
		end
	end);

	--复活
	client:registMessageCallBack("BC_ACTOR_REVIVE", function(data)
		TraceError("BC_ACTOR_REVIVE message:"..tostringex(data));
		local actor = ActorManager:getActor(data.pid);

		if actor then
			--
			--map:removeObject(data.pid);
			--map:addObject(actor, data.pos);
			actor:revive();

			local map = actor:getMap();
			map:changeObjectPos(actor:getID(), data.pos);
		else
			--向服务器请求该玩家的基础数据
			--client:sendMessageWithRecall("CLIENT_REQUEST_ACTOR_DATA", {pid=data.pid}, function(requestData)

			--end);

			--TraceError("BC_ACTOR_REVIVE:   CLIENT_REQUEST_ACTOR_DATA")
			client:sendMessage("CLIENT_REQUEST_ACTOR_DATA", {pid=data.pid})

			TraceError("no find actor "..data.pid.." for reviving");
		end
	end);

	client:registMessageCallBack("CLIENT_REQUEST_ACTOR_DATA", function(requestData)
		local actorData = requestData.actorData;
		local actor = ActorManager:createActor(actorData);
		local map = MapManager:getMap(actorData.worldid);

		if map ~= nil then
			map:addObject(actor, actorData.worldpos);

			if actor:isDie() then
				actor:revive();
			end
		else
			TraceError("CLIENT_REQUEST_ACTOR_DATA actor "..pid.." is not in the map "..actorData.worldid);
		end
	end);
end

function ControlLayer:backToChrSelScene()
	client:clearMessageCallBack();
	engine.clearEventListener();

	self:destroy();

	local chrSel = ChrSelScene:new();

	for k,v in pairs(Account:getActorsData()) do
		chrSel:addChr(v, tonumber(k));
	end

	chrSel:selChr(1);
	cc.Director:getInstance():replaceScene(chrSel);
end

function ControlLayer:initLogicalEvent()
	engine.addEventListenerWithScene(self, "BACK_TO_CHARSEL_SCENE", function(event)

	end);

	engine.addEventListenerWithScene(self, "ADD_NPC", function(event)
		TraceError("map item event");
		local data = event.info.content;
		local npc = ActorManager:createNPC(data);

		local mapid = data.mapid;
		local map = MapManager:getMap(mapid);

		if npc and map then
			map:addObject(npc, data.worldpos);
		else
			TraceError("add npc failed");
		end
	end);

	engine.addEventListenerWithScene(self, "MAP_THROW_ITEM", function(event)
		TraceError("map item event");
		local mapid = event.info.mapid;
		local map = MapManager:getMap(mapid);
		local itemData = event.info.itemData;
		local pos = event.info.pos;
		local item = ItemManager:getItem(itemData);

		if item and map then
			TraceError("add item:"..tostring(item).."   pos:"..tostringex(pos))
			map:addItem(item, pos);
		else
			TraceError("add item failed map:"..tostring(map).."   item:"..tostring(item));
		end
	end);

	engine.addEventListenerWithScene(self, "ACTOR_MOVE_STOP", function(event)
        local msg = event.info;

		local backPos = msg.pos;
		local object = ActorManager:getActor(msg.pid);

		if not object then
			print("no object:"..tostringex(msg).."  debug:"..debug.traceback());
			return;
		end

		local map = object:getMap();

		object:setMoveTargetPos(backPos);
		object:setPosition(backPos.x*TILE_WIDTH, backPos.y*TILE_HEIGHT);
		map:sigalObjectPosition(object, backPos);

		TraceError("stop all Actions");
		--鍋滄涓€鍒囧懡浠ゅ苟寰呮満
		object:stopAllActions();
		object:stopScripts();
		object:unLockActorStatus();-- = false;
		object:idle();

		--print("----------");
		if Account:getCurrActor():getID() == msg.pid then
			self:updateMap();
		else
			--print("Account:getCurrActor():getID():"..tostringex(Account:getCurrActor():getID()).."  pid:"..msg.pid);
		end
    end);

    engine.addEventListenerWithScene(self, "move", function(event)
        self:checkMoveValid(event.info.object, event.info.newPos);
    end);

	engine.addEventListenerWithScene(self, "SHOW_DAMAGE", function(event)
        local msg = event.info;
		local fromid = msg.fromid;
		local skillName = msg.skillName;

		--if Account:getCurrActor():getID() == fromid then
		for k,v in pairs(msg.atkInfo) do
			local damage = v.dg;
			local atkType = v.aty;
			local isDodge = v.isDodge;
			local isCrit = v.isCrit;
			local tarObj = ActorManager:getActor(v.toid);

			if tarObj then
				local position = tarObj:getPosition();
				local height = tarObj:getCollisionRect().top - tarObj:getCollisionRect().bottom;
				position.x = position.x + TILE_WIDTH/2;
				position.y = position.y + height + 40;

				if isDodge and not isCrit then
					self:showDamageFloat(tarObj:getParent(), "miss", position);
				else
					if isCrit then
						self:showDamageFloat(tarObj:getParent(), "Critical "..damage, position);
					else
						self:showDamageFloat(tarObj:getParent(), damage, position);
					end

					if tarObj:isDie() == false then
						tarObj:getDamage(nil, damage);
						tarObj:setHp(v.curHp);
					end

					local from = ActorManager:getActor(fromid);

					if from then
						local content = from:getName().." 对 "..tarObj:getName().." 使用技能 "..skillName..",造成了"..damage.."点伤害";
						engine.dispachEvent("SHOW_NOTICE", {content=content, type="attack"});
					end
				end
			end
		end
		--end
    end);

	engine.addEventListenerWithScene(self, "REMOVE_ITEM", function(event)
        local itemId = event.info.itemId;--self.player:getItem(itemIndex);
		local pid = event.info.pid;
		local actor = ActorManager:getActor(pid);
        --绉婚櫎閬撳叿
        local delItem = actor:removeItemWithId(itemId);

		if Account:getCurrActor():getID() == pid then
			engine.dispachEvent("UPDATE_BAG", delItem);
		end
    end);

    engine.addEventListenerWithScene(self, "USE_EQUIP", function(event)
        --浣跨敤鐗╁搧
        local eda = event.info.eda;--self.player:getItem(itemIndex);
		local pid = event.info.pid;
		local actor = ActorManager:getActor(pid);
		local equip = ItemManager:getItem(eda);
		local gridIndex =  event.info.gridIndex;

		local oldEquip = actor:loadPart(equip, event.info.extraContent);
		if oldEquip then
			engine.dispachEvent("ADD_ITEM", {playerid=pid,item=oldEquip, index=gridIndex});
			--actor:addItem(oldEquip);
		end

		if Account:getCurrActor():getID() == pid then
			engine.dispachEvent("UPDATE_STATEWINDOW");
		end
    end);

	engine.addEventListenerWithScene(self, "ADD_ITEM", function(event)
		local index = event.info.index;
		local item  = event.info.item;
		local pid   = event.info.playerid;
		local actor = ActorManager:getActor(pid);

		if actor then
			actor:addItem(item, index);

			if Account:getCurrActor():getID() == pid then
				engine.dispachEvent("UPDATE_BAG");
			end
		end
	end);

	engine.addEventListenerWithScene(self, "REMOVE_EQUIP", function(event)
		local etype = event.info.etype;
		local pid = event.info.pid;
		local actor = ActorManager:getActor(pid);

		actor:unLoadPartForType(etype);

		if Account:getCurrActor():getID() == pid then
			engine.dispachEvent("UPDATE_STATEWINDOW");
		end
	end);

    engine.addEventListenerWithScene(self, "CHANGE_ITEM_POSITION", function(event)
        local grid1 = event.info.grid1;
		local grid2 = event.info.grid2;
		local actor = ActorManager:getActor(event.info.pid);

        local item1 = actor:getItem(grid1);
        local item2 = actor:getItem(grid2);

        actor:removeItem(grid1)
        actor:removeItem(grid2)

        if item1 then
            actor:addItem(item1, grid2);
        end

        if item2 then
            actor:addItem(item2, grid1);
        end

		engine.dispachEvent("UPDATE_BAG");
    end);

	engine.addEventListenerWithScene(self, "CHANGE_OBJECT_POS", function(event)
		local pid = event.info.pid;
		local actor = ActorManager:getActor(pid);

		if actor then
			--TraceError("exec CHANGE_OBJECT_POS:"..debug.traceback());
			local newMapId = event.info.mapId;
			local pos = event.info.pos;
			local others = event.info.others;
			local mapItemsData = event.info.mapItemsData;

			if not actor:getMap() or newMapId ~= actor:getMap():getID() then
				if Account:getCurrActor() == actor then
					client:initMsgCallbackStack();
					self:destroy(true);

					local mainScene = self:getParent();
					mainScene:replaceMap(newMapId, pos, actor, others, mapItemsData);
				else
					actor:stopAllActions();
					self:changeObjectPos(actor, newMapId, pos);

					actor:idle();
				end
			else
				self:changeObjectPos(actor, newMapId, pos);

				if Account:getCurrActor() == actor then
					self:updateMap();
				end
			end
		else
			--向服务器请求该玩家的基础数据
			client:sendMessageWithRecall("CLIENT_REQUEST_ACTOR_DATA", {pid=pid}, function(requestData)
				local actorData = requestData.actorData;
				local actor = ActorManager:createActor(actorData);
				local map = MapManager:getMap(actorData.worldid);

				if map ~= nil then
					TraceError("CHANGE_OBJECT_POS:actor "..actor:getID().." to map "..actorData.worldid);
					map:addObject(actor, actorData.worldpos);
				else
					TraceError("CLIENT_REQUEST_ACTOR_DATA actor "..pid.." is not in the map "..actorData.worldid);
				end
			end);

			TraceError("no find actor "..pid.." for CHANGE_OBJECT_POS");
		end
    end);
end

function ControlLayer:showDamageFloat(layer, num, position)
	--local layer = tarObj:getParent();
	local label = engine.initLabel(num, 20);
	label:setColor(cc.c3b(255,0,0));
	label:setPosition(position.x, position.y);
	layer:addChild(label, LayerzOrder.DAMAGE);

	local action = cc.MoveTo:create(1.0, {x=position.x, y=position.y + 40});
	local callfunc = cc.CallFunc:create(function()
		layer:removeChild(label);
	end)
	local sequence = cc.Sequence:create({action, callfunc});
	label:runAction(sequence);
end

function ControlLayer:changeObjectPos(actor, mapid, newPos)
	local oldmap = actor:getMap();
	if oldmap then
		oldmap:removeObject(actor:getID());
	end

	local map = MapManager:getMap(mapid);
	map:addObject(actor, newPos);
end

function ControlLayer:checkMoveValid(object, newPos)
	local mapPos = nil;

	if newPos then
		mapPos = newPos;
	else
		local objPos = object:getPosition();
		mapPos = FuncPack:getCheckPositionOfPoint(objPos);
	end

    local lastPositionOfMap = object:getPositionOfMap();
    if FuncPack:isEqualPoint(lastPositionOfMap, mapPos) then
        return ;
    end

	self.map:sigalObjectPosition(object, mapPos);
	local player = Account:getCurrActor();
    if player and object:getID() == player:getID() then
		self:updateMap();
	end
end

function ControlLayer:onTouchesEnded(touches, events)
	if self.map then
		--self.uiLayer:onTouchEnded(touches,events);
	end
end

function ControlLayer:onTouchesBegan(touches, events)
	if self.map then
		--self.uiLayer:onTouchBegan(touches,events);
		self:updateTestLabel(touches);
	end
end

function ControlLayer:onTouchesMoved(touches, events)
	if self.map then
		--self.uiLayer:onTouchMoved(touches,events);
	end
end

------------------------touch-----------------------------
function ControlLayer:registMultiTouch(node)
    function onTouchesEnded(touches, events)
        self:onTouchesEnded(touches, events);
    end

    function onTouchesBegan(touches, events)
        self:onTouchesBegan(touches, events);
    end

    function onTouchesMoved(touches, events)
        self:onTouchesMoved(touches, events);
    end

    local listener = cc.EventListenerTouchAllAtOnce:create();
    listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(onTouchesEnded, cc.Handler.EVENT_TOUCHES_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function ControlLayer:setSceneScrollPosition(position)
    local mapSize = self.map.mapSize;    --鍦板浘灏哄
    local tileSize = {width=TILE_WIDTH, height=TILE_HEIGHT};  --缃戞牸灏哄
    --position           瑙掕壊浣嶇疆

    --鑾峰彇灞忓箷灏哄
    local screenSize=cc.Director:getInstance():getWinSize();--CCDirector::sharedDirector()->getWinSize();
    --璁＄畻Tilemap鐨勫楂橈紝鍗曚綅鏄儚绱?
    local mapSizeInPixel = cc.size(mapSize.width*tileSize.width,
        mapSize.height*tileSize.height)--CCSizeMake(mapSize.width*tileSize.width,
    --mapSize.height*tileSize.height);
    --鍙栧媷澹綋鍓峹鍧愭爣鍜屽睆骞曚腑鐐箈鐨勬渶澶у€硷紝濡傛灉鍕囧＋鐨剎鍊艰緝澶э紝鍒欎細婊氬姩
    local x=math.max(position.x,screenSize.width/2.0);
    local y=math.max(position.y,screenSize.height/2.0);
    --鍦板浘鎬诲搴﹀ぇ浜庡睆骞曞搴︾殑鏃跺€欐墠鏈夊彲鑳芥粴鍔?
    if mapSizeInPixel.width>screenSize.width then
        x=math.min(x,mapSizeInPixel.width-screenSize.width/2.0);
    end
    if mapSizeInPixel.height>screenSize.height then
        y=math.min(y,mapSizeInPixel.height-screenSize.height/2.0);
    end
    --鍕囧＋鐨勫疄闄呬綅缃?
    local heroPosition={x=x,y=y};
    --灞忓箷涓偣浣嶇疆
    local screenCenter={x=screenSize.width/2.0,y=screenSize.height/2.0};
    --璁＄畻鍕囧＋瀹為檯浣嶇疆鍜屼腑鐐逛綅缃殑璺濈
    local scrollPosition=cc.pSub(screenCenter,heroPosition);
    --灏嗗満鏅Щ鍔ㄥ埌鐩稿簲浣嶇疆
    self.map.layer:setPosition(scrollPosition);
end

function ControlLayer:destroy(isKeepUser)
	ActorManager:release(isKeepUser);

	if not isKeepUser then
		Account:release();
	end
	--SkillManager:release();
	--ItemManager:release();
	TimerManager:clear();
	EffectManager:release();
	MapManager:release();
	--AsyncLoadMirFile:release();
end

function ControlLayer:jumpToLoginScene()
	local scene = require("scene.LoginScene")
	local loginScene = scene.create()
	loginScene:playBgMusic()

	cc.Director:getInstance():replaceScene(loginScene)
end
