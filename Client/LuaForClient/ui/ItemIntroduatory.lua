ItemIntroduatory = class("ItemIntroduatory", function()
    return cc.LayerColor:create(cc.c4b(0,0,0, 180), 180, 200);
end)

local startx = 10;

function ItemIntroduatory:ctor()
	self.icon = nil;

	self.nameLabel = engine.initLabel("name", 15);
	self:addChild(self.nameLabel);

	self.descLabel = engine.initLabel("desc", 12);
	self:addChild(self.descLabel);

	self.descTitleLabel = engine.initLabel("[物品介绍]", 15)
	self:addChild(self.descTitleLabel);

	self.levelLabel = engine.initLabel("level");
	self:addChild(self.levelLabel);

	self.attriTitleLabel = engine.initLabel("[基础属性]", 15);
	self:addChild(self.attriTitleLabel);

	self.attributeLabel = engine.initLabel("", 12);
	self:addChild(self.attributeLabel);

	self.nameLabel:setAnchorPoint(0, 0);
	self.descLabel:setAnchorPoint(0, 0);
	self.levelLabel:setAnchorPoint(0, 0);
	self.attributeLabel:setAnchorPoint(0, 0);
	self.descLabel:setMaxLineWidth(self:getContentSize().width-startx*2);
	self.descLabel:setWidth(self:getContentSize().width-startx*2);

	--title label
	self.attriTitleLabel:setAnchorPoint(0, 0);
	self.descTitleLabel:setAnchorPoint(0, 0);
	self.descTitleLabel:setTextColor(cc.c4b(36, 179, 238, 255));
	self.attriTitleLabel:setTextColor(cc.c4b(36, 179, 238, 255));
	--self.attributeLabel:setAnchorPoint(0, 0);
end


function ItemIntroduatory:setItem(item)
	local iconId = item:getIconId();
	local name = item:getName()
	local desc = item:getDesc();
	local level = item:getLimitLevel()
	local quality = item:getQuality();
	local itemQualityConf = qualityConf[quality];

	local height = 10;
	self.descLabel:setString(desc);
	self.descLabel:setPosition(startx, height);
	height = height + self.descLabel:getContentSize().height + 10;

	if desc == "" or not desc then
		self.descTitleLabel:setVisible(false);
	else
		self.descTitleLabel:setVisible(true);
		self.descTitleLabel:setPosition(startx, height);
		height = height + self.descTitleLabel:getContentSize().height + 10;
	end

	local attribute = item:getAttribute();
	if attribute then
		local attributeText = attribute:toString();--self:getAttributeText(attribute);

		if item.needLevel and item.needLevel > 0 then
			attributeText = attributeText.."\n需要等级        "..(item.needLevel).."\n";
		end

		self.attributeLabel:setString(attributeText);
		self.attributeLabel:setPosition(startx, height);
		height = height + self.attributeLabel:getContentSize().height + 10;

		self.attriTitleLabel:setVisible(true);
		self.attriTitleLabel:setPosition(startx, height);
		height = height + self.attriTitleLabel:getContentSize().height + 10;
	else
		self.attriTitleLabel:setVisible(false);
		self.attributeLabel:setString("");
	end

	if level then
		self.levelLabel:setString(level);
		self.levelLabel:setPosition(startx, height);
		height = height + self.levelLabel:getContentSize().height + 10;
		self.levelLabel:setVisible(true);
	else
		self.levelLabel:setVisible(false);
	end

	self.nameLabel:setString(name);
	self.nameLabel:setPosition(startx, height);
	self.nameLabel:setTextColor(cc.c4b(itemQualityConf.colorR, itemQualityConf.colorG, itemQualityConf.colorB, 255));

	height = height + self.nameLabel:getContentSize().height + 10;

	--icon
	if self.icon then
		self:removeChild(self.icon);
	end

	self.icon = engine.readSingleSpriteFromWzl(iconId, "data/Items.wil", "data/Items.wix", true);--engine.initSprite("bagItemIcon/"..engine.formatStr(iconId)..".png");
	self.icon:setAnchorPoint(0, 0);
	self.icon:setPosition(self:getContentSize().width - 10 - self.icon:getContentSize().width, height - 10 - self.icon:getContentSize().height);
	self:addChild(self.icon);

	self:setContentSize(self:getContentSize().width, height);
end

function ItemIntroduatory:getAttributeText(attribute)
	local text = "";

	if attribute.atk[1] and attribute.atk[1][1] ~= 0 or attribute.atk[1][2] ~= 0 then
		text = text.."物理攻击         "..attribute.atk[1][1].."-"..attribute.atk[1][2].."\n";
	end
	if attribute.atk[2] and attribute.atk[2][1] ~= 0 or attribute.atk[2][2] ~= 0 then
		text = text.."魔法攻击         "..attribute.atk[2][1].."-"..attribute.atk[2][2].."\n";
	end
	if attribute.atk[3] and attribute.atk[3][1] ~= 0 or attribute.atk[3][2] ~= 0 then
		text = text.."道术攻击         "..attribute.atk[3][1].."-"..attribute.atk[3][2].."\n";
	end

	if attribute.dfs[1] and attribute.dfs[1] ~= 0 then
		text = text.."物理防御         "..attribute.dfs[1].."\n";
	end
	if attribute.dfs[2] and attribute.dfs[2] ~= 0 then
		text = text.."魔法防御         "..attribute.dfs[2].."\n";
	end
	if attribute.dfs[3] and attribute.dfs[3] ~= 0 then
		text = text.."道术防御         "..attribute.dfs[3].."\n";
	end

	if attribute.maxHp ~= 0 then
		text = text.."生命值             "..attribute.maxHp.."\n";
	end

	if attribute.maxMp ~= 0 then
		text = text.."魔法值             "..attribute.maxMp.."\n";
	end

	text = string.sub(text, 1, string.len(text)-1);

	return text;
end
