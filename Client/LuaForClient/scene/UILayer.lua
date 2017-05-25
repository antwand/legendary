--region NewFile_1.lua
--Author : legend
--Date   : 2015/4/19
--姝ゆ枃浠剁敱[BabeLua]鎻掍欢鑷姩鐢熸垚



--endregion
UILayer = class("UILayer", function()
    return cc.Node:create();
end)

local lastEquipBangle = 0
local lastEquipRing = 0
local talkWindowTag = 30

local keyboardMap =
{
	[47] = "F1",
	[48] = "F2",
	[49] = "F3",
	[50] = "F4",
	[51] = "F5",
	[52] = "F6",
	[53] = "F7",
	[54] = "F8",
}

function UILayer:ctor()
    self:initUI();--ACTOR_CAST
    self:initEvent();

	self:registInput();
end

function UILayer:initUI()
	if not self.bag then
		self.bag = Bag:new();
		self.bag:setPosition(200, 200);
		self.bag:hide();
		self:addChild(self.bag, 1);
	end

	if not self.bottomStateUI then
		self.bottomStateUI = BottomStateUI:new();
		self:addChild(self.bottomStateUI)
	end

	if not self.shortcutFrame then
		self.shortcutFrame = ShortcutFrame:new();
		self.shortcutFrame:setVisible(false);
		self:addChild(self.shortcutFrame, 2)
	end

    if not self.statueWindow then
        self.statueWindow = StatueWindow:new();
		self.statueWindow:init();
        self.statueWindow:setPosition(200, 200);
        self.statueWindow:setVisible(false);
        self.statueWindow:setSex(1);
        self.statueWindow:showPanel(1)
        self.statueWindow:showAttributePanel(1);
        self:addChild(self.statueWindow)
    end

	self:initModelDialog();
end

function UILayer:initModelDialog()
	if not self.dialog then
		local rootNode = require("ui/BaseUI/ModelDialog.lua").create();
		local window = rootNode['root'];
		self.dialog = window;
		self.dialog:setVisible(false);
		self:addChild(self.dialog, 2);
	end
end

function UILayer:showModelDialog(str, func)
	local back = self.dialog:getChildByName("back")
	local sureBtn = back:getChildByName("sureBtn")
	local cancelBtn = back:getChildByName("cancelBtn")

	sureBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			func(true);
			self.dialog:setVisible(false);
		end
	end);

	cancelBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			func();
			self.dialog:setVisible(false);
		end
	end);

	local content = back:getChildByName("Text_1")
	content:setString(str);
	self.dialog:setVisible(true);
end

