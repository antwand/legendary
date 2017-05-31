AsyncLoadMirFile = {}
AsyncLoadMirFile.loadingList = {}
AsyncLoadMirFile.loadedList = {}

function AsyncLoadMirFile:start()
	local mirLoader = et.MirFileLoader:getInstance();
	mirLoader:launchSchedule();

	local function loadingCallFunc(sprite)
		self:loadingCompleteFunc(sprite);
	end

	ScriptHandlerMgr:getInstance():registerScriptHandler(tolua.cast(mirLoader,
		"cc.Ref"), loadingCallFunc, cc.Handler.CALLFUNC);

	mirLoader:insertActionSetting(4, 0, 4, 6, 0.2, true);  --stand
	mirLoader:insertActionSetting(4, 80, 6, 4, 0.2, true); --run
	mirLoader:insertActionSetting(4, 160, 6, 4, 0.2, false);--attack
	mirLoader:insertActionSetting(4, 240, 2, 0, 0.2, false);--hurt
	mirLoader:insertActionSetting(4, 260, 20, 0, 0.2, false);--die
end

function AsyncLoadMirFile:release()
	local mirLoader = et.MirFileLoader:getInstance();

	mirLoader:release();
end

function AsyncLoadMirFile:readMirSpriteX(filename, _type, offset, callfunc, isThead)
	local mirLoader = et.MirFileLoader:getInstance();

	if isThead then
		mirLoader:asyncReadMirActionSprite(filename, _type, offset);

		table.insert(AsyncLoadMirFile.loadingList, #AsyncLoadMirFile.loadingList+1,
			callfunc);
	else
		local sprite = mirLoader:readMirActionSprite(filename, _type, offset);
		return sprite;--callfunc(sprite);
	end
end

function AsyncLoadMirFile:readSingleSprite(index, wzlname, wzxname, isIngoreOffset)
	local mirLoader = et.MirFileLoader:getInstance();

	local spriteFrame = mirLoader:readMirSpriteFrame(index, wzlname, wzxname);
	if not spriteFrame then
		TraceError(index.." single spriteframe cannot be found in "..wzlname.." and "..wzxname);
		return;
	end

	if isIngoreOffset then
		spriteFrame:setOffset({x=0,y=0});
	end

	local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame);
	if not sprite then
		TraceError(index.." single sprite cannot be found in "..wzlname.." and "..wzxname);
	end

	return sprite;
end

function AsyncLoadMirFile:loadingCompleteFunc(sprite)
	local func = AsyncLoadMirFile.loadingList[1];
	func(sprite);

	--delete
	table.remove(AsyncLoadMirFile.loadingList, 1)
end

function AsyncLoadMirFile:readMirAnimate(filename, start, frame, skip, ftime, isLoops)
	local mirLoader = et.MirFileLoader:getInstance();
	--output(filename.."--"..start.."--"..frame.."--"..skip.."--"..ftime.."--"..tostring(isLoops));
	return mirLoader:readMirAnimate(filename, start, frame, skip, ftime, isLoops);
end

function AsyncLoadMirFile:setClearNearBlackColor(clear)
	local mirLoader = et.MirFileLoader:getInstance();
	mirLoader:setClearNearBlackColor(clear);
end
