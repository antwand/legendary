BuffSpell = class("BuffSpell",  function()
    return BaseSpell:new();
end)

function BuffSpell:ctor()
    self.attack = 0;
    self.level = 1
    self.attackType = 1;  --1.物理;2.魔法;3.道术
    self.name = "slash"
    self.power = 1  --威力大到一定程度会使目标后�?
    self.action = 1;      --对应动作id
    self.auto = true;   --是否在执�?
    self.priority = 1;
    self.flyEffectSpeedPerPixel = 0.0008;
	self.type = 2;

	self.castClock = Clock:new();
	self.runningClock = Clock:new();

    --预留给子类的特效
end

function BuffSpell:initAttribute(param)
    self.baseDamage  = param.baseDamage;
    self.growDamage  = param.growDamage;
    self.attackType  = param.attackType
    self.name        = param.sz_name
    self.event       = param.sz_event
    self.action      = param.action
    self.specialFunc = param.sepcialFunc;
    self.triggerRate = param.triggerRate;
    self.priority    = param.priority;
    self.castRange   = 0;--param.castRange;
	self.type        = param.type;
	self.needMagic   = param.needMagic;
    self.castClock:setRingTimeDelta(param.coolDown);
	self.runningClock:setRingTimeDelta(param.runningTime);

    self.effect      = EffectManager:getEffect(param.effectid);
	self.boomEffect  = EffectManager:getEffect(param.boomeffectid);
end

function BuffSpell:run(object, value, callFunc)
	self:markCastTime(object);
	self.currDamage = self.baseDamage;

	if self.effect then
		self:playEffect(object);
	end
	--[[
	client:sendMessageWithRecall("ACTOR_ATTACK", {skillName=self.name,values=values}, function(msg)
		self.damageMsg = msg;
	end);]]
	if callFunc then
		self.callFunc = callFunc;
	end

	self.isRun = true;
end

function BuffSpell:update(object)
	if self.isRun then
		local point = object:getPosition();

		if self.effect then
			self.effect:setPosition(point.x, point.y);
		end

		if self.boomEffect then
			self.boomEffect:setPosition(point.x, point.y);
		end
	else
		return;
	end

	if self.runningClock:ring() and self.isRun then
		self:close(object);
	end
end

function BuffSpell:getDamage(object, num)
	if not self.isRun then
		return;
	end

	if self.boomEffect and self.effect then
		local point = object:getPosition();
		self.boomEffect:setVisible(true);
		self.boomEffect:setPosition(point.x, point.y);
		self.effect.sprite:setVisible(false);

		local effectOverFunc = cc.CallFunc:create(function()
			self.effect:setVisible(true);
			self.boomEffect:setVisible(false);
		end);

		self.boomEffect:runAction("1", {effectOverFunc});
	end
end

function BuffSpell:playEffect(object)
	self.boomEffect:remove();
	self.boomEffect:addTo(object:getLayer(), LayerzOrder.SKILL);
	self.boomEffect:setVisible(false);

	self.effect:remove();
	self.effect:addTo(object:getLayer(), LayerzOrder.SKILL);
	self.effect:setVisible(true);
	self.effect:setAllActionsSpeed(object:getCastSpeed());
	self.effect:runAction("1");

	local point = object:getPosition();
	self.effect:setPosition(point.x, point.y);
end

function BuffSpell:over(object, values)
	--object:unLockActorStatus();-- = false;
    object:idle();
end

function BuffSpell:markCastTime(object)
	self.castClock:markRingTime();
	self.runningClock:markRingTime();
	object:markCastRingTime();
end

function BuffSpell:close(object)
	self:closeEffect(object);

	self.isRun = nil;
end

function BuffSpell:closeEffect(object)
	if self.effect then
		self.effect:setVisible(false);
        self.effect:stopAllActions();
	end

	if self.boomEffect then
		self.boomEffect:setVisible(false);
        self.boomEffect:stopAllActions();
	end
end
