--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Cutter:postLoad(savegame)
    BetterFuelUsage.print("Cutter extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Cutter.getPtoPowerMultiplier);
end

function Cutter:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.lastCutterAreaBiggerZero then
        powerMultiplier = powerMultiplier + 0.3;
    end
    BetterFuelUsage.print("powerMultiplier " .. powerMultiplier);
    return powerMultiplier;
end
