--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 02/05/2017
function TreePlanter:postLoad(savegame)
    BetterFuelUsage.print("TreePlanter extension loaded on %s", self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, TreePlanter.getPtoPowerMultiplier);
end

function TreePlanter:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.treePlanterHasGroundContact then
        powerMultiplier = powerMultiplier + 1.8;
    end
    return powerMultiplier;
end