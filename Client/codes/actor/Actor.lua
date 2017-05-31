Actor = class("Actor")

--[[
ActorDir =
{
    "up",
    "upright",
    "right",
    "rightdown",
    "down",
    "downleft",
    "left",
    "leftup",
}]]

--鏂瑰悜 1...8 琛ㄧず姝ｅ悜涓婇『鏃堕拡鏃嬭浆
--鐘舵€?.銆? 琛ㄧず绔欑珛,璧拌矾,璺戞,鎸ョ爫,鏂芥硶
local statusAniStep = 8 --姣忎釜鐘舵€佸悓鏂瑰悜鐨勫姩鐢讳箣闂撮棿闅?

function Actor:ctor()
    --鍩烘湰灞炴€?
    self.attribute   = Attribute:create();

    --鍒濆鍖栧氨涓嶅彲浠ユ敼浜嗙殑
	self.style        = 1;
	self.name         = "";
    self.sex          = 1  --1 man 2 woman
    self.camp         = 1  --闃佃惀 ,1涓轰汉绫? 鍏朵粬涓烘€墿
	self.gold         = 0;
	self.ingot        = 0;
	self.level        = 1;
	self.exc          = 0;

    --鍙互璁剧疆鐨勫睘鎬?
	self.attackMode   = 1;
    self.slashDelta   = 2;     --鎸ョ爫闂撮殧
    self.moveDelta    = 0;     --绉诲姩闂撮殧
    self.slashClock   = nil;   --鎸ョ爫璁℃椂鏃堕挓
    self.allowRun     = true;

    self.type         = 1  --瑙掕壊绫诲瀷 瀵瑰簲actor.tab鐨刬d
    self.id           = 1  --浜虹墿鍞竴鏍囪瘑绗?

    --瑙掕壊琛屼负鐘舵€佸睘鎬?
    self.statusEnum =
    {
        ["stand"]=1,
        ["walk"]=2,
	    ["run"]=3,
	    ["hurt"]=10,
        ["die"]=11,
        ["slash"]=5,
        ["idle"]=4,
        ["slash2"]=7,
        ["cast"]=8,
        ["drag"]=9,
    }

    --鐘舵€佸睘鎬х敤浜庤绠楃姸鎬佺殑
    self.status          = 1
    self.idleStatus      = 1    --璀︽垝鐘舵€侊紝鏀诲嚮鍚庢敼鍙?
    self.idleClock       = nil  --璁＄畻璀︽垝鐨勬椂閽?
    self.idleStatusTime  = 5    --鍗曚綅绉?
    self.lockBehavior = false   --閿佸畾琛屼负,鍙互鐢ㄦ潵鎺у埗瑙掕壊鑴氭湰鍒囨崲,濡傝嚜鍔ㄥ璺笉浼氬娆¤繍琛?
    self.lockStatus   = false   --閿佸畾鐘舵€?鐩墠鐢ㄦ潵闃叉鑷姩瀵昏矾鐨勬椂鍊欏垏鎹㈠姩鐢?

    --娑夊強鏄剧ず鍜岀敾闈㈢殑灞炴€?
    self.dir = 1 -- 1...8 鍒嗗埆浠庢涓婃柟椤烘椂閽堟棆杞?
    self.positionOfMap = {x=0,y=0};    --鎵€澶勫湴鍥剧殑浣嶇疆
    self.x = 0
    self.y = 0
    self.zOrder = 0

    --韬綋閮ㄤ欢
    --瑁呭鏁扮粍鍖呮嫭宸茬粡瑁呭鐨?
    self.nakedBody = nil;   --鍒濆韬綋锛屽鏋減art[1]娌℃湁鍊煎垯鏄剧ず杩欎釜韬綋
    self.parts =
    {
        [1] = nil,   --琛ｆ湇
        [2] = nil,   --姝﹀櫒
        [3] = nil,   --澶寸洈
        [4] = nil,   --椤归摼
        [5] = nil,   --鎵嬮暞
        [6] = nil,   --鎵嬮暞
        [7] = nil,   --鎴掓寚
        [8] = nil,   --鎴掓寚
        [9] = nil,   --澶村彂
        [10] = nil,  --寰呭畾
		[0] = nil,  --hair
    }

    --鍔熻兘鑴氭湰
    self.scripts = {}
	self.buff = {};

    --鎶€鑳?
    self.skills = {}
    self.slashSkills = {}

    --绮剧伒鐨勫綋鍓嶆樉绀哄湴鍥?
    self.map = nil;

	---------------------------------------------
    --------
	--------UI
	--------
	---------------------------------------------
    --鑳屽寘
    self.items = {};
    self.itemCount = 40;
    --self.bag = Bag:new();
    --self.bag:setSize(8, 5);

    --鏄剧ず鍚嶅瓧
    self.nameLabel = nil
    self.nameLabelOffset = 20
    self.nameLabelColor = cc.c3b(255, 0, 0)

    --鏄剧ず琛€鏉＄殑
    self.bloodBar = nil;

    --鏄剧ず琛€閲?
    self.bloodLabel = nil;
end

function Actor:updateState()
	local stateType = 0;
	for k,v in pairs(self.buff) do
		stateType = k;
	end

	self:setEffect(stateType);
end

function Actor:addBuff(buff)
	self.buff[buff.type] = buff;
end

function Actor:getBuff(_type)
	return self.buff[_type];
end

