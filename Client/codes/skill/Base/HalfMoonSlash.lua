HalfMoonSlash = class("HalfMoonSlash", function()
    return SlashSpell:new();
end)

function HalfMoonSlash:ctor()

end


--打包战斗信息
function HalfMoonSlash:packageAttackInfo(object, values)
    local info = {}
    info.fromid = object.id;
	info.attackInfos = {};

	--attack info
	local baseAttack = object:getRandomAttack(self.attackType);
    local totalAttack = baseAttack*self.growDamage + self.baseDamage;
	local attackValue = {type=self.attackType,attack=totalAttack, power=self.power};

	--target info
	local objPos = object:getPositionOfMap();
	local attackRange = {object:getDir()+7, object:getDir()+1, object:getDir()+2}

	for k,dir in pairs(attackRange) do
		if dir > 8 then
			dir = dir%8;
		end

		local tarPosBySide = FuncPack:nextPositionWithDir(objPos,dir,1);
		local targetBySide = object:getMap():getObjectFromMap(tarPosBySide);

		if targetBySide then
			local attackInfo = {value={type=self.attackType,attack=totalAttack*0.5, power=self.power}, target = targetBySide}
			table.insert(info.attackInfos, #info.attackInfos+1, attackInfo);
		end
	end

    local tarPos = FuncPack:nextPositionWithDir(objPos,object:getDir(),1)
	local faceTarget = object:getMap():getObjectFromMap(tarPos);
	local attackInfo = {value={type=self.attackType,attack=totalAttack, power=self.power}, target = faceTarget}
	table.insert(info.attackInfos, #info.attackInfos+1, attackInfo);

	return info;
end
