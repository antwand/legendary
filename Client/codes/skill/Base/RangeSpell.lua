RangeSpell = class("RangeSpell", function()
    return BaseSpell:new();
end)

function RangeSpell:ctor()
    self.attack = 0;
    self.level = 1
    self.attackType = 1;  --1.物理;2.魔法;3.道术
    self.name = "slash"
    self.power = 1  --威力大到一定程度会使目标后�?
    self.action = 1;      --对应动作id
    self.castClock = Clock:new();
    self.auto = true;   --是否在执�?
    self.priority = 1;
    self.flyEffectSpeedPerPixel = 0.0008;
	self.type = 2;

    --预留给子类的特效
    self.effect = nil
end

--[[
--技能基本属�?
function RangeSpell:initAttribute(param)
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
	self.type        = param.type
	self.needMagic   = param.needMagic;
    self.castClock:setRingTimeDelta(param.coolDown);

    self.effect      = EffectManager:getEffect(param.effectid);
    self.flyEffect   = EffectManager:getEffect(param.flyeffectid);
    self.boomEffect  = EffectManager:getEffect(param.boomeffectid);
end
]]
function RangeSpell:remove()
    if self.effect then
        self.effect:remove();
    end

    if self.flyEffect then
        self.flyEffect:remove();
    end

    if self.boomEffect then
        self.boomEffect:remove();
    end
end

--执行
function RangeSpell:run(object, tarPos, callFunc)
	self.from = object;
	self.tarPos = tarPos;
    self:markCastTime(object);
    self:playEffect(object, tarPos);  --播放特效

	--[[
	client:sendMessageWithRecall("ACTOR_ATTACK", {skillName=self.name,values=values}, function(msg)
		self.damageMsg = msg;
	end);]]
	if callFunc then
		self.callFunc = callFunc;
	end

	self.isRun = true;
end

function RangeSpell:update(object)
end

--普攻没有特效,如需�?则子类重载此函数
function RangeSpell:playEffect(object, tarPos)
	local point = FuncPack:PositionTopoint(tarPos);

    if not self.effect then
        return;
    end

    self:adjustEffectPos(self.effect, object:getPosition())

    if self.effect.sprite:getParent() == nil then
        self.effect:addTo(object:getLayer(), LayerzOrder.SKILL);
    end

	--释放效果回调函数
	local effectOverFunc = cc.CallFunc:create(function()
		self:closeEffect(self.effect);

		if self.flyEffect then
			self:playFlyEffect(object, point);
		else
			self:playBoomEffect(object, point);
		end
	end);

	self.effect:setAllActionsSpeed(object:getCastSpeed());
	--run effect
	local actionCount = self.effect:getActionCount();
    if actionCount == 1 then
        self.effect:runAction("1", {effectOverFunc});
	else
        self.effect:runAction(tostring(object:getDir()), {effectOverFunc});
	end

    self.effect.sprite:setVisible(true);
end

function RangeSpell:playFlyEffect(object, tarPoint)
	local objpos   = object:getPosition();
    local enemypos = tarPoint;
	local layer    = object:getLayer();

    --调整位置
    self:adjustEffectPos(self.flyEffect, objpos)

	if self.flyEffect.sprite:getParent() == nil then
        self.flyEffect:addTo(layer, LayerzOrder.SKILL);
    end

    local flyEffectOverFunc = cc.CallFunc:create(function()
        self:closeEffect(self.flyEffect);

		if self.boomEffect then
			self:playBoomEffect(object, tarPoint);
		end
    end);

    --执行播放动画
    local dir = FuncPack:calcuteDirFromPoint(objpos, enemypos);
    self.flyEffect:runAction(tostring(dir));

    --移动action
    local distance = FuncPack:getAbsoluteDistanceWithOPoints(enemypos, objpos);
    local _time = self.flyEffectSpeedPerPixel * distance;
    local moveAction = cc.MoveTo:create(_time, enemypos);
    self.flyEffect:runActions({moveAction, flyEffectOverFunc});

    --set visible fly effect
	self.flyEffect:setVisible(true);
end

function RangeSpell:playBoomEffect(object, tarPoint)
	--local enemy    = ActorManager:getActor(values);

    self:adjustEffectPos(self.boomEffect, tarPoint)

	if self.boomEffect.sprite:getParent() == nil then
        self.boomEffect:addTo(object:getLayer(), LayerzOrder.SKILL);
    end

	local boomEffectOverFunc = cc.CallFunc:create(function()
        self:closeEffect(self.boomEffect);
		self:calculateDamage(object, tarPoint);
	end);

	self.boomEffect:runAction("1", {boomEffectOverFunc});
	self.boomEffect.sprite:setVisible(true);
end

function RangeSpell:isCoolDown()
    if self.castClock:ring() then
        return nil;
    end

    return 1;
end

--调整ui位置,父类不需�?
function RangeSpell:adjustEffectPos(effect, pos)
    effect:setPosition(pos.x, pos.y);
end

function RangeSpell:setDamageMsg(msg)
	self.damageMsg = msg;
end

--结束动画进行结算
function RangeSpell:calculateDamage(object, values)
	if self.callFunc then
		self.callFunc();
	end
end

function RangeSpell:over(object, values)
	object:unLockActorStatus();-- = false;
    object:idle();

	self.isRun = nil;
end

function RangeSpell:closeEffect(effect)
	if effect ~= nil then
		effect.sprite:setVisible(false);
        effect:stopAllActions();
		return;
	end

    if self.effect then
        self.effect.sprite:setVisible(false);
        self.effect:stopAllActions();
    end

	if self.flyEffect then
		self.flyEffect.sprite:setVisible(false);
        self.flyEffect:stopAllActions();
	end

	if self.boomEffect then
        self.boomEffect.sprite:setVisible(false);
        self.boomEffect:stopAllActions();
    end
end

--打包战斗信息
function RangeSpell:packageAttackInfo(object, values)
    local info = {}
    info.fromid = object.id;

    local baseAttack = object:getRandomAttack(attackInfo.type);
    local totalAttack = baseAttack*self.growDamage + self.baseDamage;
    info.attackInfos = {{value={type=self.attackType,attack=totalAttack, power=self.power}, target=values}};

    return info;
end

--是否符合条件
function RangeSpell:satifyCastPremise(object, values)
    if self.castClock:ring() == false then
        return false, "skill no coolDown";
    end

	if object.castClock:ring() == false then
		return false, "actor cast no coolDown";
	end

	--��������,�����ܵ��ͷųɹ���
    if self.triggerRate then
        local rate = FuncPack:getRandomNumber(1, 100)

        if rate > self.triggerRate * 100 then
            return true
        end
    end

	if self.isRun then
		return false, "skill still running";
	end

	if object:getMp() < self.needMagic then
		return false, "no enough magic";
	end

    return true;
end

function RangeSpell:markCastTime(object)
    self.castClock:markRingTime();
	object:markCastRingTime();
end

function RangeSpell:release()
    if self.effect then
        self.effect:release();
    end

	if self.flyEffect then
		self.flyEffect:release();
	end

	if self.boomEffect then
		self.boomEffect:release();
	end
end
