--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function ForageWagon:postLoad(savegame)
    BetterFuelUsage.print("ForageWagon extension loaded on %s", self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, ForageWagon.getPtoPowerMultiplier);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, ForageWagon.getConsumedPtoTorque);
end

function ForageWagon:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if self.forageWagon.lastAreaBiggerZero then
        powerMultiplier = powerMultiplier + 0.55;
    end
    return powerMultiplier;
end

function ForageWagon:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.pickupAnimationName ~= "" and self:getIsAnimationPlaying(self.pickupAnimationName) then
        torque = torque + (Utils.getMotorPowerPercentage(self, 0.15, 25) / (540 * math.pi / 30));
    end
    return torque;
end
