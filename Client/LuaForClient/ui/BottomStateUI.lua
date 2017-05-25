BottomStateUI = class("BottomStateUI", function()
    return cc.Layer:create();
end)

function BottomStateUI:ctor()
	local result = require("ui/BottomUI.lua").create();
    local rootNode = result['root'];
	self.rootNode = rootNode;
	self:addChild(rootNode);

	--rootNode:setScale(800/1024, 600/768);
	--[[
	]]
	local equipBtn = rootNode:getChildByName("equipBtn")
	local inputText = rootNode:getChildByName("input")
	local bagBtn = rootNode:getChildByName("bagBtn")
	local skillBtn = rootNode:getChildByName("skillBtn")
	local levelText = rootNode:getChildByName("LevelText")
	local listView = self.rootNode:getChildByName("ScrollView")
	local outBtn = rootNode:getChildByName("outBtn")
	--local noticeWindow = self.rootNode:getChildByName("NoticeWindow")
	--noticeWindow:setTextBackColor();

	listView:setBounceEnabled(true);
	listView:setInertiaScrollEnabled(false);
	listView:setScrollBarEnabled(false);
	listView:setTouchEnabled(false);

	self:initEventListener(outBtn, function()
		engine.dispachEvent("CONFIRM_BACK_TO_CHRSEL_SCENE", function(ret)
			if ret then
				engine.dispachEvent("REQUEST_BACK_TO_CHRSEL_SCENE", nil);
			end
		end)
	end);

	self:initEventListener(equipBtn, function()
		engine.dispachEvent("OPEN_STATEWINDOW_FOR_EQUIP", nil);
	end);

	self:initEventListener(bagBtn, function()
		engine.dispachEvent("OPEN_BAG", nil);
	end);

	self:initEventListener(skillBtn, function()
		engine.dispachEvent("OPEN_STATEWINDOW_FOR_SKILL", nil);
	end);

	local slider = self.rootNode:getChildByName("slider")
	self:initEventListener(slider, function()
		self.isMoveSlider = nil;
	end, nil, function()
		self.isMoveSlider = true;
	end)

	self:registKeyboard();
	self:registListener();
	--self:registShortCut();
	self.currItemIndex = 0;
	self.currNoticeItemIndex = 0;
end

function BottomStateUI:pointIsInBackground(point)
	for i=1, 6 do
		local shortCut = self.rootNode:getChildByName("shortCut"..i);

		local isClick = self:checkButtonClick(shortCut, point);
		if isClick then
			return i;
		end
	end

	return nil;
end

function BottomStateUI:checkButtonClick(btn, point)
	local location = btn:convertToNodeSpace(point)
    local size = btn:getContentSize();
    local rect = cc.rect(0,0, size.width, size.height)

    if cc.rectContainsPoint(rect,location) then
        return true;
    end

    return false;
end

function BottomStateUI:registListener()
    local function onTouchBegan(touch, event)
		if self:isVisible() == false then
            return false;
        end

		local ret = self:pointIsInBackground(touch:getLocation());
		if ret and currState then
			if ret then
				if currChooseItem then
					self:addShortCutItem(ret, currChooseItem:getTypeID());
					self:saveSetting();
				end

				currChoose = nil;
				currChooseItem = nil;
				currState = false;
			end

			return true;
		elseif ret and not currState then
			self:shortcutUse(ret);

			return true;
		elseif currState and not ret then
			engine.dispachEvent("THROW_ITEM", currChooseItem);

			currChoose = nil;
			currChooseItem = nil;
			currState = false;

			return true
		end

        return false;
    end

    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    --listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    --listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

local shortCutItem = {};
function BottomStateUI:registShortCut()
	local shortCut1 = self.rootNode:getChildByName("shortCut1");
	local shortCut2 = self.rootNode:getChildByName("shortCut2");
	local shortCut3 = self.rootNode:getChildByName("shortCut3");
	local shortCut4 = self.rootNode:getChildByName("shortCut4");
	local shortCut5 = self.rootNode:getChildByName("shortCut5");
	local shortCut6 = self.rootNode:getChildByName("shortCut6");

	shortCut1:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
			if currChooseItem then
				self:addShortCutItem(1, currChooseItem);
			else
				self:shortcutUse(1);
			end
        end
	end);

	shortCut2:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
            if currChooseItem then
				self:addShortCutItem(2, currChooseItem);
			else
				self:shortcutUse(2);
			end
        end
	end);

	shortCut3:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
            if currChooseItem then
				self:addShortCutItem(3, currChooseItem);
			else
				self:shortcutUse(3);
			end
        end
	end);

	shortCut4:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
            if currChooseItem then
				self:addShortCutItem(4, currChooseItem);
			else
				self:shortcutUse(4);
			end
        end
	end);

	shortCut5:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
            if currChooseItem then
				self:addShortCutItem(5, currChooseItem);
			else
				self:shortcutUse(5);
			end
        end
	end);

	shortCut6:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
            if currChooseItem then
				self:addShortCutItem(6, currChooseItem);
			else
				self:shortcutUse(6);
			end
        end
	end);