function UILayer:initEvent()
	------------------------------------------------------
	-----------
	-----------		用于UI操作
	-----------
	------------------------------------------------------
	engine.addEventListenerWithScene(self, "CONFIRM_BACK_TO_CHRSEL_SCENE", function(event)
		self:showModelDialog("是否确定要退出当前地图，回退到角色选择页面?", event.info);
	end);

	engine.addEventListenerWithScene(self, "OPEN_SHORTCUT", function(event)
		local skill = event.info;

		self.shortcutFrame:showFrame(skill.skillid);
		self.shortcutFrame:setVisible(true);
	end);

	engine.addEventListenerWithScene(self, "SET_SKILL_SHORTCUT", function(event)
		self.statueWindow:setSkillShortcut(self.shortcutFrame:getShortcutList());

		self.statueWindow:updateSkill(self.statueWindow.skillPage);
	end);

	engine.addEventListenerWithScene(self, "OPEN_BAG", function(event)
		if not self.bag:isVisible() then
			self:updateBag();
			self.bag:show();
		else
			self.bag:setVisible(false);
		end
	end);

	engine.addEventListenerWithScene(self, "OPEN_STATEWINDOW_FOR_EQUIP", function(event)
		if not self.statueWindow:isVisible() then
			self:updateStateWindow(1);
			self.statueWindow:setVisible(true);
		else
			self.statueWindow:setVisible(false);
		end
	end);

	engine.addEventListenerWithScene(self, "OPEN_STATEWINDOW_FOR_SKILL", function(event)
		if not self.statueWindow:isVisible() then
			self:updateStateWindow(3);
			self.statueWindow:setVisible(true);
		else
			self.statueWindow:setVisible(false);
		end
	end);

	engine.addEventListenerWithScene(self, "BAG_PUT_ITEM_BACK", function(event)
		self.bag:endMoveItem();
		self.bag:endMoveTitle();
	end);

	engine.addEventListenerWithScene(self, "UPDATE_BAG", function(event)
		self:updateBag();

		local item = event.info;

		if item then
			local itemTypeID = item:getTypeID();
			local hasItem = self.player:getItemForTypeid(itemTypeID);
			self.bottomStateUI:updateShortcut(itemTypeID, hasItem);
		end
	end);

	engine.addEventListenerWithScene(self, "OPEN_SHORTCUT", function(event)
		local skill = event.info;

		self.shortcutFrame:showFrame(skill.skillid);
		self.shortcutFrame:setVisible(true);
	end);

	engine.addEventListenerWithScene(self, "UPDATE_BottomUI", function(event)
		local actor = event.info;

		self:updateBottomUI(actor);
	end);

	engine.addEventListenerWithScene(self, "UPDATE_STATEWINDOW", function(event)
		self:updateStateWindow();
	end);

	engine.addEventListenerWithScene(self, "ACTOR_UPDATE_BOTTOM_UI", function(event)
		local pid = event.info;
		if pid == self.player:getID() then
			self:updateBottomUI(self.player);
		end
	end);

	engine.addEventListenerWithScene(self, "SHOW_MESSAGE", function(event)
		if self.bottomStateUI then
			self.bottomStateUI:showMessage(event.info.content, 14);
		end
	end);

	engine.addEventListenerWithScene(self, "SHOW_NOTICE", function(event)
		if self.bottomStateUI and event.info.type ~= "attack" then
			self.bottomStateUI:showNotice(event.info.content, 14);
		end
	end);

	engine.addEventListenerWithScene(self, "UI_INIT_MMAP", function(event)
		if self.bottomStateUI then
			self.bottomStateUI:initMMap(event.info.mapId, event.info.mmapId);
		end
	end);

	engine.addEventListenerWithScene(self, "UI_INIT_BIG_MMAP", function(event)
		if self.bottomStateUI then
			self.bottomStateUI:initBigMMap(event.info.mapId, event.info.mmapId);
		end
	end);

	engine.addEventListenerWithScene(self, "UI_UPDATE_BIG_MMAP", function(event)
		local mapPos = event.info.mapPos;
		local mapSize = event.info.mapSize;

		if self.bottomStateUI then
			self.bottomStateUI:updateBigMMap(mapPos, mapSize);
		end
	end);

	engine.addEventListenerWithScene(self, "UI_UPDATE_MMAP", function(event)
		local mapPos = event.info.mapPos;
		local mapSize = event.info.mapSize;

		if self.bottomStateUI then
			self.bottomStateUI:updateMMap(mapPos, mapSize);
		end
	end);

	engine.addEventListenerWithScene(self, "UI_UPDATE_SKILL", function(event)
		self.statueWindow:setSkills(self.player:getSkillsData());
		self.statueWindow:updateSkill(1);
	end);

	engine.addEventListenerWithScene(self, "UI_SHOW_TALKING_WINDOW", function(event)
		if not self:getChildByTag(talkWindowTag) then
			local conf = talkConf[event.info.talkId];
			local createFunc = loadstring("return "..conf.sz_class..":new()")
			self.talkWindow = createFunc();
			self.talkWindow:setTag(talkWindowTag);
			self.talkWindow:readConf(conf);
			self.talkWindow.npcId = event.info.npcId;

			local size = cc.Director:getInstance():getVisibleSize();
			local winSize = self.talkWindow:getWindowSize();

			self.talkWindow:setPosition(0, size.height - winSize.height);
			self:addChild(self.talkWindow);
		else
			TraceError("already exists talk window");
		end
	end);

	if not client then
		return;
	end

	------------------------------------------------------
	-----------
	-----------		用于物品道具的使用丢弃等等事件,涉及服务器
	-----------
	------------------------------------------------------
	engine.addEventListenerWithScene(self, "REQUEST_BACK_TO_CHRSEL_SCENE", function(event)
		client:sendMessage("ACTOR_BACK_TO_CHRSEL_SCENE", {});
	end);


	engine.addEventListenerWithScene(self, "THROW_ITEM", function(event)
		local item = event.info;

		client:sendMessage("ACTOR_THROW_ITEM", {itemId=item:getID()});
	end);

	engine.addEventListenerWithScene(self, "PLAYER_REMOVE_ITEM", function(event)
        local itemId = event.info;--self.player:getItem(itemIndex);
		client:sendMessage("ACTOR_REMOVE_ITEM", {itemId=itemId});
    end);

    engine.addEventListenerWithScene(self, "PLAYER_USE_ITEM", function(event)
        --浣跨敤鐗╁搧
        local itemId = event.info;
		local leftOrRight = nil;

		local item = ItemManager:getItemForId(itemId);
		local itemType = item:getType();
		if itemType == 5 then  --如果是手镯或者戒指，则需要判断替换的当前装备是左边的还是右边的
			local leftEquip = self.player:getEquip(itemType);
			local rightEquip = self.player:getEquip(itemType+1);

			if leftEquip and rightEquip then
				leftOrRight = lastEquipBangle

				lastEquipBangle = (lastEquipBangle + 1)%2;
			elseif leftEquip and not rightEquip then
				leftOrRight = 1;
			end
		elseif itemType == 7 then
			local leftEquip = self.player:getEquip(itemType);
			local rightEquip = self.player:getEquip(itemType+1);

			if leftEquip and rightEquip then
				leftOrRight = lastEquipRing

				lastEquipRing = (lastEquipRing + 1)%2;
			elseif leftEquip and not rightEquip then
				leftOrRight = 1;
			end
		end

		client:sendMessage("ACTOR_USE_ITEM", {itemId=itemId, extraContent=leftOrRight});
    end);

	engine.addEventListenerWithScene(self, "PLAYER_REMOVE_EQUIP", function(event)
		local etype = event.info;
		client:sendMessage("ACTOR_REMOVE_EQUIP", {etype=etype})
	end);

    engine.addEventListenerWithScene(self, "PLAYER_CHANGE_ITEM", function(event)
        local data = event.info;

		--服务器消息
		client:sendMessage("ACTOR_CHANGE_ITEM_POS", {index1=data.index1, index2=data.index2})

		--本地事件
		--local pid = self.player:getID();
		--engine.dispachEvent("CHANGE_ITEM_POSITION", {grid1=data.index1,grid2=data.index2,pid=pid});
    end);

	engine.addEventListenerWithScene(self, "PREPARE_MOVE", function(event)
		local isRun = event.info.isRun;
		local dir = event.info.dir;

		client:sendMessage("ACTOR_MOVE", {isRun=isRun, dir=dir,pos=event.info.pos});
    end);

	--进行攻击的预备操作
	engine.addEventListenerWithScene(self, "PREPARE_ATTACK", function(event)
		local object = event.info.object;
		object:stopRun();

		local values = event.info.values;
		local skillName = event.info.skillName;
		local damageInfo = nil;

		local ret = object:cast(skillName, values, function()
			--client:sendMessageWithRecall("ACTOR_ATTACK", {skillName=skillName,values=values}, function(msg)
			--	engine.dispachEvent("SHOW_DAMAGE", msg);
			--end);
		end)

		if ret then
			client:sendMessage("ACTOR_CAST", {skillName=skillName,values=values});
		else
			TraceError("cast "..skillName.."  failed");
		end
	end);

	engine.addEventListenerWithScene(self, "SEND_MESSAGE", function(event)
		client:sendMessage("ACTOR_SEND_MESSAGE", {content = event.info, type=1});
	end);
