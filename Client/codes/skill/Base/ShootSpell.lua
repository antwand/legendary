ShootSpell = class("ShootSpell", function()
    return RangeSpell:new();
end)

function ShootSpell:ctor()
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

function ShootSpell:run(object, tarPos, callFunc)
	self.from = object;
	self.tarPos = tarPos;
    self:markCastTime(object);

	if callFunc then
		self.callFunc = callFunc;
	end

	self.isRun = true;
end

function ShootSpell:over(object, tarPos)
	object:unLockActorStatus();-- = false;
    object:idle();

	if self.flyEffect then
		local point = FuncPack:PositionTopoint(tarPos);
		self:playFlyEffect(object, point);
	end

	self.isRun = nil;
end
