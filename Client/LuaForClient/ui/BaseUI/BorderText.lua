BorderText = class("BorderText", function()
	local label = ccui.Text:create();
	label.setParentString = label.setString;
	label.setParentPosition = label.setPosition;
	label.setParentFontSize = label.setFontSize;
	label.parentIgnoreContentAdaptWithSize = label.ignoreContentAdaptWithSize;
	label.setParentAnchorPoint = label.setAnchorPoint;
	label.setParentContentSize = label.setContentSize;
	label.setParentTextHorizontalAlignment = label.setTextHorizontalAlignment;
	return label;
end)

function BorderText:ctor()

end

function BorderText:setTextHorizontalAlignment(param)
	self:setParentTextHorizontalAlignment(param);

	if self.up then
		self.up:setTextHorizontalAlignment(param);
	end

	if self.left then
		self.left:setTextHorizontalAlignment(param);
	end

	if self.right then
		self.right:setTextHorizontalAlignment(param);
	end

	if self.down then
		self.down:setTextHorizontalAlignment(param);
	end

	self.HorizontalAlignment = param;
end

function BorderText:setFontSize(str)
	self:setParentFontSize(str);

	if self.up then
		self.up:setFontSize(str);
	end

	if self.left then
		self.left:setFontSize(str);
	end

	if self.right then
		self.right:setFontSize(str);
	end

	if self.down then
		self.down:setFontSize(str);
	end
end

function BorderText:setString(str)
	self:setParentString(str);

	if self.up then
		self.up:setString(str);
	end

	if self.left then
		self.left:setString(str);
	end

	if self.right then
		self.right:setString(str);
	end

	if self.down then
		self.down:setString(str);
	end
end

function BorderText:ignoreContentAdaptWithSize(enable)
	self:parentIgnoreContentAdaptWithSize(enable);

	if self.up then
		self.up:ignoreContentAdaptWithSize(enable);
	end

	if self.left then
		self.left:ignoreContentAdaptWithSize(enable);
	end

	if self.right then
		self.right:ignoreContentAdaptWithSize(enable);
	end

	if self.down then
		self.down:ignoreContentAdaptWithSize(enable);
	end

	self.adaptWithSize = enable;
end

function BorderText:setAnchorPoint(x, y)
	self:setParentAnchorPoint(x, y);
end

function BorderText:setContentSize(x, y)
	self:setParentContentSize(x, y);

	if self.up then
		self.up:setContentSize(x, y);
	end

	if self.left then
		self.left:setContentSize(x, y);
	end

	if self.right then
		self.right:setContentSize(x, y);
	end

	if self.down then
		self.down:setContentSize(x, y);
	end
end

function BorderText:updateContentSize()
	local size = self:getContentSize();

	if self.up then
		self.up:setContentSize(size.width, size.height);
	end

	if self.left then
		self.left:setContentSize(size.width, size.height);
	end

	if self.right then
		self.right:setContentSize(size.width, size.height);
	end

	if self.down then
		self.down:setContentSize(size.width, size.height);
	end
end

function BorderText:setPosition(x, y)
	self:setParentPosition(x, y);
end

function BorderText:enableLabelOutline(color, size)
	color.a = nil;
	fSize = self:getFontSize();
	size = size or 1;

	local name = self:getString();
	local point = {x=0,y=0}--self:getAnchorPoint();

	local up = ccui.Text:create();
	up:setFontSize(fSize);
	up:setString(name);
	local labelSize = self:getContentSize();

	up:setAnchorPoint(point.x, point.y);
	up:setColor(color);
	up:setPosition(0, size);
	self:addChild(up, -1);

	local left = ccui.Text:create();
	left:setPosition(-size, 0);
	left:setAnchorPoint(point.x, point.y);
	left:setColor(color);
	left:setFontSize(fSize);
	left:setString(name);
	self:addChild(left, -1);

	local right = ccui.Text:create();
	right:setPosition(size, 0);
	right:setAnchorPoint(point.x, point.y);
	right:setColor(color);
	right:setFontSize(fSize);
	right:setString(name);
	self:addChild(right, -1);

	local down = ccui.Text:create();
	down:setPosition(0, - size);
	down:setAnchorPoint(point.x, point.y);
	down:setColor(color);
	down:setFontSize(fSize);
	down:setString(name);
	self:addChild(down, -1);

	up:setContentSize(labelSize.width, labelSize.height);
	left:setContentSize(labelSize.width, labelSize.height);
	right:setContentSize(labelSize.width, labelSize.height);
	down:setContentSize(labelSize.width, labelSize.height);

	self.up = up;
	self.down = down;
	self.left = left;
	self.right = right;
	self.size = size;

	self:setFontSize(fSize);

	local param = self.HorizontalAlignment;

	if param then
		self.up:setTextHorizontalAlignment(param);
		self.left:setTextHorizontalAlignment(param);
		self.right:setTextHorizontalAlignment(param);
		self.down:setTextHorizontalAlignment(param);
	end

	if self.adaptWithSize == true or self.adaptWithSize == false then
		self.up:ignoreContentAdaptWithSize(self.adaptWithSize);
		self.left:ignoreContentAdaptWithSize(self.adaptWithSize);
		self.right:ignoreContentAdaptWithSize(self.adaptWithSize);
		self.down:ignoreContentAdaptWithSize(self.adaptWithSize);
	end
end