function Actor:delBuff(buff)
	self.buff[buff.type] = nil;
end

function Actor:setHair(hair)
	local partType = 11;

    --鍗歌浇鏃ц澶?
    local oldPart = self.parts[partType];
    if oldPart then
        oldPart:remove();
    end

	local pos = self:getPosition();
	hair:setPosition(pos.x, pos.y);
	self:changePartStatus(hair);
	self.parts[partType] = hair;
	self.parts[partType]:retain();

    --澶у湴鍥句笂
    local stage = self:getLayer();
    if stage then
        hair:addToMap(stage, self.zOrder - partType);
	else
		TraceError("no stage for adding part");
    end

	return oldPart;
end

function Actor:setNakedBody(_body)
	self.nakedBody = _body;
	self.nakedBody:retain();
end

function Actor:init(value)
	self:updateBaseAttribute();
    self:setAtb(value);
    self:initUI();
end

function Actor:updateBaseAttribute()
	local attribute = GetActorLevelAttribute(self.attributeId, self.level);
    self:setLevelAttribute(attribute);

	for _, part in pairs(self.parts) do
		self.attribute:plus(part.attribute);
	end

	self:setSlashSpeed(self.attribute.slashSpeed);
	self:setCastSpeed(self.attribute.castSpeed);
end

function Actor:setAtb(value)
    --璁剧疆鍩烘湰闅愯棌灞炴€?
    self.slashDelta             = value.slashDelta;    --鎸ョ爫闂撮殧
	self.castDelta              = value.castDelta or 0;
    self.moveDelta              = value.moveDelta;     --绉诲姩闂撮殧
    self.allowRun               = value.allowRun;      --鏄惁鍏佽濂旇窇
    --self.camp                   = value.camp;          --闃佃惀,涓嶅悓闃佃惀鍙兘寮哄埗PK,骞朵笖璁＄畻PK鍊?
	self.castSpeed              = value.castSpeed or 0.2;
	self.bodyid                 = value.bodyid;
	self.conf                   = value;

	self.idleClock = Clock:new();
    self.idleClock:setRingTimeDelta(self.idleStatusTime);

	self.slashClock = Clock:new();
    self.slashClock:setRingTimeDelta(self.slashDelta);

	self.castClock = Clock:new();
	self.castClock:setRingTimeDelta(self.castDelta);

	--self:setSlashSpeed(self.attribute.slashSpeed);
	--self:setCastSpeed(self.attribute.castSpeed);
end

function Actor:slashSpeedUp(value)
	local speed = self:getSlashSpeed();
	self:setSlashSpeed(speed - value);

	local _clock = self.slashClock;
	local delta = _clock:getRingTimeDelta();
	_clock:setRingTimeDelta(delta - value);
end

function Actor:setLevelAttribute(value)
    --璁剧疆闈㈡澘灞炴€э紝鐜╁鍙煡鐪嬬殑
	self.attribute:ctor();
	self.attribute:init(value);
end

function Actor:setSlashSpeed(speed)
    if speed == nil then
       return;
    end

	if self.statusEnum["slash"] then
		self:setStatusSpeed(self.statusEnum["slash"], speed);
	end

	self.attribute.slashSpeed = speed;
end

function Actor:setCastSpeed(speed)
    if speed == nil then
       return;
    end

	if self.statusEnum["cast"] then
		self:setStatusSpeed(self.statusEnum["cast"], speed);
	end
end

function Actor:setZOrder(order)
    self.zOrder = order;

    self:adjustPartZOrder();
    self:setUIZOrder(order);
end

function Actor:update(delta)
    --if self:checkMove() then
        self:synBodyPointToSelf();
    --end

    --寰幆鎵ц鑴氭湰
    for k,v in pairs(self.scripts) do
        v:update(self);
    end

    --寰幆鎵ц鎶€鑳?
    for k,v in pairs(self.skills) do
        v:update(self);
    end

    self:updateIdleStatus();
    self:checkPlayDamageAction();
    --self:showContactRect();
end

function Actor:showContactRect()
    if not self.node then
        self.node = cc.DrawNode:create();
        local stage = self:getParent();
        stage:addChild(self.node, self.zOrder-10);
    end

    self.node:clear();
    local rect = self:getCollisionRect();
    self.node:drawSolidRect({x=rect.left,y=rect.bottom},
        {x=rect.right,y=rect.top},
        cc.c4f(1, 1, 1, 1));
end

--鍥犱负绉诲姩鏄娇鐢ㄥ姩浣滃彉鍖栫粍浠剁殑鍧愭爣鎵€浠ラ渶瑕佸湪绉诲姩鐨勬椂鍊欏皢璇ョ粍浠剁殑鍧愭爣杞崲鎴恆ctor鐨勫潗鏍?
function Actor:synBodyPointToSelf()
    --鐘舵€佷负2,3琛ㄧず浜虹墿鍦ㄨ繘琛岀Щ鍔紝鏇存柊閮ㄤ欢鍧愭爣
    local curpos = self:getPosition();

    self.x = curpos.x;
    self.y = curpos.y;

    self:adjustSpritePosition();

    self:updateUIPosition();

	--鍙戦€佹秷鎭洿鏂拌鑹蹭綅锟?
	self:sendPosJusticeEvent(curpos);
end

