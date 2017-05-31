--region NewFile_1.lua
--Author : legend
--Date   : 2015/5/21
--此文件由[BabeLua]插件自动生成



--endregion
MapManager = {}
MapManager.waitLoadingMaps = {};
MapManager.maps = {};

function MapManager:getMap(id, callfunc)
	if MapManager.maps[id] then
		return MapManager.maps[id];
	end

    local conf = MapConf[id];

    if not conf then
		TraceError("map conf no found");
        return nil;
    else
        return MapManager:loadingMap(conf, callfunc);
    end
end

function MapManager:loadingMap(conf, callfunc)
    if MapManager.waitLoadingMaps[conf.id] then
        TraceError("already exist map");
        return MapManager.waitLoadingMaps[conf.id];
    end

    local map = Map:create();
	map:setID(conf.id);
	map:setConf(conf);
    map:initWithSize({width=10, height=10}, {width=TILE_WIDTH, height=TILE_HEIGHT});
    map:initWithJsonFile(conf.sz_path, "loadMapComplete");
	map:retain();

	if not callfunc then
		TraceError("no found callfunc for map "..conf.id.."  track:"..debug.traceback());
	end

    MapManager.waitLoadingMaps[conf.id] = {map=map, callfunc=callfunc};

    return map;
end

function MapManager:launch()
    if not MapManager.loadingMapScheduler then
        local function loadingMapFunc()
            MapManager:loadingMapFunc();
        end

        local scheduler = cc.Director:getInstance():getScheduler();
        self.loadingMapScheduler = scheduler:scheduleScriptFunc(loadingMapFunc, 1, false);
    end
end

function MapManager:loadingMapFunc()
    for k,v in pairs(MapManager.waitLoadingMaps) do
        if v.map:getLoadingDataComplete() == 1 then
            v.map:updateMapSize();
			v.map:init();
            v.callfunc(v.map);

            --标记
            MapManager.maps[k] = v.map;
            MapManager.waitLoadingMaps[k] = nil;
        end
    end
end

function MapManager:release()
	for k,v in pairs(MapManager.maps) do
		v:release();
	end

	for k,v in pairs(MapManager.waitLoadingMaps) do
		v:release();
	end

	MapManager.waitLoadingMaps = {};
	MapManager.maps = {};
end

function MapManager:destroyMap(mapid)
	if MapManager.maps[mapid] then
		MapManager.maps[mapid]:removeFrom();
		MapManager.maps[mapid]:release();
		MapManager.maps[mapid] = nil;
	end
end
