ActionSprite = {}
ActionSprite.__index = ActionSprite

function ActionSprite:create()
    local sprite = {};
    setmetatable(sprite,ActionSprite)
    sprite:ctor();
    return sprite;
end

function ActionSprite:ctor()
    self.actionName = "";
    self.actionList = {};
    self.actionOffset = {};
    self.sprite = nil;
    self.lastAction = nil;
    self.actionCount = 0;
	self.logSwitch = nil;
end

function ActionSprite:setSprite(sprite)
	self.sprite = sprite;

	self.sprite:setAnchorPoint(0, 0)
    self.sprite:retain();
end

function ActionSprite:addActions(actions)
    for k,v in pairs(actions) do
        self:addStateAni(v, k);
    end
end

function ActionSprite:addActionOffset(actionName, offsetTable)
    if self.actionList[actionName] == nil then
        return -1;
    end

    self.actionOffset[actionName] = offsetTable;
end

function ActionSprite:initSpriteFromFrameCache(name)
    self.sprite = engine.initSpriteFromFrameCache(name);

    return self.sprite;
end

function ActionSprite:addAction(animate, actionName)
    if self.sprite == nil then
        self:interInitSprite(animate);
    end

    if self.actionList[actionName] ~= nil then
        return -1;
    end

    self.actionList[actionName] = animate;

    --retain,保持动画不被销毁
    --animate:retain();

    self.actionCount = self.actionCount + 1;

    return 1;
end

function ActionSprite:setShaderEnable(enable)
	if self.sprite then
		self.sprite:setShaderEnable(enable);
	end
end

function ActionSprite:interInitSprite(animate)
    local animation = animate:getAnimation();
    local animationframe = animation:getFrames()[1]
    local spriteFrame = animationframe:getSpriteFrame();
    self.sprite = engine.initSpriteFromSpriteFrame(spriteFrame);--et.SpriteX:createWithSpriteFrame(spriteFrame)
    self.sprite:setAnchorPoint(0, 0)
    self.sprite:retain();
end

--销毁所属动作集
function ActionSprite:release()
	--[[
    for k,v in pairs(self.actionList) do
       v:release();
    end
	]]
    self.sprite:release();
end

function ActionSprite:isClick(point)
	return  self.sprite:isClick(point);
end

function ActionSprite:getLeftBottomPosition()
	local spriteframe = self.sprite:getSpriteFrame();
	local offset = spriteframe:getOffset();
	local position = self:getPosition();

	return {x=position.x+offset.x, y=position.y+offset.y};
end

function ActionSprite:retain()
    --self.sprite:retain();
end

function ActionSprite:runSameAction(actionName)
	--TraceError("check run same action:"..self.actionName.."   new name:"..actionName);
    if self.actionName ~= actionName then
        return nil;
    end

    return true;
end

function ActionSprite:runActions(actionArray)
    local sequence = cc.Sequence:create(actionArray);
    self.lastAction = self.sprite:runAction(sequence);
end

function ActionSprite:runAction(actionName, actionArray)
    if actionArray == nil then
		success = self.sprite:runStateAni(actionName);

		if success then
			self.lastAction = self.sprite:getAnimateFromName(actionName);
		end
    else
		local animate = self.sprite:getAnimateFromName(actionName);
		if animate then
			table.insert(actionArray, 1, animate);
		end

		--TraceError("     debug:"..debug.traceback());
        local sequence = cc.Sequence:create(actionArray);
        success = self.sprite:runAction(sequence);

		self.lastAction = success;
    end

	self.actionName = actionName;

	--TraceError("run action:"..actionName);

    return 1, success;
end

function ActionSprite:getLastAction()
    return self.lastAction;
end

--[[
function ActionSprite:stopActionWithName(actionName)
    if self.actionList[actionName] == nil then
        return -1;
    end

    self.sprite:runAction(self.actionList[actionName]);

    return 1;
end
]]

function ActionSprite:stopAction(action)
    self.sprite:stopAction(action);
    return 1;
end

function ActionSprite:stopAllActions()
    self.sprite:stopAllActions();
end

function ActionSprite:addTo(parent, zOrder)
    if not zOrder then
        zOrder = 0;
    end

    parent:addChild(self.sprite, zOrder)
end

function ActionSprite:setPosition(x, y)
    self.sprite:setPosition(x, y);
end

function ActionSprite:getPosition()
    local _x, _y = self.sprite:getPosition();
    return {x=_x, y=_y};
