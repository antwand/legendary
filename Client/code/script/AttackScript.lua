AttackScript = {}

function AttackScript:exec(from, to, attackInfo)
    local attack  = attackInfo.attack;
    local defense = to:getRandomDefense(attackInfo.type);
    local damage  = attack - defense;

    if damage <= 0 then
        damage = 1;
    end

    from:setAtkTarget(to:getID());
    to:getDamage(to:getID(), damage);
    to:updateUIStatus();
end