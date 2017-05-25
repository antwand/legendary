--region NewFile_1.lua
--Author : legend
--Date   : 2015/7/28
--姝ゆ枃浠剁敱[BabeLua]鎻掍欢鑷姩鐢熸垚



--endregion
ChrSelScene = class("ChrSelScene", function()
    return BaseScene:create()
end)

local styleGroups = {"战士", "巫师", "道士"}
local MAX_ACTOR_COUNT = 2;

function ChrSelScene:ctor()
	local result = require("ui/ChrSel.lua").create();
    local back = result['root'];
	self:addChild(back);

	--back:setScale(800/1024, 600/768);

	--local back = cc.CSLoader:createNode("chrSelUI.csb");
	--self:addChild(back);

	local chrSelPanel = back:getChildByName("chrSel");
	local chrCreatePanel = back:getChildByName("chrCreate");

	local warriorBtn = chrCreatePanel:getChildByName("warriorBtn");
	local magicBtn = chrCreatePanel:getChildByName("magicBtn");
	local taoistBtn = chrCreatePanel:getChildByName("taoistBtn");
	local womanBtn = chrCreatePanel:getChildByName("womanBtn");
	local manBtn = chrCreatePanel:getChildByName("manBtn");
	local commitBtn = chrCreatePanel:getChildByName("commitBtn");
	local closeBtn = chrCreatePanel:getChildByName("closeBtn");


	local createBtn = chrSelPanel:getChildByName("CreateBtn");
	local leftSelBtn = chrSelPanel:getChildByName("LeftSelBtn");
	local rightSelBtn = chrSelPanel:getChildByName("RightSelBtn");
	local startBtn = chrSelPanel:getChildByName("StartBtn");
	local delBtn = chrSelPanel:getChildByName("DelBtn");

	local l_nameLabel = chrSelPanel:getChildByName("LeftNameLabel");
	local l_levelLabel = chrSelPanel:getChildByName("LeftLevelLabel");
	local l_styleLabel = chrSelPanel:getChildByName("LeftStyleLabel");
	local r_nameLabel = chrSelPanel:getChildByName("RightNameLabel");
	local r_levelLabel = chrSelPanel:getChildByName("RightLevelLabel");
	local r_styleLabel = chrSelPanel:getChildByName("RightStyleLabel");

	l_nameLabel:setString("");
	l_levelLabel:setString("");
	l_styleLabel:setString("");
	r_nameLabel:setString("");
	r_levelLabel:setString("");
	r_styleLabel:setString("");

	self.chrSelPanel = chrSelPanel;
	self.chrCreatePanel = chrCreatePanel;

	leftSelBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			self:selChr(1);
        end
    end);

	rightSelBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			self:selChr(2);
        end
    end);

	closeBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
        elseif eventTouchType == ccui.TouchEventType.ended then
			chrCreatePanel:setVisible(false);
        end
    end);

	startBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
        elseif eventTouchType == ccui.TouchEventType.ended then
			self:start();
        end
    end);

	createBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
        elseif eventTouchType == ccui.TouchEventType.ended then
			chrCreatePanel:setVisible(true);
        end
    end);
	--[[
	delBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
			delBtn:setLocalZOrder(1);
        elseif eventTouchType == ccui.TouchEventType.ended then
			delBtn:setLocalZOrder(-1);

			self:delChr(self.currChr);
        end
    end);]]

	manBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:selSex(1);
        end
    end);

	womanBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            self:selSex(2);
        end
    end);

	warriorBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			self:selStyle(1);
        end
    end);

	magicBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            self:selStyle(2);
        end
    end);

	taoistBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            self:selStyle(3);
        end
    end);

	commitBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
        elseif eventTouchType == ccui.TouchEventType.ended then
			chrCreatePanel:setVisible(false);

			self:createChr();
        end
    end);

	self:selStyle(1);
	self:selSex(1);

	chrCreatePanel:setVisible(false);

	self.chrGroups = {};
	self.currChr = 1;

	client:addConnectEventListener(NETWORK_EVENT_CLOSE, function()
		Account:release();
		ActorManager:release();
		SkillManager:release();
		ItemManager:release();
		EffectManager:release();
		MapManager:release();

		local scene = require("scene.LoginScene")
		local loginScene = scene.create()
		loginScene:playBgMusic()

		cc.Director:getInstance():replaceScene(loginScene)
	end);
end

