AutoFightWithMonster = {}
AutoFightWithMonster.__index = AutoFightWithMonster
AutoFightWithMonster.logSwitch = nil;

function AutoFightWithMonster:create()
    local script = {}
    setmetatable(script, AutoFightWithMonster)
    script:ctor();
    return script
end

function AutoFightWithMonster:ctor()
    self.targetID = -1;
    self.auto = false;
	self.slashRange = 0;
end

function AutoFightWithMonster:getRunning()
    if self.targetID <= 0 then
        return nil;
    end

    return true;
end

function AutoFightWithMonster:execute(value, master)
    self.targetID = value;
    self.enemyPosOfMap = nil;
end

function AutoFightWithMonster:stop()
    self:ctor();
end

function AutoFightWithMonster:update(object)
    if self.targetID == -1  then
        return;
    end

    if object:getLockBehavior() == true then
        return;
    end

    local map = object:getMap();
    local enemy = map:getObjectWithId(self.targetID);
    if not enemy or enemy:isDie() then
        self:ctor();
        return;
    end

    local enemyPos     = enemy:getPositionOfMap();
    local objectPos    = object:getPositionOfMap();
    local distance     = FuncPack:getStepBetweenPos(enemyPos, objectPos);
	local skill        = object:getProperSlashSkill();

	if skill then
		self.slashRange   = skill:getCastRange();
	end

	if self.slashRange == 0 then
		return;
	end

    if distance > self.slashRange or distance == 0 then
        if not object:getScriptRuning("findpath") then
			object:executeScript("findpath", enemyPos);
        end
    elseif skill then
        local dir = FuncPack:calcuteDirFromPoint(objectPos, enemyPos);
		local name = skill:getName();

		engine.dispachEvent("PREPARE_ATTACK", {object=object, skillName=name, values=dir});
    end
end

function AutoFightWithMonster:startFight(object)

end

function AutoFightWithMonster:die()
    self:stop();
end

function AutoFightWithMonster:checkNoFight()
    return self.auto == false and self.targetID == -1
end

function AutoFightWithMonster:checkEnemyMove(enemyPos)
    return FuncPack:isEqualPoint(self.lastEnemyPos, enemyPos) == false
end

function AutoFightWithMonster:registMoveListener(object)
    if self.moveListener then
        return;
    end

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    --对象移动的时候监听
    local AutoFightMove = function(event)
        if event.info.id == self.targetID then
            self:startFight(object);
        end
    end

    self.moveLister = cc.EventListenerCustom:create("move", AutoFightMove)
    eventDispatcher:addEventListenerWithFixedPriority(self.moveLister, 1);
end

function AutoFightWithMonster:registDieListener(object)
    if self.dieLister then
        return
    end

    --有对象死亡的监听器
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    local AutoFightDie = function(event)
        if event.info.id == self.targetID then
            self:die();
        end
    end

    self.dieLister = cc.EventListenerCustom:create("die", AutoFightDie)
    eventDispatcher:addEventListenerWithFixedPriority(self.dieLister, 1)
end

function AutoFightWithMonster:removeMoveListener()
    if not self.moveListener then
        return
    end

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:removeEventListener(self.moveListener);
    self.moveListener = nil;
end

function AutoFightWithMonster:removeDieListener()
    if not self.dieListener then
        return
    end

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    eventDispatcher:removeEventListener(self.dieListener);
    self.dieListener = nil;
end
