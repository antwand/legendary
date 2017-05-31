NPCTalkingWindow = class("NPCTalkingWindow", function()
    return cc.Layer:create();
end)

function NPCTalkingWindow:ctor()
	local result = require("ui/TalkWindow.lua").create();
    local rootNode = result['root'];
	self.rootNode = rootNode;
	self:addChild(rootNode);

	local closeBtn = rootNode:getChildByName("closeBtn")
	closeBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:getParent():removeChild(self);
        end
	end);

	self.callFuncs = {};

	self:regisCallFunc(1, function(funcType, funcStr, commandIdx)
		print(funcStr);
	end);

	self:regisCallFunc(2, function(funcType, funcStr, commandIdx)
		print("传送:"..tostringex({npcId=self.npcId,confId=self.confId, commandIdx=commandIdx}));

		client:sendMessageWithRecall("NPC_REQUEST", {npcId=self.npcId,confId=self.confId, commandIdx=commandIdx}, function(msg)
			--engine.dispachEvent("SHOW_DAMAGE", msg);
		end);
	end);

	self:regisCallFunc(3, function(funcType, funcStr, commandIdx)
		print("购买");
	end);

	self:regisCallFunc(4, function(funcType, funcStr, commandIdx)
		print("切换面板");
		self:clear();

		local conf = talkConf[tonumber(funcStr)];
		self:readConf(conf);

		self.confId = conf.id;
	end);
end

function NPCTalkingWindow:regisCallFunc(_type, func)
	self.callFuncs[_type] = func;
end

function NPCTalkingWindow:getWindowSize()
	local back = self.rootNode:getChildByName("back")
	return back:getContentSize();
end

function NPCTalkingWindow:clear()
	local listView = self.rootNode:getChildByName("ListView")
	listView:clear();
end

function NPCTalkingWindow:readConf(conf)
	local listView = self.rootNode:getChildByName("ListView")

	for k,v in pairs(conf.tb_content) do
		local _type = v.type or 1;
		local str = v.str;
		local color = v.color;
		local funcType = v.funcType;
		local funcStr = v.funcStr;
		local isWrap = v.isWrap;
		local callFunc = nil;

		if funcType then
			callFunc = self.callFuncs[funcType];
		end

		if _type == 1 then
			listView:insertString(str, fontSize, color, isWrap, funcType, funcStr, k, callFunc);
		elseif _type == 2 then
			listView:insertImage(filename, isWrap, funcType, funcStr, k, callFunc);
		end
	end

	self.confId = conf.id;
end
