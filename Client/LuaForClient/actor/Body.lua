Body = class("Body")

function Body:ctor()
	self.nakedBody = nil;   --初始身体，如果part[1]没有值则显示这个身体
    self.parts =
    {
        [1] = nil,   --衣服
        [2] = nil,   --武器
        [3] = nil,   --头盔
        [4] = nil,   --项链
        [5] = nil,   --手镯
        [6] = nil,   --手镯
        [7] = nil,   --戒指
        [8] = nil,   --戒指
        [9] = nil,   --头发
        [10] = nil,  --待定
    }

	self.x = 0;
	self.y = 0;
	self.dir = 1;
	self.status = 1;
	self.zOrder = 0;
end

function Body:setNakedBody(_nakedBody)
	self.nakedBody = _nakedBody;
end

function Body:loadPart(part, partType)
    if partType > 10 or partType <= 0 or not part then
        print("invalid part "..partType);
        return;  --组件不合�?
    end

	--卸载旧装�?
    local oldPart = self.parts[partType];
    if oldPart then
        self:unLoadPart(partType);
	else
		oldPart = 1;
    end

	--装备加载到大地图
	local pos = self:getPosition();
	part:setPosition(pos.x, pos.y);

	--更新装备状�?
	self:changePartStatus(part.mapSprite);

	--更新数据
	self.parts[partType] = part;

    --大地图上
    local stage = self:getParent();
    if stage then
        part:addTo(stage, self.zOrder - partType);
    end

    if partType == 1 and self.nakedBody then
        self.nakedBody:setVisible(false);
    end

    --更新组件的order
    self:adjustPartZOrder();

    return oldPart;
end

function Body:adjustPartZOrder(ZOrder)

end

function Body:setNakedBody(_body)
	self.nakedBody = _body;
end

function Body:unLoadPart(partType)
	if partType > 10 or partType <= 0 then
        return;  --组件不合�?
    end

    local part = self.parts[partType];
    if not part then
        return;
    end

    self.parts[partType] = nil
    part:remove();

    if partType == 1 and self.nakedBody then
        self.nakedBody:setVisible(true);
    end

    return part;
end

function Body:changeStatus(status, actionArray)
	for partType, part in pairs(self.parts) do
        if partType == 1 then
            self:changePartStatus(part, actionArray);
        else
            self:changePartStatus(part);
        end
    end

    --是否没有装备衣服,如果没有则状态变化的是裸体身�?
    if not self.parts[1] and self.nakedBody then
        self:changePartStatus(self.nakedBody, actionArray);
    end

	self.status = _status
end

function Body:changePartStatus(part, actionArray)
	if not part then
        return false;
    end

	local aniIndex = self.dir + (self.status-1) * statusAniStep
    local aniName = tostring(aniIndex);

    if part:runSameAction(aniName) and part:isRunning() then
        return true;--self:unLockActorBehavior();--sprite:isRunning()
    else
        part:stopAllActions();
        return part:runAction(aniName, actionArray);
    end
end

function Body:adjustPartZOrder()
    for partType,part in pairs(self.parts) do
        if (self.dir >= 2 and self.dir <= 5) and partType == 2 then
            part:setLocalZOrder(self.zOrder)
        else
            part:setLocalZOrder(self.zOrder - partType)
        end
    end

    if self.nakedBody then
        self.nakedBody:setLocalZOrder(self.zOrder - 1)
    end
end

function Body:runActions(actions)
    if self.parts[1] then
        self.parts[1]:runActions(actions);
    else
        if self.nakedBody then
            self.nakedBody:runActions(actions);
        end
    end
end

function Body:getParent()
	if self.nakedBody then
        return self.nakedBody:getParent();
    end
end

function Body:setPosition(_x, _y)
	for k, part in pairs(self.parts) do
        part:setPosition(_x, _y);
    end

    if self.nakedBody then
        self.nakedBody:setPosition(_x ,_y);
    end
end

function Body:getPosition()
	return {x=self.x, y=self.y}
end

function Body:setZorder(order)
	self.zOrder = order;
end
