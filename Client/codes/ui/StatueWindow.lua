--region NewFile_1.lua
--Author : legend
--Date   : 2015/4/22
--此文件由[BabeLua]插件自动生成



--endregion
StatueWindow = class("StatueWindow", function()
    return cc.Layer:create();
end)

function StatueWindow:init()
	self.itemIntro = ItemIntroduatory:new();
	self.itemIntro:setVisible(false);
	self:addChild(self.itemIntro);

	self.equipBackClick = {};
end


function StatueWindow:clear()
	for k,v in pairs(self.equipGroup) do
		StatueWindow:removeEquip(k);
	end
end

function StatueWindow:setNewEquips(equips)
	StatueWindow:clear();

	for k,v in pairs(equips) do
		StatueWindow:addEquip(v);
	end
end

function StatueWindow:showPanel(index)
    local panel1 = self.back:getChildByName("AttributePanel")
    local panel2 = self.back:getChildByName("Panel2")
    local panel3 = self.back:getChildByName("Panel3")

    if index == 1 then
        panel1:setVisible(true);
        panel2:setVisible(false);
        panel3:setVisible(false);
    elseif index == 2 then
        panel1:setVisible(false);
        panel2:setVisible(true);
        panel3:setVisible(false);
    elseif index == 3 then
        panel1:setVisible(false);
        panel2:setVisible(false);
        panel3:setVisible(true);
    end
end

function StatueWindow:showAttributePanel(index)
    local panel1 = self.back:getChildByName("AttributePanel")
    local equip = panel1:getChildByName("equip");
    local attri = panel1:getChildByName("attribute");
    local skill = panel1:getChildByName("skill");
    local unknown = panel1:getChildByName("unknown");

    if index == 1 then
        equip:setVisible(true);
        attri:setVisible(false);
        skill:setVisible(false);
        unknown:setVisible(false);
    elseif index == 2 then
        equip:setVisible(false);
        attri:setVisible(true);
        skill:setVisible(false);
        unknown:setVisible(false);
    elseif index == 3 then
        equip:setVisible(false);
        attri:setVisible(false);
        skill:setVisible(true);
        unknown:setVisible(false);
    elseif index == 4 then
        equip:setVisible(false);
        attri:setVisible(false);
        skill:setVisible(false);
        unknown:setVisible(true);
    end
end

