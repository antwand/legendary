BorderLabel = class("BorderLabel", function()
	local label = cc.Label:createWithSystemFont("", "", 12);
	label.setParentString = label.setString;
	label.setParentPosition = label.setPosition;
	return label;
end)

function BorderLabel:ctor()

end

function BorderLabel:setString(name)
	self:setParentString(name);

	if self.up then
		self.up:setString(name);
	end

	if self.left then
		self.left:setString(name);
	end

	if self.right then
		self.right:setString(name);
	end

	if self.down then
		self.down:setString(name);
	end
end

function BorderLabel:setFontSize(fontSize)
	self:setSystemFontSize(fontSize);

	if self.up then
		self.up:setSystemFontSize(fontSize);
	end

	if self.left then
		self.left:setSystemFontSize(fontSize);
	end

	if self.right then
		self.right:setSystemFontSize(fontSize);
	end

	if self.down then
		self.down:setSystemFontSize(fontSize);
	end
end

function BorderLabel:setPosition(x, y)
	self:setParentPosition(x, y);

	local size = self.size;

	if self.up then
		local labelSize = self.up:getContentSize();
		self.up:setPosition(labelSize.width*0.5, labelSize.height*0.5 + size);
	end

	if self.left then
		local labelSize = self.left:getContentSize();
		self.left:setPosition(labelSize.width*0.5 - size, labelSize.height*0.5);
	end

	if self.right then
		local labelSize = self.right:getContentSize();
		self.right:setPosition(labelSize.width*0.5 + size, labelSize.height*0.5);
	end

	if self.down then
		local labelSize = self.down:getContentSize();
		self.down:setPosition(labelSize.width*0.5, labelSize.height*0.5 - size);
	end
end

function BorderLabel:enableLabelOutline(color, fontSize, size)
	local name = self:getString();

	local up = cc.Label:createWithSystemFont(name, "", fontSize);
	local labelSize = up:getContentSize();

	--up:setAnchorPoint(0, 0);
	up:setColor(color);
	up:setPosition(labelSize.width*0.5, labelSize.height*0.5 + size);
	self:addChild(up, -1);

	local left = cc.Label:createWithSystemFont(name, "", fontSize);
	left:setPosition(labelSize.width*0.5 - size, labelSize.height*0.5);
	--left:setAnchorPoint(0, 0);
	left:setColor(color);
	self:addChild(left, -1);

	local right = cc.Label:createWithSystemFont(name, "", fontSize);
	right:setPosition(labelSize.width*0.5 + size, labelSize.height*0.5);
	--right:setAnchorPoint(0, 0);
	right:setColor(color);
	self:addChild(right, -1);

	local down = cc.Label:createWithSystemFont(name, "", fontSize);
	down:setPosition(labelSize.width*0.5, labelSize.height*0.5 - size);
	--down:setAnchorPoint(0, 0);
	down:setColor(color);
	self:addChild(down, -1);

	self.up = up;
	self.down = down;
	self.left = left;
	self.right = right;
	self.size = size;

	self:setSystemFontSize(fontSize);
end
