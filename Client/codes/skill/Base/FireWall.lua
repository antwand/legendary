FireWall = class("RangeSpell", function()
    return RangeSpell:new();
end)

function FireWall:initAttribute(param)
    self.baseDamage  = param.baseDamage;
    self.growDamage  = param.growDamage;
    self.attackType  = param.attackType
    self.name        = param.sz_name
    self.event       = param.sz_event
    self.action      = param.action
    self.specialFunc = param.sepcialFunc;
    self.triggerRate = param.triggerRate;
    self.priority    = param.priority;
    self.castRange   = param.castRange;
	self.type        = param.type;
	self.needMagic   = param.needMagic;
	self.maxWallNum  = 4;
	self.wallList    = {};
    self.castClock:setRingTimeDelta(param.coolDown);

    self.effect      = EffectManager:getEffect(param.effectid);

	for i=1, self.maxWallNum do
		local wall = FireWallUnit:new();
		wall:setEffect(param.boomeffectid);
		wall:setRunningTime(param.runningTime);
		table.insert(self.wallList, #self.wallList+1, wall);
	end

	self.currWallUnit = 0;
end

function FireWall:update(object)
	for k,v in pairs(self.wallList) do
		v:update(object);
	end
end

function FireWall:playBoomEffect(object, tarPoint)
	local layer    = object:getLayer();
    --调整位置
	local tarPosition = FuncPack:pointToPosition(tarPoint);

	local wall = self:getNextFireWallUnit();

	--print("cast fireWall at ("..tarPosition.x..","..tarPosition.y..")");
	wall:start(layer, tarPosition);
end

function FireWall:getNextFireWallUnit()
	local wall = self.wallList[self.currWallUnit+1];

	self.currWallUnit = (self.currWallUnit + 1) % (self.maxWallNum);

	return wall;
end

function FireWall:closeEffect(effect)
	if effect ~= nil then
		effect.sprite:setVisible(false);
        effect:stopAllActions();
		return;
	end

    if self.effect then
        self.effect.sprite:setVisible(false);
        self.effect:stopAllActions();
    end
	--[[
	if self.flyEffect then
		self.flyEffect.sprite:setVisible(false);
        self.flyEffect:stopAllActions();
	end

	if self.fireLeftEffect then
        self.fireLeftEffect.sprite:setVisible(false);
        self.fireLeftEffect:stopAllActions();
    end

	if self.fireUpEffect then
        self.fireUpEffect.sprite:setVisible(false);
        self.fireUpEffect:stopAllActions();
    end

	if self.fireRightEffect then
        self.fireRightEffect.sprite:setVisible(false);
        self.fireRightEffect:stopAllActions();
    end

	if self.fireDownEffect then
        self.fireDownEffect.sprite:setVisible(false);
        self.fireDownEffect:stopAllActions();
    end]]
end


function FireWall:release()
    if self.effect then
        self.effect:release();
    end

	if self.flyEffect then
		self.flyEffect:release();
	end

	if self.boomEffect then
		self.boomEffect:release();
	end

	--[[
	if self.fireLeftEffect then
        self.fireLeftEffect.sprite:release();
    end

	if self.fireUpEffect then
        self.fireUpEffect.sprite:release();
    end

	if self.fireRightEffect then
        self.fireRightEffect.sprite:release();
    end

	if self.fireDownEffect then
        self.fireDownEffect.sprite:release();
    end]]
end
