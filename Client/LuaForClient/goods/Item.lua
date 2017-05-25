Item = class("Item")

function Item:create()
    local object = {}
    setmetatable(object,Item)
    object:ctor();
    return object;
end

function Item:ctor()
    self.name = ""
    self.limitLevel = 0
    self.description = ""
    self.type = 0

    --物品功能
    self.func = nil

    --精灵
    self.mapSprite = nil
    self.bagIconSprite = nil
    self.mapIconSprite = nil;
    self.bigIconSprite = nil;

    --label
    self.nameLabel = nil;
end

function Item:initAttribute(parameter)
	self.typeid       = parameter.id;
	self.quality = parameter.quality;
    self.name = parameter.sz_name
    self.limitLevel = parameter.limitLevel
    self.description = parameter.sz_description
    self.type = parameter.type
	self.iconId = parameter.iconId;
	self.needLevel = parameter.need_level;
	self.needSex = parameter.need_sex;
	self:initSprite(parameter);

	if parameter.quality ~= 0 then
		local itemQualityConf = qualityConf[parameter.quality];
		self.nameLabel = engine.initLabel(self.name);
		self.nameLabel:retain();
		self.nameLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);
		self.nameLabel:setTextColor(cc.c4b(itemQualityConf.colorR, itemQualityConf.colorG, itemQualityConf.colorB, 255));
	end
end

function Item:initSprite(parameter)
	local iconId = parameter.iconId;

	if iconId and iconId ~= 0 then
		--local bagIconSpriteName = bagItemIconPath.."/"..engine.formatStr(iconId)..".png";
		--local mapIconSpriteName = mapItemIconPath.."/"..engine.formatStr(iconId)..".png";
		--local bigIconSpriteName = stateItemIconPath.."/"..engine.formatStr(iconId)..".png";

		--iconId = 104;
		self.bagIconSprite = engine.readSingleSpriteFromWzl(iconId, "data/Items.wil", "data/Items.wix", true);--engine.initSprite(bagIconSpriteName);
		self.bagIconSprite:setAnchorPoint(0,0);
        self.bagIconSprite:retain();

		self.mapIconSprite = engine.readSingleSpriteFromWzl(iconId, "data/DnItems.wil", "data/DnItems.wix", true);--engine.initSprite(mapIconSpriteName);
		self.mapIconSprite:setAnchorPoint(0,0);
        self.mapIconSprite:retain();

		if self:getType() <= 10 then
			if self:getType() >= 4 and self:getType() <= 8 then
				self.bigIconSprite = engine.readSingleSpriteFromWzl(iconId, "data/stateitem.wil", "data/stateitem.wix", true);--engine.initSprite(bigIconSpriteName);
				self.bigIconSprite:setAnchorPoint(0.5, 0.5);
			else
				self.bigIconSprite = engine.readSingleSpriteFromWzl(iconId, "data/stateitem.wil", "data/stateitem.wix")--engine.initSpriteWithOffset(stateItemIconPath, engine.formatStr(iconId)..".png");
				self.bigIconSprite:setAnchorPoint(0, 0);
			end

			self.bigIconSprite:retain();
		end
	end
end

function Item:getTypeID()
	return self.typeid;
end

function Item:getType()
    return self.type;
end

function Item:getIconId()
	return self.iconId;
end

function Item:getName()
	return self.name;
end

function Item:getDesc()
	return self.description;
end

function Item:getLimitLevel()
	return self.limitLevel;
end

function Item:getQuality()
	return self.quality;
end

function Item:getAttribute()
	return self.attribute;
end

function Item:setBagSpritePosition(x, y)
    if self.bagIconSprite then
        self.bagIconSprite:setPosition(x, y);
    end
end

function Item:getBagSpriteContentSize()
    if self.bagIconSprite then
        return self.bagIconSprite:getContentSize();
    end
end

function Item:getBagSpritePosition()
    if self.bagIconSprite then
        return self.bagIconSprite:getPosition();
    end
end

