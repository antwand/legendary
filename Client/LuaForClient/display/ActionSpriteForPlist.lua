ActionSpriteForPlist = {}
ActionSpriteForPlist.__index = ActionSpriteForPlist

function ActionSpriteForPlist:create()
    local sprite = {};
    setmetatable(sprite,ActionSpriteForPlist)
    sprite:ctor();
    return sprite;
end

function ActionSpriteForPlist:ctor()
    self.actionName = "";
    self.actionList = {};
    self.actionOffset = {};
    self.sprite = nil;
    self.lastAction = nil;
    self.actionCount = 0;
end

function ActionSpriteForPlist:setSprite(sprite)
	self.sprite = sprite;

	self.sprite:setAnchorPoint(0, 0)
    self.sprite:retain();
end

function ActionSpriteForPlist:addActions(actions)
    for k,v in pairs(actions) do
        self:addAction(v, k);
    end
end

function ActionSpriteForPlist:addActionOffset(actionName, offsetTable)
    if self.actionList[actionName] == nil then
        return -1;
    end

    self.actionOffset[actionName] = offsetTable;
end

function ActionSpriteForPlist:initSpriteFromFrameCache(name)
    self.sprite = engine.initSpriteFromFrameCache(name);

    return self.sprite;
end

function ActionSpriteForPlist:addAction(animate, actionName)
    if self.sprite == nil then
        self:interInitSprite(animate);
    end

    if self.actionList[actionName] ~= nil then
        return -1;
    end

    self.actionList[actionName] = animate;

    --retain,保持动画不被销毁
    animate:retain();

    self.actionCount = self.actionCount + 1;

    return 1;
end

function ActionSpriteForPlist:interInitSprite(animate)
    local animation = animate:getAnimation();
    local animationframe = animation:getFrames()[1]
    local spriteFrame = animationframe:getSpriteFrame();
    self.sprite = engine.initSpriteFromSpriteFrame(spriteFrame);--et.SpriteX:createWithSpriteFrame(spriteFrame)
    self.sprite:setAnchorPoint(0, 0)
    self.sprite:retain();
end

--销毁所属动作集
function ActionSpriteForPlist:release()
    for k,v in pairs(self.actionList) do
       v:release();
    end

    self.sprite:release();
end

function ActionSpriteForPlist:retain()
    --self.sprite:retain();
end

function ActionSpriteForPlist:runSameAction(actionName)
    if self.actionName ~= actionName then
        return nil;
    end

    return true;
end

function ActionSpriteForPlist:runActions(actionArray)
    local sequence = cc.Sequence:create(actionArray);
    self.sprite:runAction(sequence);
end

function ActionSpriteForPlist:runAction(actionName, actionArray)
	local lastAction = self.actionList[self.actionName];
	if lastAction then
		--self.sprite:stopAction(lastAction);
	end

    if actionArray == nil then
		if self.actionList[actionName] then
			self.sprite:runAction(self.actionList[actionName]);

			self.lastAction = self.actionList[actionName];
		else
			--TraceError("no animate "..actionName);
		end
    else
		if self.actionList[actionName] then
			table.insert(actionArray, 1, self.actionList[actionName]);
		end

        local sequence = cc.Sequence:create(actionArray);
        self.sprite:runAction(sequence);

		self.lastAction = sequence;
    end

	self.actionName = actionName;

    return 1;
end

function ActionSpriteForPlist:getLastAction()
    return self.lastAction;
end

function ActionSpriteForPlist:stopActionWithName(actionName)
    if self.actionList[actionName] == nil then
        return -1;
    end

    self.sprite:runAction(self.actionList[actionName]);

    return 1;
end

function ActionSpriteForPlist:stopAction(action)
    self.sprite:stopAction(action);

    return 1;
end

function ActionSpriteForPlist:stopAllActions()
    self.sprite:stopAllActions();
end

function ActionSpriteForPlist:addTo(parent, zOrder)
    if not zOrder then
        zOrder = 0;
    end

    parent:addChild(self.sprite, zOrder)
end

function ActionSpriteForPlist:setPosition(x, y)
    self.sprite:setPosition(x, y);
end

function ActionSpriteForPlist:getPosition()
    local _x, _y = self.sprite:getPosition();
    return {x=_x, y=_y};
end

function ActionSpriteForPlist:setEffect(effectid)
    self.sprite:setEffect(effectid);
end

function ActionSpriteForPlist:setLocalZOrder(zOrder)
    self.sprite:setLocalZOrder(zOrder);
end

function ActionSpriteForPlist:setVisible(visible)
    self.sprite:setVisible(visible);
end

function ActionSpriteForPlist:setEdging(outlineSize, color)
	if self.sprite then
		local contentSize = self.sprite:getContentSize();
		self.sprite:setEdging(outlineSize, color, contentSize);
	end
end

function ActionSpriteForPlist:setOpacity(opacity)
	if self.sprite then
		self.sprite:setOpacity(opacity);
	end
end

function ActionSpriteForPlist:getVisible()
    return self.sprite:getVisible();
end

function ActionSpriteForPlist:getActionCount()
	local actionCount = 0;
	for k,v in pairs(self.actionList) do
		actionCount = actionCount + 1;
	end

    return actionCount;
end

function ActionSpriteForPlist:getParent()
    return self.sprite:getParent();
end

function ActionSpriteForPlist:setActionsSpeed(names, duration)
    for k,name in pairs(names) do
        local action = self.actionList[name];

        if action then
            action:setDuration(duration);
        end
    end
end

function ActionSpriteForPlist:setCurrFrameIndex(index)
    if self.actionList[self.actionName] == nil then
        return -1;
    end

    local animation = self.actionList[self.actionName]:getAnimation();
    local animationframe = animation:getFrames()[index]
    local spriteFrame = animationframe:getSpriteFrame();

    self.sprite:setSpriteFrame(spriteFrame);
end

function ActionSpriteForPlist:isRunning()
    return self.sprite:isRunning();
end

function ActionSpriteForPlist:setAllActionsSpeed(duration)
    for k,v in pairs(self.actionList) do
        v:setDuration(duration);
    end
end

function ActionSpriteForPlist:remove()
    if self.sprite:getParent() then
        self.sprite:getParent():removeChild(self.sprite)
    end
end

function ActionSpriteForPlist:release()
	if self.sprite then
		self.sprite:release();
	end

	self.sprite = nil;
    --self:stopAllActions();
	--���ﲻ����ôд��ӦΪ����ͷ�����Ķ����Ļ�������ͬһ�������Ľ�ɫ�����ͷ�һ�Σ��ͻᵼ��Ұָ��
	--[[
    for k,v in pairs(self.actionList) do
        v:release();
    end]]
end

function ActionSpriteForPlist:copy(asprite)
	local parent = self:getParent();
	local pos = self:getPosition();
	asprite:release();

	self.actionList = asprite.actionList;

	for k,v in pairs(self.actionList) do
		local animation = v:getAnimation();
		local animationframe = animation:getFrames()[1]
		local spriteFrame = animationframe:getSpriteFrame();
		local offsetStr = spriteFrame:getOffset();
		self.sprite:setSpriteFrame(spriteFrame);

		self:runAction(self.actionName);

		return;
	end
end