end

function UILayer:updateBottomUI(actor)
	self.bottomStateUI:setLevel(actor:getLevel());
	self.bottomStateUI:setBlood(actor:getHp(), actor:getMaxHp());
	self.bottomStateUI:setMagic(actor:getMp(), actor:getMaxMp());

	local maxExc = getMaxExc(actor.conf.sz_excConf, actor:getLevel());--self:getMaxExc(actor:getType(), actor:getLevel());
	self.bottomStateUI:setExc(actor:getExc(), maxExc);
	self.bottomStateUI:setName(actor:getName());
end

function UILayer:getMaxExc(style, level)
	return 10000;
end

function UILayer:updateBag()
    self.bag:clearItem();
    self.bag:setItemData(self.player.items);
	self.bag:showGold(self.player:getGold());
end

function UILayer:updateStateWindow(_type)
	local actor = self.player;

    for k,v in pairs(self.statueWindow.equipGroup) do
        local etype = k;
        self.statueWindow:removeEquip(etype);
    end

    --鏇存柊鐘舵€佹爮闈㈡澘
    for k,v in pairs(actor.parts) do
        self.statueWindow:addEquip(v, k);
    end

	self.statueWindow:setName(actor:getName());
    self.statueWindow:updateAttribute(actor:getAttribute());

	self.statueWindow:showPanel(1);
	self.statueWindow:showAttributePanel(_type);
