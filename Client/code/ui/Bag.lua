--region NewFile_1.lua
--Author : legend
--Date   : 2015/4/21
--此文件由[BabeLua]插件自动生成



--endregion
currChoose = nil;
currChooseItem = nil;
local useItemTime = 0.5;
local singleCellWidth = 37.5
local singleCellHeight = 37.5

Bag = class("Bag", function()
    return cc.Layer:create();
end)

function Bag:ctor()
    self:setSize(8,5);
end

function Bag:setSize(row, col)
    self.itemGroup = {};
    self.itemBackGroup = {};
    self.row = row;
    self.col = col;
    self.useItemClock = Clock:new();
    self.useItemClock:setRingTimeDelta(useItemTime);

    self:initUI();
	self:registListener();
	self:registMouse();
end

function Bag:setItemData(items)
    for k,v in pairs(items) do
        self:addItemWithIndex(v, k);
    end
end

function Bag:initUI()
    local back = engine.initSprite("UIRes/ui/000336.png");
    back:setAnchorPoint(0,0);
    back:setTag(0);
    self:addChild(back);

    local len = self.row * self.col;

    for i=0, len-1 do
        local itemCol = math.modf(i/self.row);
        local itemRow = math.fmod(i, self.row);

        local itemBack = cc.Layer:create();
        itemBack:setTag(i);
        itemBack:setPosition(26 + (itemRow)*37.5, 216 - (itemCol)*37.5);
        self.itemBackGroup[i+1] = itemBack;
        self:addChild(itemBack);
    end

    --gold label
    self.goldLabel = engine.initLabel();
	self.goldLabel:setWidth(120);
	self.goldLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT);
    self.goldLabel:setPosition(120, 38);
    self.goldLabel:enableShadow(cc.c4b(0,0,0,1));
    self:addChild(self.goldLabel);


	self:showGold(12321321);
    --close button
    local function closeWindow()
        self:hide();
    end

    local item = cc.MenuItemImage:create("UIRes/ui_common/000003.png","UIRes/ui_common/000005.png");
    item:registerScriptTapHandler(closeWindow)
    local menu = cc.Menu:create(item);
    menu:setPosition(345, 267);
    self:addChild(menu);

	self.itemIntro = ItemIntroduatory:new();
	self.itemIntro:setVisible(false);
	self:addChild(self.itemIntro);
end

function Bag:showGold(num)
    self.goldLabel:setString(num);
end

function Bag:addItem(item)
    local len = self.row * self.col;

    for i=1, len do
        if not self.itemGroup[i] then
            self:addItemWithIndex(item,i);
            return true;
        end
    end

    return false;
end

function Bag:addItemWithIndex(item, index)
	if index == nil then
		TraceError(debug.traceback());
	end

    if index > self.row * self.col then
        return false;
    end

    self.itemGroup[index] = item;

    self:addToUI(item, index);
end

function Bag:addToUI(item, i)
	local bagSize = item:getBagSpriteContentSize();
	local x = singleCellWidth/2 - bagSize.width/2;
	local y = singleCellHeight/2 - bagSize.height/2 - 5;
    item:setBagSpritePosition(x, y);

    --ui
	if self.itemBackGroup[i] then
		item:addToBag(self.itemBackGroup[i], 0);
	else
		TraceError("item back no exists id:"..tostring(i));
	end
end

function Bag:clearItem()
    for k,v in pairs(self.itemGroup) do
        self:removeItem(k);
    end
end

function Bag:removeItem(i)
    local item = self.itemGroup[i];

    --ui
    if item then
        item:removeFromBag();
        self.itemGroup[i] = nil;
    end

    return item;
end

function Bag:addItemUI(item, i)
    item:addToBag(self.itemBackGroup[i], 0);
end

function Bag:removeItemUI(i)
    local item = self.itemGroup[i];

    --ui
    item:removeFromBag();

    return item;
end

function Bag:show()
    self:setVisible(true);
end

function Bag:hide()
    self:setVisible(false);
	self.itemIntro:setVisible(false);
end

function Bag:getChooseItem()

end

function Bag:getCurrChooseIndex()
    return currChoose;
end

function Bag:isTouchTitle(point)
    local bagX,bagY = self:getPosition();

    if point.x >= 24 + bagX and point.x <= bagX + 324 and
        point.y >= bagY + 254 and point.y <= bagY + 284 then
        return true;
    end

    return false;
end

function Bag:getTouchItemIndex(point)
    for i=1, #self.itemBackGroup do
        local itemBack = self.itemBackGroup[i];
        local location = itemBack:convertToNodeSpace(point)
        local rect = cc.rect(0,0,37.5, 37.5)

        if cc.rectContainsPoint(rect,location) then
            return i;
        end
    end

    return nil;
end