function Actor:sendPosJusticeEvent(curpos)
	if not self.moveTargetPos then
		return;
	end

    local curMapPos = FuncPack:getCheckPositionOfPoint(curpos);
    local lastPositionOfMap = self:getPositionOfMap();

	if FuncPack:isEqualPoint(self.moveTargetPos, lastPositionOfMap) == false
		and FuncPack:isEqualPoint(lastPositionOfMap, curMapPos) == true then
		local dir = FuncPack:calcuteDirFromPoint(curMapPos, self.moveTargetPos);
		local nextStepPoint = FuncPack:nextPositionWithDir(lastPositionOfMap, dir, 1);
        engine.dispachEvent("move", {object=self,newPos=nextStepPoint});
	end
end

function Actor:sigalCurrMapPos()
	--锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷为锟斤拷时锟斤拷锟斤拷一锟斤拷锟皆硷拷锟斤拷前锟侥碉拷图位锟斤拷
	local curMapPos = FuncPack:getCheckPositionOfPoint(self:getPosition());
    local lastPositionOfMap = self:getPositionOfMap();

	if FuncPack:isEqualPoint(lastPositionOfMap, curMapPos) == false then
		--print("sigal CurrMapPos:("..curMapPos.x..","..curMapPos.y..")"..);
        engine.dispachEvent("move", {object=self});
	end
end

function Actor:loadPart(part, isLeftOrRight) --第二个参数为手镯或者戒指准备,1为左，2为右
    local partType = part:getType();
	isLeftOrRight = isLeftOrRight or 0;

	partType = partType + isLeftOrRight;

    if partType > 10 or partType <= 0 then
        print("invalid part "..partType);
        return;  --缁勪欢涓嶅悎娉?
    end

    --鍗歌浇鏃ц澶?
    local oldPart = self.parts[partType];
    if oldPart then
        self:unLoadPart(oldPart, isLeftOrRight);
    end

    --灏嗙粍浠跺姞杞?
	--瑁呭鍔犺浇鍒板ぇ鍦板浘
	local pos = self:getPosition();
	part:setPosition(pos.x, pos.y);
	self:changePartStatus(part);
	self.parts[partType] = part;
	self.parts[partType]:retain();

    --澶у湴鍥句笂
    local stage = self:getLayer();
    if stage then
        part:addToMap(stage, self.zOrder - partType);
	else
		TraceError("no stage for adding part");
    end

    if partType == 1 and self.nakedBody then
        self.nakedBody:setVisible(false);
    end

    --鏇存柊attribute
	self.attribute:plus(part.attribute);
    self:setSlashSpeed(self.attribute.slashSpeed);
	self:setCastSpeed(self.attribute.castSpeed);

    --鏇存柊缁勪欢鐨刼rder
    self:adjustPartZOrder();

	self:updateUIStatus();

    return oldPart;
end

function Actor:getStatus()
    return self.status;
end

function Actor:unLoadPart(part, isLeftOrRight)
    local partType = part:getType();
	isLeftOrRight = isLeftOrRight or 0;

	partType = partType + isLeftOrRight;

    if partType > 10 or partType <= 0 then
        return -1;  --缁勪欢涓嶅悎娉?
    end

    self.parts[partType] = nil
    part:removeFromMap();
	part:release();

    if partType == 1 then
        self.nakedBody:setVisible(true);
    end

    --璁＄畻鎷夸笅瑁呭鐨勫睘鎬?
    self.attribute:minus(part.attribute);
	self:setSlashSpeed(self.attribute.slashSpeed);
	self:setCastSpeed(self.attribute.castSpeed);

	self:updateUIStatus();

    return 1;
end

function Actor:getEquip(etype)
	return self.parts[etype];
end

function Actor:unLoadPartForType(partType)
    if partType > 10 or partType <= 0 then
        return -1;  --缁勪欢涓嶅悎娉?
    end

    local part = self.parts[partType];
    if not part then
        return;
    end

    self.parts[partType] = nil
    part:removeFromMap();
	part:release();

    if partType == 1 then
        self.nakedBody:setVisible(true);
    end

    --璁＄畻鎷夸笅瑁呭鐨勫睘鎬?
    self.attribute:minus(part.attribute);
	self:setSlashSpeed(self.attribute.slashSpeed);
	self:setCastSpeed(self.attribute.castSpeed);

	self:updateUIStatus();

    return 1;
end

function Actor:setPartVisible(type, visible)
    if self.parts[type] then
        self.parts[type]:setVisible(visible);
    end
end

function Actor:adjustPartZOrder()
    for k,part in pairs(self.parts) do
        if (self.dir >= 2 and self.dir <= 5) and part:getType() == 2 then
            part:setLocalZOrder(self.zOrder)
        else
            part:setLocalZOrder(self.zOrder - part:getType())
        end
    end

    if self.nakedBody then
        self.nakedBody:setLocalZOrder(self.zOrder - 1)
    end
end

function Actor:adjustSpritePosition()
	local pos = self:getPosition();

    for k, part in pairs(self.parts) do
        part:setPosition(self.x, self.y);
    end

    if self.nakedBody then
        self.nakedBody:setPosition(self.x ,self.y);
    end

    self:updateUIPosition();
end

