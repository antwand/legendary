Monster = class("Monster", function()
    return Actor:new()
end)

function Monster:ctor()
    self.statusEnum =
    {
        ["stand"]=1,
        ["walk"]=2,
        ["slash"]=3,
        ["hurt"]=4,
        ["die"]=5
    }
end

function Monster:getAllowRun()
    return false;
end

function Monster:changeIdleStatus()
end

function Monster:updateIdleStatus()
end
