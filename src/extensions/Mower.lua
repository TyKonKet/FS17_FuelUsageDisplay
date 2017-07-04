--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Mower:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("Mower extension loaded on %s", self.typeName);
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Mower.getPtoPowerMultiplier);
    end
end
Mower.postLoad = Utils.appendedFunction(Mower.postLoad, Mower.postPostLoad);

function Mower:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    local mowerEffectActive = false;
    for _, mowerEffect in pairs(self.mower.effects) do
        if mowerEffect.isActive then
            mowerEffectActive = true;
            break;
        end
    end
    if mowerEffectActive then
        powerMultiplier = powerMultiplier + 0.55;
    end
    return powerMultiplier;
end
