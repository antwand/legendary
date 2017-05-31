
Account = {}
Account.actorGroups = {}
Account.currActorIndex = 0;

function Account:init(data)
	Account.data = data;
end

function Account:initActorData(data)
	Account.data.actorsInfo = data;
end

function Account:addActorData(data)
	table.insert(Account.data.actorsInfo, #Account.data.actorsInfo+1, data);
end

function Account:addActorFromData(data, index, cover)
	if Account.actorGroups[index] and not cover then  --如果角色已经初始化，则在cover覆盖为假的情况下不会再次初始化角色
		return Account.actorGroups[index];
	end

	local actor = ActorManager:createActor(data, true);
	actor:retain();
	Account.actorGroups[index] = actor;
    --table.insert(Account.actorGroups, #Account.actorGroups+1, actor);

	return actor;
end

function Account:addActor(actor)
    table.insert(Account.actorGroups, #Account.actorGroups+1, actor);
end

function Account:selActor(index)
    Account.currActorIndex = index;
end

function Account:getCurrActor()
    return Account.actorGroups[Account.currActorIndex];
end

function Account:getActor(id)
    return Account.actorGroups[id];
end

function Account:getActorsData()
	return Account.data.actorsInfo;
end

function Account:getActorsCount()
	return #Account.data.actorsInfo;
end

function Account:release()
	for k,v in pairs(Account.actorGroups) do
		v:release();
	end

	Account.actorGroups = {};
end

function Account:checkIsUser(pid)
	for k,v in pairs(Account.actorGroups) do
		if v:getID() == pid then
			return true;
		end
	end

	return false;
end

function Account:setCurrActor(actor)
    Account.actorGroups[Account.currActorIndex] = actor;
end
