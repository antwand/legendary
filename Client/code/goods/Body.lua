Body = class("Body")

function Body:ctor()
	self.isShowShadow = true;
	self.logSwitch = false;
end

function Body:getType()
    return self.type;
end

function Body:setType(_type)
	self.type = _type;
end


function Body:setID(_id)
	self.id = _id;
end

function Body:getID()
	return self.id;
end

function Body:initSprite(spriteid)
	if spriteid and spriteid ~= 0 then
		self.mapSprite = engine.readASprite(spriteid);

		self.mapSprite.sprite:setBlendFunc({src=gl.SRC_ALPHA, dst=gl.ONE_MINUS_SRC_ALPHA})

		if self.isShowShadow then
			self.mapSpriteShadow = engine.readASprite(spriteid);
			self.mapSpriteShadow.sprite:setBlendFunc({src=gl.SRC_ALPHA, dst=gl.ONE_MINUS_SRC_ALPHA})
			self.mapSpriteShadow.sprite:setOpacity(180);
		end
	end
end

function Body:setShaderEnable(enable)
	if self.mapSprite then
		self.mapSprite:setShaderEnable(enable);
	end
end

function Body:isClick(point)
	if self.mapSprite then
		self.mapSprite:isClick(point);
	end
end

function Body:runAction(aniName, actionArray)
	if self.isShowShadow and self.mapSpriteShadow then
		self:runActionForSprite(self.mapSpriteShadow, aniName);
	else
		--TraceError("Body:runAction error:"..self.itemId.."--"..tostringex(self.isShowShadow).."--"..tostringex(self.mapSpriteShadow).." :"..debug.traceback());
	end

	if self.mapSprite then
		return self:runActionForSprite(self.mapSprite, aniName, actionArray);
	end
end

function Body:runActions(actionArray)
	if self.mapSprite then
		self.mapSprite:runActions(actionArray);
	else
		TraceError("can not find Body:"..tostringex(self.name).."------"..tostringex(self.type));
	end
end

function Body:stopAllActions()
	if self.mapSprite then
		self.mapSprite:stopAllActions();
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:stopAllActions();
	end
end

function Body:setCurrFrameIndex(index)
	if self.mapSprite then
		self.mapSprite:setCurrFrameIndex(index);
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setCurrFrameIndex(index);
	end
end

function Body:setLastCurrFrameIndex(aniName)
	if self.mapSprite then
		self.mapSprite:setLastCurrFrameIndex(aniName);
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setLastCurrFrameIndex(aniName);
	end
end

function Body:runActionForSprite(sprite, aniName, actionArray)
	if not sprite then
		return true;
	end

	if sprite:runSameAction(aniName) and sprite:isRunning() then
        return false;--self:unLockActorBehavior();--sprite:isRunning()
    else
        sprite:stopAllActions();

        local ret,success = sprite:runAction(aniName, actionArray);

		return ret, success;
    end
end

function Body:getParent()
	if self.mapSprite then
		return self.mapSprite:getParent();
	end
end

function Body:getLeftBottomPosition()
	if self.mapSprite then
		return self.mapSprite:getLeftBottomPosition();
	end
end

function Body:addToMap(parent, zOrder)
	if self.mapSprite then
		self.mapSprite:addTo(parent, zOrder);
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:addTo(parent, zOrder+LayerzOrder.SHADOW);
	end
end

function Body:removeFromMap(parent, zOrder)
    if self.mapSprite then
        self.mapSprite:remove();
    end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:remove();
	end
end

function Body:setEdging(outlineSize, color)
	if self.mapSprite then
		self.mapSprite:setEdging(outlineSize, color)
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setEdging(outlineSize, color)
	end
end

function Body:setActionsSpeed(aniNames, duration)
	if self.mapSprite then
		self.mapSprite:setActionsSpeed(aniNames, duration)
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setActionsSpeed(aniNames, duration)
	end
end

function Body:setEffect(effectid)
	if self.mapSprite then
		self.mapSprite:setEffect(effectid)
	end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setEffect(effectid)
	end
end

function Body:getContentSize()
	if self.mapSprite then
		return self.mapSprite.sprite:getContentSize();
	end
end

function Body:levelUp()

end

function Body:setLocalZOrder(order)
    if self.mapSprite then
        self.mapSprite:setLocalZOrder(order);
    end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setLocalZOrder(order+LayerzOrder.SHADOW);
	end
end

function Body:setGlobalZOrder(order)
    if self.mapSprite then
        self.mapSprite:setGlobalZOrder(order);
    end

	if self.isShowShadow and self.mapSpriteShadow then
		self.mapSpriteShadow:setGlobalZOrder(order+LayerzOrder.SHADOW);
	end
end

function Body:setVisible(visible)
	if self.mapSprite then
        self.mapSprite:setVisible(visible);
    end

	if self.mapSpriteShadow then
        self.mapSpriteShadow:setVisible(visible);
    end
end

function Body:getPosition()
    if self.mapSprite then
        return self.mapSprite:getPosition();
    end
end

function Body:setPosition(x, y)
    if self.mapSprite then
        self.mapSprite:setPosition(x, y);
    end

	if self.mapSpriteShadow then
		self.mapSpriteShadow:setPosition(x, y);
	end
end

function Body:retain()
    if self.mapSprite then
        self.mapSprite:retain();
    end

	if self.mapSpriteShadow then
		self.mapSpriteShadow:retain();
	end
end


function Body:release()
    if self.mapSprite then
        self.mapSprite:release();
		--self.mapSprite = nil;
    end

	if self.mapSpriteShadow then
		self.mapSpriteShadow:release();
		--self.mapSpriteShadow = nil;
	end
end
