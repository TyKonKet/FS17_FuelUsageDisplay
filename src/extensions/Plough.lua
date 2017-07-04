--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 04/04/2017
function Plough:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Plough.getConsumedPtoTorque);
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Plough.getPtoRpm);
        BetterFuelUsage.print("Plough extension loaded on %s", self.typeName);
    end
end
Plough.postLoad = Utils.appendedFunction(Plough.postLoad, Plough.postPostLoad);

function Plough:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.rotationPart.turnAnimation ~= nil and self:getIsAnimationPlaying(self.rotationPart.turnAnimation) then
        torque = torque + (Utils.getMotorPowerPercentage(self, 0.3, 50) / (540 * math.pi / 30));
    end
    return torque;
end

function Plough:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.rotationPart.turnAnimation ~= nil and self:getIsAnimationPlaying(self.rotationPart.turnAnimation) then
        ptoRpm = math.max(ptoRpm, 540);
    end
    return ptoRpm;
end
