FireWallUnit = class("FireWallUnit")

function FireWallUnit:ctor()

end

function FireWallUnit:setEffect(effectid)
	self.fireCenterEffect   = EffectManager:getEffect(effectid);
	self.fireLeftEffect     = EffectManager:getEffect(effectid);
	self.fireUpEffect       = EffectManager:getEffect(effectid);
	self.fireRightEffect    = EffectManager:getEffect(effectid);
	self.fireDownEffect     = EffectManager:getEffect(effectid);

	self.runningClock = Clock:new();
	self.isRun = nil;
end

function FireWallUnit:start(layer, point)
	self.isRun = true;

	self.runningClock:markRingTime();
	self:initPosition(layer, point);
end

function FireWallUnit:close()
	if self.fireCenterEffect then
		self.fireCenterEffect.sprite:setVisible(false);
        self.fireCenterEffect:stopAllActions();
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
    end

	self.isRun = nil;
end

function FireWallUnit:setRunningTime(_time)
	self.runningClock:setRingTimeDelta(_time);
end

function FireWallUnit:initPosition(layer, point)
	local upPos = FuncPack:PositionTopoint(FuncPack:nextPositionWithDir(point, 1, 1));
	local leftPos = FuncPack:PositionTopoint(FuncPack:nextPositionWithDir(point, 7, 1));
	local rightPos = FuncPack:PositionTopoint(FuncPack:nextPositionWithDir(point, 3, 1));
	local downPos = FuncPack:PositionTopoint(FuncPack:nextPositionWithDir(point, 5, 1));
	local centerPos = FuncPack:PositionTopoint(point);
    self:playFireEffect(layer, self.fireCenterEffect, centerPos)
	self:playFireEffect(layer, self.fireLeftEffect, leftPos)
	self:playFireEffect(layer, self.fireUpEffect, upPos)
	self:playFireEffect(layer, self.fireRightEffect, rightPos)
	self:playFireEffect(layer, self.fireDownEffect, downPos)
end

function FireWallUnit:update(object)
	if self.isRun then
		if self.runningClock:ring() then
			self:close();
		end
	end
end

function FireWallUnit:playFireEffect(layer, effect, pos)
	effect:remove();
	effect:addTo(layer, LayerzOrder.SKILL);

	effect:runAction("1");
	effect:setPosition(pos.x, pos.y);
	effect:setVisible(true);
end

function FireWallUnit:release()
	if self.fireCenterEffect then
		self.flyEffect:release();
	end

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
    end
end