end

function BottomStateUI:updateShortcut(typeid, hasItem)
	if hasItem then
		return;
	end

	for k,v in pairs(shortCutItem) do
		local _typeid = v.typeid;
		if _typeid == typeid then
			self:delShortCutItem(k);
		end
	end
end

function BottomStateUI:delShortCutItem(idx)
	local shortCut1 = self.rootNode:getChildByName("shortCut"..idx);

	if shortCutItem[idx] then
		shortCut1:removeChild(shortCutItem[idx].icon);

		shortCutItem[idx] = nil;
	end
end

function BottomStateUI:execShortcut(keyCode)
	if keyCode >= 77 and keyCode <= 82 then
		self:shortcutUse(keyCode - 76);
	end

	if keyCode == 136 and self.bigmmapBack then
		local visible = self.bigmmapBack:isVisible();
		self.bigmmapBack:setVisible(not visible);
	end
end

function BottomStateUI:shortcutUse(idx)
	local back = shortCutItem[idx];

	if back then
		local typeid = back.typeid;

		local player = Account:getCurrActor();
		local sameItem = player:getItemForTypeid(typeid);
		if sameItem then
			TraceError("use item type"..typeid);
			TraceError("use item:"..tostring(sameItem:getID()));
			engine.dispachEvent("PLAYER_USE_ITEM", sameItem:getID());
		else
			self:delShortCutItem(idx);
		end
	end
end

function BottomStateUI:addShortCutItem(idx, typeid)
	local iconId = EquipmentConf[typeid].iconId;

	local shortCut1 = self.rootNode:getChildByName("shortCut"..idx);

	if shortCutItem[idx] then
		shortCut1:removeChild(shortCutItem[idx].icon);
	end

	local icon = engine.readSingleSpriteFromWzl(iconId, "data/Items.wil", "data/Items.wix", true);
	icon:setAnchorPoint(0,0);

	local size = icon:getContentSize();
	icon:setPosition(35/2 - size.width/2, 5);
	shortCut1:addChild(icon, 1);
	shortCutItem[idx] = {typeid=typeid, icon=icon};

	engine.dispachEvent("BAG_PUT_ITEM_BACK", {});
end

function BottomStateUI:initMMap(mapId, mmapId)
	if mmapId and mmapId > 0 then
		local mmapBack = self.rootNode:getChildByName("mmapBack")
		self.mmapBack = mmapBack:getChildByName("mmap")

		if self.mmapSprite then
			self.mmapBack:removeChild(self.mmapSprite);
		end

		self.mmapSprite = engine.readSingleSpriteFromWzl(mmapId, "data/mmap.wzl", "data/mmap.wzx", true);
		if self.mmapSprite then
			self.mmapSprite:setAnchorPoint(0, 0);
			self.mmapBack:addChild(self.mmapSprite);

			self.playerMark = ccui.Layout:create()
			self.playerMark:ignoreContentAdaptWithSize(false)
			self.playerMark:setClippingEnabled(true)
			self.playerMark:setTouchEnabled(true);
			self.playerMark:setLayoutComponentEnabled(true)
			self.playerMark:setContentSize(5, 5);
			self.playerMark:setPosition(0, 0)
			self.playerMark:setBackGroundColorType(1)
			self.playerMark:setBackGroundColor({r = 255, g = 255, b = 255})
			self.playerMark:setBackGroundColorOpacity(255)
			self.mmapSprite:addChild(self.playerMark);
		else
			self.mmapBack:removeChild(self.mmapSprite);
			self.mmapSprite = nil;
		end
	elseif mmapId and mmapId == 0 then
		if self.mmapSprite then
			self.mmapBack:removeChild(self.mmapSprite);
			self.mmapSprite = nil;
		end
	end

	local mapNameText = self.rootNode:getChildByName("mapNameText");
	local mapName = MapConf[mapId].sz_name;
	mapNameText:setString(mapName);
end

