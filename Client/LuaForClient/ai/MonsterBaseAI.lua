MonsterBaseAI = class("MonsterBaseAI")

function MonsterBaseAI:ctor()
    self.autoClock = Clock:new();
    self.autoClock:setRingTimeDelta(5);
    self.enemyid = -1;
    self.maxAlertTile = 8;
end

function MonsterBaseAI:die(master, enemy)
    if enemy.id == self.enemyid then
        self:giveUpEnemy();
    end
end

function MonsterBaseAI:giveUpEnemy(object)
    object:stopScripts();
    self.enemyid = -1;
end

function MonsterBaseAI:fight(master, enemy)
    local enemyCamp = enemy:getCamp();
    local masterCamp = master:getCamp();

    if masterCamp ~= enemyCamp then
        local masterPos = master:getPositionOfMap();
        local enemyPos = enemy:getPositionOfMap();
        local distance = FuncPack:getDistanceWithOfPositions(masterPos,enemyPos)

        if distance <= self.maxAlertTile then
            master:executeScript("autofight", enemy.id);
            self.enemyid = enemy.id;
            return true;
        end
    end

    return false;
end

function MonsterBaseAI:update(object)
    self:execute(object);
end

function MonsterBaseAI:execute(object)
    if not self:checkClock() then
        return;
    end

    if object:getScriptRuning("autofight") then
        return;
    end

    if self:checkValid(object) then
        self:giveUpEnemy(object);
    end

    self:findEnemy(object);
end

function MonsterBaseAI:findEnemy(object)
    local currMap = object:getMap();
    local actorList = currMap:getActors();

    for k,actor in pairs(actorList) do
        local ret = self:fight(object, actor);
        if ret then
            return;
        end
    end
end

function MonsterBaseAI:checkValid(object)
    if self.enemyid ~= -1 then
        local map = object:getMap();
        local enemy = map:getObjectWithId(self.enemyid);

        if enemy then
            local objecPos = object:getPositionOfMap();
            local enemyPos = enemy:getPositionOfMap();
            local distance = FuncPack:getDistanceWithOfPositions(objecPos,enemyPos)

            if distance > self.maxAlertTile then
                return true;
            end
        end
    end

    return nil;
end

function MonsterBaseAI:getAlertRange(centerPos, range)
    return {x=centerPos.x-range, y=centerPos.y-range},{x=centerPos.x+range, y=centerPos.y+range};
end

function MonsterBaseAI:checkClock()
    if self.autoClock:ring() == false then
        return nil;
    end

    self.autoClock:markRingTime();

    return true;
end

--[[
function MonsterBaseAI:findEnemy(monster)
    if monster then
        return;
    end

    local map = monster.map;
    local monsterPos = monster:getPositionOfMap();
    local objects = map:getObjectsInMapFromLayer(2)

    for k,v in pairs(objects) do
        local objectPos = v:getPositionOfMap();
        local distance = FuncPack:getDistanceWithOfPositions(monsterPos,objectPos)

        if distance < 30 and v:getCamp() ~= monster:getCamp() then
            monster:executeScript("autofight", v.id);

            self.enemy = v.id;
            return;
        end
    end
end
]]
function MonsterBaseAI:stop()

end

function MonsterBaseAI:checkEnemyDie()
    local enemy = ActorManager:getMonster(self.enemyid)

    if not enemy or enemy:isDie() then
        return true;
    end

    return false;
end
