--region NewFile_1.lua
--Author : legend
--Date   : 2015/4/15
--此文件由[BabeLua]插件自动生成



--endregion
local Client = class("Client")

NETWORK_EVENT_CLOSE = 1
NETWORK_EVENT_DATA = 2
NETWORK_EVENT_CONNECT_OVERTIME = 3
NETWORK_EVENT_CONNECT_SUCCESS = 4

--connect type
local SOCK_STREAM = 1;
local SOCK_DGRAM = 2;

--protocol
local IPPROTO_TCP = 0
local IPPROTO_UDP = 1

function Client:ctor()
    self.msgCallbackStack = {};
	self.init = false;
    self.isConnect = false;
	self.delayTime = {};
end

function Client:connect(ip, port)
	if not self.init then
		TraceError("client create");
		self.client = et.ODClient:create();
		self.client:createSocket(2,1,0);
		self.client:retain();
		self.init = true;
	end

	if not self.isConnect then
		TraceError("client connect");
		self.ip = ip;
		self.port = port;
		self.isConnect = true;
		self:registLoginListener();
	end
end

function Client:setOvertime(time)
    if not self.overtimeClock then
        self.overtimeClock = Clock:new();
    end

    self.overtimeClock:setRingTimeDelta(time);
    self.overtimeClock:markRingTime();
end

function Client:registLoginListener()
	if self.loginUpdate then
		return;
	end

    local function loginUpdateFunc(delta)
        self:LoginUpdate(delta);
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    self.loginUpdate = scheduler:scheduleScriptFunc(loginUpdateFunc, 1, false);
end

function Client:removeLoginListener()
	if self.loginUpdate then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.loginUpdate);
		self.loginUpdate = nil;
	end
end

function Client:connectSuccess()
    local function ClientUpdateData()
        self:updateData();
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    self.dataUpdate = scheduler:scheduleScriptFunc(ClientUpdateData, 0, false);

	self.isConnect = true;
    self.client:listen();
    self.successFunc();
end

function Client:closeDataQuest()
	if not self.init or not self.isConnect then
		TraceError("client already close")
		return;
	end

	if self.dataUpdate then
		TraceError("close data schedule");
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.dataUpdate);
		self.dataUpdate = nil;
	end
end

function Client:send(msg)
	if self.isConnect == true then
		self.client:send(msg);
	else
		--TraceError("client not connect to server:"..tostring(self.isConnect));
	end
end

function Client:updateData()
	if self.isConnect then
		--local hasMsg = self.client:hasNewMessage();
		while self.client:hasNewMessage() do
			local msg = self.client:getNewMessage();
			--self.dataFunc(msg);
			local ret = self:parseData(msg);
			if ret then
				self.client:popMessage();
			end
		end

		local offline = self.client:getOffLine();
		if offline then
			TraceError("close client");
			self:close();
			self.closeFunc();

			return;
		end
	end
end

function Client:LoginUpdate(delta)
	if self.init then
		if self.overtimeClock:ring() then
			TraceError("overtime");
			self.overtimeFunc("overtime");
			self:removeLoginListener();
			self.isConnect = false;
		else
			local ret = self.client:connect(self.ip, self.port);
			TraceError("connect:"..tostring(ret));
			if ret == true then
				self:removeLoginListener();
				self:connectSuccess();
			end
		end
	end
end

function Client:addConnectEventListener(etype, func)
    if etype == NETWORK_EVENT_CLOSE then
        self.closeFunc = func;
    elseif etype == NETWORK_EVENT_DATA then
        self.dataFunc = func;
    elseif etype == NETWORK_EVENT_CONNECT_OVERTIME then
        self.overtimeFunc = func;
    elseif etype == NETWORK_EVENT_CONNECT_SUCCESS then
        self.successFunc = func;
    end
end

function Client:parseData(data)
    local dataTable = stringToTable(data);

	if not dataTable then
		TraceError("nil msg:|"..data.."|");
        return true;
	end

    if not dataTable.id then
        TraceError("invalid msg:"..data);
        return true;
    end

	if dataTable.ret then
		if dataTable.ret ~= 1 then
			TraceError(dataTable.id.." server msg error id:"..tostringex(dataTable._error));
		end
	end

    local msgName = dataTable.id;
    if not self.msgCallbackStack[dataTable.id] then
        TraceError("not find message type:"..dataTable.id);
        return true;
    end

	--TraceError("message id: "..dataTable.id);
	local parseSucceed = false;
	if self.msgCallbackStack[msgName] then
		self.msgCallbackStack[msgName](dataTable);

		parseSucceed = true;
	else
		TraceError("not find message type callfunc:"..dataTable.id.."  str:"..data);
	end

	--[[
	if self.delayTime[msgName] then
		--TraceError("msg:"..msgName.." delay:"..(engine.gettime()-self.delayTime[msgName]));
	end]]

	return parseSucceed;
end

function Client:sendMessage(id, values)
	values.id = id;

    local msgStr = TableToString(values);
    self:send(msgStr);
end

function Client:sendMessageWithRecall(id, values, func)
    values.id = id;

    local msgStr = TableToString(values);
    self:send(msgStr);

    self:registMessageCallBack(id, func);

	self.delayTime[id] = engine.gettime();
end

function Client:addMessageEventListener(msgName, func)
    self:registMessageCallBack(msgName, func);
end

function Client:registMessageCallBack(id, func)
	if self.msgCallbackStack[id] then
		TraceError(id.." message exists");
		return;
	end

    self.msgCallbackStack[id] = func;
end

function Client:clearMessageCallBack()
	self.msgCallbackStack = {};
	--TraceError("clear self.msgCallbackStack:"..tostringex(self.msgCallbackStack));
end

function Client:initMsgCallbackStack()
	self.msgCallbackStack = {};
end

function Client:close()
	self:initMsgCallbackStack();
	self:closeDataQuest();
	self:removeLoginListener();
    self.client:clean();
	self.client:release();
	self.init = nil;
	self.isConnect = false;
	TraceError("+---------------------+");
	TraceError("|----close connect----|");
	TraceError("+---------------------+");
end

TableToString = function(_t)
	if type(_t) ~= "table" then
		return _t;
	end

    local szRet = "{"
    function doT2S(_i, _v)
        if "number" == type(_i) then
            szRet = szRet .. "[" .. _i .. "]="
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "table" == type(_v) then
                szRet = szRet .. TableToString(_v) .. ","
			elseif "boolean" == type(_v) then
                szRet = szRet .. tostring(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        elseif "string" == type(_i) then
            szRet = szRet .. '["' .. _i .. '"]='
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "table" == type(_v) then
                szRet = szRet .. TableToString(_v) .. ","
			elseif "boolean" == type(_v) then
				szRet = szRet .. tostring(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        end
    end
    table.foreach(_t, doT2S)
    szRet = szRet .. "}"
    return szRet
end

stringToTable = function(string)
    local str = "return "..string
    local func = loadstring(str)
    return func();
end

function printTime(title, _time)
	local int,digit = math.modf(_time);
	TraceError(title..lua_to_db_time(int).."."..(digit*100000000000000))
end

return Client;
