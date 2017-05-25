ItemManager = {}
ItemManager.items = {}
ItemManager.bodys = {}

function ItemManager:addEquip(info)
    local equipConf = EquipmentConf[info.typeid];

	if not equipConf then
		print("no item:"..tostringex(info));
		return;
	end

    local item = nil;
	local createFunc = loadstring("return "..equipConf.sz_class..":new()")
    item = createFunc();
	item.data = info;
	item:retain();
	item:initAttribute(equipConf);
	item:setID(info.itemid);

	ItemManager.items[info.itemid] = item;

    return item;
end

function ItemManager:getBody(typeId, id)
	local body = Body:new();
	body:initSprite(typeId);
	body:setID(id);

	table.insert(ItemManager.bodys, #ItemManager.bodys+1, body);

	return body;
end

function ItemManager:getItem(data)
	if type(data) == "table" then
		return ItemManager:getItemForTable(data);
	elseif type(data) == "number" then
		return ItemManager:getItemForId(data);
	end

	return nil;
end

function ItemManager:getItemForTable(data)
	if ItemManager.items[data.itemid] then
		return ItemManager.items[data.itemid];
	end

	return ItemManager:addEquip(data);
end

function ItemManager:getItemForId(itemid)
	if ItemManager.items[itemid] then
		return ItemManager.items[itemid];
	end

	return nil;
end

function ItemManager:registEquip(item)
    table.insert(self.items, #self.items+1, item);
end

function ItemManager:release()
	for k,v in pairs(self.items) do
		v:release();
	end

	for k,v in pairs(self.bodys) do
		v:release();
	end

	ItemManager.items = {};
	ItemManager.bodys = {};
end