function Item:addToBag(parent, zOrder)
    if self.bagIconSprite then
        parent:addChild(self.bagIconSprite, zOrder);
    end
end

function Item:removeFromBag()
    --print("self.bagIconSprite:"..tostringex(self.bagIconSprite).."---parent:"..tostringex(self.bagIconSprite:getParent()));
    if self.bagIconSprite and self.bagIconSprite:getParent() then
        self.bagIconSprite:getParent():removeChild(self.bagIconSprite);
    end
end

function Item:getStateIcon()
    --print("获取精灵:"..tostringex(self.bigIconSprite));
    return self.bigIconSprite;
end

function Item:addToMap(parent, zOrder)
    parent:addChild(self.mapSprite, zOrder);
end

function Item:removeFromMap(parent, zOrder)
    if self.mapSprite then
        self.mapSprite:remove();
    end
end

function Item:addToMapWithIcon(parent, zOrder)
    if self.mapIconSprite then
        parent:addChild(self.mapIconSprite, zOrder);
    end

	if self.nameLabel then
		parent:addChild(self.nameLabel, zOrder);
	end
    --end
end

function Item:removeFromMapWithIcon(parent, zOrder)
    if self.mapIconSprite then
        self.mapIconSprite:getParent():removeChild(self.mapIconSprite);
    end

    if self.nameLabel then
        self.nameLabel:getParent():removeChild(self.nameLabel);
    end
end

function Item:addToStatue(parent, zOrder)
    if self.bigIconSprite then
        parent:addChild(self.bigIconSprite, zOrder);
    end
end

function Item:removeFromStatue(parent, zOrder)
    if self.bigIconSprite then
        self.bigIconSprite:getParent():removeChild(self.bigIconSprite);
    end
end

function Item:setPosition(x, y)
    if self.mapSprite then
        self.mapSprite:setPosition(x, y);
    end
end

function Item:setVisible(visible)
	if self.mapSprite then
        self.mapSprite:setVisible(visible);
    end
end

function Item:setIconPosition(x, y)
	if self.mapIconSprite then
		local size = self.mapIconSprite:getContentSize();

		self.mapIconSprite:setPosition(x + (TILE_WIDTH-size.width)/2, y + (TILE_HEIGHT-size.height)/2);

		if self.nameLabel then
			self.nameLabel:setPosition(x + TILE_WIDTH/2, y - 10 + (TILE_HEIGHT-size.height)/2);
		end
    end
end

function Item:getIconPosition()
    local x,y = self.mapIconSprite:getPosition();

    return {x=x,y=y}
end

function Item:setID(id)
    self.id = id;
end

function Item:getID()
	return self.id;
end

function Item:setBaseData(data)
	self.data = data;
end

function Item:getBaseData()
	return self.data;
end

function Item:retain()
    if self.mapSprite then
        self.mapSprite:retain();
    end

	if self.mapSpriteShadow then
		self.mapSpriteShadow:retain();
	end

	if self.bagIconSprite then
		self.bagIconSprite:retain();
	end

    if self.mapIconSprite then
        self.mapIconSprite:retain();
    end

    if self.bigIconSprite then
        self.bigIconSprite:retain();
    end

	if self.nameLabel then
		self.nameLabel:retain();
	end
end


function Item:release()
	if self.mapSprite then
		--print("name:"..self:getName().."   count:"..self.mapSprite:getReferenceCount());
        self.mapSprite:release();
		--self.mapSprite = nil;
    end

	if self.mapSpriteShadow then
		self.mapSpriteShadow:release();
		--self.mapSpriteShadow = nil;
	end

	if self.bagIconSprite then
		self.bagIconSprite:release();
		--self.bagIconSprite = nil;
	end

    if self.mapIconSprite then
        self.mapIconSprite:release();
		--self.mapIconSprite = nil;
    end

    if self.bigIconSprite then
        self.bigIconSprite:release();
		--self.bigIconSprite = nil;
    end

	if self.nameLabel then
		self.nameLabel:release();
		--self.nameLabel = nil;
	end
end
