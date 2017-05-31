BloodVial = class("BloodVial", function()
    return Item:new();
end)

function BloodVial:ctor()
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