function Actor:changeStatus(_status, actionArray)
    self.status = _status
	local ret, success = nil;

    for k, v in pairs(self.parts) do
        if v:getType() == 1 then
            ret, success = self:changePartStatus(v, actionArray);
        else
            self:changePartStatus(v);
        end
    end

    --鏄惁娌℃湁瑁呭琛ｆ湇,濡傛灉娌℃湁鍒欑姸鎬佸彉鍖栫殑鏄８浣撹韩浣?
    if not self.parts[1] and self.nakedBody then
        ret, success = self:changePartStatus(self.nakedBody, actionArray);
    end

	return 1, success;
end

function Actor:changePartStatus(part, actionArray)
    local aniIndex = self.dir + (self.status-1) * statusAniStep
    local aniName = tostring(aniIndex);
	local ret,success = part:runAction(aniName, actionArray);
	if ret == false then
		self:unLockActorBehavior();
	end

	return ret,success;
end

function Actor:runActions(actions)
    if self.parts[1] then
        self.parts[1]:runActions(actions);
    else
        if self.nakedBody then
            self.nakedBody:runActions(actions);
		else
			TraceError("no naked Body:"..self.id);
        end
    end
end

function Actor:runOriginalAction(actions)

end

function Actor:stopAllActions()
    for k,v in pairs(self.parts) do
        v:stopAllActions();
    end

    if not self.parts[1] then
        self.nakedBody:stopAllActions();
    end

	self:unLockActorBehavior();
	self:unLockActorStatus();
	self.moveTargetPos = nil;
end

function Actor:stopScripts(name)
    if name ~= nil and self.scripts[name] then
        self.scripts[name]:stop();
        return;
    end

    for k,v in pairs(self.scripts) do
        v:stop();
    end
end

function Actor:setAtkTarget(targetId)
    self.atkTarget = targetId;
end

function Actor:getAtkTarget()
    return self.atkTarget
end

function Actor:getAtkedBy()
    return self.attackedBy
end

function Actor:getDamage(fromid, num)
    if self.attribute.hp <= 0 then
        return;
    end

    self.attackedBy = fromid;
    self.attribute.hp = self.attribute.hp - num;
    self:changeIdleStatus();

    if self.attribute.hp <= 0 then
        self.damage = false;
        self.attribute.hp = 0;
        self:die();

		self:closeSkillEffect();
	else
		self:playSkillGetDamageEffect(num);
    end

    self:updateUIStatus();

	return true;
end

function Actor:setShaderEnable(enable)
	if not self.parts[1] then
		self.nakedBody:setShaderEnable(enable);
		return;
	end

	self.parts[1]:setShaderEnable(enable);
end

function Actor:playSkillGetDamageEffect(num)
	for _,v in pairs(self.skills) do
		if v.getDamage then
			v:getDamage(self, num);
		end
	end
end

function Actor:useMagic(value, num)
	if self.attribute.mp < num then
		return;
	end

	self.attribute.mp = self.attribute.mp - num;

	self:updateUIStatus();

	return true;
end

--涓嶆柇妫€娴嬫挱鏀炬敹鍒颁激瀹崇殑鍔ㄧ敾
function Actor:checkPlayDamageAction()
    if self.damage and self:checkMove() == false then
        self:lockActorBehavior()    --閿佸畾鐘舵€?

        --鍙椾激缁撴潫
        local hurtOver = cc.CallFunc:create(function()
            self:idle();
            self.damage=false;
        end)

        --鎵ц琛屽姩
        self:changeStatus(self.statusEnum["hurt"],{hurtOver});--self.statusEnum
        self:closeSkillEffect();
    end
end

--琚墦鏂?
function Actor:closeSkillEffect()
	for k, v in pairs(self.skills) do
		if v.type == 1 or v.type == 3 then
			v:closeEffect();
		end
    end
end

function Actor:checkMove()
    if self.status == self.statusEnum["walk"] or self.status == self.statusEnum["run"] then
        return true;
    end

    return false;
end

function Actor:getActionName(status)
	local aniIndex = self.dir + (status-1) * statusAniStep
    local aniName = tostring(aniIndex);

	return aniName;
end

function Actor:die()
    --锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷
	self.attribute.hp = 0;

	--self:setEffect(0);

	self:stopAllActions();
	self:stopScripts();
	self:lockActorBehavior()
	self:changeStatus(self.statusEnum["die"]);

	--hide ui
	self:closeSkillEffect();
	self:setUIVisible(false);
end

function Actor:revive()
	self.attribute.hp = self.attribute.maxHp
    self.attribute.mp = self.attribute.maxMp

    self:unLockActorBehavior();
	self:unLockActorStatus();

	--self:setPosition(FuncPack:);
    self:changeStatus(self.statusEnum["stand"]);
    self:setUIVisible(true);

    self:updateUIStatus();
end

function Actor:move(dir, step, callFunc)
	if self:isDie() then
		return;
	end

	return MoveScript:move(self, dir, step, callFunc);
end

function Actor:walk(dir, callFunc)
	if self:isDie() then
		return;
	end

    return MoveScript:move(self, dir, 1, callFunc);
end

function Actor:run(dir, callFunc)
	if self:isDie() then
		TraceError(self.id.." is dead");
		return;
	end

    return MoveScript:move(self, dir, 2, callFunc);
end

function Actor:runTo(point)
    return false; --self:executeScript("findpath", point);
end

function Actor:stopRun()
    return self:executeScript("findpath", nil);
end

