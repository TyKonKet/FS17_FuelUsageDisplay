--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Baler:postPostLoad(savegame)
    BetterFuelUsage.print("Baler extension loaded on %s", self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Baler.getPtoPowerMultiplier);
end
Baler.postLoad = Utils.appendedFunction(Baler.postLoad, Baler.postPostLoad);

function Baler:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.baler.lastAreaBiggerZero then
        powerMultiplier = powerMultiplier + 0.8;
    end
    return powerMultiplier;
end