function ChrSelScene:selStyle(style)
	local warriorBtn = self.chrCreatePanel:getChildByName("warriorBtn");
	local magicBtn = self.chrCreatePanel:getChildByName("magicBtn");
	local taoistBtn = self.chrCreatePanel:getChildByName("taoistBtn");

	if style == 1 then
		warriorBtn:setEnabled(false);
		magicBtn:setEnabled(true);
		taoistBtn:setEnabled(true);
	elseif style == 2 then
		warriorBtn:setEnabled(true);
		magicBtn:setEnabled(false);
		taoistBtn:setEnabled(true);
	elseif style == 3 then
		warriorBtn:setEnabled(true);
		magicBtn:setEnabled(true);
		taoistBtn:setEnabled(false);
	end

	self.style = style;
end

function ChrSelScene:selSex(sex)
	local womanBtn = self.chrCreatePanel:getChildByName("womanBtn");
	local manBtn = self.chrCreatePanel:getChildByName("manBtn");

	if sex == 1 then
		womanBtn:setEnabled(true);
		manBtn:setEnabled(false);
	elseif sex == 2 then
		womanBtn:setEnabled(false);
		manBtn:setEnabled(true);
	end

	self.sex = sex;
end


function ChrSelScene:selChr(side)
	if side > Account:getActorsCount() then
		TraceError("no find actor:"..side);
		return;
	end

	local dormantSprite = self.chrSelPanel:getChildByTag(side + 2);
	local activeSprite = self.chrSelPanel:getChildByTag(side);

	if not dormantSprite then
		TraceError("no actor");
		return;
	end

	dormantSprite:setVisible(false);
	activeSprite:setVisible(true);

	local otherSide = nil;
	if side == 1 then
		otherSide = 2;
	else
		otherSide = 1;
	end

	local node = nil;
	if tonumber(side) == 1 then
		node = self.chrSelPanel:getChildByName("LeftNode");
	else
		node = self.chrSelPanel:getChildByName("RightNode");
	end
	local x, y = node:getPosition();

	local effectBack = self:readSpriteWithAni(4, 17, 1, 1, 0.05);
	effectBack:setPosition(x, y);
	self.chrSelPanel:addChild(effectBack, 3);

	local otherDormantSprite = self.chrSelPanel:getChildByTag(otherSide + 2);
	local otherActiveSprite = self.chrSelPanel:getChildByTag(otherSide);

	if otherActiveSprite then
		otherActiveSprite:setVisible(false);
		otherDormantSprite:setVisible(true);
	end

	self.currChr = tonumber(side);
	TraceError("self.currChr:"..tostringex(self.currChr));
end

