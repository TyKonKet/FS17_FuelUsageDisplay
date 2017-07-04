--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 28/03/2017
function TreeSaw:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("TreeSaw extension loaded on %s", self.typeName);
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, TreeSaw.getPtoPowerMultiplier);
    end
end
TreeSaw.postLoad = Utils.appendedFunction(TreeSaw.postLoad, TreeSaw.postPostLoad);

function TreeSaw:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.treeSaw.cutTimer > 0 then
        powerMultiplier = powerMultiplier + 2.5;
    end
    return powerMultiplier;
end
