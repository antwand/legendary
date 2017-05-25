
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

function output(str)
	local file = io.open("D:/log.txt", "w");
	file:write("----------------------------------------------");
	file:write(os.date("%Y-%m-%d %X ", os.time()).."    msg:"..str.."   :"..debug.traceback());
	file:write("----------------------------------------------\r\n\r\n");
	file:close();
end

-- CC_USE_DEPRECATED_API = true
require "cocos.init"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\r\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
	--[[
	output(msg);
	]]
    return msg;
end


local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

	--load lua module
	require "config.lua"

    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    --director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

    --cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, 0)
	cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1024, 768, 0)

	--cc.Texture2D:setDefaultAlphaPixelFormat(3);
    --create scene
	--local scene = require("scene.LoadResScene.lua")
	local scene = require("test/ChooseScene.lua")
    local gameScene = scene.create()
    gameScene:playBgMusic()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
