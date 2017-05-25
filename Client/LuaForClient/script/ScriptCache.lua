ScriptCache = {}
ScriptCache.__index = ScriptCache

function ScriptCache:create()
    local script = {}
    setmetatable(script, ScriptCache)
    script:ctor();
    return script;
end

function ScriptCache:ctor()
    self.commands = {};
    self.excCount = 1;
	self.isRun = nil;
	self.calcIsRunTimer = Clock:new();
	self.calcIsRunTimer:setRingTimeDelta(2);
end

--鍒濆鍖栬嚜鍔ㄥ璺熀鏈俊鎭?
function ScriptCache:execute(command, master)
    if not command then
        self:stop();
        return;
    end

	table.insert(self.commands, #self.commands+1, command);
end

function ScriptCache:update(master)
	if #self.commands > 0 then
		if master:getLockBehavior() then   --还在执行任务就挂起
			if self.calcIsRunTimer:ring() then   --持续20秒没有操作判断有异常情况
				self.isRun = nil;
			end

			return;
		end

		self.calcIsRunTimer:markRingTime();
		self:runCommand(master);
	end
end


function ScriptCache:runCommand(master)
	local command = self.commands[self.excCount];
	if not command then
		self:over(master);
		return;
	elseif command.id == 1 then
		local isRun = command.isRun;
		local dir = command.dir;

		if master.moveDelta == 0 then
			master:lockActorStatus();-- = true;
		end

		master:move(dir, isRun+1);
	elseif command.id == 2 then
		local skillName = command.skillName
		local values = command.values;
		local srcPos = command.srcPos;

		if FuncPack:isEqualPoint(srcPos,master:getPositionOfMap()) == false then
			local map = master:getMap();
			map:changeObjectPos(master:getID(), srcPos);
			master:idle();
		end

		master:unLockActorBehavior();

		local ret,reason = master:cast(skillName, values);
		if not ret then
			TraceError(master:getID().." cast "..skillName.." failed, because "..tostring(reason));
		end
	elseif command.id == 3 then
		local stand = command.stand
		if stand then
			master:stand();
		else
			master:climb();
		end
	elseif command.id == 4 then
		master:appear();
	end

	self.excCount = self.excCount + 1;
end

function ScriptCache:over(object)
    object:unLockActorStatus();-- = false

    if self.excCount ~= 0 then
        object:idle();
    end

    self:ctor();
end

function ScriptCache:stop()
	self:ctor();
end