end

function UILayer:updateStatueWindowSex(actor)
    local sex = actor:getSex();
    self.statueWindow:setSex(sex);

    self:updateStateWindow(actor);
end

function UILayer:setPlayer(player)
    self.player = player;
    self.enemy = nil;

	self.shortcutFrame:readSetting(self.player:getID());
	self.bottomStateUI:readSetting(self.player:getID());

	self.statueWindow:setSkillShortcut(self.shortcutFrame:getShortcutList());
	self.statueWindow:setSkills(self.player:getSkillsData());
	self.statueWindow:updateSkill(1);
	self.statueWindow:setSex(player:getSex());
end

function UILayer:getPlayer()
    return self.player;
end

function UILayer:update(dt)
    if self.player then
        self:updatePlayerMove();

		if client then
			self:judgeIsPick();
		end
    end

	if self.bottomStateUI then
		self.bottomStateUI:update(dt);
	end
end

local lastPickTime = {}--FuncPack:gettime();
function UILayer:judgeIsPick()
	if self.player:checkMove()==false then
		local pos = self.player:getPositionOfMap();
		local map = self.player:getMap();

		if map then
			local item = map:getItemFromMap(pos);

			--and (not pickUpItem[item:getID()] or pickUpItem[item:getID()] == item:getID())
			if item then
				if not lastPickTime[item:getID()] then
					lastPickTime[item:getID()] = FuncPack:gettime() - 10;
				end

				if FuncPack:gettime() - lastPickTime[item:getID()] >= 5 then
					client:sendMessage("ACTOR_PICK_UP_ITEM", {point=pos});
					lastPickTime[item:getID()] = FuncPack:gettime();
				end
			end
		end
	end
end

