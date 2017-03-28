--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Trailer:postLoad(savegame)
    --BetterFuelUsage.print("Trailer extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Trailer.getPtoPowerMultiplier);
    self.getDoConsumePtoPower = Utils.overwrittenFunction(self.getDoConsumePtoPower, Trailer.getDoConsumePtoPower);
end

function Trailer:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if (self.tipState == Trailer.TIPSTATE_OPENING or self.tipState == Trailer.TIPSTATE_CLOSING) and (self.getIsTurnedOn ~= nil and self:getIsTurnedOn()) then
        powerMultiplier = powerMultiplier + 0.25;
    end
    BetterFuelUsage.print("powerMultiplier " .. powerMultiplier);
    return powerMultiplier;
end

function Trailer:getDoConsumePtoPower(superFunc)
    local r = false;
    if superFunc ~= nil then
        r = superFunc(self);
    end
    return r or self.tipState ~= Trailer.TIPSTATE_CLOSED;
end