function Bag:useItem(touch)
    local point = touch:getLocation();
    local itemIndex = self:getTouchItemIndex(point);

    if itemIndex then
        local item = self.itemGroup[itemIndex] or currChooseItem;

        if item then
            if self.pressItem and item == self.pressItem and self.useItemClock:ring()==false then
                self:endMoveItem();

                engine.dispachEvent("PLAYER_USE_ITEM", item:getID());

                self.pressItem = nil;

				self.itemIntro:setVisible(false);

                return true;
            else
                self.pressItem = item;
				self.pressMousePoint = point;

				local x,y = self.itemBackGroup[itemIndex]:getPosition();
				local bagSize = item:getBagSpriteContentSize();
				local itemx = x + singleCellWidth/2 - bagSize.width/2;
				local itemy = y + singleCellHeight/2 - bagSize.height/2 - 5;

				self.pressItemPoint = {x=itemx,y=itemy};
                self.useItemClock:markRingTime();
            end

			if self.itemIntro:isVisible() then
				self.itemIntro:setVisible(false);
			else
				local selfX,selfY = self:getPosition();
				self.itemIntro:setPosition(point.x-selfX, point.y-selfY);
				self.itemIntro:setItem(item);
				self.itemIntro:setVisible(true);
			end
        end
	else
		if self.itemIntro:isVisible() then
			self.itemIntro:setVisible(false);
		end
    end

    return false;
end

function Bag:touchItem(touch)
    if currChooseItem then
        return;
    end

    local point = touch:getLocation();
    --点击标题
    if self:isTouchTitle(point) then
        self.pressTitlePoint = point;
        self.oldBagX,self.oldBagY = self:getPosition();
		return;
    end

    local itemIndex = self:getTouchItemIndex(point);
    if itemIndex then
        currChooseItem = self:removeItem(itemIndex);
        if currChooseItem then
            local parent = self:getParent();
            currChoose = itemIndex;
            currChooseItem:addToBag(parent, 1);

            self:movingItem(point);
        end
    end

    return true;
end


function Bag:movingItem(point)
    if currChooseItem then
		local selfX,selfY = self:getPosition();
		local newPoint = {x=self.pressItemPoint.x - self.pressMousePoint.x + point.x,y=self.pressItemPoint.y - self.pressMousePoint.y + point.y};
        currChooseItem:setBagSpritePosition(newPoint.x + selfX, newPoint.y + selfY);
    end
end

function Bag:interChangeItem(index1, index2)
    engine.dispachEvent("PLAYER_CHANGE_ITEM", {index1=index1, index2=index2})
end

function Bag:endMoveItem()
    if not currChooseItem then
        return;
    end

    local i = currChoose;
    local currTouchItemIndex = self:getTouchItemIndex(self.mousePoint);

    currChooseItem:removeFromBag();
    self:addItemWithIndex(currChooseItem, i);

    if currTouchItemIndex and i ~= currTouchItemIndex then
        self:interChangeItem(currTouchItemIndex, i);
    end

	--judge if move out of the dialog
	if self:checkMoveOutOf(self.mousePoint) then
		--engine.dispachEvent("THROW_ITEM", currChooseItem);
		--currChoose = nil;
		--currChooseItem = nil;
		currState = true;

		return nil;
	end

	currChoose = nil;
	currChooseItem = nil;
	currState = false;
end

function Bag:checkMoveOutOf(point)
	local back = self:getChildByTag(0);
	local size = back:getContentSize();
	local location = back:convertToNodeSpace(point)
	local rect = cc.rect(0,0, size.width, size.height)

	if not cc.rectContainsPoint(rect,location) then
		return true;
	end

	return nil;
end

function Bag:moveingTitle(point)
    if self.pressTitlePoint then
        self:setPosition({x=self.oldBagX+point.x-self.pressTitlePoint.x,
            y=self.oldBagY+point.y-self.pressTitlePoint.y});
    end
end

function Bag:endMoveTitle(point)
    self.pressTitlePoint = nil;
end

function Bag:pointIsInBackground(point)
    local background = self:getChildByTag(0);
    local location = background:convertToNodeSpace(point)
    local size = background:getContentSize();
    local rect = cc.rect(0,0, size.width, size.height)

    if cc.rectContainsPoint(rect,location) then
        return true;
    end

    return false;
end

---------------------
---
---onTouchFunction
---
---------------------
function Bag:onTouchesBegan(touch, events)
    self.mousePoint = touch:getLocation();

	if currChooseItem then
		if self:useItem(touch) == false then
			return self:endMoveItem();
		end
	else
		if self:useItem(touch) == false then
			self:touchItem(touch);
		end
	end
end

function Bag:onTouchesMoved(touch, events)
    local point = touch:getLocation();
    self.mousePoint = point;

    --self:movingItem(point);
    self:moveingTitle(point);
end

function Bag:onTouchesEnded(touches, events)
	self:endMoveTitle()
end


function Bag:registListener()
    local function onTouchEnded(touch, event)
        self:onTouchesEnded(touch, event);
    end

    local function onTouchBegan(touch, event)
		if self:isVisible() == false then
            return false;
        end

        local ret = self:onTouchesBegan(touch, event);
		if ret then
			return ret;
		end

		local ret = self:pointIsInBackground(touch:getLocation());
        return ret;
    end

    local function onTouchMoved(touch, event)
        self:onTouchesMoved(touch, event);
    end

    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function Bag:registMouse()
	local function onMouseMove(event)
		local x = event:getCursorX();
		local y = event:getCursorY();

		if currChooseItem then
			local point = {x=x,y=y};

			self:movingItem(point);
			self:moveingTitle(point);
		end
	end

	local listener = cc.EventListenerMouse:create();
    listener:registerScriptHandler(onMouseMove, cc.Handler.EVENT_MOUSE_MOVE)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end
