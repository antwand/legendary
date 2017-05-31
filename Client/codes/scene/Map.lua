Map = {}
Map.__index = Map

function Map:create()
    local map = {};
    setmetatable(map, Map)
    map:ctor();
    return map;
end

function Map:ctor()
	self.id = nil;

    self.mapTiles = {}
    self.mapTiles[1] = {} --地面物品
    self.mapTiles[2] = {}  --中间存放玩家
    self.actorGroups = {}

    self.loadedTilesRects = {};
    self.layer = et.MirTileMap:create();
end

function Map:getLoadingDataComplete()
    return self.layer:getInitComplete();
end

function Map:initWithJsonFile(filename, callback)
    self.layer:setTileSize(TILE_WIDTH, TILE_HEIGHT);
    self.layer:setTileOrder(LayerzOrder.TILE, LayerzOrder.MID, LayerzOrder.OBJ);
    self.layer:initWithMapFile(filename, callback);
end

function Map:updateMapSize()
    self.mapSize = {width=self.layer:getWidth(), height=self.layer:getHeight()}
	self.layer:setShowTileDetail(false);
end

function Map:getInitComplete()
    return self.layer:getInitComplete();
end

function Map:show()
    local x,y = self.layer:getPosition();
    local visibleSize = cc.Director:getInstance():getVisibleSize();
    self.layer:showPart(-x-TILE_WIDTH*10, -y-TILE_HEIGHT*10, visibleSize.width+TILE_WIDTH*11, visibleSize.height+TILE_HEIGHT*11);
end

function Map:initWithSize(mapSize, tileSize)
    self.mapSize = mapSize;
    self.tileSize = tileSize;
end

function Map:init()
	--[[local count = self.layer:getPortalCount();
	print("current map portal count:"..count);
	for i=1, count do
		local pos = self.layer:getPortal(i-1);
		print("portal point:("..pos.x..","..pos.y..")");
	end]]
end

function Map:setDebugDrawMask(parent)
    local color = cc.c4f(100, 100, 100, 1)
    local mapSize = self.mapSize
    local tileSize = self.tileSize;

    for i=0, mapSize.width*mapSize.height do
        local row = i%mapSize.width
        local col = math.modf(i/mapSize.width)
        local tile = engine.initSprite("background.jpg", {x=0,y=0,width=tileSize.width,height=tileSize.height})
        local size = tile:getContentSize();

        tile:setAnchorPoint(0, 0);
        tile:setScale(tileSize.width/size.width, tileSize.height/size.height)
        tile:setPosition(row*tileSize.width, col*tileSize.height);
    end
end

function Map:hasObstacle(pos)
    local mapObj = self:getObjectFromMap(pos);

    if mapObj then
		--TraceError("("..pos.x..","..pos.y..")".." has obstacle");
        return mapObj;
    end

	if self:getLoadingDataComplete() == 1 then
		local mapTile = self:getMapTile(pos.x, pos.y);
		local isCanWalk = mapTile:getCanWalk();

		if isCanWalk == false then
			--TraceError("("..pos.x..","..pos.y..")".." can not walk");
			return 1;
		end
	end

    return nil;
end

function Map:getCanWalk(pos)
	local mapTile = self:getMapTile(pos.x, pos.y);
	local isCanWalk = mapTile:getCanWalk();

	return isCanWalk;
end

function Map:hasObstacleInPoint(point)
    local pos = FuncPack:pointToPosition(point);

    return self:hasObstacle(pos);
end

