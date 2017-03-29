--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 28/03/2017
function StumpCutter:postLoad(savegame)
    BetterFuelUsage.print("StumpCutter extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, StumpCutter.getPtoPowerMultiplier);
end

function StumpCutter:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.curSplitShape ~= nil then
        powerMultiplier = powerMultiplier + 2;
    end
    return powerMultiplier;
end
