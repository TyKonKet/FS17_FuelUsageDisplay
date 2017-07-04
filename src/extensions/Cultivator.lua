--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Cultivator:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("Cultivator extension loaded on %s", self.typeName);
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Cultivator.getPtoPowerMultiplier);
    end
end
Cultivator.postLoad = Utils.appendedFunction(Cultivator.postLoad, Cultivator.postPostLoad);

function Cultivator:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.cultivatorHasGroundContact then
        powerMultiplier = powerMultiplier + 0.4;
    end
    return powerMultiplier;
end
