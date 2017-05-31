SlashSpell = class("SlashSpell", function()
    return BaseSpell:new();
end)

function SlashSpell:ctor()
	--[[
    self.attack = 0;
    self.level = 1
    self.attackType = 1;  --1.物理;2.魔法;3.道术
    self.name = "slash"
    self.power = 1  --威力大到一定程度会使目标后�?
    self.action = 1;      --对应动作id
    self.castClock = Clock:new();
    self.auto = true;   --是否在执�?
    self.priority = 1;
	self.type = 1;

    --预留给子类的特效
    self.effect = nil]]
end


--技能基本属�?
function SlashSpell:initAttribute(param)
    self.baseDamage  = param.baseDamage
    self.growDamage  = param.growDamage
    self.attackType  = param.attackType
    self.name        = param.sz_name
	self.type        = param.type
    self.event       = param.sz_event
    self.action      = param.action
    self.castRange   = param.castRange;
    self.specialFunc = param.sepcialFunc;
    self.triggerRate = param.triggerRate;
    self.priority    = param.priority;
    self.class       = param.sz_class;
	self.effectid    = param.effectid;
	self.needMagic   = param.needMagic;
    self.castClock:setRingTimeDelta(param.coolDown);
end


function SlashSpell:setCurrFrameIndex(index)
    if self.effect then
        self.effect:setCurrFrameIndex(index);
    end
end

--执行
function SlashSpell:run(object, values, callFunc)
    object:setDir(values);
    self:markCastTime(object);

	--TraceError("play effect "..self.effectid);
	--CREATE
	self.effect = EffectManager:getEffect(self.effectid);
    self:playEffect(object, values);  --播放特效

    object:markSlashRingTime();

	if callFunc then
		self.callFunc = callFunc;
	end
end

--普攻没有特效,如需�?则子类重载此函数
function SlashSpell:playEffect(object, values)
    if not self.effect then
        return;
    end

    self:adjustEffectPos(object)

    if not self.effect.sprite:getParent() then
        self.effect:addTo(object:getLayer(), LayerzOrder.SKILL);
    end

    --setSpeed
    self.effect:setAllActionsSpeed(object:getSlashSpeed());
	--run effect
    --self.effect:setCurrFrameIndex(1, tostring(values));
    local ret,success = self.effect:runAction(tostring(values));

	if not success then
		TraceError(object:getID().." cast "..self.name.." effect failed");
	end

    self.effect.sprite:setVisible(true);
end

function SlashSpell:update(object)
end

function SlashSpell:isCoolDown()
    if self.castClock:ring() then
        return nil;
    end

    return 1;
end

--调整ui位置,父类不需�?
function SlashSpell:adjustEffectPos(object)
    local pos = object:getPosition();
    self.effect:setPosition(pos.x, pos.y);
end

--结束动画进行结算
function SlashSpell:over(object, values)
    object:unLockActorStatus();--.lockStatus = false;
    object:idle();

    self:closeEffect();

	if self.callFunc then
		self.callFunc();
	end
end

function SlashSpell:getCastRange()
    return self.castRange;
end

--打包战斗信息
function SlashSpell:packageAttackInfo(object, values)
    local info = {}
    info.fromid = object.id;

    local objPos = object:getPositionOfMap();
    local tarPos = FuncPack:nextPositionWithDir(objPos,object:getDir(),1)
	local target = object:getMap():getObjectFromMap(tarPos);

	if not target or target:getCamp() == object:getCamp() then
		return nil;
	end

    local baseAttack = object:getRandomAttack(self.attackType);
    local totalAttack = baseAttack*self.growDamage + self.baseDamage;

    info.attackInfos = {{value={type=self.attackType,attack=totalAttack, power=self.power},target=target}};

    return info;
end

function SlashSpell:markCastTime(object)
    self.castClock:markRingTime();
	object:markSlashRingTime();
end

function SlashSpell:closeEffect()
	if self.effect then
		self.effect:remove();
		self.effect = nil;
		--self.effect.sprite:setVisible(false);
        --self.effect:stopAllActions();
		return;
	end
end

--[[
function SlashSpell:stopPlayEffect()
    if self.effect then
        --self.effect.sprite:setVisible(false);
        self.effect:stopAllActions();
    end
end]]
