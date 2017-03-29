--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 28/03/2017
function TreeSaw:postLoad(savegame)
    BetterFuelUsage.print("TreeSaw extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, TreeSaw.getPtoPowerMultiplier);
end

function TreeSaw:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.treeSaw.cutTimer > 0 then
        powerMultiplier = powerMultiplier + 2.75;
    end
    return powerMultiplier;
end
