ThrustFencing = class("ThrustFencing", function()
    return SlashSpell:new();
end)

function ThrustFencing:ctor()
end

--[[
--打包战斗信息
function ThrustFencing:packageAttackInfo(object, values)
    local info = {}
    info.fromid = object.id;
	info.attackInfos = {};

	local baseAttack = object:getRandomAttack(self.attackType);
    local totalAttack = baseAttack*self.growDamage + self.baseDamage;

    local objPos = object:getPositionOfMap();
    local tarPos1 = FuncPack:nextPositionWithDir(objPos,object:getDir(),1)
	local tarPos2 = FuncPack:nextPositionWithDir(objPos,object:getDir(),2)
	local target1 = object:getMap():getObjectFromMap(tarPos1);
	local target2 = object:getMap():getObjectFromMap(tarPos2);

	if target1 then
		table.insert(info.attackInfos, #info.attackInfos+1, {value={type=self.attackType,attack=totalAttack, power=self.power},target=target1});
	end

	if target2 then
		table.insert(info.attackInfos, #info.attackInfos+1, {value={type=self.attackType,attack=totalAttack, power=self.power},target=target2});
	end

    return info;
end
]]
