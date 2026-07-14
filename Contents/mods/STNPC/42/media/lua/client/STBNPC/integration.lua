function STBNPC_Client.GetTargetNPC(player)
    if not player then return nil end

    local square = player:getSquare()
    if not square then return nil end

    local objs = square:getMovingObjects()
    if not objs then return nil end

    for i = 0, objs:size() - 1 do
        local obj = objs:get(i)

        if obj and obj ~= player then
            if instanceof(obj, "IsoPlayer") then
                return obj
            end

            -- futuro suporte a NPC/bandit modded
            if obj.getModData and obj:getModData().brain then
                return obj
            end
        end
    end

    return nil
end