SkillManager = {}
SkillManager.skills = {}
SkillManager.buff = {};

function SkillManager:addSkill(data)
	local skillid = data.skillid;
    local conf = skillConf[skillid];
    local skillClass = "return "..conf.sz_class..":new()";
    local createSkillFunc = loadstring(skillClass);
    local skill = createSkillFunc();

	skill:setBaseData(data);
    skill:initAttribute(conf);
    self:registSkill(skill);

    return skill;
end

function SkillManager:getBuff(buffid)
	for k,v in pairs(SkillManager.buff) do
		if v:isFree() and v:getID() == buffid then
			return v;
		end
	end

    local conf = buffConf[buffid];
	if conf then
		local skillClass = "return "..conf.sz_class..":new()";
		local createSkillFunc = loadstring(skillClass);
		local buff = createSkillFunc();
		buff:init(conf);

		table.insert(self.buff, #self.buff+1, buff);

		return buff;
	end
end

function SkillManager:registSkill(skill)
    table.insert(self.skills, #self.skills+1, skill);
end

function SkillManager:release()
	for k,v in pairs(SkillManager.skills) do
		v:release();
	end

	SkillManager.skills = {}
end
