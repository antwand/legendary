engine = {}
engine.aniCache = {}
engine.bodyFileCache = {};

local ttfConfig = {}
ttfConfig.fontFilePath = "fonts/W2.ttf"--"fonts/song.ttf"
ttfConfig.fontSize = 20
ttfConfig.glyphs = 0

engine.initLabel = function(name, size)
	size = size or 12;

	local label = BorderLabel:new(size);--cc.Label:createWithSystemFont(name, "", size);
	--label:setString(name);
	--label:enableOutline(cc.c3b(0, 0, 0), 1);
	label:setString(name);
	--label:setAnchorPoint(0, 0);
	label:enableLabelOutline({r=0, g= 0, b=0}, size, 1);

    return label--engine.initLabelEx(name, size);
end

function degrees2radians(angle)
    return angle * 0.01745329252
end

function radians2degrees(angle)
    return angle * 57.29577951
end

engine.createStroke = function(node, strokeWidth, color, opacity)
    local w = node:getContentSize().width + strokeWidth * 2
    local h = node:getContentSize().height + strokeWidth * 2
    local rt = cc.RenderTexture:create(w, h)

    -- 记录原始位置

    local originX, originY = node:getPosition()
    -- 记录原始颜色RGB信息

    local originColorR = node:getColor().r
    local originColorG = node:getColor().g
    local originColorB = node:getColor().b
    -- 记录原始透明度信息

    local originOpacity = node:getOpacity()
    -- 记录原始是否显示

    local originVisibility = node:isVisible()
    -- 记录原始混合模式

    local originBlend = node:getBlendFunc()

    -- 设置颜色、透明度、显示

    node:setColor(color)
    node:setOpacity(opacity)
    node:setVisible(true)
    -- 设置新的混合模式

    local blendFuc = {}
    blendFuc.src = GL_SRC_ALPHA
    blendFuc.dst = GL_ONE
    -- blendFuc.dst = GL_ONE_MINUS_SRC_COLOR

    node:setBlendFunc(blendFuc)

    -- 这里考虑到锚点的位置，如果锚点刚好在中心处，代码可能会更好理解点

    local bottomLeftX = node:getContentSize().width * node:getAnchorPoint().x + strokeWidth
    local bottomLeftY = node:getContentSize().height * node:getAnchorPoint().y + strokeWidth

    local positionOffsetX = node:getContentSize().width * node:getAnchorPoint().x - node:getContentSize().width / 2
    local positionOffsetY = node:getContentSize().height * node:getAnchorPoint().y - node:getContentSize().height / 2

    local rtPosition = {x=originX - positionOffsetX, y=originY - positionOffsetY}

    rt:begin()
    -- 步进值这里为10，不同的步进值描边的精细度也不同

    for i = 0, 360, 10 do
        -- 这里解释了为什么要保存原来的初始信息

        node:setPosition({x=bottomLeftX + math.sin(degrees2radians(i)) * strokeWidth, y=bottomLeftY + math.cos(degrees2radians(i)) * strokeWidth})
        node:visit()
    end
    rt:endToLua()

    -- 恢复原状

    node:setPosition(originX, originY)
    node:setColor(cc.c3b(originColorR, originColorG, originColorB))
    node:setBlendFunc(originBlend)
    node:setVisible(originVisibility)
    node:setOpacity(originOpacity)

    rt:setPosition(rtPosition)

    return rt
end

engine.initLabelEx = function(name, size)
	local oldSize = ttfConfig.fontSize;
	ttfConfig.fontSize = size or 20;

    local label = cc.Label:createWithTTF(ttfConfig, name)
	label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
	label:setString(name);
	label:setColor(cc.c3b(255, 255, 255));
	label:enableOutline(cc.c3b(0, 0, 0), 1);
	--label:enableShadow(cc.c3b(0, 0, 0), {x=1, y=-1}, 0);
	--[[
	local label = cc.Label:createWithSystemFont(name, "Arial",
		ttfConfig.fontSize, {x=0,y=0}, cc.TEXT_ALIGNMENT_LEFT, cc.TEXT_ALIGNMENT_LEFT);
	label:setString(name);
	label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);]]
	--label:enableOutline(cc.c3b(0, 0, 0), 1);

	ttfConfig.fontSize = oldSize;

    return label;
