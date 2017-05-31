MoveScript = {}

function MoveScript:ctor()
end

function MoveScript:move(object, dir, moveType, callfunc)
	if object:isDie() then
		return;
	end

    local point = self:getMovePoint(object:getPosition(), dir, moveType);
    return self:exc(object, point, moveType, callfunc);
end

function MoveScript:moveTo(object, point, moveType, callfunc)
	if object:isDie() then
		return;
	end

    return self:exc(object, point, moveType, callfunc);
end

function MoveScript:exc(object, point, moveType, moveCallfunc)
    if object.lockBehavior == true then
		--TraceError(object:getID().." lock behavior cannot move");
        return;
    end

    local callfunc = cc.CallFunc:create(function()
        self:moveOverCallFunc(object);
		if moveCallfunc then
			moveCallfunc();
		end

		--[[
		if string.find(object:getName(), "%(") then
			TraceError(object:getName().." end move");
		end]]
    end)

    local objPoint = object:getPosition();
    local dir = FuncPack:calcuteDirFromPoint(objPoint, point)
    --local distance = FuncPack:getAbsoluteDistanceWithOPoints(objPoint, point)/TILE_WIDTH;
	local distance = FuncPack:getTimeForWalk(object:getPositionOfMap(), FuncPack:pointToPosition(point));
	local speed = object:getSpeed(moveType);
	local speedTime = FuncPack:keepDigital(speed*distance);
	--*distance
	local action = cc.MoveTo:create(speedTime, point);

    object:setDir(tonumber(dir));
    if moveType == 1 then
        object:changeStatus(object.statusEnum["walk"])
    else
        object:changeStatus(object.statusEnum["run"])
    end

	--[[
	if string.find(object:getName(), "%(") then
		TraceError(object:getName().." start move");
	end]]

	object:setMoveTargetPos(FuncPack:pointToPosition(point));
    object:runActions({action, callfunc});
    object:lockActorBehavior();

    return moveType-1;
end

function MoveScript:moveOverCallFunc(object)
    object:idle();
end

function MoveScript:getMovePoint(originalPoint, dir, moveCheckCount)
    local point = {};
    local offsetx = TILE_WIDTH*moveCheckCount;
    local offsety = TILE_HEIGHT*moveCheckCount;

    if dir == 1 then
        point = {x=originalPoint.x, y=originalPoint.y + offsety};
    elseif dir == 2 then
        point = {x=originalPoint.x + offsetx, y=originalPoint.y + offsety}
    elseif dir == 3 then
        point = {x=originalPoint.x + offsetx, y=originalPoint.y}
    elseif dir == 4 then
        point = {x=originalPoint.x + offsetx, y=originalPoint.y - offsety}
    elseif dir == 5 then
        point = {x=originalPoint.x, y=originalPoint.y - offsety}
    elseif dir == 6 then
        point = {x=originalPoint.x - offsetx, y=originalPoint.y - offsety}
    elseif dir == 7 then
        point = {x=originalPoint.x -offsetx, y=originalPoint.y}
    elseif dir == 8 then
        point = {x=originalPoint.x - offsetx, y=originalPoint.y + offsety}
    end

    return point;
end
