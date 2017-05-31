GodMon = class("GodMon", function()
    return Actor:new()
end)

local statusAniStep = 8

function GodMon:ctor()
	self.climbStatusEnum =
	{
		["appear"] = 1,
		["stand"] = 2,
		["walk"] = 3,
		["hurt"] = 4,
		["die"] = 5,
		["change"] = 6,
		["slash"] = 9,
	}

	self.standStatusEnum =
	{
		["stand"] = 7,
		["walk"] = 8,
		["slash"] = 9,
		["hurt"] = 10,
		["die"] = 11,
		["change"] = -6,
	}

	self.appearTime = 1.0;
	self.poseTimme = 1.0;
	self:markIsStand(nil);
end

function GodMon:getIsStand()
	return self.isStand;
end

function GodMon:stand(func)
	if not self.isStand and not self:getLockBehavior() then
		self:lockActorBehavior();

		local callfunc = cc.CallFunc:create(function()
			self:markIsStand(true);
			self:unLockActorBehavior();
			self:idle();

			if func then
				func();
			end
			--print("end callback  self.idleStatus:"..tostring(self.idleStatus).."   lock behavior:"..tostring(self:getLockBehavior()));
		end)

		self:setStatusSpeed(self.climbStatusEnum["change"], self.poseTimme);
		local ret = self:changeStatus(self.climbStatusEnum["change"], {callfunc})

		return 1;
	end
end

function GodMon:climb(func)
	if self.isStand and not self:getLockBehavior() then
		self:lockActorBehavior();

		local callfunc = cc.CallFunc:create(function()
			self:unLockActorBehavior();
			self:markIsStand();
			self:idle();

			if func then
				func();
			end
		end)

		local aniIndex = self.dir + (self.climbStatusEnum["change"]-1) * statusAniStep;
		local action = self.nakedBody.mapSprite.sprite:getAnimateFromName(aniIndex);

		self:setStatusSpeed(self.climbStatusEnum["change"], self.poseTimme);
		if action then
			local action1 = action:reverse();
			local action2 = action:reverse();
			action1:setDuration(self.poseTimme);
			action2:setDuration(self.poseTimme);

			self.nakedBody.mapSprite:stopAllActions();
			self.nakedBody.mapSprite:runActions({action1, callfunc});
			if self.nakedBody.mapSpriteShadow then
				self.nakedBody.mapSpriteShadow:stopAllActions();
				self.nakedBody.mapSpriteShadow:runActions({action2});
			end
		else
			return nil;
		end

		return 1;
	end
end

function GodMon:appear(func)
	self.nakedBody.logSwitch = true;

	if not self:getLockBehavior() then
		self:lockActorBehavior();

		local callfunc = cc.CallFunc:create(function()
			self:unLockActorStatus();
			self:unLockActorBehavior();
			self:markIsStand();
			self:idle();

			if func then
				func();
			end
		end)

		--TraceError("set appear time start:"..self.appearTime);
		self:setStatusSpeed(self.climbStatusEnum["appear"], self.appearTime);
		--TraceError("set appear time end:"..self.appearTime);
		self:changeStatus(self.climbStatusEnum["appear"], {callfunc})

		return 1;
	end
end

function GodMon:markIsStand(_stand)
	self.isStand = _stand;

	if _stand then
		self.statusEnum = self.standStatusEnum;
	else
		self.statusEnum = self.climbStatusEnum;
	end

	self.idleStatus = self.statusEnum["stand"];
end

function GodMon:getAllowRun()
    return false;
end

function GodMon:changeIdleStatus()
end

function GodMon:updateIdleStatus()
end
