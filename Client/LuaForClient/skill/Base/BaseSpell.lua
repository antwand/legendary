BaseSpell = class("BaseSpell")

function BaseSpell:ctor()
    self.attack = 0;
    self.level = 1
    self.attackType = 1;  --1.鐗╃悊;2.榄旀硶;3.閬撴湳
    self.name = "slash"
    self.power = 1  --濞佸姏澶у埌涓€瀹氱▼搴︿細浣跨洰鏍囧悗锟?
    self.action = 1;      --瀵瑰簲鍔ㄤ綔id
    self.castClock = Clock:new();
    self.auto = true;   --鏄惁鍦ㄦ墽锟?
    self.priority = 1;
    self.flyEffectSpeedPerPixel = 0.0008;
	self.type = 2;

    --棰勭暀缁欏瓙绫荤殑鐗规晥
    self.effect = nil
end

function BaseSpell:setBaseData(data)
	self.baseData = data;
end

function BaseSpell:getBaseData()
	self.baseData.level = self.level;
	self.baseData.exc = self.exc;

	return self.baseData;
end

--鎶€鑳藉熀鏈睘锟?
function BaseSpell:initAttribute(param)
	self.baseDamage  = param.baseDamage
    self.growDamage  = param.growDamage
    self.attackType  = param.attackType
    self.name        = param.sz_name
	self.type        = param.type
    self.event       = param.sz_event
    self.action      = param.action
    self.castRange   = param.castRange;
    self.specialFunc = param.sepcialFunc;
    self.triggerRate = param.triggerRate;
    self.priority    = param.priority;
    self.class       = param.sz_class;
	self.effectid    = param.effectid;
	self.needMagic   = param.needMagic;
	self.cn_name     = param.sz_cn_name;
    self.castClock:setRingTimeDelta(param.coolDown);

    self.effect      = EffectManager:getEffect(param.effectid);
    self.flyEffect   = EffectManager:getEffect(param.flyeffectid);
    self.boomEffect  = EffectManager:getEffect(param.boomeffectid);
end

function BaseSpell:getName()
	return self.name;
end

function BaseSpell:getType()
	return self.type;
end

function BaseSpell:run(object, value, callFunc)

end

function BaseSpell:calcMagic(object)
	object:setMp(object:getMp() - self.needMagic);
end

function BaseSpell:update(object)
end

function BaseSpell:isCoolDown()
    if self.castClock:ring() then
        return nil;
    end

    return 1;
end

--璋冩暣ui浣嶇疆,鐖剁被涓嶉渶锟?
function BaseSpell:adjustEffectPos(object)
    local pos = object:getPosition();
    self.effect:setPosition(pos.x, pos.y);
end

--缁撴潫鍔ㄧ敾杩涜缁撶畻
function BaseSpell:over(object, values)
    object:unLockActorStatus();--.lockStatus = false;
    object:idle();

    self:closeEffect();

	if self.callFunc then
		self.callFunc();
	end
end

function BaseSpell:getCastRange()
    return self.castRange or 0;
end

function BaseSpell:active()
	if self.auto then
		self.auto = nil;
	else
		self.auto = true;
	end

	TraceError(self.name..":"..tostringex(self.auto));

	return self.auto;
end

--鏄惁绗﹀悎鏉′欢
function BaseSpell:satifyCastPremise(object, values)
    if self.castClock:ring() == false then
        return false, "cooling down";
    end

    if self.triggerRate then
        local rate = FuncPack:getRandomNumber(1, 100)

        if rate > self.triggerRate * 100 then
            return false, "no trigger";
        end
    end

    if not self.auto then
		return nil, "no auto";
	end

	if object:getMp() < self.needMagic then
		return false, "no enought magic";
	end

    return true;
end

function BaseSpell:closeEffect()
    if self.effect then
        self.effect:setVisible(false);
    end

    if self.flyEffect then
        self.flyEffect:setVisible(false);
    end

    if self.boomEffect then
        self.boomEffect:setVisible(false);
    end
end

function BaseSpell:remove()
    if self.effect then
        self.effect:remove();
    end

    if self.flyEffect then
        self.flyEffect:remove();
    end

    if self.boomEffect then
        self.boomEffect:remove();
    end
end

function BaseSpell:retain()
    if self.effect then
        self.effect:retain();
    end

	if self.flyEffect then
		self.flyEffect:retain();
	end

	if self.boomEffect then
		self.boomEffect:retain();
	end
end


function BaseSpell:release()
    if self.effect then
        self.effect:release();
    end

	if self.flyEffect then
		self.flyEffect:release();
	end

	if self.boomEffect then
		self.boomEffect:release();
	end
end
