--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function ForageWagon:postLoad(savegame)
    BetterFuelUsage.print("ForageWagon extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, ForageWagon.getPtoPowerMultiplier);
end

function ForageWagon:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.forageWagon.lastAreaBiggerZero then
        powerMultiplier = powerMultiplier + 0.50;
    end
    return powerMultiplier;
end
