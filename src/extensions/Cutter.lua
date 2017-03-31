--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Cutter:postLoad(savegame)
    BetterFuelUsage.print("Cutter extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Cutter.getPtoPowerMultiplier);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Cutter.getPtoRpm);
end

function Cutter:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.lastCutterAreaBiggerZero then
        powerMultiplier = powerMultiplier + 0.35;
    end
    if self:getCombine().chopperPSenabled then
        powerMultiplier = powerMultiplier + 0.3;
    end
    return powerMultiplier;
end

function Cutter:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.reelStarted and self.powerConsumer ~= nil then
        ptoRpm = math.max(ptoRpm, self.powerConsumer.ptoRpm);
    end
    return ptoRpm;
end
