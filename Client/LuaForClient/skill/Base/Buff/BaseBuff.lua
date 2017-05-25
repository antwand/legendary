BaseBuff = class("BaseBuff")

function BaseBuff:ctor()
	self.name = "";
	self.type = 1;
	self.runningTime = 0;
	self.runningTimer = nil;--Timer:new();

	self.target = nil;
end

function BaseBuff:init(param)
	self.id = param.id;
	self.name = param.sz_name;
	self.type = param.type;
	self.runningTime = param.runningTime;
end

function BaseBuff:getID()
	return self.id;
end

function BaseBuff:update(target)
end

function BaseBuff:resetDelay(_delay)
	self.runningTimer:resetDelay(_delay);
end

function BaseBuff:attachTo(target)
	local sameTypeBuff = target:getBuff(self.type);
	if sameTypeBuff then
		local lastTime = sameTypeBuff:getRemainTime();
		local newTime = math.max(self.runningTime, lastTime);
		sameTypeBuff:resetDelay(newTime);
	else
		if self.runningTimer then
			local newTime = math.max(self.runningTime, self:getRemainTime());
			self.runningTimer:resetDelay(newTime);
		else
			target:unLockActorStatus();
			target:stopAllActions();
			target:stopScripts();
			target:lockActorBehavior();
			target:idle();
			target:addBuff(self);
			target:setEffect(1);

			self.runningTimer = TimerManager:getTimer():scheduleOnce(self.runningTime, function()
				self.runningTimer = nil;
				self.target:delBuff(self);
				self.target:updateState();
				self.target:unLockActorBehavior();
				self.target = nil;
			end);
		end

		self.target = target;
	end
end

function BaseBuff:isFree()
	if self.runningTimer then
		return self.runningTimer:getSleep();
	end

	return nil;
end

function BaseBuff:getRemainTime()
	if self.runningTimer then
		return self.runningTimer:getRemainTime();
	end

	return nil;
end

function BaseBuff:close()
	--buff did not close itself

end