-----------------------------regist Touch event---------------------------
function UILayer:registMultiTouch()
	local function onTouchesEnded(touches, events)
        self:onTouchesEnded(touches, events);
    end

    local function onTouchesBegan(touches, events)
        self:onTouchesBegan(touches, events);
    end

    local function onTouchesMoved(touches, events)
        self:onTouchesMoved(touches, events);
    end

    local listener = cc.EventListenerTouchAllAtOnce:create();
    listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(onTouchesEnded, cc.Handler.EVENT_TOUCHES_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function UILayer:registInput()
	local function sceneUpdate(delta)
		self:update(delta)
	end

	self:scheduleUpdateWithPriorityLua(sceneUpdate,1)
	self:registMultiTouch();
	self:registKeyboard();
	self:registMouse();
end

function UILayer:unRegistInput()
	self:unscheduleUpdate ();

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
	eventDispatcher:removeEventListenersForTarget(self);
end

function UILayer:registMouse()
	local function onMouseMove(event)
		local x = event:getCursorX();
		local y = event:getCursorY();

		if self.player then
			local currMap = self.player:getMap();

			if currMap then
				local actor  = self:getTouchActor({x=x,y=y}, currMap);

				if actor then
					if actor ~= self.player and actor:getCamp() ~= self.player:getCamp() then
						self:chooseEnemy(actor);
					else
						local touchMapPoint = currMap:scenePointToMapPoint({x=x,y=y});
						local touchMapPosition = FuncPack:pointToPosition(touchMapPoint);
						self.cursorPos = touchMapPosition;

						if self.enemy then
							self.enemy:updateState();
							self.enemy = nil;
						end
					end
				else
					local touchMapPoint = currMap:scenePointToMapPoint({x=x,y=y});
					local touchMapPosition = FuncPack:pointToPosition(touchMapPoint);
					self.cursorPos = touchMapPosition;

					if self.enemy then
						self.enemy:updateState();--setEdging(0, cc.c3b(255,255,255), {width=2,height=2}, cc.c3b(0,0,0));
						self.enemy = nil;
					end
				end
			end
		end
	end

	local listener = cc.EventListenerMouse:create();
    listener:registerScriptHandler(onMouseMove, cc.Handler.EVENT_MOUSE_MOVE)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function UILayer:registKeyboard()
	local function keyboardPressed(keyCode, event)
		if keyboardMap[keyCode] then
			self:triggerShortcut(keyCode);
		end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher = self:getEventDispatcher()

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function UILayer:triggerShortcut(code)
	local shortcutList = self.shortcutFrame:getShortcutList();
	local skill = nil;
	for k,v in pairs(shortcutList) do
		if v == keyboardMap[code] then
			skill = self.player:getSkillById(k);
		end
	end

	if not skill then
		TraceError("triggerShortcut no found this skill");
		return;
	end

	local skillType = skill:getType();
	if skillType == 1 then
		local ret = skill:active();
		if ret then
			engine.dispachEvent("SHOW_MESSAGE", {content=skill:getName().."已激活", type="skillSetting"});
		else
			engine.dispachEvent("SHOW_MESSAGE", {content=skill:getName().."已禁用", type="skillSetting"});
		end
	elseif skillType >= 2 then
		local position = nil;
		local enemy = self.enemy or self.lastEnemy;
		if enemy and enemy:isDie() == false then
			position = enemy:getPositionOfMap();
			local playerPos = self.player:getPositionOfMap();
			local distance = FuncPack:getStepBetweenPos(position, playerPos);

			if distance >= 10 then
				position = self.cursorPos;

				self.enemy = nil;
				self.lastEnemy = nil;
			end
		else
			position = self.cursorPos;
		end

		local ret,reason = self.player:cast(skill:getName(), position)
		if ret then
			if client then
				client:sendMessage("ACTOR_CAST", {skillName=skill:getName(),values=position});
			end
			--TraceError(skill:getName().."技能释放失败,原因:"..reason);
		end
	else
		TraceError(skill:getName().."技能类型未知:"..tostring(skillType));
	end
end

------------------------------------Touch Event------------------------------------
function UILayer:onTouchesBegan(touches, events)
    if self.player then
        local point = touches[1]:getLocation();
        self:onTouchMap(point);
    end
end

function UILayer:onTouchesMoved(touches, events)
    if self.player then
        local point = touches[1]:getLocation();

        self:playerMoving(point);
    end
end

function UILayer:onTouchesEnded(touches, events)
    if self.player then
        self:endPlayerMove();
    end
end

function UILayer:checkCanAttack(enemy)
	if self.player:getCamp() == enemy:getCamp() then
		return nil;
	end

	return true;
end

function UILayer:onTouchMap(touchPoint)
    local currMap = self.player:getMap();
    local enemy  = self:getTouchActor(touchPoint, currMap);

	if enemy then
		if enemy == self.player then

		elseif enemy:getCamp() == 3 then
			enemy:request();
		elseif self.enemy and enemy == self.enemy then
			if self:checkCanAttack(enemy) then
				self.player:executeScript("autofight", enemy:getID())
			end
		end

		self:chooseEnemy(enemy);
	else
		self:beginPlayerMove(touchPoint);
	end
end

function UILayer:getTouchActor(touchPoint, currMap)
	local touchMapPoint = currMap:scenePointToMapPoint(touchPoint);
	local actorList = currMap:getActorsGroup();

	for k,actor in pairs(actorList) do
		if actor:isDie() == false then
			if actor:isClick(touchMapPoint) then
				return actor;
			end
		end
	end

    return nil;
end

function UILayer:beginPlayerMove(_cursorPoint)
    self.beginMove = true;
    self.cursorPoint = _cursorPoint;
    self.player:lockActorStatus();
    self.player:stopScripts();
end

function UILayer:updatePlayerMove()
    if not self.beginMove then
		--TraceError("already beginMove");
        return;
    end

    if self.player:getLockBehavior() then
        return true;
    end

    local currMap   = self.player:getMap();
    local tarPoint  = currMap:scenePointToMapPoint(self.cursorPoint);
    local targetPos = FuncPack:pointToPosition(tarPoint);
    local playerPos = self.player:getPositionOfMap();

    if FuncPack:isEqualPoint(playerPos, targetPos) then
        self:endPlayerMove();
        return true;
    end

    local direction       = FuncPack:getDirectionWithPosition(playerPos, targetPos);
    local nextOneStepPos  = FuncPack:nextPositionWithDir(playerPos, direction, 1);
    local nextOneHasObj   = currMap:hasObstacle(nextOneStepPos);

    if nextOneHasObj then
        local findPathTargetPos = FuncPack:nextPositionWithDir(playerPos, direction, 3);
        local path = AStarFindPath:getAStarPath(playerPos,findPathTargetPos,currMap);

        if path then
			local nextPos = FuncPack:pointToPosition(path[2]);
			local isRun,newDir = self:getNextStepAndDir(nextPos);

			--print("use A* find to find way: dir:"..newDir.."  from ("..playerPos.x..","..playerPos.y..") to ("..nextPos.x..","..nextPos.y..")");
			self:moveActor(isRun, newDir);
		else
			self:endPlayerMove();
        end
    else
        local nextTwoStepPos = FuncPack:nextPositionWithDir(playerPos, direction, 2);
        local nextTwoHasObj = currMap:hasObstacle(nextTwoStepPos);
        local distance = FuncPack:getDistanceWithOfPositions(playerPos, targetPos);

		local isRun = self:checkNextTwoPosIsCanMove(nextTwoHasObj, distance, direction);
		--print("normally find way: dir:"..direction.."  from ("..playerPos.x..","..playerPos.y..") to ("..nextTwoStepPos.x..","..nextTwoStepPos.y..") isHasobj:"..
		--	tostring(nextTwoHasObj).." isRun:"..tostring(isRun));
		self:moveActor(isRun, direction);
    end

    return true;
end

function UILayer:moveActor(isRun, direction)
	local ret = 0;

	if isRun == 1 and self.player:getAllowRun() then
		ret = self.player:run(direction);
	else
		ret = self.player:walk(direction);
	end

	if ret then
		engine.dispachEvent("PREPARE_MOVE", {isRun=isRun, dir=direction,pos=self.player:getPositionOfMap()});
	end
end

function UILayer:checkNextTwoPosIsCanMove(nextTwoHasObj, distance, direction)
	local ret = nil;

	if nextTwoHasObj or distance < 2 then
		ret = 0--self.player:walk(direction);
	else
		ret = 1--self.player:run(direction);
	end

	return ret;
end

function UILayer:chooseEnemy(enemy)
	if enemy then
		if not self.enemy or self.enemy ~= enemy then
			TraceError(enemy:getID().." monster is chosen");
			enemy:setEdging(1, cc.c3b(255,255,255), {width=2,height=2}, cc.c3b(0,0,0));

			if self.enemy then
				self.enemy:updateState();
			end
		end

		self.enemy = enemy;
		self.lastEnemy = enemy;
	end
end

function UILayer:getNextStepAndDir(targetPos)
    local playerPos = self.player:getPositionOfMap();
    local direction = FuncPack:getDirectionWithPosition(playerPos, targetPos);
    local distance = FuncPack:getDistanceWithOfPositions(playerPos, targetPos);

	if distance < 2 then
		return 0,direction;
    else
		return 1,direction;
    end
end

function UILayer:playerMoving(_cursorPoint)
    if self.beginMove then
        self.cursorPoint = _cursorPoint;
    end
end

function UILayer:endPlayerMove()
    self.beginMove = nil
    self.player:unLockActorStatus();

    --is walk stop
    if self.player.lockBehavior == false then
        self.player:idle();
    end
end
