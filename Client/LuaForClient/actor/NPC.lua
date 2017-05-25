NPC = class("NPC", function()
	return Actor:new();
end)

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

--方向 1...8 表示正向上顺时针旋转
--状�?.�? 表示站立,走路,跑步,挥砍,施法
local statusAniStep = 3 --每个状态同方向的动画之间间�?

function NPC:ctor()
	self.statusEnum =
    {
        ["stand"]=1,
        ["action"]=2,
    }

	self.dir = 1
	self.commands = {};
end

function NPC:init(conf)
	local tConf = talkConf[conf.talkId];
	--local commands = tConftb_content.tConf;
	for k,v in pairs(tConf.tb_content) do
		table.insert(self.commands, #self.commands+1,
			{funcType=v.funcType,funcStr=v.funcStr});
	end

	self:initUI();
	self.talkId = conf.talkId;
end

function NPC:request()
	engine.dispachEvent("UI_SHOW_TALKING_WINDOW", {npcId=self.id,talkId=self.talkId});
end

function NPC:initUI()
    if self.nameLabel == nil then
        self.nameLabel = engine.initLabel(self.name);
        self.nameLabel:retain();
    end

    self:updateUIStatus();
    self:updateUIPosition();
end