function StatueWindow:ctor()
	local result = require("ui/StatusUI.lua").create();
    local rootNode = result['root'];
	--local rootNode = cc.CSLoader:createNode("StateUI.csb");
    local back = rootNode:getChildByName("back");
    back:getParent():removeChild(back);
	self.back = back;
    self:addChild(back);
	--[[
	local rootNode = require("ui/StateUI.lua").create();
	local back = rootNode.root:getChildByName("back");
	self:addChild(rootNode.root);]]
	self.shortcutList = {};

    local Panel1Label = back:getChildByName("Panel1Label")
    local Panel2Label = back:getChildByName("Panel2Label")
    local Panel3Label = back:getChildByName("Panel3Label")

    local panel1 = back:getChildByName("AttributePanel")
    local panel2 = back:getChildByName("Panel2")
    local panel3 = back:getChildByName("Panel3")

    Panel1Label:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            panel1:setVisible(true);
            panel2:setVisible(false);
            panel3:setVisible(false);
        end
    end);

    Panel2Label:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            panel1:setVisible(false);
            panel2:setVisible(true);
            panel3:setVisible(false);
        end
    end);

    Panel3Label:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            panel1:setVisible(false);
            panel2:setVisible(false);
            panel3:setVisible(true);
        end
    end);

    local equipLabel = panel1:getChildByName("equipLabel");
    local attriLabel = panel1:getChildByName("attributeLabel");
    local skillLabel = panel1:getChildByName("skillLabel");
    local unknownLabel = panel1:getChildByName("unknownLabel");

    local equip = panel1:getChildByName("equip");
    local attri = panel1:getChildByName("attribute");
    local skill = panel1:getChildByName("skill");
    local unknown = panel1:getChildByName("unknown");

	local leftBtn = skill:getChildByName("leftBtn");
	local rightBtn = skill:getChildByName("rightBtn");

	leftBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			local page = self.skillPage;
			if page > 1 then
				self:updateSkill(page - 1);
			end
		end
	end);

	rightBtn:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
			local page = self.skillPage;
			if #self.skills/6 > page then
				self:updateSkill(page + 1);
			end
		end
	end);

    equipLabel:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            equip:setVisible(true);
            attri:setVisible(false);
            skill:setVisible(false);
            unknown:setVisible(false);
        end
    end);

    attriLabel:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            equip:setVisible(false);
            attri:setVisible(true);
            skill:setVisible(false);
            unknown:setVisible(false);
        end
    end);

    skillLabel:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            equip:setVisible(false);
            attri:setVisible(false);
            skill:setVisible(true);
            unknown:setVisible(false);
        end
    end);

    unknownLabel:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            equip:setVisible(false);
            attri:setVisible(false);
            skill:setVisible(false);
            unknown:setVisible(true);
        end
    end);


    local nameLabel = back:getChildByName("nameLabel")
    nameLabel:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.began then
            self.beganPoint = nameLabel:getTouchBeganPosition();
            local x, y = self:getPosition();
            self.lastWindowPoint = {x=x, y=y};
        elseif eventTouchType == ccui.TouchEventType.moved then
            if self.beganPoint then
                local mousePoint = nameLabel:getTouchMovePosition();
                local movePoint = {x=mousePoint.x-self.beganPoint.x,
                    y=mousePoint.y-self.beganPoint.y};
                self:setPosition({x=self.lastWindowPoint.x+movePoint.x,
                    y=self.lastWindowPoint.y+movePoint.y});
            end
        elseif eventTouchType == ccui.TouchEventType.ended then
            self.beganPoint = nil;
        end
    end);

    local closeButton = back:getChildByName("closeButton")
    closeButton:addTouchEventListener(function(event, eventTouchType)
        if eventTouchType == ccui.TouchEventType.ended then
            self:setVisible(false);
        end
    end);

	--equipBack
	local equipBack = equip:getChildByName("equipBack");
	local clothesBack = equipBack:getChildByName("clothesBack");
	local weaponBack = equipBack:getChildByName("weaponBack");
	local helmetBack = equipBack:getChildByName("helmetBack");
	local necklaceBack = equipBack:getChildByName("necklaceBack");
	local ring1Back = equipBack:getChildByName("ring1Back");
	local ring2Back = equipBack:getChildByName("ring2Back");
	local bangle1Back = equipBack:getChildByName("bangle1Back");
	local bangle2Back = equipBack:getChildByName("bangle2Back");
	--local helpBack = equipBack:getChildByName("helpBack");

	--ADDJUST label nameLabel
    local attributePanel = panel1:getChildByName("attribute");
	local PhyATKLabel = attributePanel:getChildByName("PhyATKLabel");
	local TaoATKLabel = attributePanel:getChildByName("TaoATKLabel");

	self:registBackButtonListener(clothesBack, 1);
	self:registBackButtonListener(weaponBack, 2);
	self:registBackButtonListener(helmetBack, 3);
	self:registBackButtonListener(necklaceBack, 4);
	self:registBackButtonListener(ring1Back, 7);
	self:registBackButtonListener(ring2Back, 8);
	self:registBackButtonListener(bangle1Back, 5);
	self:registBackButtonListener(bangle2Back, 6);
	--self:registBackButtonListener(helpBack, 9);

	self:initSkill()

    self.equipPanel = equip;
	self.equipBack = equipBack;
    self.equipGroup = {};
	self.skillPage = 1;
end