function BottomStateUI:initBigMMap(mapId, mmapId)
	if mmapId and mmapId ~= 0 then
		self.bigmmapBack = self.rootNode:getChildByName("bigmmapBack")

		if self.bigmmapSprite then
			self.bigmmapBack:removeChild(self.bigmmapSprite);
		end

		self.bigmmapSprite = engine.readSingleSpriteFromWzl(mmapId, "data/mmap.wzl", "data/mmap.wzx", true);
		if self.bigmmapSprite then
			self.bigmmapSprite:setAnchorPoint(0, 0);
			self.bigmmapBack:addChild(self.bigmmapSprite, 10);

			self.bigPlayerMark = ccui.Layout:create()
			self.bigPlayerMark:ignoreContentAdaptWithSize(false)
			self.bigPlayerMark:setClippingEnabled(true)
			self.bigPlayerMark:setTouchEnabled(true);
			self.bigPlayerMark:setLayoutComponentEnabled(true)
			self.bigPlayerMark:setContentSize(5, 5);
			self.bigPlayerMark:setPosition(0, 0)
			self.bigPlayerMark:setBackGroundColorType(1)
			self.bigPlayerMark:setBackGroundColor({r = 255, g = 255, b = 255})
			self.bigPlayerMark:setBackGroundColorOpacity(255)
			self.bigmmapSprite:addChild(self.bigPlayerMark);
		end
	elseif mmapId and mmapId == 0 then
		if self.bigmmapSprite then
			self:removeChild(self.bigmmapSprite);
			self.bigmmapSprite = nil;
		end
	end

	self.rootNode:getChildByName("bigmmapBack"):setVisible(false);
end

function BottomStateUI:updateBigMMap(mapPos, mapSize)
	if self.bigmmapSprite and self.bigmmapBack:isVisible() then
		local mmapSize = self.bigmmapSprite:getContentSize();
		local position = {x=mapPos.x/mapSize.width*mmapSize.width, y=mapPos.y/mapSize.height*mmapSize.height}
		self.bigPlayerMark:setPosition(position.x, position.y);

		local size = self.bigmmapSprite:getContentSize();
		--position           角色位置

		--获取屏幕尺�
		local screenSize = self.bigmmapBack:getContentSize();
		--计算Tilemap的宽高，单位是像�?
		local mapSizeInPixel = cc.size(size.width, size.height)--CCSizeMake(mapSize.width*tileSize.width,
		--mapSize.height*tileSize.height);
		--取勇士当前x坐标和屏幕中点x的最大值，如果勇士的x值较大，则会滚动
		local x=math.max(position.x,screenSize.width/2.0);
		local y=math.max(position.y,screenSize.height/2.0);
		--地图总宽度大于屏幕宽度的时候才有可能滚�?
		if mapSizeInPixel.width>screenSize.width then
			x=math.min(x,mapSizeInPixel.width-screenSize.width/2.0);
		end
		if mapSizeInPixel.height>screenSize.height then
			y=math.min(y,mapSizeInPixel.height-screenSize.height/2.0);
		end
		--勇士的实际位�?
		local heroPosition={x=x,y=y};
		--屏幕中点位置
		local screenCenter={x=screenSize.width/2.0,y=screenSize.height/2.0};
		--计算勇士实际位置和中点位置的距离
		local scrollPosition=cc.pSub(screenCenter,heroPosition);
		--将场景移动到相应位置
		self.bigmmapSprite:setPosition(scrollPosition);
	end
end

function BottomStateUI:updateMMap(mapPos, mapSize)
	if self.mmapSprite then
		local mmapSize = self.mmapSprite:getContentSize();
		local position = {x=mapPos.x/mapSize.width*mmapSize.width, y=mapPos.y/mapSize.height*mmapSize.height}
		self.playerMark:setPosition(position.x, position.y);

		local size = self.mmapSprite:getContentSize();
		--position           角色位置

		--获取屏幕尺�
		local mmapBack = self.rootNode:getChildByName("mmapBack");
		local mmap = mmapBack:getChildByName("mmap");
		local screenSize = mmap:getContentSize();
		--计算Tilemap的宽高，单位是像�?
		local mapSizeInPixel = cc.size(size.width, size.height)--CCSizeMake(mapSize.width*tileSize.width,
		--mapSize.height*tileSize.height);
		--取勇士当前x坐标和屏幕中点x的最大值，如果勇士的x值较大，则会滚动
		local x=math.max(position.x,screenSize.width/2.0);
		local y=math.max(position.y,screenSize.height/2.0);
		--地图总宽度大于屏幕宽度的时候才有可能滚�?
		if mapSizeInPixel.width>screenSize.width then
			x=math.min(x,mapSizeInPixel.width-screenSize.width/2.0);
		end
		if mapSizeInPixel.height>screenSize.height then
			y=math.min(y,mapSizeInPixel.height-screenSize.height/2.0);
		end
		--勇士的实际位�?
		local heroPosition={x=x,y=y};
		--屏幕中点位置
		local screenCenter={x=screenSize.width/2.0,y=screenSize.height/2.0};
		--计算勇士实际位置和中点位置的距离
		local scrollPosition=cc.pSub(screenCenter,heroPosition);
		--将场景移动到相应位置
		self.mmapSprite:setPosition(scrollPosition);
	end

	local posText = self.rootNode:getChildByName("posText");
	posText:setString(mapPos.x..","..mapPos.y);