function Map:getObjectFromMapWithRange(leftBottom, rightTop)
    local leftBottomIndex = self:tranferPosToIndex(leftBottom);
    local rightTopIndex = self:tranferPosToIndex(rightTop);
    local rowOffset = rightTop.x - leftBottom.x;
    local colOffset = rightTop.y - leftBottom.y;

    local objList = {};
    local objLayer = self.mapTiles[2];

    for k,v in pairs(objLayer) do
        for col=0, colOffset do
            local rowMaxIndex = leftBottomIndex + rowOffset + col*self.mapSize.width;
            local rowMinIndex = leftBottomIndex + col*self.mapSize.width;

            if k >= rowMinIndex and k <= rowMaxIndex and v:isDie() == false then
                table.insert(objList, #objList+1, v);
            end
        end
    end
    --end

    return objList;
end

function Map:clearObjList()
    self.objList = nil;
end

function Map:tranferPosToIndex(pos)
    return pos.x + pos.y*self.mapSize.width
end

--[[
function Map:getObjectFromMap(pos)
	if self:checkPosValid(pos) == false then
		return nil;
	end

    local layer = 2;
    local index  = pos.x + pos.y*self.mapSize.width
    local objects = self.mapTiles[layer][index];

	--local _objects = {}
    if objects then
        if #objects > 0 then
			for k,v in pairs(objects) do
				if not v:isDie() then
					return v;
				end
			end
        end
    end

    return nil;
end
]]

function Map:getObjectFromMap(pos)
	if self:checkPosValid(pos) == false then
		return nil;
	end

    local layer = 2;
    local index  = pos.x + pos.y*self.mapSize.width
    local objects = self.mapTiles[layer][index];

	local liveObjects = {}
	if objects then
		for k,v in pairs(objects) do
			if not v:isDie() then
				table.insert(liveObjects, #liveObjects+1, v);
			end
		end
	end

	if #liveObjects <= 0 then
		liveObjects = nil;
	end

	return liveObjects;
end

function Map:removeObject(pid)
	local layer = 2;
    local actor = self.actorGroups[pid];

    if actor then
        local pos = actor:getPositionOfMap();
        local index  = self:tranferPosToIndex(pos);
        local objects = self.mapTiles[layer][index];

        for k,v in pairs(objects) do
            if v:getID() == pid then
                self.mapTiles[layer][index][k] = nil;
            end
        end

		actor:remove();
		actor.map = nil;
        self.actorGroups[pid] = nil;
    end

	return actor;
end

function Map:changeObjectPos(pid, point)
	if self:checkPosValid(point) == false then
		return false, "point invalid map width:"..self.mapSize.width..",height:"..self.mapSize.height;
	end

	local actor = self.actorGroups[pid];
	if actor then
		--delete
		local layer = 2;
		local pos = actor:getPositionOfMap();
        local index  = self:tranferPosToIndex(pos);
        local objects = self.mapTiles[layer][index];

		if objects then
			for k,v in pairs(objects) do
				if v:getID() == pid then
					self.mapTiles[layer][index][k] = nil;
				end
			end

			self.actorGroups[pid] = nil;
		end

		--add
		local curLayer = self.mapTiles[layer];
		local mapSize = self.mapSize;
		local tileSize = self.tileSize;
		local newPoint = {x=point.x*TILE_WIDTH, y=point.y*TILE_HEIGHT}

		--标记玩家位置
		self:sigalObjectPosition(actor, point);

		self:sigalObject(actor);

		actor:setPosition(newPoint.x, newPoint.y);
	end

	return 1;
end

function Map:addObject(object, point)
	local ret, reason = self:checkPosValid(point);
	if ret then
		local type = 2;
		local curLayer = self.mapTiles[type];
		local mapSize = self.mapSize;
		local tileSize = self.tileSize;

		--if self:hasObstacle(point) == nil then
		local newPoint = {x=point.x*TILE_WIDTH, y=point.y*TILE_HEIGHT}

		--标记玩家位置
		self:sigalObjectPosition(object, point);

		self:sigalObject(object);

		object:setPosition(newPoint.x, newPoint.y);

		if object:getMap() then
			if object:getMap() ~= self then
				object:remove();
				object:addTo(self.layer);
			end
		else
			object:addTo(self.layer);
		end

		object.map = self;

		--if hp <0 then play dead animation
		if object:getHp() == 0 then
			object:die();
		end
	else
		print("add object "..object:getID().." failed, reason:"..reason);
	end

	return true;
	--else
    --end
end

function Map:sigalObject(object)
	--id
    self.actorGroups[object:getID()] = object;
end

--[[
function Map:sigalObjectPosition(object, pos)
    local objLayerIndex = 2;

    if object.positionOfMap then
        local oldPos   = object.positionOfMap;
        local oldIndex = oldPos.x + oldPos.y*self.mapSize.width
        --删除老位�?
        self.mapTiles[objLayerIndex][oldIndex] = nil;
    end

    local index = pos.x + pos.y*self.mapSize.width

    --标记当前位置
    object.positionOfMap = pos;
    self.mapTiles[objLayerIndex][index] = object;
end]]

function Map:sigalObjectPosition(object, pos)
	if self:checkPosValid(pos) == false then
		return nil;
	end

    local objLayerIndex = 2;

    if object:getMap() then
        local oldPos = object:getPositionOfMap();
        self:delObjectWithIdAndPosition(object:getID(), oldPos);
    end

    local index = pos.x + pos.y*self.mapSize.width;
	if not self.mapTiles[objLayerIndex][index] then
		self.mapTiles[objLayerIndex][index] = {};
	end
    table.insert(self.mapTiles[objLayerIndex][index], #self.mapTiles[objLayerIndex][index]+1, object);

	object.positionOfMap = pos;
end

function Map:delObjectWithIdAndPosition(id, pos)
	if self:checkPosValid(pos) == false then
		return false;
	end

    local index = pos.x + pos.y*self.mapSize.width;
    local objects = self.mapTiles[2][index];

    for k,v in pairs(objects) do
        if id == v:getID() then
			self.mapTiles[2][index][k].positionOfMap = nil;
            self.mapTiles[2][index][k] = nil;
        end
    end

	return true;
end

function Map:addItem(item, position)
    local type = 1;
    local curLayer = self.mapTiles[type];

    if self:getItemFromMap(position) == nil then
        local mapSize = self.mapSize;
        local tileSize = self.tileSize;
        local newPos = {x=position.x*tileSize.width, y=position.y*tileSize.height}

        item:setIconPosition(newPos.x, newPos.y);
        item.positionOfMap = position;
        item:addToMapWithIcon(self.layer, LayerzOrder.ITEM);
        item.map = self;

        --标记玩家位置
        self:sigalItemPosition(item, position);
        return true;
    end

    return false;
end

function Map:removeItem(position)
    local item = self:getItemFromMap(position)
    --self.layer:removeChild(item.mapIconSprite);

    item:removeFromMapWithIcon();
    self:sigalItemPosition(nil, position);

	return item;
end

function Map:getItemFromMap(position)
    local itemLayer = 1;
    local index = position.x + position.y*self.mapSize.width

    return self.mapTiles[itemLayer][index];
end

function Map:sigalItemPosition(item, position)
    local itemLayer = 1;

    local index = position.x + position.y*self.mapSize.width
    --删除老位置
    self.mapTiles[itemLayer][index] = item;
end

function Map:getRandomCheckAroundCheck(pos)
    if pos.x > self.mapSize.width or pos.y > self.mapSize.height then
        return nil;
    end

    local objectLayerIdx = 2;
    if not self:getObjectFromMap({x=pos.x-1,y=pos.y}, objectLayerIdx) then        --left
        return {x=pos.x-1,y=pos.y}
    elseif not self:getObjectFromMap({x=pos.x+1,y=pos.y}, objectLayerIdx) then    --right
        return {x=pos.x+1,y=pos.y}
    elseif not self:getObjectFromMap({x=pos.x,y=pos.y-1}, objectLayerIdx) then    --down
        return {x=pos.x,y=pos.y-1}
    elseif not self:getObjectFromMap({x=pos.x,y=pos.y+1}, objectLayerIdx) then    --up
        return {x=pos.x,y=pos.y+1}
    elseif not self:getObjectFromMap({x=pos.x+1,y=pos.y+1}, objectLayerIdx) then       --upright
        return {x=pos.x+1,y=pos.y+1}
    elseif not self:getObjectFromMap({x=pos.x+1,y=pos.y-1}, objectLayerIdx) then         --downright
        return {x=pos.x+1,y=pos.y-1}
    elseif not self:getObjectFromMap({x=pos.x-1,y=pos.y-1}, objectLayerIdx) then           --downleft
        return {x=pos.x-1,y=pos.y-1}
    elseif not self:getObjectFromMap({x=pos.x-1,y=pos.y+1}, objectLayerIdx) then             --upleft
        return {x=pos.x-1,y=pos.y+1}
    else
        return nil;
    end
end

function Map:getClosedPosition(fromPos, toPos)
    local distance = nil;
    local closedPos = nil;

    local positions = FuncPack:getEightDirectionPosition(toPos);

    for k,v in pairs(positions) do
        local newDistance = self:getFreeSpaceDistanceToPosition(v, fromPos);
        if not distance or newDistance < distance then
            closedPos = v;
            distance = newDistance;
        end
    end

    return closedPos;
end

function Map:getFreePlaceAroundPosition(position, count)
    local positions = FuncPack:getEightDirectionPosition(position);
    local freePositions = {};

    for k,v in pairs(positions) do
        if self:getItemFromMap(v) == nil then
            table.insert(freePositions,#freePositions+1,v);
            count = count - 1;

            if count <= 0 then
                return freePositions;
            end
        end
    end

    return freePositions;
end

function Map:getFreeSpaceDistanceToPosition(pos, pos2, distance)
    if self:getObjectFromMap(pos) then
       return 10000;
    end

    return FuncPack:getDistanceWithOfPositions(pos, pos2)
end

function Map:updateObjectPosition(object, type)
    local curLayer = self.mapTiles[type];
    local point = object:getPosition();
    local position = {x=point.x/TILE_WIDTH, y=point.y/TILE_HEIGHT};

    if curLayer[position.x + position.y*self.mapSize.width] ~= nil then
        return false;
    end

    curLayer[position.x + position.y*self.mapSize.width] = object;

    return true;
end


function Map:setActorNameLabelColor(point, color)
    for k, v in pairs(self.mapTiles[3]) do
        local box = v:getCollisionRect();

        if point.x >= box.left and point.y >= box.bottom and point.x < box.right and point.y < box.top then
            v.nameLabel:setColor(color);
        else
            v.nameLabel:setColor(v.nameLabelColor);
        end
    end
end

function Map:centerOfPointInMap(point)
    local position = FuncPack:pointToPosition(point)
    local centerPoint = {x=position.x*TILE_WIDTH+TILE_WIDTH/2, y=position.y*TILE_HEIGHT+TILE_HEIGHT/2}

    return centerPoint;
end

--获取该层所有玩家列表
function Map:getObjectsInMapFromLayer()
    local players = {};
    local objectLayer = self.mapTiles[2];

    for k,v in pairs(objectLayer) do
        if v:isDie() == false then
            table.insert(players, #players+1, v);
        end
    end

    return players;
end

function Map:scenePointToMapPoint(point)
    local x,y = self.layer:getPosition();

    return {x=point.x-x, y=point.y-y};
end

function Map:checkPosValid(pos)
	if self:getLoadingDataComplete() ~= 1 then
		return true, "map is loading";
	end

	if pos.x >= self.mapSize.width or pos.x < 0 or pos.y >= self.mapSize.height or pos.y < 0 then
		return false, "invalid pos:("..pos.x..","..pos.y..")  map width:"..self.mapSize.width.."  height:"..self.mapSize.height;
	end

	return true;
end

function Map:getMapTile(x, y)
	--print("self.layer:getMapTile:  ("..x..","..y..")");
	return self.layer:getMapTile(x, y);
end

function Map:getRandomPosition()
	local x = FuncPack:getRandomNumber(0, self.mapSize.width-1);
	local y = FuncPack:getRandomNumber(0, self.mapSize.height-1);

	while self:hasObstacle({x=x,y=y}) do
		x = FuncPack:getRandomNumber(0, self.mapSize.width-1);
		y = FuncPack:getRandomNumber(0, self.mapSize.height-1);
	end

	--print("width:"..self.mapSize.width.."  height:"..self.mapSize.height.."   x:"..x.."  y:"..y);

	return {x=x,y=y};
end

--获取该层所有玩家id列表
function Map:getObjectsIDInMapFromLayer(layer)
    local playersID = {};
    local objectLayer = self.mapTiles[layer];

    for k,v in pairs(objectLayer) do
        if v:isDie() == false then
            table.insert(playersID, #playersID+1, v.id);
        end
    end

    return playersID;
end

function Map:setPosition(x, y)
	self.layer:setPosition(x, y);
	--print("2  x:".._x.."    y:".._y);
end

function Map:getPosition()
	local x,y = self.layer:getPosition();

	return {x=x, y=y};
end

function Map:getObjectWithId(id)
    return self.actorGroups[id];
end

function Map:getActorsGroup()
    return self.actorGroups;
end

function Map:getActors()
    return self.mapTiles[2];
end

function Map:setID(_id)
    self.id = _id;
end

function Map:getID()
	return self.id;
end

function Map:setConf(_conf)
	self.conf = _conf;
end

function Map:getConf()
	return self.conf;
end

function Map:addTo(parent, zOrder)
    parent:addChild(self.layer, zOrder);
end

function Map:removeFrom()
	local parent = self.layer:getParent();
	if parent then
		parent:removeChild(self.layer);
	end
end

function Map:retain()
    if self.layer then
        self.layer:retain();
    end
end

function Map:release()
	local count = self.layer:getReferenceCount();
	--print("map:"..self.id.."   count:"..count);
    if self.layer then
        self.layer:release();
		self.layer = nil;
    end
end
