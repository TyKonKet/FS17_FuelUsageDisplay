--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Tedder:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("Tedder extension loaded on %s", self.typeName);
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Tedder.getPtoPowerMultiplier);
    end
end
Tedder.postLoad = Utils.appendedFunction(Tedder.postLoad, Tedder.postPostLoad);

function Tedder:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    for _, ps in pairs(self.tedderParticleSystems) do
        if ps.isEnabled then
            powerMultiplier = powerMultiplier + 0.3;
            break;
        end
    end
    return powerMultiplier;
end
