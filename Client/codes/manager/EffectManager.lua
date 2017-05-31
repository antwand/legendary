EffectManager = {}

function EffectManager:getEffect(id)
	if id <= 0 then
		return;
	end

    if spriteConf[id] == nil then
        TraceError(id.." effect no found");
        return;
    end

    return engine.readASprite(id);
end

function EffectManager:release()

end