--褰撳墠浣嶇疆宸茬粡鏈変簡瀵硅薄鐨勬椂鍊欓渶瑕佽繑鍥炲師鏉ョ殑浣嶇疆
function Actor:backLastPosition(curPoint)
    local oppositeDir = (self.dir + 3)%#ActorDir + 1
    local lastPosition = MoveScript:getMovePoint(curPoint, oppositeDir, self.status-1);
    self:setPosition(lastPosition.x, lastPosition.y);
end

function Actor:addScript(name, script)
    if self.scripts[name] ~= nil then
        TraceError("宸插瓨鍦ㄨ鑴氭湰.."..name);
        return
    end

    self.scripts[name] = script;
end

function Actor:executeScript(name, values)
	if not self.scripts[name] then
		TraceError("no have "..name.." script");
		return;
	end

    self.scripts[name]:execute(values, self);
end

function Actor:getScriptRuning(name)
    if self.scripts[name] then
        return self.scripts[name]:getRunning();
    end

    return nil;
end

function Actor:addSkill(skill)
	if not skill then
		return;
	end

    if self.skills[skill.name] ~= nil then
        TraceError(skill.name.." already exist");
        --return;
    end

	if skill.type == 1 then
        skill.action = self.statusEnum["slash"];
	end

    self.skills[skill.name] = skill;
	self.skills[skill.name]:retain();

    --鏍规嵁鎶€鑳戒紭鍏堢骇鎺掑簭
	--[[
    if skill.type == 1 then
        skill.action = self.statusEnum["slash"];

        local skillCompare = function(s1, s2)
            return s1.priority > s2.priority
        end

		if self.id == 3 then
			TraceError("add skil "..skill.name.." address:"..tostring(skill));
		end
    	table.insert(self.slashSkills, #self.slashSkills+1, skill);

		if #self.slashSkills >= 2 then
			table.sort(self.slashSkills, skillCompare)
		end

		for k,v in pairs(self.slashSkills) do
			TraceError("repeat slash skill:"..v.name.." address:"..tostring(v));
		end
    end]]
end

function Actor:delSkill(skillid)
	local skill = nil;

	for k,v in pairs(self.skills) do
		local baseData = v:getBaseData();
		if baseData.skillid == skillid then
			skill = v;
			self.skills[k] = nil;
			break;
		end
	end

	for k,v in pairs(self.slashSkills) do
		local baseData = v:getBaseData();
		if baseData.skillid == skillid then
			self.slashSkills[k] = nil;
			break;
		end
	end

	--skill:remove();
	skill:release();

	return skill;
end

function Actor:getSkillById(id)
	for k,v in pairs(self.skills) do
		local skillid = v:getBaseData().skillid;
		if skillid == id then
			return v;
		end
	end
end

function Actor:getSkillsData()
	local skillData = {};

	for k,v in pairs(self.skills) do
		local baseData = v:getBaseData();

		if baseData.skillid ~= 1 then
			table.insert(skillData, #skillData+1, baseData);
		end
	end

	return skillData;
end

function Actor:addItem(item, index)
	if self:hasItem(item:getID()) then
		--print("repeat add item:"..item:getID().."  debug:"..debug.traceback());
		return;
	end

    if index then
        if not self.items[index] then
            self.items[index] = item;
			self.items[index]:retain();
            return true;
        else
            return false;
        end
    end

    for i=1, self.itemCount do
        if self.items[i] == nil then
            self.items[i] = item;
			self.items[i]:retain();
            return true;
        end
    end

    return false;
end

function Actor:hasItem(itemId)
	for i=1, self.itemCount do
        if self.items[i] and self.items[i]:getID() == itemId then
            return true;
        end
    end

	return false;
end

function Actor:getItem(index)
    return self.items[index]
end

function Actor:getItemForTypeid(typeid)
	for k,v in pairs(self.items) do
		if v:getBaseData().typeid == typeid then
			return v;
		end
	end
end

function Actor:removeItem(index)
	if self.items[index] then
		self.items[index]:release();
		self.items[index] = nil;
	end
end

function Actor:removeItemWithId(itemId)
	for k,v in pairs(self.items) do
		if v:getID() == itemId then
			self.items[k]:release();
			self.items[k] = nil;
			return v;
		end
	end

	return nil;
end

function Actor:slash(values, callfunc)
	local slashName,reason = self:getProperSlashSkill();

	if not slashName then
		return nil, reason;
	end

	return self:cast(slashName, values, callfunc);
end

function Actor:getProperSlashSkill()
	if self:checkSlashClockRing() == false then
		return nil, "slash cooling down:"..self.slashClock:getDeltaTime();
	end

	local skills = self.skills;
	local currSlashSkill = nil;
	for k, v in pairs(skills) do
		if v:getType() == 1 then
			local ret,reason = v:satifyCastPremise(self, values);
			if ret then
				if not currSlashSkill then
					currSlashSkill = v;
				elseif currSlashSkill.priority < v.priority then
					currSlashSkill = v;
				end
			end
		end
	end

	if currSlashSkill then
		return currSlashSkill, "currSlashSkill nil";
	end
end

function Actor:setCurrFrameIndex(index)
    for k,v in pairs(self.parts) do
        v:setCurrFrameIndex(index);
    end

    if not self.parts[1] and self.nakedBody then
        self.nakedBody:setCurrFrameIndex(index);
    end
end

function Actor:setLastCurrFrameIndex(aniName)
    for k,v in pairs(self.parts) do
        v:setLastCurrFrameIndex(aniName);
    end

    if not self.parts[1] and self.nakedBody then
        self.nakedBody:setLastCurrFrameIndex(aniName);
    end
end

function Actor:setAniCurrFrameIndex(name, index)
    self:setCurrFrameIndex(index);
    self:stopAllActions();

    local skill = self.skills[name];
    skill:stopPlayEffect();
    skill:setCurrFrameIndex(index);
end

function Actor:cast(name, values, callFunc)
	if not name then
		TraceError(" cast failed, because name invalid:"..debug.traceback());
        return nil, "no name";
	end

    if self.lockBehavior == true then
		TraceError(name.." cast failed, because lock behavior");
        return nil, "lock behavior";
    end

    local skill = self.skills[name]
    if not skill then
        TraceError("skill "..name.." no have");
        return nil, "no skill "..name;
    end

    --涓嶇鍚堟潯浠跺垯閲婃斁澶辫触
	local ret, reason = skill:satifyCastPremise(self, values);
    if ret == false then
        return nil, reason;
    end

	if skill.type == 1 then
		self:setSlashSpeed(self.attribute.slashSpeed);
	elseif skill.type >= 2 then
		self:setCastSpeed(self.attribute.castSpeed);

		if values then
			local dir = FuncPack:calcuteDirFromPoint(self:getPositionOfMap(), values);
			self:setDir(dir);
		end
	end

    --鍒濆鍖栨妧鑳?
    skill:run(self, values, callFunc);
	skill:calcMagic(self);

    --鎶€鑳界粨鏉熷洖璋冨嚱鏁?
    local func = cc.CallFunc:create(function()
        self:changeIdleStatus();
		self:unLockActorBehavior();

        skill:over(self, values);
    end);

    --瑙掕壊瀵瑰簲鎶€鑳界殑鍔ㄤ綔
    local ret = self:changeStatus(skill.action, {func})

    --閿佸畾琛屼负
    self:lockActorBehavior();

    return skill;
end

function Actor:idle()
    --鍒ゆ柇鏄惁杩樻湁鍚庣画鍔ㄤ綔娌℃湁鍒欐仮澶嶅緟瀹氱姸鎬?
	if self:isDie() then
		return;
	end

	if self.lockStatus == false then
        self:changeStatus(self.idleStatus);
    end

	self:synBodyPointToSelf();

    --琛屼负閿佸畾瀹屾瘯
    self:unLockActorBehavior();
end

function Actor:changeIdleStatus()
    self.idleStatus = self.statusEnum["idle"];
    self.idleClock:markRingTime();
end

function Actor:updateIdleStatus()
    if self.idleStatus ~= 1 then
        if self.idleClock:ring() then
            --鏃堕挓鏍囪杩欐鐨勫搷閾冩椂闂?
            self.idleClock:markRingTime();

            --鎭㈠鐘舵€?
            self.idleStatus = 1

            if self.lockBehavior == false then
                self:idle();
            end
        end
    end
end

function Actor:lockActorBehavior()
    self.lockBehavior = true;
end

function Actor:unLockActorBehavior()
    if self:isDie() then
        return;
    end

	--[[
	local ret = string.find(self.name, "%(");
	if ret then
		TraceError("unLockActorBehavior :"..debug.traceback());
	end]]

    self.lockBehavior = false;
end

function Actor:markIsStand(isStand)

end

function Actor:lockActorStatus()
	--TraceError("lockActorStatus:");
    self.lockStatus = true;
end

function Actor:unLockActorStatus()
    self.lockStatus = false;
end

function Actor:getLockBehavior()
    return self.lockBehavior;
end

function Actor:getMap()
    return self.map;
end

function Actor:addTo(parent)
    for k, v in pairs(self.parts) do
        v:addToMap(parent, self.zOrder - v:getType());
    end

    if self.nakedBody then
        self.nakedBody:addToMap(parent, self.zOrder - 1);
    end

    self:addUI(parent);

    self:adjustSpritePosition();
end

function Actor:remove()
    for k, v in pairs(self.parts) do
		v:removeFromMap();
    end

    self.nakedBody:removeFromMap();
    self:removeUI();

    --remove skill effect
    for k,v in pairs(self.skills) do
        --print("skill name:"..v.name);
        v:remove();
    end
end

function Actor:getSlashSpeed()
    return self.attribute.slashSpeed;
end

function Actor:getCastSpeed()
	return self.attribute.castSpeed;
end

function Actor:getDir()
    return self.dir;
end

function Actor:getLayer()
    return self.nakedBody:getParent();
end

function Actor:getParent()
    return self.nakedBody:getParent();
end

function Actor:getPositionOfMap()
    return self.positionOfMap;
end

function Actor:setEdging(outlineSize, color)
    local body = self.nakedBody;

    if self.parts[1] then
        body = self.parts[1];
    end

    body:setEdging(outlineSize, color);
end

function Actor:setEffect(effectid)
    local body = self.nakedBody;

    if self.parts[1] then
        body = self.parts[1];
    end

    body:setEffect(effectid);
end

function Actor:setBody(_body)
    self.body = _body;
end

function Actor:setName(_name)
    self.name = _name
end

function Actor:setPosition(_x, _y)
    self.x = _x
    self.y = _y

    self:adjustSpritePosition();
end

function Actor:getPosition()
    local body = self.nakedBody;

    if self.parts[1] then
        body = self.parts[1]
    end

    if not body then
        return {x=self.x,y=self.y}
    end

	if self.parts[1] then
		for k,v in pairs(self.parts) do
			--print("1      body:"..tostring(v.name).." id "..self.id);
		end
	else
		--print("2      body:"..tostring(body.name).." id "..self.id.."   "..debug.traceback());
	end
    local pos = body:getPosition();

    if not pos then
        return {x=self.x,y=self.y}
    end

    return pos;
end

function Actor:setDir(_dir)
    if not _dir or _dir > 8 or _dir <= 0 then
        return;
    end

    self.dir = _dir

    self:adjustPartZOrder();
end

function Actor:setType(_type)
    self.type = _type;
end

function Actor:getType()
    return self.type;
end

function Actor:isDie()
    return self.attribute.hp <= 0;
end

function Actor:setStatusSpeed(status, duration)
    local aniNames = {}

    for dir=1, statusAniStep do
        local aniIndex = dir + (status-1) * statusAniStep
        local aniName = tostring(aniIndex);

        table.insert(aniNames, #aniNames+1, aniName);
    end

    for k,v in pairs(self.parts) do
		v:setActionsSpeed(aniNames, duration);
	end

    if self.nakedBody then
        self.nakedBody:setActionsSpeed(aniNames, duration);
    end
end

function Actor:stopSkill(skillName)
	local skill = self.skills[skillName];
	if skill then
		skill:close();
	end
end

function Actor:markSlashRingTime()
    self.slashClock:markRingTime();
end

function Actor:markCastRingTime()
    self.castClock:markRingTime();
end

function Actor:checkSlashClockRing()
    return self.slashClock:ring();
end

function Actor:checkCastClockRing()
    return self.castClock:ring();
end

function Actor:levelUp()
	self:updateUIStatus();

	engine.dispachEvent("ACTOR_UPDATE_BOTTOM_UI", self.id);
	--engine.dispachEvent("UPDATE_BottomUI", self);
end

--锟斤拷前锟狡讹拷锟斤拷目锟斤拷锟斤拷锟斤拷
function Actor:setMoveTargetPos(pos)
	self.moveTargetPos = pos;
end

function Actor:getIsStand()
	return true;
end

---------------------------------------------------------------
-----
-----            set   get   function
-----
---------------------------------------------------------------
function Actor:getName()
	return self.name
end

function Actor:setName(_name)
	self.name = _name;
end

function Actor:setCamp(_camp)
    self.camp = _camp
end

function Actor:getCamp()
    return self.camp
end

function Actor:setLevel(_level)
    self.level = _level
end

function Actor:setSex(_sex)
    self.sex = _sex
end

function Actor:getSex()
    return self.sex
end

function Actor:getLevel()
    return self.level;
end

function Actor:getSlashRange()
    return 1;
end

function Actor:getSpeed(_type)
    return self.attribute.speed[_type]
end

function Actor:setAllowRun(_allowRun)
    self.allowRun = _allowRun;
end

function Actor:getAllowRun()
    return self.allowRun;
end

function Actor:getID()
    return self.id;
end

function Actor:setID(id)
    self.id = id;
end

function Actor:getAttribute()
    return self.attribute;
end

function Actor:setExc(exc)
	self.exc = exc;
end

function Actor:addExc(exc)
	local newLevel,newExc = getLevelFromExc(self.conf.sz_excConf, self.level, self.exc+exc);
	local isLevelUp = nil;
	if newLevel ~= self.level then
		isLevelUp = true;
	end

	self.level = newLevel;
	self.exc = newExc;

	if isLevelUp then
		self:updateBaseAttribute();
		self:levelUp();
	else
		engine.dispachEvent("ACTOR_UPDATE_BOTTOM_UI", self.id);
	end
end

function Actor:getExc()
	return self.exc;
end

function Actor:setGold(gold)
	self.gold = gold;
end

function Actor:getGold()
	return self.gold;
end

function Actor:getMoveDelta()
    return self.moveDelta;
end

function Actor:setHp(_hp)
	self.attribute.hp = _hp;

	self:updateUIStatus();
end

function Actor:getHp()
	return self.attribute.hp;
end

function Actor:getMaxHp()
	return self.attribute.maxHp;
end

function Actor:getMp()
	return self.attribute.mp;
end

function Actor:setMp(_mp)
	self.attribute.mp = _mp;

	if self == Account:getCurrActor() then
		engine.dispachEvent("UPDATE_BottomUI", self);
	end
end

function Actor:getMaxMp()
	return self.attribute.maxMp;
end

function Actor:setAttributeId(_attributeId)
	self.attributeId = _attributeId;
end

function Actor:getAttributeId()
	return self.attributeId;
end

function Actor:getRandomAttack(type)
    local ATKParam = self.attribute.atk[type];
    local randomAttack = FuncPack:getRandomNumber(ATKParam[1], ATKParam[2]);

    return randomAttack;
end

function Actor:getRandomDefense(type)
    return self.attribute.dfs[type] or 0;
end

function Actor:getCollisionRect()
    local body = self.nakedBody;
    local size = body:getContentSize();
    local pos = body:getLeftBottomPosition();

	if not size or (size.width <= 5 and size.height <= 5) then
		size = {width=40, height=60}

		return {left=self.x+10, bottom=self.y+TILE_HEIGHT/2, right=self.x+10+size.width/2,
			top = self.y+TILE_HEIGHT/2 + size.height}
	end

	if self.id == 2 then
		--print("getPosition:"..tostringex(size));
		--print("getLeftBottomPosition:"..tostringex(body:getLeftBottomPosition()));
	end
    return {left=pos.x, bottom=pos.y, right=pos.x+10+size.width - 40,
        top = pos.y + size.height}
end

function Actor:isClick(point)
	--[[local body = self.nakedBody;
	if self.parts[1] then
		body = self.parts[1];
	end

	if body then
		local ret = body:isClick(point);
		print("body:isClick(point):"..tostring(ret));
		return ret;
	end]]

	local rect = self:getCollisionRect();
	return FuncPack:rectContainPoint(rect, point);
end

function Actor:release()
    for k,v in pairs(self.parts) do
        v:release();
    end

    if self.nakedBody then
        self.nakedBody:release();
    end

    if self.nameLabel then
        self.nameLabel:release();
    end

    if self.bloodBar then
        self.bloodBar:release();
    end

    if self.bloodLabel then
        self.bloodLabel:release();
    end

	for k,v in pairs(self.items) do
		v:release();
	end

	for k,v in pairs(self.skills) do
		v:release();
	end
end


function Actor:retain()
	for k,v in pairs(self.parts) do
        v:retain();
    end

    if self.nakedBody then
        self.nakedBody:retain();
    end

    if self.nameLabel then
        self.nameLabel:retain();
    end

    if self.bloodBar then
        self.bloodBar:retain();
    end

    if self.bloodLabel then
        self.bloodLabel:retain();
    end

	for k,v in pairs(self.items) do
		v:retain();
	end

	for k,v in pairs(self.skills) do
		v:retain();
	end
end

--[[
function Actor:uiRelease()
	for k, v in pairs(self.parts) do
		v:release();
    end

	print("----------------release---------------");
    self.nakedBody:release();

    --remove skill effect
    for k,v in pairs(self.skills) do
        --print("skill name:"..v.name);
        v:release();
    end
end
]]
-------------------------UI---------------------
--
--               UI function
--
------------------------------------------------
function Actor:initUI()
    if self.nameLabel == nil then
        self.nameLabel = engine.initLabel(self.name);
        --self.nameLabel:retain();
    end

    if self.bloodBar == nil then
        self.bloodBar = BloodBar:new();
        --self.bloodBar:retain();
    end

    if not self.bloodLabel then
        self.bloodLabel = engine.initLabel(self.name);
        --self.bloodLabel:retain();
    end

    self:updateUIStatus();
    self:updateUIPosition();
end

function Actor:setUIZOrder(zOrder)
	--[[
    if self.nameLabel then
        self.nameLabel:setLocalZOrder(zOrder);
    end

    if self.bloodBar then
        self.bloodBar:setLocalZOrder(zOrder);
    end

    if self.bloodLabel then
        self.bloodLabel:setLocalZOrder(zOrder);
    end]]
end

function Actor:updateUIPosition()
    local pos = self:getPosition();

    if self.nameLabel then
        self.nameLabel:setPosition(pos.x + TILE_WIDTH/2, pos.y + TILE_HEIGHT/2);

		if self:getCamp() == 3 then
			self.nameLabel:setColor(cc.c3b(0, 255, 0));
		end

        local pos = self:getPositionOfMap();
        self.nameLabel:setString(self.name);
    end

    if self.bloodBar then
        self.bloodBar:setPosition(pos.x + TILE_WIDTH/2, pos.y + TILE_HEIGHT/2);
    end

    if self.bloodLabel then
        self.bloodLabel:setPosition(pos.x + TILE_WIDTH/2,
            pos.y + TILE_HEIGHT/2 + self.bloodBar:getOffset() + 10);
    end
end

function Actor:setUIVisible(visible)
    if self.nameLabel then
        self.nameLabel:setVisible(visible);
    end

    if self.bloodBar then
        self.bloodBar:setVisible(visible);
    end

    if self.bloodLabel then
        self.bloodLabel:setVisible(visible);
    end
end

function Actor:updateBloodBar()
    if not self.bloodBar then
        return;
    end

    local bloodPercent = self.attribute.hp/self.attribute.maxHp*100;
    self.bloodBar:setPercentage(bloodPercent);
end

function Actor:updateBloodLabel()
    if not self.bloodLabel then
        return;
    end

    self.bloodLabel:setString(self.attribute.hp.."/"..self.attribute.maxHp);
end

function Actor:updateUIStatus()
	if self == Account:getCurrActor() then
		engine.dispachEvent("UPDATE_BottomUI", self);
	end

    self:updateBloodBar();
    self:updateBloodLabel();
end

function Actor:addUI(parent)
    if self.bloodBar then
        parent:addChild(self.bloodBar, LayerzOrder.UI);
    end

    if self.bloodLabel then
        parent:addChild(self.bloodLabel, LayerzOrder.UI);
    end

    if self.nameLabel then
        parent:addChild(self.nameLabel, LayerzOrder.UI);
    end
end

function Actor:removeUI()
    if self.nameLabel and self.nameLabel:getParent() then
        self.nameLabel:getParent():removeChild(self.nameLabel);
    end

    if self.bloodBar and self.bloodBar:getParent() then
        self.bloodBar:getParent():removeChild(self.bloodBar);
    end

    if self.bloodLabel and self.bloodLabel:getParent() then
        self.bloodLabel:getParent():removeChild(self.bloodLabel);
    end
end
