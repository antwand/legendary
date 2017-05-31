--额外的功能类
require "socket"
require "tools/tools.lua"
require "tools/FuncPack.lua"
require "tools/Clock.lua"
require "tools/Timer.lua"

require "network/Client.lua"

--cocos2dx功能封装类
--require "display/ActionSpriteForPlist.lua"
require "display/ActionSprite.lua"
require "display/Engine.lua"
require "display/ResLoader.lua"
require "display/AsyncLoadFile.lua"
require "display/AsyncLoadMirFile.lua"

--场景
require "scene/BaseScene.lua"
require "scene/Map.lua"
require "scene/ControlLayer.lua"
require "scene/ChrSelScene.lua"
require "scene/UILayer.lua"
require "ui/BaseUI/MyRichText.lua"
require "ui/BloodBar.lua"
require "ui/Bag.lua"
require "ui/ShortcutFrame.lua"
require "ui/StatueWindow.lua"
require "ui/BottomStateUI.lua"
require "ui/ItemIntroduatory.lua"
require "ui/TalkWindow.lua"
require "ui/NPCUI/NPCTalkingWindow.lua"
require "ui/BaseUI/RichText.lua"
require "ui/BaseUI/BorderLabel.lua"
require "ui/BaseUI/BorderText.lua"

--管理
require "manager/SkillManager.lua"
require "manager/ActorManager.lua"
require "manager/ItemManager.lua"
require "manager/EffectManager.lua"
require "manager/MapManager.lua"
require "manager/TimerManager.lua"

--物品
require "goods/Equipment.lua"
require "goods/Item.lua"
require "goods/Body.lua"
require "goods/BloodVial.lua"
require "goods/Ticket.lua"
require "goods/GoodPack.lua"

--角色
require "actor/Attribute.lua"
require "actor/Actor.lua"  --包括玩家和怪物
require "actor/Monster.lua"
require "actor/GodMon.lua"
--require "actor/Player.lua"
--require "actor/Body.lua"
require "actor/Account.lua"
require "actor/NPC.lua"

--skill
--require "skill/warrior/ThrustFencing.lua"
require "skill/Base/BaseSpell.lua"
require "skill/Base/CallPet.lua"
require "skill/Base/GodAtkSpell.lua"
require "skill/Base/BuffSpell.lua"
require "skill/Base/SlashSpell.lua"
require "skill/Base/RangeSpell.lua"
require "skill/Base/ThrustFencing.lua"
require "skill/Base/HalfMoonSlash.lua"
require "skill/Base/FireWallUnit.lua"
require "skill/Base/FireWall.lua"
require "skill/Base/SpeedUpSpell.lua"
require "skill/Base/ShootSpell.lua"
require "skill/Base/Buff/BaseBuff.lua"

--脚本类给actor调用
require "script/AStarFindPath.lua"
require "script/AutoFindPath.lua"
require "script/MoveScript.lua"
require "script/AutoFightWithMonster.lua"
require "script/AttackScript.lua"
require "script/ScriptCache.lua"

--AI
require "ai/MonsterBaseAI.lua"

function readConf()
    TILE_WIDTH = 48
    TILE_HEIGHT = 32

    LayerzOrder =
    {
        MAP    = 0,
        TILE   = 200,
        MID    = 200,
		DIE    = 400,
        OBJ    = 999,
        ITEM   = 800,
        ACTOR  = 1000,
		SHADOW = 1500,
        SKILL  = 4000,
		DAMAGE = 4500,
        UI     = 5000,
    }

	--[[
	xfileConf =
	{
		{"xfile/common.pvr.ccz","xfile/common.xfile"},
		{"xfile/human.pvr.ccz","xfile/human.xfile"},
		--{"xfile/human0.pvr.ccz","xfile/human0.xfile"},
		{"xfile/mon3.pvr.ccz","xfile/mon3.xfile"},
		--{"xfile/objects1.pvr.ccz","xfile/objects1.xfile"},
		--{"xfile/SmTiles.pvr.ccz","xfile/SmTiles.xfile"},
		--{"xfile/Tiles.pvr.ccz","xfile/Tiles.xfile"},
		--{"xfile/weapon1.pvr.ccz","xfile/weapon1.xfile"},
		--{"xfile/magic1.pvr.ccz","xfile/magic1.xfile"},
		{"xfile/magic2.pvr.ccz","xfile/magic2.xfile"},
	}
	]]

	--ActorConf        = require ("conf/ActorConf.lua")
	ActorConf    	 = readTabFile("conf/actor/actor.tab")
	ActorGrowConf    = readTabFile("conf/actor/actorAttribute.tab")
	ActorLvAttribute = readActorLevelAttributeConf();
    skillConf        = readTabFile("conf/skill/skill.tab")
	buffConf         = readTabFile("conf/skill/buff.tab")
    effectConf       = readTabFile("conf/effect/effect.tab")
    EquipmentConf    = readTabFile("conf/equip/equipment.tab")
	qualityConf      = readTabFile("conf/equip/itemQuality.tab")
	spriteConf       = readTabFile("conf/sprite/sprite.tab")
	MapConf 		 = readTabFile("conf/map/map.tab")
	npcConf          = readTabFile("conf/npc/npc.tab")
	talkConf         = readTabFile("conf/npc/talkConf.tab")

	for k,v in pairs(talkConf) do
		local path = v.sz_conf;
		local tb_content = readTabFile(path);
		v.tb_content = tb_content;
	end

	--equip
    for k,v in pairs(EquipmentConf) do
        if v.sz_atk ~= nil then
            EquipmentConf[k].atk = StringToTable(v.sz_atk);
        end

        if v.sz_dfs ~= nil then
            EquipmentConf[k].dfs = StringToTable(v.sz_dfs);
        end
    end

	--actor
	for k,v in pairs(ActorConf) do
        --ActorConf[k].speed = StringToTable(v.sz_speed);
		ActorConf[k].name = v.sz_name;

		if v.allowRun == 1 then
			ActorConf[k].allowRun = true;
		else
			ActorConf[k].allowRun = false;
		end
    end

	AsyncLoadMirFile:start();

	Client = require("network/Client.lua");

    --client type
    CLIENT_TYPE = 2; --1:Single，2:mutile
