AutoFindPath = {}
AutoFindPath.__index = AutoFindPath

function AutoFindPath:create()
    local script = {}
    setmetatable(script, AutoFindPath)
    script:ctor();
    return script;
end

function AutoFindPath:ctor()
    self.tarPoint = nil;
    self.curPathID = 1;
    self.autoFindPath = nil;
    self.path = nil;
    self.excCount = 0;
    self.moveClock = Clock:new();
end

--初始化自动寻路基本信息
function AutoFindPath:execute(values, master)
    if not values then
        self:stop();
        return;
    end

    self.master = master;
    --[[
    self.tarPoint = values;
    self.curPathID = 1;
    self.autoFindPath = 1;
    self.path = nil;]]

    self:findPath(values);
end

function AutoFindPath:findPath(newPos)
    if self.autoFindPath == nil then
        local fromPos = self.master:getPositionOfMap();
        self.path = self:initPath(fromPos, newPos);

        if self.path then
            --object锁定状态
            if self.master.moveDelta == 0 then
                self.master:lockActorStatus();--lockStatus = 1;
            end

            self.autoFindPath = 1;
        else
			--print(self.master:getID().."�Զ�Ѱ·�Ҳ���·��");
            self:over(self.master);
        end
    else
        --找寻最优路径
        local shortestDistance = nil;
        local shortestDistancePos = nil;
        local shortestDistanceId = -1;
        for i=self.curPathID+1, #self.path do
            local tarPos   = FuncPack:pointToPosition(self.path[i]);
            local distance = FuncPack:getDistanceWithOfPositions(tarPos, newPos)

            --新路径更优
            if not shortestDistance or distance < shortestDistance then
                shortestDistance = distance;
                shortestDistancePos = tarPos;
                shortestDistanceId = i;
            else
                self.path[i] = nil;
            end
        end

        --合并新老路径
        local newPath = self:initPath(shortestDistancePos, newPos)
		--print("2 topos:"..tostringex(newPos).."  path:"..tostringex(newPath));

        if newPath == nil then
			print(self.master:getID().."�����Զ�Ѱ·�Ҳ���·��");
            self:over(self.master);
            return;
        end

        for i=1, #newPath do
            self.path[shortestDistanceId+i] = newPath[i];
        end
    end
end

function AutoFindPath:initPath(sourPos, tarPos)
    local path = nil;

    if self.path == nil then
        --if self:pointIsOnCheck(sourPos) then
		path = self:getAStarPath(sourPos, tarPos, self.master:getMap());
        --end
    end
    --[[
    if not self.path then
        --self:over(object);
        return false;
    end]]

    return path;
end

function AutoFindPath:stop()
    self:ctor();
end

function AutoFindPath:update(object)
    if self.autoFindPath ~= nil and object:getLockBehavior() == false then
        --是否开始移动
        if self:checkBeginMove(object) == false then
            return;
        end

        --开始自动寻路，第一步生成寻路路径
        local objPoint = object:getPosition();
        local tarPoint = self.path[self.curPathID];  --根据生成的寻路路径得出开始点和结束点

        --是否切换下一个路径
        if self:shiftNextPath(objPoint, tarPoint) then
            tarPoint = self.path[self.curPathID];

            --到头了结束寻路
            if tarPoint == nil then
                self:over(object);
                return;
            end

            --遇到障碍物重新计算路径
            local map = object:getMap();
            if map:hasObstacleInPoint(tarPoint) then
                local tarPos = FuncPack:pointToPosition(self.path[#self.path]);
                self.autoFindPath = nil;
                self:findPath(tarPos);
                return;
            end

            --开始寻路
            self:moveToPath(object, tarPoint);
            self.excCount = self.excCount + 1;
        end
    end
end

function AutoFindPath:moveToPath(object, tarPoint)
    local objPoint = object:getPosition();   --角色坐标

    --计算方向并移动目标对象
    local dir = FuncPack:calcuteDirFromPoint(objPoint, tarPoint)
    local step = FuncPack:getDistanceWithOPoints(objPoint, tarPoint)
    if step >= 2 and object:getAllowRun() then
        step = 2;
    else
        step = 1;
    end

    local ret = MoveScript:moveTo(object, tarPoint, step);

    --移动间隔时间
    if ret then
        self.moveClock:markRingTime();

		engine.dispachEvent("PREPARE_MOVE", {isRun=step-1, dir=dir, pos=object:getPositionOfMap()});
    end
end

function AutoFindPath:checkBeginMove(object)
    local objPoint = object:getPosition();

    if self:checkDelta(object:getMoveDelta()) == false then
        --TraceError("time:"..engine.gettime());
        return false;
    end

    return true;
end

function AutoFindPath:checkMoveDone(object)
    local objPoint = object:getPosition();

    if FuncPack:isEqualPoint(objPoint, self.tarPoint) then
        self:over(object);
        return true;
    end

    return false;
end

function AutoFindPath:shiftNextPath(objPoint, currTarPoint)
    if FuncPack:isEqualPoint(objPoint, currTarPoint) then
        self.curPathID = self.curPathID + 1;

        return true;
    end

    return false;
end

function AutoFindPath:pointIsOnCheck(pos)
    return pos.x%TILE_WIDTH == 0 and pos.y%TILE_HEIGHT == 0;
end

function AutoFindPath:getRunning()
    return self.autoFindPath;
end

function AutoFindPath:over(object)
    object:unLockActorStatus();-- = false

    if self.excCount ~= 0 then
        object:idle();
    end

    self:ctor();
end

--检查是否到了移动的间隔时间
function AutoFindPath:checkDelta(delta)
    self.moveClock:setRingTimeDelta(delta);
    return self.moveClock:ring();
end

--获取路径
function AutoFindPath:getAStarPath(objPos, tarPos, map)
    --判断是否运行跑步
    local step = nil;
    if self.master:getAllowRun() then
        step = 2;
    end

    local path = AStarFindPath:getAStarPath(objPos, tarPos, map, step) --path get

    --去掉最后一个,这个是目标占的位置
    --[[if path ~= nil and #path > 0 then
        table.remove(path, #path);
    end]]

    return path;
end
