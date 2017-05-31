CallPet = class("CallPet", function()
    return BaseSpell:new();
end)

function CallPet:ctor()
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
    self.effect = nil
end

--执行
function CallPet:run(object, values, callFunc)
    self:markCastTime(object);

	--TraceError("play effect "..self.effectid);
	--CREATE
	--self.effect = EffectManager:getEffect(self.effectid);
    self:playEffect(object, values);  --播放特效

    object:markSlashRingTime();

	if callFunc then
		self.callFunc = callFunc;
	end
end

--普攻没有特效,如需�?则子类重载此函数
function CallPet:playEffect(object, values)
    if not self.effect then
        return;
    end

    self:adjustEffectPos(object);

    if not self.effect.sprite:getParent() then
        self.effect:addTo(object:getLayer(), LayerzOrder.SKILL);
    end

    --setSpeed
    self.effect:setAllActionsSpeed(object:getSlashSpeed());
	--run effect
    --self.effect:setCurrFrameIndex(1, tostring(values));
    self.effect:runAction("1");
    self.effect.sprite:setVisible(true);
end

--打包战斗信息
function CallPet:packageAttackInfo(object, values)
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


function CallPet:markCastTime(object)
    self.castClock:markRingTime();
	object:markCastRingTime();
end

function CallPet:closeEffect()
    if self.effect ~= nil then
		self.effect.sprite:setVisible(false);
        self.effect:stopAllActions();
		return;
	end
end

--[[
function CallPet:stopPlayEffect()
    if self.effect then
        --self.effect.sprite:setVisible(false);
        self.effect:stopAllActions();
    end
end]]
