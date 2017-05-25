ActorManager = {}
ActorManager.actors = {}

--根据id增加角色
function ActorManager:addCharactor(id, attribute)
    local charactor = Actor:new();
    charactor:init(attribute);

    ActorManager.actors[id] = charactor;
end

function ActorManager:initActorBody(actor, actorData, attribute)
    if attribute.sz_class == "Actor" then
		local body = nil;

        if actorData.sex == 2 then
			body = ItemManager:getBody(2, actorData.pid);--ItemManager:getItem({itemid=-actorData.pid,typeid=6});
        else
			body = ItemManager:getBody(1, actorData.pid);--ItemManager:getItem({itemid=-actorData.pid,typeid=5});
        end

		body:setType(actorData.style);
		actor:setNakedBody(body);
    else
		local body = ItemManager:getBody(attribute.bodyid, actorData.pid);

		if body then
			body:setType(actorData.style);
			actor:setNakedBody(body);
		else
			print("no found body:"..tostringex(conf));
		end
    end

	if actorData.hairId and actorData.hairId ~= 0 then
		local hair = ItemManager:getBody(actorData.hairId, actorData.pid);
		hair:setType(0);
		actor:setHair(hair);
	end
end

function ActorManager:initActorExtra(actor, actorData)
	local skill = SkillManager:addSkill({skillid=1, level=1, exc=0})
	actor:addSkill(skill);

    for k,v in pairs(actorData.skill) do
        local skill = SkillManager:addSkill(v)
        actor:addSkill(skill);
    end

    for k,v in pairs(actorData.equip) do
        local equip = ItemManager:addEquip(v);
		local extraContent = v.extraContent;
        if not equip then
            TraceError("no equip:"..tostringex(v));
		else
			actor:loadPart(equip, extraContent)
        end
    end

    for k,v in pairs(actorData.item) do
        local item = ItemManager:addEquip(v);
		if item then
			actor:addItem(item, v.gridIndex);
		end
    end
end

function ActorManager:initActorScript(actor,isPlayer)
    --增加脚本
	if isPlayer then
		local findPathScript = AutoFindPath:create();
		actor:addScript("findpath", findPathScript);

		local fightScript = AutoFightWithMonster:create()
		actor:addScript("autofight", fightScript);
	else
		local scriptCache = ScriptCache:create();

		actor:addScript("scriptCache", scriptCache);
	end
end

function ActorManager:createNPC(actorData)
	if ActorManager:getActor(actorData.pid) then
		TraceError(actorData.pid.." already exists");
		return ActorManager:getActor(actorData.pid);
	end

	local conf = npcConf[actorData.style];
	local npc = NPC:new();
	npc:setName(conf.sz_name);
	npc:setCamp(3);
	npc:init(conf);

	local body = ItemManager:getBody(conf.spriteid, actorData.pid);
	body:setType(actorData.style);
	npc:setNakedBody(body);
	npc:changeStatus(npc.statusEnum["stand"]);

	if CLIENT_TYPE == 1 then
        self:registActorWithID(npc, #ActorManager.actors+1);
    else
        self:registActorWithID(npc, actorData.pid);
    end

	return npc;
end

function ActorManager:createActor(actorData, isPlayer)
	if ActorManager:getActor(actorData.pid) then
		TraceError(actorData.pid.." already exists:");
		return ActorManager:getActor(actorData.pid);
	end

	--if camp==3 then its npc
	if actorData.camp == 3 then
		return self:createNPC(actorData);
	end

    local actorConf = ActorConf[actorData.style];
    local createFunc = loadstring("return "..actorConf.sz_class..":new()")
    local actor = createFunc();

	if CLIENT_TYPE == 1 then
        self:registActorWithID(actor, #ActorManager.actors+1);
    else
        self:registActorWithID(actor, actorData.pid);
    end

	actor:markIsStand(actorData.isStand);
    actor:setName(actorData.name);
    actor:setSex(actorData.sex);
    actor:setType(actorData.style);
    actor:setLevel(actorData.level);
	actor:setExc(actorData.exc);
	actor:setGold(actorData.gold);
	actor:setCamp(actorData.camp);
	actor:setAttributeId(actorConf.attributeid);
    actor:init(actorConf);
	actor:retain();

    self:initActorBody(actor, actorData, actorConf);
    self:initActorExtra(actor, actorData);
    self:initActorScript(actor, isPlayer);
	actor:changeStatus(actor.statusEnum["stand"]);

	if actorData.curHp then
		actor:setHp(actorData.curHp);
	end

	if actorData.curMp then
		actor:setMp(actorData.curMp);
	end

    return actor;
end

function ActorManager:getCharactor(id)
    return ActorManager.actors[id];
end

function ActorManager:getActor(id)
    return ActorManager.actors[id];
end

function ActorManager:createMonster(actorData)
	if ActorManager:getActor(actorData.pid) then
		print(actorData.pid.." already exists");
		return ActorManager:getActor(actorData.pid);
	end

	local actorConf = ActorConf[actorData.style];
    local createFunc = loadstring("return "..actorConf.sz_class..":new()")
    local actor = createFunc();

	if CLIENT_TYPE == 1 then
        self:registActorWithID(actor, #ActorManager.actors+1);
    else
        self:registActorWithID(actor, actorData.pid);
    end

    actor:setName(actorConf.sz_name);
    actor:setSex(actorData.sex);
    actor:setType(actorData.style);
    actor:setLevel(actorData.level);
	actor:setExc(actorData.exc);
	actor:setAttributeId(actorConf.attributeid);
    actor:init(actorConf);

    self:initActorBody(actor, actorData, actorConf);
    self:initActorExtra(actor, actorData);
    self:initActorScript(actor);

	actor:changeStatus(actor.statusEnum["stand"]);
    --ai
    --local ai = MonsterBaseAI:new()
    --actor:addScript("lowLevelAI", ai);

    return actor;
end

function ActorManager:registActor(actor)
    local id = #ActorManager.actors + 1
    ActorManager.actors[id] = actor;

    return id;
end

function ActorManager:release(isKeepUser)
	local destroyActors = {};
    for k,v in pairs(ActorManager.actors) do
		local id = v:getID();

		if Account:checkIsUser(id) and isKeepUser then
			TraceError("keep user:"..id);
		else
			v:release();
			ActorManager.actors[k] = nil;
		end
    end
end

--[[
function ActorManager:release(isKeepUser)
	local destroyActors = {};
    for k,v in pairs(ActorManager.actors) do
		local id = v:getID();

		if Account:checkIsUser(id) and isKeepUser then
			TraceError("keep user:"..id);
		elseif not destroyActors[id] then
			v:release();
			destroyActors[id] = 1;

			ActorManager.actors[k] = nil;
		else
			TraceError("id:"..id.." destroy repeat");
		end
    end

	--ActorManager.actors = {};
end]]

function ActorManager:registActorWithID(actor, id)
    ActorManager.actors[id] = actor;
    actor:setID(id);
end