end

function BottomStateUI:update(dt)
	if self.isMoveSlider then
		self:updateShowText();
	end
end

function BottomStateUI:registKeyboard()
	local function keyboardPressed(keyCode, event)
		local inputText = self.rootNode:getChildByName("input")

		if keyCode == 164 and inputText:getIsTttachIME() then
			engine.dispachEvent("SEND_MESSAGE", inputText:getInputText());
			inputText:setText("");
		else
			self:execShortcut(keyCode);
		end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher = self:getEventDispatcher()

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function BottomStateUI:initEventListener(btn, func, func2, func3)
	--local bagBtn = rootNode:getChildByName("bagBtn")
	btn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended and func then
            func();
        end

		if eventTouchType == ccui.TouchEventType.moved and func2 then
            func2();
        end

		if eventTouchType == ccui.TouchEventType.began and func3 then
            func3();
        end
    end);
end

function BottomStateUI:setBlood(curr, total)
	local chrWindow = self.rootNode:getChildByName("chrWindow")
	local bloodBar = chrWindow:getChildByName("bloodBar")
	bloodBar:setPercent(curr/total*100);
end

function BottomStateUI:setMagic(curr, total)
	local chrWindow = self.rootNode:getChildByName("chrWindow")
	local magicBar = chrWindow:getChildByName("magicBar")
	magicBar:setPercent(curr/total*100);
end

function BottomStateUI:setName(name)
	local nameLabel = self.rootNode:getChildByName("nameLabel")
	nameLabel:setString(name);
end

function BottomStateUI:show(str, fontSize, color)
	self:showNotice(str, fontSize, color)
end


function BottomStateUI:showImage(filename)
	--local listView = self.rootNode:getChildByName("NoticeWindow")
	--listView:insertImage(filename);
	--listView:jumpToPercentVertical(100);
end

function BottomStateUI:showNotice(str, fontSize, color)
	--local listView = self.rootNode:getChildByName("NoticeWindow")
	--listView:insertString(str, fontSize, color);
	--listView:jumpToPercentVertical(100);
end

function BottomStateUI:showMessage(str, fontSize, color)
	local listView = self.rootNode:getChildByName("ScrollView")
	listView:insertString(str, fontSize, color);
	listView:jumpToPercentVertical(100);
end

function BottomStateUI:updateShowText()
	local listView = self.rootNode:getChildByName("ScrollView")
	local slider = self.rootNode:getChildByName("slider")

	local percent = slider:getPercent();
	listView:jumpToPercentVertical(percent);
end

function BottomStateUI:updateNoticeWindow()
	--local listView = self.rootNode:getChildByName("NoticeWindow")
	--listView:jumpToPercentVertical(100);
end

function BottomStateUI:setLevel(level)
	local chrWindow = self.rootNode:getChildByName("chrWindow")
	local levelText = chrWindow:getChildByName("levelText")
	levelText:setString(level);
end

function BottomStateUI:setExc(exc, maxExc)
	local expBar = self.rootNode:getChildByName("expBar");
	expBar:setPercent(100*(exc/maxExc));
end

function BottomStateUI:clear()
	self.playerMark:release();
end

function BottomStateUI:readSetting(pid)
	local file = io.open("res/userSetting/"..pid.."/shotcutSetting.init");
	if file then
		for line in file:lines() do
			if line ~= "" then
				local str = split(line, "\t");
				local idx = tonumber(str[1]);
				local itemTypeId = tonumber(str[2]);


				self:addShortCutItem(idx, itemTypeId);
			end
		end

		file:close();
	end
end

function BottomStateUI:saveSetting()
	local actor = Account:getCurrActor();
	local pid = actor:getID();

	os.execute('md "res/userSetting"');
	os.execute('md "res/userSetting/'..pid..'"');

	local file = io.open("res/userSetting/"..pid.."/shotcutSetting.init","w");
	for k,v in pairs(shortCutItem) do
		local typeid = v.typeid;
		file:write(k.."\t"..typeid.."\n");
	end

	file:close();
end
