SpeedUpSpell = class("SpeedUpSpell",  function()
    return BuffSpell:new();
end)

function SpeedUpSpell:ctor()
end

function SpeedUpSpell:run(object, value, callFunc)
	self:markCastTime(object);

	if callFunc then
		self.callFunc = callFunc;
	end


	if not self.isRun then
		object:slashSpeedUp(self.baseDamage);
		object:setShaderEnable(true);

		self.isRun = true;
	end
end

function SpeedUpSpell:closeEffect(object)
	if self.isRun then
		object:setShaderEnable(false);
		object:slashSpeedUp(-self.baseDamage);
	end
end
