function initNetworkEvent()
	engine.addEventListenerWithScene(self, "SEND_MOVE_MESSAGE", function(event)
		local info = event.info;
        sendMoveMessage(info.id, info.isRun, info.dir);
    end);
end

function sendMoveMessage(id, isRun, dir)
	client:sendMessageWithRecall("ACTOR_MOVE", {isRun=isRun, dir=dir}, function(msg)
		if msg.ret == 0 then
			local backPos = msg.pos;
			local object = ActorManager:getActor(id);
			local map = object:getMap();

			object:setPosition(backPos.x*TILE_WIDTH, backPos.y*TILE_HEIGHT);
			map:sigalObjectPosition(object, backPos);

			--停止一切命令并待机
			object:unLockActorStatus();--lockStatus = false;
			object:stopAllActions();
			object:stopScripts();
			object:idle();

			self:updateMap();
		end
	end);
end

initNetworkEvent();