local skillPicPos = {}
function StatueWindow:initSkill()
	self:setSkill(1, 0);
	self:setSkill(2, 0);
	self:setSkill(3, 0);
	self:setSkill(4, 0);
	self:setSkill(5, 0);
	self:setSkill(6, 0);

	local panel1 = self.back:getChildByName("AttributePanel")
	local skill = panel1:getChildByName("skill");
	for index=1, 6 do
		local skillPic = skill:getChildByName("skillPic"..index);

		skillPic:addTouchEventListener(function(event, eventTouchType)
			if opaque== 0 then
				return;
			end

			if eventTouchType == ccui.TouchEventType.ended then
				local pos = skillPicPos[index];
				skillPic:setPosition(pos.x, pos.y);

				local skill = self.skills[(self.skillPage-1)*6 + index];
				self:showSkillShortcutSetting(skill);
			elseif eventTouchType == ccui.TouchEventType.began then
				local pos = skillPicPos[index];
				skillPic:setPosition(pos.x + 1, pos.y - 1);
			end
		end);
	end
end

function StatueWindow:setSkillShortcut(shortcutList)
	self.shortcutList = shortcutList;
end

function StatueWindow:showSkillShortcutSetting(skill)
	engine.dispachEvent("OPEN_SHORTCUT", skill);
end

function StatueWindow:setSkill(index, skillid, level, exp)
	local panel1 = self.back:getChildByName("AttributePanel")
	local skill = panel1:getChildByName("skill");
	local skillPic = skill:getChildByName("skillPic"..index);
	local levelText = skillPic:getChildByName("levelText");
	local Text_1 = skillPic:getChildByName("Text_1");
	local Text_1_0 = skillPic:getChildByName("Text_1_0");
	local levelText_0 = skillPic:getChildByName("levelText_0");
	local nameText = skillPic:getChildByName("nameText");
	local shorcutText = skillPic:getChildByName("shorcutText");
	local shortcut = self.shortcutList[skillid] or "";

	if not skillid or skillid <= 0 then
		--skillPic:loadTexture("temporary/blank.png");
		skillPic:setOpacity(0);
		levelText:setString("");
		Text_1:setString("");
		Text_1_0:setString("");
		levelText_0:setString("");
		nameText:setString("");
	else
		local filename = skillConf[skillid].sz_icon;
		skillPic:loadTexture(filename);
		skillPic:setOpacity(255);
		levelText:setString(level);
		Text_1:setString("Level:");
		Text_1_0:setString("Exp:");
		levelText_0:setString(exp);
		nameText:setString(skillConf[skillid].sz_cn_name);
	end

	shorcutText:setString(shortcut);
	if not skillPicPos[index] then
		local x,y = skillPic:getPosition();
		skillPicPos[index] = {x=x,y=y}
	end
end

function StatueWindow:setSkills(skills)
	self.skills = skills;
	self.skillPage = 1;

	--print("self.skills:"..tostringex(self.skills));
end

function StatueWindow:updateSkill(page)
	local startIndex = (page-1)*6 + 1;
	for i=1,6 do
		local v = self.skills[startIndex];
		if v then
			self:setSkill(i, v.skillid, v.level, v.exp);
		else
			self:setSkill(i, nil);
		end

		startIndex = startIndex + 1;
	end

	self.skillPage = page;
end

function StatueWindow:registBackButtonListener(backButton, btype)
	backButton:setVisible(true);
	backButton:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.began then
			if not self.equipBackClick[btype] then
				self.equipBackClick[btype] = FuncPack:gettime()-5;
			end

			local equip = self.equipGroup[btype]
			if FuncPack:gettime() - self.equipBackClick[btype] < 0.5 then
				if equip == nil then
					return;
				end

				self.itemIntro:setVisible(false);
				engine.dispachEvent("PLAYER_REMOVE_EQUIP", btype);
			else
				local x = event.x;
				local y = event.y;

				if not self.itemIntro:isVisible() and equip then
					self.itemIntro:setItem(equip);
					self.itemIntro:setVisible(true);
					--self.itemIntro:setPosition(x, y);
				elseif self.itemIntro:isVisible() then
					self.itemIntro:setVisible(false);
				end
			end
			--engine.dispachEvent("PLAYER_ADD_ITEM", equip);

			self.equipBackClick[btype] = FuncPack:gettime();
		end
    end);