function ChrSelScene:createChr()
	local nameLabel = self.chrCreatePanel:getChildByName("nameLabel")
	local name = nameLabel:getInputText();

	if name == "" then
		self:showMessage("角色名字不能为空");
		return;
	end

	if Account:getActorsCount() >= MAX_ACTOR_COUNT then
		self:showMessage("当前角色数量已达上限");
		return;
	end

	local info = {name=name, sex=self.sex, style= self.style}
	client:sendMessageWithRecall("CREATE_ACTOR", info, function(msg)
		if msg.ret == 0 then
			--TraceError("create actor fail");
			self:showMessage("连接超时,请检查服务器参数");
		else
			Account:addActorData(msg.data);
			self:addChr(msg.data, #self.chrGroups+1);
		end
	end);
end

function ChrSelScene:addChr(chrTable, index)
	if self.chrGroups[index] or index > 2 then
		return;
	end

	self.chrGroups[index] = chrTable;
	--table.insert(self.chrGroups, #self.chrGroups+1, chrTable);
	self:addChrAni(chrTable.style, chrTable.sex, chrTable.name, chrTable.level, index);
end

function ChrSelScene:addChrAni(style, sex, name, level, side)
	local styleIndex = style*40;
	local sexIndex = sex*120 - 120;
	local activeAniCountMin = styleIndex + sexIndex;
	local activeAniCountMax = styleIndex + sexIndex + 15;
	local dormantPicIndex = styleIndex + sexIndex + 20;

	local dormantSprite = engine.initSprite("UIRes/chrSel/"..formatNum(dormantPicIndex)..".png");
	local activeSprite = self:readSpriteWithAni(activeAniCountMin, activeAniCountMax, nil, -1);

	local node = nil;
	if tonumber(side) == 1 then
		node = self.chrSelPanel:getChildByName("LeftNode");
	else
		node = self.chrSelPanel:getChildByName("RightNode");
	end
	local x, y = node:getPosition();

	dormantSprite:setTag(side + 2);
	dormantSprite:setPosition(x, y);
	self.chrSelPanel:addChild(dormantSprite, 5);

	activeSprite:setTag(side);
	activeSprite:setPosition(x, y);
	activeSprite:setVisible(false);
	self.chrSelPanel:addChild(activeSprite, 5);


	local nameLabel = nil;
	local levelLabel = nil;
	local styleLabel = nil;

	if side == 1 then
		nameLabel = self.chrSelPanel:getChildByName("LeftNameLabel");
		levelLabel = self.chrSelPanel:getChildByName("LeftLevelLabel");
		styleLabel = self.chrSelPanel:getChildByName("LeftStyleLabel");
	else
		nameLabel = self.chrSelPanel:getChildByName("RightNameLabel");
		levelLabel = self.chrSelPanel:getChildByName("RightLevelLabel");
		styleLabel = self.chrSelPanel:getChildByName("RightStyleLabel");
	end

	nameLabel:setString(name);
	levelLabel:setString(level);
	styleLabel:setString(styleGroups[style]);
end

function formatNum(i)
	local title = "";

	if i < 10 then
		title = "00000"..i
	elseif i < 100 then
		title = "0000"..i
	elseif i < 1000 then
		title = "000"..i
	elseif i < 10000 then
		title = "00"..i
	elseif i < 100000 then
		title = "0"..i
	end

	return title;
end

function ChrSelScene:readSpriteWithAni(min, max, callBack, times, delay)
	local sprite = nil;
	if not delay then
		delay = 0.2;
	end

	local animation = cc.Animation:create();
    animation:setLoops(times);
    animation:setDelayPerUnit(delay);
    animation:setRestoreOriginalFrame(true);

	for i=min, max do
		local path = "UIRes/chrSel/"..formatNum(i)..".png";
		local frame = engine.getSpriteFrame(path);

		if frame then
			animation:addSpriteFrame(frame)
		end

		if not sprite then
			sprite = engine.initSprite(path);
		end
	end

	local animate = cc.Animate:create(animation);

	if callBack then
		local sequence = cc.Sequence:create({animate, cc.CallFunc:create(function()
			if sprite:getParent() then
				sprite:getParent():removeChild(sprite);
			end
		end)});

		sprite:runAction(sequence);
	else
		sprite:runAction(animate);
	end

	return sprite;
end

function ChrSelScene:delChr(side)
	self.chrGroups[side] = nil;
	self:delChrAni(side);
end

function ChrSelScene:delChrAni(side)

end

function ChrSelScene:setBtnEnable(enable)
	--[[local chrCreatePanel = self.chrCreatePanel;
	local chrSelPanel = self.chrSelPanel;
	local warriorBtn = chrCreatePanel:getChildByName("warriorBtn");
	local magicBtn = chrCreatePanel:getChildByName("magicBtn");
	local taoistBtn = chrCreatePanel:getChildByName("taoistBtn");
	local womanBtn = chrCreatePanel:getChildByName("womanBtn");
	local manBtn = chrCreatePanel:getChildByName("manBtn");
	local commitBtn = chrCreatePanel:getChildByName("commitBtn");
	local closeBtn = chrCreatePanel:getChildByName("closeBtn");
	local createBtn = chrSelPanel:getChildByName("CreateBtn");
	local leftSelBtn = chrSelPanel:getChildByName("LeftSelBtn");
	local rightSelBtn = chrSelPanel:getChildByName("RightSelBtn");
	local startBtn = chrSelPanel:getChildByName("StartBtn");
	local delBtn = chrSelPanel:getChildByName("DelBtn");


	warriorBtn:setEnable(enable);
	magicBtn:setEnable(enable);
	taoistBtn:setEnable(enable);
	womanBtn:setEnable(enable);
	manBtn:setEnable(enable);
	commitBtn:setEnable(enable);
	closeBtn:setEnable(enable);
	createBtn:setEnable(enable);
	leftSelBtn:setEnable(enable);
	rightSelBtn:setEnable(enable);
	startBtn:setEnable(enable);
	delBtn:setEnable(enable);]]
end

function ChrSelScene:start()
	local aid = Account.data.aid;

	self:setBtnEnable(false);

	local chrSelIdx = self.currChr;
	client:sendMessageWithRecall("ENTER_WORLD", {side=chrSelIdx}, function(msg)
		TraceError("ENTER_WORLD:"..tostringex(msg));
		if msg.ret == 0 then
			self:setBtnEnable(true);
			self:showMessage("进入游戏失败");
			--print("enter world failed");
		else
			--delete old data
			local scene = require("scene.MainScene")
			local mainScene = scene:create();
			cc.Director:getInstance():replaceScene(mainScene);

			local data = Account:getActorsData()[msg.side];
			--TraceError("Account:getActorsData():"..tostringex(Account:getActorsData()));
			--TraceError("data:"..tostringex(data));
			if not data then
				TraceError("no data:"..tostring(msg.side));
				return;
			end

			local actor = Account:addActorFromData(data, msg.side);
			if actor then
				mainScene:enterMap(msg.worldid, msg.worldpos, actor, msg.others, msg.mapItemsData)
				Account:selActor(msg.side)
			else
				TraceError("no find actor:");
			end
		end
	end);
end
