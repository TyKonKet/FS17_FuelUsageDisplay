--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function ForageWagon:postLoad(savegame)
    BetterFuelUsage.print("ForageWagon extension loaded on %s", self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, ForageWagon.getPtoPowerMultiplier);
end

function ForageWagon:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.forageWagon.lastAreaBiggerZero then
        powerMultiplier = powerMultiplier + 0.55;
    end
    return powerMultiplier;
end