end

function StatueWindow:setName(name)
    local nameLabel = self.back:getChildByName("nameLabel")
    nameLabel:setString(name);
end

function StatueWindow:updateAttribute(attribute)
    local panel1 = self.back:getChildByName("AttributePanel")
    local attributePanel = panel1:getChildByName("attribute");
    local physicalAtkLabel = attributePanel:getChildByName("physicalAtk");
    local physicalDfsLabel = attributePanel:getChildByName("physicalDef");
    local magicAtkLabel = attributePanel:getChildByName("magicAtk");
    local magicDfsLabel = attributePanel:getChildByName("magicDef");
	local taogistAtkLabel = attributePanel:getChildByName("taoistAtk");

    physicalAtkLabel:setString(attribute.atk[1][1].."-"..attribute.atk[1][2]);
    physicalDfsLabel:setString(attribute.dfs[1]);

    magicAtkLabel:setString(attribute.atk[2][1].."-"..attribute.atk[2][2]);
    magicDfsLabel:setString(attribute.dfs[2]);

	taogistAtkLabel:setString(attribute.atk[3][1].."-"..attribute.atk[3][2]);
end

function StatueWindow:setSex(sex)
    local man_back = self.equipPanel:getChildByName("man_back")
    local woman_back = self.equipPanel:getChildByName("woman_back")

    if sex == 1 then
        man_back:setVisible(true);
        woman_back:setVisible(false);
    elseif sex == 2 then
        man_back:setVisible(false);
        woman_back:setVisible(true);
    end
end

function StatueWindow:removeEquip(etype)
    local equip = self.equipGroup[etype];

    if equip then
        local equipIcon = equip:getStateIcon();
        self.equipPanel:removeChild(equipIcon);
        self.equipGroup[etype] = nil
    else
        --print("equip type:"..etype);
        --print("equip:"..tostringex(self.equipGroup));
    end

    return equip;
end

function StatueWindow:addEquip(equip, etype)
    if etype > 10 then
        return;
    end

	if etype > 0 and etype <= 10 then
		local equipIcon = equip:getStateIcon();
		local node = nil;
		local xoffset = 0;
		local yoffset = 0;

		if etype == 1 then
			node = self.equipPanel:getChildByName("clothes")
			xoffset = -41;
			yoffset = 24;
		elseif etype == 2 then
			node = self.equipPanel:getChildByName("weapon")
		elseif etype == 3 then
			node = self.equipPanel:getChildByName("helmet")
			xoffset = 1;
			yoffset = -6;
		elseif etype == 4 then
			node = self.equipPanel:getChildByName("necklace")
		elseif etype == 5 then
			node = self.equipPanel:getChildByName("bangle1")
		elseif etype == 6 then
			node = self.equipPanel:getChildByName("bangle2")
		elseif etype == 7 then
			node = self.equipPanel:getChildByName("ring1")
		elseif etype == 8 then
			node = self.equipPanel:getChildByName("ring2")
		elseif etype == 9 then
		elseif etype == 10 then
		end

		local x,y = node:getPosition();
		equipIcon:setPosition(x+xoffset, y+yoffset);
		self.equipPanel:addChild(equipIcon);
		self.equipGroup[etype] = equip;
	end
    --[[
    self.parts =
    {
        [1] = nil,   --衣服
        [2] = nil,   --武器
        [3] = nil,   --头盔
        [4] = nil,   --项链
        [5] = nil,   --手镯
        [6] = nil,   --手镯
        [7] = nil,   --戒指
        [8] = nil,   --戒指
        [9] = nil,   --头发
        [10] = nil,  --待定
    }]]
end