end

engine.initSpriteWithOffset = function(dir, file)
	if not dir or not file then
		return;
	end

    local frame = engine.getSpriteFrame(dir.."/"..file);
    local str = split(file, ".");
    local offset = engine.registFramesOffset(dir.."/Placements/"..str[1]..".txt");

    local size = frame:getOriginalSize();
    frame:setOffset({x=offset.x, y=offset.y-size.height});

    local sprite = engine.initSpriteFromSpriteFrame(frame);
    sprite:setAnchorPoint(0, 0);
    return sprite;
end

engine.initSprite = function(imgPath)
    if not imgPath then
        return nil;
    end

    local sprite = et.SpriteX:create(imgPath);

    if not sprite then
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(imgPath);

		if frame then
			sprite = et.SpriteX:createWithSpriteFrame(frame);
		else
			TraceError("no found sprite:"..imgPath);
			return;
		end
    end

	if not sprite then
		TraceError("no found sprite:"..imgPath);
		return;
	end

	sprite:getTexture():setAliasTexParameters();
	sprite:getTexture():setAntiAliasTexParameters();

    return sprite;
end

engine.initSpriteFromSpriteFrame = function(spriteFrame)
	if not spriteFrame then
		TraceError("invalid spriteframe "..debug.traceback());
		return;
	end

    return et.SpriteX:createWithSpriteFrame(spriteFrame);
end

engine.getBlankSprite = function()
    local aSprite = ActionSprite:create();
    local sprite = engine.initSprite("temporary/blank.png");
    aSprite:setSprite(sprite);
	aSprite.isBlankSprite = true;

    return aSprite;
end

engine.getAnimation = function(name)
    local ani = cc.AnimationCache:getInstance():getAnimation(name)
    return ani;
end

engine.getSpriteFrame = function(name)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name);

    if not frame then
        local texture = cc.Director:getInstance():getTextureCache():addImage(name)

        if texture then
            local rect = cc.rect(0, 0, texture:getPixelsWide(), texture:getPixelsHigh())
            frame = cc.SpriteFrame:createWithTexture(texture, rect)
        end
	else
		TraceError("no found spriteframe "..name);
    end

    return frame;
end

engine.getDefaultSpriteFrame = function()
    local texture = cc.Director:getInstance():getTextureCache():addImage("temporary/blank.png");
    local rect = cc.rect(0, 0, texture:getPixelsWide(), texture:getPixelsHigh())
    local frame = cc.SpriteFrame:createWithTexture(texture, rect)

    return frame;
end

engine.getTexture2D = function(name)
    return cc.TextureCache:getInstance():getTextureForKey(name);
end

engine.initSpriteWithRect = function(imgPath, rect)
    local sprite = et.SpriteX:create(imgPath, rect);

    if not sprite then
        --TraceError(imgPath.." no found");
    end

    return sprite;
end

engine.initSpriteWithRect = function(imgPath, x, y, width, height)
    local rect = {x = x, y = y, width = width, height = height}
    return et.SpriteX:create(imgPath,rect);
end

--棰濆娣诲姞涓€涓鍔犳瘡涓€甯у搴旂殑鍋忕Щ浣嶇疆
engine.registFramesOffset = function(fileName)
    local fileIsExit = cc.FileUtils:getInstance():isFileExist(fileName)
    if fileIsExit == false then
        TraceError("鎵句笉鍒拌鏂囦欢" .. fileName..debug.traceback())
        return nil;
    end

    local fileData = cc.FileUtils:getInstance():getStringFromFile(fileName);
    local rows = split(fileData, "\r\n")
    local x = tonumber(rows[1]);
    local y = -tonumber(rows[2]) + TILE_HEIGHT;

    return {x=x, y=y};
end

