Equipment = class("Equipment", function()
    return Item:new();
end)

local stateItemIconPath = "stateItemIcon";
local bagItemIconPath = "bagItemIcon";
local mapItemIconPath = "mapIcon";


function Equipment:ctor()
    --Attribute
    self.attribute = Attribute:create();

    --需要的条件
    self.needLevel = 0;
    self.needStrength = 0;
    self.needMagic = 0;
	self.isShowShadow = true;
end

function Equipment:setShaderEnable(enable)
	if self.mapSprite then
		self.mapSprite:setShaderEnable(enable);
	end
end

--是否满足穿戴条件
function Equipment:justice(actor_attribute)
    if actor_attribute.level < self.needLevel then
        return false;
    end

    if actor_attribute.needStrength < self.needStrength then
        return false;
    end

    if actor_attribute.magic < self.needMagic then
        return false;
    end

    return true;
end

function Equipment:initSprite(parameter)
	self.attribute:init(parameter);

    --初始化精灵
    local offset     = parameter.mapSpriteOffset;
    local spritePath = parameter.sz_mapSpritePath;
    local spriteid   = parameter.spriteid;
	local iconId     = parameter.iconId;

	if spriteid and spriteid ~= 0 then
		self.mapSprite = engine.readASprite(spriteid);
		self.mapSprite.sprite:setBlendFunc({src=gl.SRC_ALPHA, dst=gl.ONE_MINUS_SRC_ALPHA})

		if self.isShowShadow then
			self.mapSpriteShadow = engine.readASprite(spriteid);
			self.mapSpriteShadow.sprite:setBlendFunc({src=gl.SRC_ALPHA, dst=gl.ONE_MINUS_SRC_ALPHA})
			self.mapSpriteShadow.sprite:setOpacity(180);
		end
	end

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

function Equipment:getLeftBottomPosition()
	if self.mapSprite then
		self.mapSprite:getLeftBottomPosition();
	end
end

function Equipment:runAction(aniName, actionArray)
	if self.isShowShadow and self.mapSpriteShadow then
		self:runActionForSprite(self.mapSpriteShadow, aniName);
	else
		--TraceError("Equipment:runAction error:"..self.itemId.."--"..tostringex(self.isShowShadow).."--"..tostringex(self.mapSpriteShadow).." :"..debug.traceback());
	end

	if self.mapSprite then
		return self:runActionForSprite(self.mapSprite, aniName, actionArray);
	end
end

function Equipment:runActions(actionArray)
	if self.mapSprite then
		self.mapSprite:runActions(actionArray);
	else
		TraceError("can not find equipment:"..tostringex(self.name).."------"..tostringex(self.type));
	end
end

function Equipment:stopAllActions()
	if self.mapSprite then
		self.mapSprite:stopAllActions();
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:stopAllActions();
	end
end

function Equipment:isClick(point)
	if self.mapSprite then
		self.mapSprite:isClick(point);
	end
end

function Equipment:setCurrFrameIndex(index)
	if self.mapSprite then
		self.mapSprite:setCurrFrameIndex(index);
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setCurrFrameIndex(index);
	end
end

function Equipment:setLastCurrFrameIndex(aniName)
	if self.mapSprite then
		self.mapSprite:setLastCurrFrameIndex(aniName);
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setLastCurrFrameIndex(aniName);
	end
end

function Equipment:runActionForSprite(sprite, aniName, actionArray)
	if not self.mapSprite then
		return true;
	end

	if sprite:runSameAction(aniName) and sprite:isRunning() then
		--TraceError("aniName:"..aniName.." still playing");
        return false;--self:unLockActorBehavior();--sprite:isRunning()
    else
        sprite:stopAllActions();
        return sprite:runAction(aniName, actionArray);
    end
end

function Equipment:getParent()
	if self.mapSprite then
		return self.mapSprite:getParent();
	end
end

function Equipment:addToMap(parent, zOrder)
	if self.mapSprite then
		self.mapSprite:addTo(parent, zOrder);
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:addTo(parent, zOrder+LayerzOrder.SHADOW);
	end
end

function Equipment:removeFromMap(parent, zOrder)
    if self.mapSprite then
        self.mapSprite:remove();
    end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:remove();
	end
end

function Equipment:setEdging(outlineSize, color)
	if self.mapSprite then
		self.mapSprite:setEdging(outlineSize, color)
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setEdging(outlineSize, color)
	end
end

function Equipment:setActionsSpeed(aniNames, duration)
	if self.mapSprite then
		self.mapSprite:setActionsSpeed(aniNames, duration)
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setActionsSpeed(aniNames, duration)
	end
end

function Equipment:setEffect(effectid)
	if self.mapSprite then
		self.mapSprite:setEffect(effectid)
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setEffect(effectid)
	end
end

function Equipment:getContentSize()
	if self.mapSprite then
		return self.mapSprite.sprite:getContentSize();
	end
end

function Equipment:levelUp()

end

function Equipment:setLocalZOrder(order)
    if self.mapSprite then
        self.mapSprite:setLocalZOrder(order);
    end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setLocalZOrder(order+LayerzOrder.SHADOW);
	end
end

function Equipment:setGlobalZOrder(order)
    if self.mapSprite then
        self.mapSprite:setGlobalZOrder(order);
    end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setGlobalZOrder(order+LayerzOrder.SHADOW);
	end
end

function Equipment:setVisible(visible)
	if self.mapSprite then
        self.mapSprite:setVisible(visible);
    end

	if self.mapSprite then
        self.mapSpriteShadow:setVisible(visible);
    end
end

function Equipment:getPosition()
    if self.mapSprite then
        return self.mapSprite:getPosition();
    end
end

function Equipment:setPosition(x, y)
    if self.mapSprite then
        self.mapSprite:setPosition(x, y);
    end

	if self.mapSpriteShadow then
		self.mapSpriteShadow:setPosition(x, y);
	end
end
