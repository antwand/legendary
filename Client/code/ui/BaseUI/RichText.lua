RichText = class("RichText", function()
    return ccui.Layout:create()
end)

function RichText:ctor()
	self.currNoticeItemIndex = 0;
	self.upperBoundary = 0;
	self.lowerBoundary = 0;
	self.leftBoundary = 0;
	self.startX = 0;
	self:setBackGroundColorOpacity(102)
end

function RichText:insertString(str, fontSize, color, isWrap, funcType, funcStr, commandIdx, callfunc)
	color = color or {r=255, g=255, b=255};

	local label = self:createLabel(str, fontSize, color);
	self:addItem(label, isWrap);

	--print(str.."   func:"..tostringex(callfunc));

	if callfunc then
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			if eventTouchType == ccui.TouchEventType.ended then
				label:setColor({r = color.r, g = color.g, b = color.b});

				callfunc(funcType, funcStr, commandIdx);
			end

			if eventTouchType == ccui.TouchEventType.moved then
			end

			if eventTouchType == ccui.TouchEventType.began then
				label:setColor({r = 255, g = 0, b = 0});
			end
		end);
	end
end

function RichText:insertImage(str, isWrap, funcType, funcStr, commandIdx, callfunc)
	local image = ccui.ImageView:create();

	if image then
		image:loadTexture(str);
		self:addItem(image, isWrap);

		if callfunc then
			image:addTouchEventListener(function(event, eventTouchType)
				if eventTouchType == ccui.TouchEventType.ended then
					callfunc(funcType, funcStr, commandIdx);
				end

				if eventTouchType == ccui.TouchEventType.moved then
				end

				if eventTouchType == ccui.TouchEventType.began then
				end
			end);
		end
	end
end

function RichText:addItem(item, isWrap)
	local size = item:getContentSize();
	local parentSize = self:getLayoutSize();

	item:setPosition(self.startX + self.leftBoundary, parentSize.height - size.height - self.lowerBoundary);
	self:addChild(item);

	if isWrap then
		self.lowerBoundary = self.lowerBoundary + size.height;
		self.leftBoundary = 0;
	else
		self.leftBoundary = self.leftBoundary + size.width;
	end
end

function RichText:clear()
	self:removeAllChildren();
	self.currNoticeItemIndex = 0;
	self.upperBoundary = 0;
	self.lowerBoundary = 0;
	self.leftBoundary = 0;
	self.startX = 0;
end

function RichText:createLabel(str, fontSize, color, callfunc)
	local fColor = color or {r=255, g=255, b=255};
	local fSize = fontSize or 14;

	local title = BorderText:new();
	--title:setLineBreakWithoutSpace(true);
	title:ignoreContentAdaptWithSize(false)
	--title:setFontName("fonts/W2.ttf")
	title:setFontSize(fSize)
	title:setString(str)
	title:setColor({r = fColor.r, g = fColor.g, b = fColor.b});
	title:setTextColor({r = fColor.r, g = fColor.g, b = fColor.b});
	title:enableLabelOutline({r=0, g= 0, b=0}, 1);
	title:setAnchorPoint(0, 0);

	local size = title:getAutoRenderSize();
	local parentSize = self:getLayoutSize();

	if size.width > parentSize.width then
		local width = parentSize.width;
		local extraHeight = (size.width - parentSize.width) / parentSize.width;
		local scaleY = math.ceil(extraHeight);

		title:setContentSize(width, size.height + scaleY * size.height);
	else
		title:setContentSize(size.width, size.height);
	end

	title:updateContentSize();

	return title;
end
