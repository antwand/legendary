ShortcutFrame = class("ShortcutFrame", function()
    return cc.Layer:create();
end)

function ShortcutFrame:ctor()
	local result = require("ui/ShortcutLayer.lua").create();
    local rootNode = result['root'];
	--local rootNode = cc.CSLoader:createNode("StateUI.csb");
	self.rootNode = rootNode;

	local winSize = cc.Director:getInstance():getWinSizeInPixels();
	local frameSize = rootNode:getChildByName("Sprite_1"):getContentSize();
	rootNode:setPosition(winSize.width/2 - frameSize.width/2, winSize.height/2 - frameSize.height/2);
    self:addChild(rootNode);

	self.shortcutList = {};

	local f1 = rootNode:getChildByName("F1");
	local f2 = rootNode:getChildByName("F2");
	local f3 = rootNode:getChildByName("F3");
	local f4 = rootNode:getChildByName("F4");
	local f5 = rootNode:getChildByName("F5");
	local f6 = rootNode:getChildByName("F6");
	local f7 = rootNode:getChildByName("F7");
	local f8 = rootNode:getChildByName("F8");
	local skillPic = rootNode:getChildByName("skillPic");
	local skillNameText = rootNode:getChildByName("skillNameText");
	local noneBtn = rootNode:getChildByName("noneBtn");
	local okBtn = rootNode:getChildByName("okBtn");
	local closeBtn = rootNode:getChildByName("closeBtn");
	local currChrText = rootNode:getChildByName("currChrText");

	okBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:selSkillShortcut();
			self:setVisible(false);
			self:saveSetting();

			engine.dispachEvent("SET_SKILL_SHORTCUT");
        end
    end);

	noneBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable();
        end
    end);

	closeBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setVisible(false);
        end
    end);

	f1:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f1, false);
        end
    end);

	f2:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f2, false);
        end
    end);

	f3:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f3, false);
        end
    end);

	f4:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f4, false);
        end
    end);

	f5:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f5, false);
        end
    end);

	f1:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f1, false);
        end
    end);

	f6:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f6, false);
        end
    end);

	f7:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f7, false);
        end
    end);

	f8:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:setFButtonEnable(f8, false);
        end
    end);
end

function ShortcutFrame:readSetting(pid)
	local file = io.open("res/userSetting/"..pid.."/setting.init");
	if file then
		for line in file:lines() do
			local str = split(line, "\t");
			local skillid = tonumber(str[1]);
			local sel = str[2];

			self.shortcutList[skillid] = sel;
		end

		file:close();
	end
end

function ShortcutFrame:saveSetting()
	local actor = Account:getCurrActor();
	local pid = actor:getID();

	os.execute('md "res/userSetting"');
	os.execute('md "res/userSetting/'..pid..'"');

	local file = io.open("res/userSetting/"..pid.."/setting.init","w");
	for k,v in pairs(self.shortcutList) do
		file:write(k.."\t"..v.."\n");
	end

	file:close();
end

function ShortcutFrame:showFrame(skillid)
	local rootNode = self.rootNode;
	local skillPic = rootNode:getChildByName("skillPic");
	local skillNameText = rootNode:getChildByName("skillNameText");
	local currChrText = rootNode:getChildByName("currChrText");

	local name = skillConf[skillid].sz_cn_name;
	local icon = skillConf[skillid].sz_icon;
	skillNameText:setString(name);
	skillPic:loadTexture(icon);

	local curSel = self.shortcutList[skillid];

	if curSel then
		local fBtn = rootNode:getChildByName(curSel);
		self:setFButtonEnable(fBtn, false);

		currChrText:setString("当前选择的快捷键:"..curSel);
	else
		self:setFButtonEnable();

		currChrText:setString("当前没有选择快捷键");
	end

	self.skillid = skillid;
end

function ShortcutFrame:selSkillShortcut()
	for k,v in pairs(self.shortcutList) do
		if v == self.sel then
			self.shortcutList[k] = nil;
			break;
		end
	end

	self.shortcutList[self.skillid] = self.sel;
end

function ShortcutFrame:getShortcutList()
	return self.shortcutList;
end

function ShortcutFrame:setFButtonEnable(btn, enable)
	local rootNode = self.rootNode;
	local f1 = rootNode:getChildByName("F1");
	local f2 = rootNode:getChildByName("F2");
	local f3 = rootNode:getChildByName("F3");
	local f4 = rootNode:getChildByName("F4");
	local f5 = rootNode:getChildByName("F5");
	local f6 = rootNode:getChildByName("F6");
	local f7 = rootNode:getChildByName("F7");
	local f8 = rootNode:getChildByName("F8");

	if not btn then
		f1:setEnabled(true);
		f2:setEnabled(true);
		f3:setEnabled(true);
		f4:setEnabled(true);
		f5:setEnabled(true);
		f6:setEnabled(true);
		f7:setEnabled(true);
		f8:setEnabled(true);
		self.sel = nil;
		return;
	end

	if f1 == btn then
		self.sel = "F1";
		f1:setEnabled(enable);
	else
		f1:setEnabled(self:reverse(enable));
	end

	if f2 == btn then
		self.sel = "F2";
		f2:setEnabled(enable);
	else
		f2:setEnabled(self:reverse(enable));
	end

	if f3 == btn then
		self.sel = "F3";
		f3:setEnabled(enable);
	else
		f3:setEnabled(self:reverse(enable));
	end

	if f4 == btn then
		self.sel = "F4";
		f4:setEnabled(enable);
	else
		f4:setEnabled(self:reverse(enable));
	end

	if f5 == btn then
		self.sel = "F5";
		f5:setEnabled(enable);
	else
		f5:setEnabled(self:reverse(enable));
	end

	if f6 == btn then
		self.sel = "F6";
		f6:setEnabled(enable);
	else
		f6:setEnabled(self:reverse(enable));
	end

	if f7 == btn then
		self.sel = "F7";
		f7:setEnabled(enable);
	else
		f7:setEnabled(self:reverse(enable));
	end

	if f8 == btn then
		self.sel = "F8";
		f8:setEnabled(enable);
	else
		f8:setEnabled(self:reverse(enable));
	end
end

function ShortcutFrame:reverse(enable)
	if enable then
		return false;
	end

	if not enable then
		return true;
	end
end

function ShortcutFrame:init()
	self.itemIntro = ItemIntroduatory:new();
	self.itemIntro:setVisible(false);
	self:addChild(self.itemIntro);

	self.equipBackClick = {};
end
