--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Windrower:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("Windrower extension loaded on %s", self.typeName);
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Windrower.getPtoPowerMultiplier);
    end
end
Windrower.postLoad = Utils.appendedFunction(Windrower.postLoad, Windrower.postPostLoad);

function Windrower:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    for _, ps in pairs(self.sortedWindrowerParticleSystems) do
        if ps.isEnabled then
            powerMultiplier = powerMultiplier + 0.3;
            break;
        end
    end
    return powerMultiplier;
end
