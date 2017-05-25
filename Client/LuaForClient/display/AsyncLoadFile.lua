AsyncLoadFile = {}
AsyncLoadFile.waitingLoadFile = {}
AsyncLoadFile.fileCache = {}
AsyncLoadFile.threadPool = {}
AsyncLoadFile.loadedthreadPool = {}
AsyncLoadFile.threadMaxSize = 64
AsyncLoadFile.currTask = nil

--[[
AsyncLoadFile.LoadFile = function(filePath, callfunc)
	AsyncLoadFile.start();

	if type(filePath) == "table" then
		return AsyncLoadFile.loadMultiFile(filePath, callfunc);
	elseif type(filePath) == "string" then
		return AsyncLoadFile.loadSingleFile(filePath, nil, callfunc);
	end
end

AsyncLoadFile.start = function()
	if AsyncLoadFile.poll then
		return;
	end

    local scheduler = cc.Director:getInstance():getScheduler()
    AsyncLoadFile.poll = scheduler:scheduleScriptFunc(function()
		AsyncLoadFile.update();
	end, 1, false);
end

AsyncLoadFile.stop = function()
	if AsyncLoadFile.poll then
		local scheduler = cc.Director:getInstance():getScheduler();
		scheduler:unscheduleScriptEntry(AsyncLoadFile.poll);
	end
end

AsyncLoadFile.loadMultiFile = function(filepaths, callfunc)
	local threadid = nil;

	for k,v in pairs(filepaths) do
		if AsyncLoadFile.checkExist(v) == 0 then
			if not threadid then
				threadid = AsyncLoadFile.createAsyncThread();
			end

			AsyncLoadFile.loadSingleFile(v, threadid, callfunc)
		end
	end

	return threadid;
end

AsyncLoadFile.loadSingleFile = function(filepath, threadid, func)
	local isExist = AsyncLoadFile.checkExist(filepath);
	if isExist == 1 then
		if func then
			func(false);
		end
		return;
	elseif isExist == 2 then
		table.insert(AsyncLoadFile.waitingLoadFile[filepath].callfunc,
		#AsyncLoadFile.waitingLoadFile[filepath].callfunc+1, func);

		local imgPath  = filepath..".pvr.ccz";
		local confPath = filepath..".xfile";
		local threadid = AsyncLoadFile.waitingLoadFile[filepath].threadid;
		--TraceError("wait thread id "..threadid.." add file:"..imgPath..","..confPath);

		return AsyncLoadFile.waitingLoadFile[filepath].threadid;
	elseif isExist == 0 then
		if not threadid then
			threadid = AsyncLoadFile.createAsyncThread();
		end

		AsyncLoadFile.waitingLoadFile[filepath] = {callfunc={}, name=filepath};

		if func then
			table.insert(AsyncLoadFile.waitingLoadFile[filepath].callfunc,
			#AsyncLoadFile.waitingLoadFile[filepath].callfunc+1, func);
		end

		local thread   = AsyncLoadFile.getAsyncThread(threadid);
		local imgPath  = filepath..".pvr.ccz";
		local confPath = filepath..".xfile";
		thread:addLoadImg(imgPath, confPath);

		AsyncLoadFile.waitingLoadFile[filepath].threadid = threadid;
		AsyncLoadFile.waitingLoadFile[filepath].imgPath = imgPath;
		AsyncLoadFile.waitingLoadFile[filepath].confPath = confPath;

		--TraceError("start thread id "..threadid.." add file:"..imgPath..","..confPath);

		return threadid;
	end
	--createAsyncThread(filepath);
end

AsyncLoadFile.update = function(dt)
	if AsyncLoadFile.currTask then
		local threadid = AsyncLoadFile.currTask.threadid;
		local thread = AsyncLoadFile.getAsyncThread(threadid);
		local progress = thread:getLoadingPercent();

		if progress == 1 then
			for k,v in pairs(AsyncLoadFile.currTask.callfunc) do
				if v then
					v(true);
				end
			end

			AsyncLoadFile.signalThreadRan(threadid);

			AsyncLoadFile.fileCache[AsyncLoadFile.currTask.name] = AsyncLoadFile.currTask;

			AsyncLoadFile.currTask = nil;

			--print("thread id:"..threadid.." has been done");
			--print("-----------start load res file end--------------")
		end

		return;
	end

	for k,v in pairs(AsyncLoadFile.waitingLoadFile) do
		local threadid = v.threadid;

		if AsyncLoadFile.checkThreadRan(threadid) then
			AsyncLoadFile.fileCache[k] = AsyncLoadFile.waitingLoadFile[k];
			AsyncLoadFile.waitingLoadFile[k] = nil;
			--print(k.." file has been already loaded");
			return;
		end

		--print("-----------start load res file--------------")
		--print("load file:"..v.imgPath..","..v.confPath);

		local thread = AsyncLoadFile.getAsyncThread(threadid);
		thread:launchLoad();

		AsyncLoadFile.currTask = AsyncLoadFile.waitingLoadFile[k];
		AsyncLoadFile.waitingLoadFile[k] = nil;

		--print(k.." file start to load, thread id:"..threadid);

		return;
	end
end

AsyncLoadFile.createAsyncThread = function()
	if #AsyncLoadFile.threadPool >= AsyncLoadFile.threadMaxSize then
		--print("loaded thread over "..AsyncLoadFile.threadMaxSize);
		return;
	end

	local threadLoader = et.AsyncLoader:create();
	threadLoader:setIsLoadPlist(true);
	threadLoader:retain();

	table.insert(AsyncLoadFile.threadPool, #AsyncLoadFile.threadPool+1, threadLoader);

	return #AsyncLoadFile.threadPool;
end

AsyncLoadFile.getAsyncThread = function(id)
	return AsyncLoadFile.threadPool[id];
end

AsyncLoadFile.checkExist = function(name)
	if AsyncLoadFile.fileCache[name] then
		return 1;
	end

	if AsyncLoadFile.waitingLoadFile[name] then
		return 2;
	end

	return 0;
end

AsyncLoadFile.checkThreadRan = function(id)
	if AsyncLoadFile.loadedthreadPool[id] then
		return true;
	end
end

AsyncLoadFile.signalThreadRan = function(id)
	if AsyncLoadFile.loadedthreadPool[id] then
		--print("already exist loaded thread id:"..id);
	end

	AsyncLoadFile.loadedthreadPool[id] = 1;
end

AsyncLoadFile.getCurrTaskProgress = function()
	if AsyncLoadFile.currTask then
		local threadid = AsyncLoadFile.currTask.threadid;
		local thread = AsyncLoadFile.getAsyncThread(threadid);
		local progress = thread:getLoadingPercent();

		return progress;
	end
end

AsyncLoadFile.getTaskProgress = function(threadid)
	local thread = AsyncLoadFile.getAsyncThread(threadid);
	if thread then
		local progress = thread:getLoadingPercent();
		return progress;
	end
end
]]
