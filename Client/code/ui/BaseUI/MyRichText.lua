MyRichText = class("MyRichText", function()
    return ccui.ListView:create();
end)

function MyRichText:ctor()
	self.currNoticeItemIndex = 0;
	self.textBackColor = {r = 255, g = 0, b = 0}
end

function MyRichText:createLayerColor(label, width, height, color)
	local layer = ccui.Layout:create();

	layer:setContentSize(width, height);
	layer:setBackGroundColorType(1);
	layer:setBackGroundColor(color or self.textBackColor);
	layer:addChild(label);

	return layer;
end

function MyRichText:setTextBackColor(color)
	self.textBackColor = color;
end

function MyRichText:insertString(str, fontSize, color, callfunc)
	local label, width, height = self:createLabel(str, 12, color);
	label:setAnchorPoint(0, 0);

	if self.textBackColor then
		local layer = self:createLayerColor(label, width, height);
		self:insertCustomItem(layer, self.currNoticeItemIndex);
	else
		self:insertCustomItem(label, self.currNoticeItemIndex);
	end

	self.currNoticeItemIndex = self.currNoticeItemIndex + 1;

	self:jumpToPercentVertical(100);

	if callfunc then
		label:setTouchEnabled(true)
		label:addTouchEventListener(function(event, eventTouchType)
			if eventTouchType == ccui.TouchEventType.ended then
				callfunc();
			end

			if eventTouchType == ccui.TouchEventType.moved then
			end

			if eventTouchType == ccui.TouchEventType.began then
			end
		end);
	end
end

function MyRichText:insertImage(str, callfunc)
	local image = ccui.ImageView:create();

	if image then
		image:loadTexture(str);
		self:insertCustomItem(image, self.currNoticeItemIndex);

		self.currNoticeItemIndex = self.currNoticeItemIndex + 1;

		if callfunc then
			image:addTouchEventListener(function(event, eventTouchType)
				if eventTouchType == ccui.TouchEventType.ended then
					callfunc();
				end

				if eventTouchType == ccui.TouchEventType.moved then
				end

				if eventTouchType == ccui.TouchEventType.began then
				end
			end);
		end
	end
end

function MyRichText:createLabel(str, fontSize, color, callfunc)
	local fColor = color or {r=255, g=255, b=255};
	local fSize = fontSize or 10;

	local title = ccui.Text:create()
	title:ignoreContentAdaptWithSize(false)
	--title:setFontName("fonts/blackSingle.ttf")
	title:setFontSize(fSize)
	title:setString(str)
	title:setColor({r = fColor.r, g = fColor.g, b = fColor.b});
	title:setTextColor({r = fColor.r, g = fColor.g, b = fColor.b});
	title:setTextHorizontalAlignment(0)
	--title:enableShadow({r = fColor.r, g = fColor.g, b = fColor.b, a = 255}, {width = 1, height = -1}, 0)
	--title:enableOutline({r = 0, g = 0, b = 0, a = 255}, 1)
	--title:enableOutline({r = fColor.r, g = fColor.g, b = fColor.b, a = 255}, 1)
	title:setAnchorPoint(0, 0);

	local size = title:getAutoRenderSize();
	local parentSize = self:getLayoutSize();

	local extraHeight = (size.width - parentSize.width) / parentSize.width;
	if extraHeight < 0 then
		extraHeight = 0;
	end

	title:setContentSize(parentSize.width, size.height + math.ceil(extraHeight) * size.height);

	return title, size.width, size.height + math.ceil(extraHeight) * size.height;
end

--[[
function MyRichText:jumpToPercentVertical(pec)
	--local listView = self.rootNode:getChildByName("NoticeWindow")
	self:jumpToPercentVertical(100);
end]]