end

function readActorLevelAttributeConf()
	local conf = {};

	for key,value in pairs(ActorGrowConf) do
		conf[key] = {};

		for k,v in pairs(value) do
			local title = k;
			local value = v;
			local grow = 0;

			if string.find(title, "sz_") then
				local keys = split(k, "_");
				title = keys[2];
			end

			if string.find(v, "%(") then
				if string.find(v, "{") then
					local array = split(v, "(")
					value = StringToTable(array[1]);

					grow = StringToTable(string.sub(array[2], 2, string.len(array[2])-1));
				else
					local values = split(v, "(");
					value = tonumber(values[1]);
					grow = tonumber(string.sub(values[2], 1,
						string.len(values[2])-1));
				end
			else
				if string.find(v, "{") then
					value = StringToTable(v);
					grow = nil;
				else

				end
			end

			local growTitle = title.."_Grow";
			conf[key][title] = value;
			conf[key][growTitle] = grow;
			conf[key]["description_Grow"] = nil;
			conf[key]["id_Grow"] = nil;
		end
	end

	--TraceError("conf:"..tostringex(conf));
	return conf;
end

function GetActorLevelAttribute(id, _level)
	local level = _level - 1;

	local conf = ActorLvAttribute[id];
	if not conf then
		return;
	end

	local attribute = {};
	attribute.maxHp = conf.maxHp + conf.maxHp_Grow*level;
	attribute.maxMp = conf.maxMp + conf.maxMp_Grow*level;
	attribute.atk = {{0,0},{0,0},{0,0}}--conf.attack;
	attribute.dfs = {0, 0, 0}--conf.defense;

	--attribute
	for k,v in pairs(attribute.atk) do
		local grow = 0;
		if conf.attack_Grow and type(conf.attack_Grow) == "table" then
			grow = conf.attack_Grow[k];
		end

		attribute.atk[k][1] = v[1] + grow*level;
		attribute.atk[k][2] = v[2] + grow*level;

		if conf.attack[k] then
			attribute.atk[k][1] = attribute.atk[k][1] + conf.attack[k][1];
			attribute.atk[k][2] = attribute.atk[k][2] + conf.attack[k][2];
		end
		--attribute.atk[k][3] = v[3] + grow*level;
	end

	for k,v in pairs(attribute.dfs) do
		local grow = 0;
		if conf.defense_Grow and type(conf.defense_Grow) == "table" then
			grow = conf.defense_Grow[k];
		end

		attribute.dfs[k] = v + grow*level;

		if conf.defense[k] then
			attribute.dfs[k] = attribute.dfs[k] + conf.defense[k];
		end
	end

	attribute.castSpeed = conf.castSpeed;
	attribute.slashSpeed = conf.slashSpeed;
	attribute.speed = conf.speed;

	attribute.strength = (conf.strength or 0) + (conf.strength_Grow or 0)*level;
	attribute.aligity = (conf.aligity or 0) + (conf.aligity_Grow or 0)*level;
	attribute.taoistMagic = (conf.taoistMagic or 0) + (conf.taoistMagic_Grow or 0)*level;
	attribute.critRate = (conf.critRate or 0) + (conf.critRate_Grow or 0)*level;
	attribute.defenCrit = (conf.defenCrit or 0) + (conf.defenCrit_Grow or 0)*level;
	attribute.lucky = (conf.lucky or 0) + (conf.lucky_Grow or 0)*level;
	attribute.precise = (conf.precise or 0) + (conf.precise_Grow or 0)*level;
	attribute.dodge = (conf.dodge or 0) + (conf.dodge_Grow or 0)*level;
	--attrribute.maxHp = attack

	return attribute;
end

function getLevelFromExc(sz_conf, level, exc)
	--print();
	local conf = readTabFile(sz_conf);
	if conf then
		local maxExc = conf[level].maxExc;
		while exc >= maxExc do
			if conf[level+1] then
				exc = exc - maxExc;
				level = level + 1;

				maxExc = conf[level].maxExc;
			else
				exc = maxExc;
				break;
			end
		end
	end

	return level, exc;
end

function getMaxExc(sz_conf, level)
	local conf = readTabFile(sz_conf);
	if conf and conf[level] then
		return conf[level].maxExc;
	end

	return 0;
end

--[[
{maxHp=100000,maxMp=100,atk={{3,4},{10,100},{10,100}},
        dfs={10,10,10},strength=10, magic=10, aligity=10, taoistMagic=10, critRate=10,
        defenCrit=10, lucky=10, precise=10, dodge=10, }]]

readConf();