engine.getFramesInfoList = function(info, isReadOffset)
    local framesName = {};
    local framesOffset = {};

    for index = info.offset, info.offset + info.count - 1, info.step do
        local frameName = string.format(info.sz_path.."_%06d.png", index)

        table.insert(framesName, #framesName+1, frameName);

        --澧炲姞甯у亸绉婚噺
        if isReadOffset == true then
            local frameOffsetFile = string.format(info.sz_path.."/Placements/%06d.txt", index)
            local offsetPoint = engine.registFramesOffset(frameOffsetFile);
            table.insert(framesOffset, #framesOffset+1, offsetPoint);
        end
    end

    return framesName, framesOffset;
end

engine.initSpriteFromFrameCache = function(name)
    local frameCache = cc.SpriteFrameCache:getInstance();
    local spriteFrame = frameCache:getSpriteFrame(name);
    local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame);
    return sprite;
end

engine.initAnimationFromNames = function(aniName, names, delay, isLoops, offsetTable, backFirstFrame)
    local animation = cc.Animation:create();
    animation:setLoops(isLoops);
    animation:setDelayPerUnit(delay);
    animation:setRestoreOriginalFrame(backFirstFrame);

    for key, value in pairs(names) do
        local frame = engine.getSpriteFrame(value);

        --[[
        if not frame and key == 1 then
            return nil;]]
        if not frame then
            frame = engine.getDefaultSpriteFrame();
        end

        --璁剧疆甯у亸绉婚噺
        if offsetTable ~= nil and offsetTable[key] ~= nil then
            local size = frame:getOriginalSize();
            frame:setOffset({x=offsetTable[key].x, y=offsetTable[key].y-size.height})
        else
            TraceError(value.."璁剧疆鍋忕Щ閲忓け锟?"..tostringex(offsetTable))
        end

        animation.addSpriteFrame(animation,frame)
    end

    local oldAnimation = cc.AnimationCache:getInstance():getAnimation(aniName)
    if oldAnimation ~= nil then
        TraceError(aniName.." already exit");
    end

    cc.AnimationCache:getInstance():addAnimation(animation,aniName)

    return animation;
end

engine.loadAnimationResource = function(conf, name, isReadOffset, backFirstFrame)
    local startOffset = conf[1].offset;

    if engine.aniCache[startOffset..name] ~= nil then
        return 0;  --宸插瓨鍦ㄥ姩鐢荤紦锟?
    end

    for index,info in pairs(conf) do
        --鐢熸垚鍔ㄧ敾淇℃伅
        local framesName, framesOffset = engine.getFramesInfoList(info, isReadOffset);

        --澧炲姞缂撳啿鍔ㄧ敾
        local aniname = name..info.offset.."_"..index;
        local animation = engine.initAnimationFromNames(aniname, framesName, info.delay, info.isLoops, framesOffset, backFirstFrame);
        if animation == nil then
            TraceError(name.."鐨勭"..index.."鍔ㄧ敾鍔犺浇澶辫触");
        end
    end

    engine.aniCache[startOffset..name] = conf;

    return 1;
end

engine.readAniConfToSprite = function(conf, name)
    local actions = {};
    local startOffset = conf[1].offset;

    for index=1, #conf, 1 do
        local offset = conf[index].offset;
        local animationName = name.."_"..startOffset.."_"..index;
        local animation = engine.getAnimation(animationName);

        if not animation then
            --g_rsyncLoader:loadPreloadAnimationData(animationName);
            --animation = engine.getAnimation(animationName);

            if not animation then
                TraceError(name.."_"..startOffset.."_"..index.." no found");
                return engine.getBlankSprite();
            end
        end

        local animate = cc.Animate:create(animation);
        actions[tostring(index)] = animate;
    end

    local aSprite = ActionSprite:create();
    aSprite:addActions(actions);

    return aSprite, true;
end

--[[
engine.readActionSpriteFromIndex = function(path)
    local spriteConf = readTabFile(path)

    if not spriteConf then
        return nil;
    end

    if engine.aniCache[path] == nil then   --璇ヨ祫婧愭枃浠舵病鏈夊姞杞借繃
        engine.loadAnimationResource(spriteConf, path, true, false)
    end

    return engine.readAniConfToSprite(spriteConf, path);
end]]

--鐢熸垚绮剧伒鐨勮鍙栭厤缃〃
--鍙傛暟 1.鏂囦欢璺緞  2.寮€濮嬪亸绉讳綅  3.鍔ㄧ敾甯ф暟  4.鍔ㄧ敾鏁伴噺   5.绌哄浘鐗囨暟锟? 6.鎾斁閫熷害  7.鏄惁寰幆
engine.figureSpriteConf = function(path, startOffset, framesPerAni, aniCount, interval, delay, isLoops)
    local confs = {};
    --(path, startOffset+0, 4, 8, 4, 0.2, -1)
    for i=0, aniCount-1 do
        local conf = {}
        conf.sz_name = path.."/"..startOffset.."/"..i;
        conf.sz_path = path;
        conf.offset = startOffset + (interval+framesPerAni)*i;
        conf.count = framesPerAni;
        conf.delay = delay;
        conf.isLoops = isLoops;
        conf.step = 1;

        table.insert(confs, #confs+1, conf);
    end

    return confs;
end

--------------------------璇诲彇瑙掕壊鍔ㄧ敾鐨勫嚱锟?-------------------------
engine.readBodyMapSprite = function(path, startOffset)
    local spriteConf = nil;


    if engine.aniCache[path..startOffset] == nil then   --璇ヨ祫婧愭枃浠舵病鏈夊姞杞借繃
        spriteConf = engine.readBodyConf(path, startOffset);

        --engine.loadAnimationResource(spriteConf, path, true, false)
        engine.aniCache[path..startOffset] = spriteConf;
    else
        spriteConf = engine.aniCache[path..startOffset];
    end

    return engine.readAniConfToSprite(spriteConf, path);
end

engine.readBodyConf = function(path, startOffset)
    local conf = {};

    --stand    1
    local standArray = engine.figureSpriteConf(path, startOffset+0, 4, 8, 4, 0.2, -1);
    for k,v in pairs(standArray) do
        table.insert(conf, #conf+1, v);
    end

    --walk     2
    local moveArray = engine.figureSpriteConf(path, startOffset+64, 6, 8, 2, 0.2, -1);
    for k,v in pairs(moveArray) do
        table.insert(conf, #conf+1, v);
    end

    --attack   3
    local attackArray = engine.figureSpriteConf(path, startOffset+200, 6, 8, 2, 0.1, 1);
    for k,v in pairs(attackArray) do
        table.insert(conf, #conf+1, v);
    end

    --hurt   4
    local hurtArray = engine.figureSpriteConf(path, startOffset+472, 3, 8, 5, 0.1, 1);
    for k,v in pairs(hurtArray) do
        table.insert(conf, #conf+1, v);
    end

    --die   5
    local dieArray = engine.figureSpriteConf(path, startOffset+536, 4, 8, 4, 0.1, 1);
    for k,v in pairs(dieArray) do
        table.insert(conf, #conf+1, v);
    end

    --run   6
    local moveArray = engine.figureSpriteConf(path, startOffset+128, 6, 8, 2, 0.2, -1);
    for k,v in pairs(moveArray) do
        table.insert(conf, #conf+1, v);
    end

    --idle   7
    local attackArray = engine.figureSpriteConf(path, startOffset+192, 1, 8, 0, 0.1, 1);
    for k,v in pairs(attackArray) do
        table.insert(conf, #conf+1, v);
    end

    --attack2  8
    local attackArray = engine.figureSpriteConf(path, startOffset+264, 6, 8, 2, 0.1, 1);
    for k,v in pairs(attackArray) do
        table.insert(conf, #conf+1, v);
    end

    --cast    9
    local castArray = engine.figureSpriteConf(path, startOffset+392, 6, 8, 2, 0.1, 1);
    for k,v in pairs(castArray) do
        table.insert(conf, #conf+1, v);
    end

    --drag    10
    local digArray = engine.figureSpriteConf(path, startOffset+456, 2, 8, 0, 0.2, 1);
    for k,v in pairs(digArray) do
        table.insert(conf, #conf+1, v);
    end

    return conf;
end

--鎬墿鍔ㄧ敾
engine.readMonsterSprite = function(spriteid)--path, startOffset)
	if not spriteid or spriteid == 0 then
		return;
	end

	local conf = spriteConf[spriteid];
	local file = conf.sz_file;
	local path = conf.sz_title;
	local startOffset = conf.offset;
	local spriteConf = nil;

    if engine.aniCache[path..startOffset] == nil then   --璇ヨ祫婧愭枃浠舵病鏈夊姞杞借繃
        spriteConf = engine.readMonsterConf(path, startOffset);
        --engine.loadAnimationResource(spriteConf, path, true, false)
        engine.aniCache[path..startOffset] = spriteConf;
    else
        spriteConf = engine.aniCache[path..startOffset];
    end

	local asprite = engine.readAniConfToSprite(spriteConf, path);

	if AsyncLoadFile.checkExist(file) == 0 then
		AsyncLoadFile.LoadFile(file, function(isThread)
			if isThread then
				local newASprite = engine.readAniConfToSprite(spriteConf, path);
				asprite:copy(newASprite);
			end
		end);
	end

    return ;
end

engine.hasSpriteId = function(spriteid)
	if not spriteid or spriteid == 0 then
		TraceError("no spriteid:"..tostringex(spriteid))
		return;
	end

	local conf = spriteConf[spriteid];
	if not conf then
		TraceError("no sprite conf id:"..spriteid);
		return;
	end

	return true;
end

engine.readASprite = function(spriteid)
	if not engine.hasSpriteId(spriteid) then
		TraceError("no found sprite id:"..spriteid);
		return;
	end

	local conf 		 = spriteConf[spriteid];
	local file      = conf.sz_file;
	local path      = conf.sz_title;
	local atype     = conf.type;
	local offset    = conf.offset;
	local isThead   = nil;
	local sprite    = engine.initSprite("temporary/blank.png");
	local aSprite   = ActionSprite:create();
	aSprite:setSprite(sprite);

	if engine.aniCache[file..offset] == nil then
		isThead = true;
	end
	--[[
	elseif atype == 2 then
		AsyncLoadMirFile:readMirSpriteX(file, 1, offset, function(aniSprite)
			if aniSprite then
				aSprite:merge(aniSprite);

				engine.aniCache[file..offset] = 1;
			end
		end, isThead);
	]]
	if atype < 10 then
		local aniSpriteX = AsyncLoadMirFile:readMirSpriteX(file, atype, offset, function(aniSprite)
			if aniSprite then
				aSprite:merge(aniSprite);

				engine.aniCache[file..offset] = 1;

				local label = aSprite:getChildByTag(10);
				if label then
					aSprite:removeChild(label);
				end
			end
		end, isThead);

		if isThead then
			local label = engine.initLabel("资源加载中...", 12);
			label:setTag(10);
			label:setPosition(TILE_WIDTH/2, TILE_HEIGHT/2 + 25);
			aSprite:addChild(label, 10);
		end

		if aniSpriteX then
			aSprite:setSprite(aniSpriteX);
		end
	elseif atype >= 10 then
		sprite:setBlendFunc({src=gl.ONE_MINUS_DST_COLOR, dst=gl.ONE});
		engine.readEffectSpriteX(sprite, conf);
	end

	return aSprite;--sprite:setBlendFunc({src=gl.ONE_MINUS_DST_COLOR, dst=gl.ONE});
end

engine.readEffectSpriteX = function(sprite, conf)
	for i=1, conf.animate do
		local animate = AsyncLoadMirFile:readMirAnimate(conf.sz_file, conf.offset+(i-1)*(conf.skip+conf.frame), conf.frame,
			1, conf.ftime, conf.b_isLoops);

		sprite:addStateAni(tostring(i), animate);
	end
end

engine.readSingleSpriteFromWzl = function(index, wzlname, wzxname, isIngoreOffset)
	return AsyncLoadMirFile:readSingleSprite(index, wzlname, wzxname, isIngoreOffset);
end

--鎬墿鍔ㄧ敾閰嶇疆
engine.readMonsterConf = function(path, startOffset)
    local conf = {}

	--engine.figureSpriteConf = function(path, startOffset, framesPerAni, aniCount, interval, delay, isLoops)
    --鍙傛暟 1.鏂囦欢璺緞  2.寮€濮嬪亸绉讳綅  3.鍔ㄧ敾甯ф暟  4.鍔ㄧ敾鏁伴噺   5.绌哄浘鐗囨暟锟? 6.鎾斁閫熷害  7.鏄惁寰幆
    --stand  1
    local standArray = engine.figureSpriteConf(path, startOffset+0, 4, 8, 6, 0.2, -1);
    for k,v in pairs(standArray) do
        table.insert(conf, #conf+1, v);
    end

    --walk   2
    local moveArray = engine.figureSpriteConf(path, startOffset+80, 6, 8, 4, 0.2, -1);
    for k,v in pairs(moveArray) do
        table.insert(conf, #conf+1, v);
    end

    --attack  3
    local moveArray = engine.figureSpriteConf(path, startOffset+160, 6, 8, 4, 0.2, 1);
    for k,v in pairs(moveArray) do
        table.insert(conf, #conf+1, v);
    end

    --hurt   4
    local moveArray = engine.figureSpriteConf(path, startOffset+240, 2, 8, 0, 0.2, 1);
    for k,v in pairs(moveArray) do
        table.insert(conf, #conf+1, v);
    end

    --die   5
    local moveArray = engine.figureSpriteConf(path, startOffset+260, 10, 8, 0, 0.2, 1);
    for k,v in pairs(moveArray) do
        table.insert(conf, #conf+1, v);
    end

    return conf;
end

--璇诲彇鍙湁涓€涓姸鎬佸嵆8涓姩鐢荤殑鍔ㄧ敾绮剧伒,涓€鑸敤浜庣壒锟?
engine.readSingleSprite = function(spriteid)
	if not spriteid or spriteid == 0 then
		return;
	end

	local conf   = spriteConf[spriteid];
	local title  = conf.sz_title;
	local offset = conf.offset;
	local file   = conf.sz_file;

	local spriteConf = nil;
	local index = conf.sz_title..conf.offset;

	if engine.aniCache[index] == nil then   --璇ヨ祫婧愭枃浠舵病鏈夊姞杞借繃
		spriteConf = engine.figureSpriteConf(title, offset, conf.framePerAni, conf.aniCount, conf.blankCount, conf.delay, conf.isLoop);

		engine.aniCache[index] = spriteConf;
	else
		spriteConf = engine.aniCache[index];
	end
end

--------------------------end--------------------------
--涓€浜涘紩鎿庡嚱锟?
engine.listenerGroup = {};
engine.dispachEvent = function(name, info)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local event = cc.EventCustom:new(name)
    event.info = info;
    eventDispatcher:dispatchEvent(event);
end

engine.addEventListenerWithScene = function(node, name, func)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    engine.listenerGroup[name] = cc.EventListenerCustom:create(name, func)
    --eventDispatcher:addCustomEventListener(name, func)

    eventDispatcher:addEventListenerWithSceneGraphPriority(engine.listenerGroup[name], node);
end

engine.addEventListener = function(name, func)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    engine.listenerGroup[name] = cc.EventListenerCustom:create(name, func)
    --eventDispatcher:addCustomEventListener(name, func)

    eventDispatcher:addEventListenerWithFixedPriority(engine.listenerGroup[name], 2);
end

engine.removeEventListener = function(name)
	if engine.listenerGroup[name] then
        local listener = engine.listenerGroup[name];
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

        eventDispatcher:removeEventListener(listener);
    end
end

engine.clearEventListener = function()
	for k,v in pairs(engine.listenerGroup) do
		engine.removeEventListener(k);
	end
end

engine.formatStr = function(iconId)
	if iconId < 10 then
		return "00000"..iconId
	elseif iconId < 100 then
		return "0000"..iconId
	elseif iconId < 1000 then
		return "000"..iconId
	elseif iconId < 10000 then
		return "00"..iconId
	elseif iconId < 100000 then
		return "0"..iconId
	elseif iconId < 1000000 then
		return iconId;
	end
end

engine.gettime = function()
    return socket.gettime();
end
