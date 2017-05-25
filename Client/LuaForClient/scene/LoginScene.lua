local LoginScene = class("LoginScene",function()
    return BaseScene:create()
end)

local port = 7991

function LoginScene.create()
    local scene = LoginScene.new()
    scene:createLayer()
    return scene
end


function LoginScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function LoginScene:playBgMusic()
end

-- create layer
function LoginScene:createLayer()
	CLIENT_TYPE = 2;

	self:initUI();
	self:initNetwork();
end
--[[
function LoginScene:initMessageWindow()
	local rootNode = require("ui/MessageWindow.lua").create();
    local window = rootNode['root'];
	self.window = window;
	self:addChild(window, 1);

	local size = cc.Director:getInstance():getWinSize();
	window:setPosition(size.width/2 - 492/2, size.height/2 - 202/2);
	window:setVisible(false);

	local Button = self.window:getChildByName("Button")
	Button:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			window:setVisible(false);
		end
	end);
end

function LoginScene:showMessage(str)
	local content = self.window:getChildByName("content")
	content:setString(str);
	self.window:setVisible(true);
end
]]
function LoginScene:initUI()
	local result = require("ui/LoginUI.lua").create();
    local rootNode = result['root'];
	--rootNode:setScale(800/1024, 600/768);
	self.rootNode = rootNode;
	self.rootNode:setPosition(-5, -40);
	self:addChild(rootNode);

	self.action = result['animation'];
	self.rootNode:runAction(self.action);
	self.action:gotoFrameAndPause(0);

	--local OpenDoor = self.rootNode:getChildByName("OpenDoor")
	local loginPanel = rootNode:getChildByName("LoginPanel")
	local AccountText = loginPanel:getChildByName("userText")
	local PasswordText = loginPanel:getChildByName("passText")
	local EnterBtn = loginPanel:getChildByName("enterBtn")
	local ip = "127.0.0.1"

	EnterBtn:addTouchEventListener(function(event, eventTouchType)
		if eventTouchType == ccui.TouchEventType.ended then
			local account = AccountText:getInputText();
			local password = PasswordText:getInputText();

			local function onSuccess()
				local account = {account=tostring(account), password=tostring(password)};

				client:sendMessageWithRecall("LOGIN_CHECK", account, function(msg)
					self:enterActorScene(msg);
				end);
			end

			client:addConnectEventListener(NETWORK_EVENT_CONNECT_SUCCESS, onSuccess);
			client:setOvertime(5);
			client:connect(ip, port);
        end
    end);

	self:initMessageWindow();
end

function LoginScene:showEnterAnimation(func)
	local loginPanel = self.rootNode:getChildByName("LoginPanel")
	loginPanel:setVisible(false);
	self.action:gotoFrameAndPlay(0,50,false);
	self.action:setFrameEventCallFunc(func);
end

function LoginScene:enterActorScene(data)
	if data.ret == 1 then  --succeed
		TraceError("Login Succeed actor data:"..tostringex(data));

		Account:init(data);

		self:showEnterAnimation(function(frame)
			local str = frame:getEvent();
			if str == "end" then
				local chrSel = ChrSelScene:new();

				for k,v in pairs(Account:getActorsData()) do
					chrSel:addChr(v, tonumber(k));
				end

				chrSel:selChr(1);
				cc.Director:getInstance():replaceScene(chrSel);
			end
		end)
	else
		--TraceError("Login Failed");
		self:showMessage("连接服务器失败,错误代码:"..data._error);
	end
end

function LoginScene:initNetwork()
	client = Client:new();

	local function onOvertime()
		self:showMessage("连接超时,请检查服务器参数");
	end

	--client:addConnectEventListener(NETWORK_EVENT_CLOSE, onClose);
	--client:addConnectEventListener(NETWORK_EVENT_DATA, onData);
	client:addConnectEventListener(NETWORK_EVENT_CONNECT_OVERTIME, onOvertime);

	client:addConnectEventListener(NETWORK_EVENT_CLOSE, function()
		Account:release();
		ActorManager:release();
		SkillManager:release();
		ItemManager:release();
		EffectManager:release();
	end);
end

return LoginScene