end

function ActionSprite:setEffect(effectid)
    self.sprite:setEffect(effectid);
end

function ActionSprite:setLocalZOrder(zOrder)
    self.sprite:setLocalZOrder(zOrder);
end

function ActionSprite:setVisible(visible)
    self.sprite:setVisible(visible);
end

function ActionSprite:setEdging(outlineSize, color)
	if self.sprite then
		local contentSize = self.sprite:getContentSize();
		self.sprite:setEdging(outlineSize, color, contentSize);
	end
end

function ActionSprite:setOpacity(opacity)
	if self.sprite then
		self.sprite:setOpacity(opacity);
	end
end

function ActionSprite:getVisible()
    return self.sprite:getVisible();
end

function ActionSprite:getActionCount()
    return self.sprite:getAinmateCount();
end

function ActionSprite:getParent()
    return self.sprite:getParent();
end

function ActionSprite:setActionsSpeed(names, duration)
	if not self.sprite then
		TraceError("no self.sprite");
		return;
	end

    for k,name in pairs(names) do
        local animate = self.sprite:getAnimateFromName(name);

		if not animate then
			--TraceError("no found animate:"..name.." duration:"..duration);
		else
			animate:setDuration(duration);
		end
    end
end

function ActionSprite:setCurrFrameIndex(index, name)
	if not self.sprite then
		TraceError("no self.sprite");
		return;
	end

	if not name then
		name = self.actionName;
	end

	local animate = self.sprite:getAnimateFromName(name);

	if animate then
		local animation = animate:getAnimation();
		local animationframe = animation:getFrames()[index];
		local spriteFrame = animationframe:getSpriteFrame();

		self.sprite:setSpriteFrame(spriteFrame);
		self.sprite:setBlendFunc(self.sprite:getBlendFunc());
	end
end

function ActionSprite:setLastCurrFrameIndex(name)
	if not self.sprite then
		TraceError("no self.sprite");
		return;
	end

	if not name then
		name = self.actionName;
	end

	local animate = self.sprite:getAnimateFromName(name);

	if animate then
		local animation = animate:getAnimation();
		local frames = animation:getFrames();
		local animationframe = frames[#frames];
		local spriteFrame = animationframe:getSpriteFrame();

		self.sprite:setSpriteFrame(spriteFrame);
		self.sprite:setBlendFunc(self.sprite:getBlendFunc());
	end

	self.actionName = name;
end

function ActionSprite:isRunning()
    return self.sprite:isPlayingAction();
end

function ActionSprite:setAllActionsSpeed(duration)
	for i=0,self.sprite:getAinmateCount()-1 do
		local animate = self.sprite:getAnimateFromIndex(i);

		if animate then
			animate:setDuration(duration);
		end
	end
end

function ActionSprite:remove()
    if self.sprite and self.sprite:getParent() then
        self.sprite:getParent():removeChild(self.sprite)
    end
end

function ActionSprite:retain()
	if self.sprite then
		self.sprite:retain();
	end
    --self:stopAllActions();
	--���ﲻ����ôд��ӦΪ����ͷ�����Ķ����Ļ�������ͬһ�������Ľ�ɫ�����ͷ�һ�Σ��ͻᵼ��Ұָ��
	--[[
    for k,v in pairs(self.actionList) do
        v:release();
    end]]
end

function ActionSprite:getReferenceCount()
	if self.sprite then
		return self.sprite:getReferenceCount();
	end
end

function ActionSprite:addChild(node, order)
	if self.sprite then
		self.sprite:addChild(node, order);
	end
end

function ActionSprite:getChildByTag(tag)
	if self.sprite then
		return self.sprite:getChildByTag(tag);
	end
end

function ActionSprite:removeChild(node)
	if self.sprite then
		self.sprite:removeChild(node);
	end
end

function ActionSprite:release()
	if self.sprite then
		self.sprite:release();
	end

	--self.sprite = nil;
    --self:stopAllActions();
	--���ﲻ����ôд��ӦΪ����ͷ�����Ķ����Ļ�������ͬһ�������Ľ�ɫ�����ͷ�һ�Σ��ͻᵼ��Ұָ��
	--[[
    for k,v in pairs(self.actionList) do
        v:release();
    end]]
end

function ActionSprite:merge(_sprite)
	if self.sprite then
		self.sprite:merge(_sprite);
		self.lastAction = self:runAction(self.actionName);
	else
		_sprite:release();
	end
end
