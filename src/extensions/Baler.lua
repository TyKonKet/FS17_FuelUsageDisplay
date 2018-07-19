--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Baler:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("Baler extension loaded on %s", self.typeName)
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Baler.getPtoPowerMultiplier)
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Baler.getConsumedPtoTorque)
    end
end
Baler.postLoad = Utils.appendedFunction(Baler.postLoad, Baler.postPostLoad)

function Baler:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1
    if superFunc ~= nil then
        powerMultiplier = superFunc(self)
    end
    if self.baler.lastAreaBiggerZero then
        powerMultiplier = powerMultiplier + 1.2
    end
    return powerMultiplier
end

function Baler:getConsumedPtoTorque(superFunc)
    local torque = 0
    if superFunc ~= nil then
        torque = superFunc(self)
    end
    if self.pickupAnimationName ~= "" and self:getIsAnimationPlaying(self.pickupAnimationName) then
        torque = torque + (Utils.getMotorPowerPercentage(self, 0.15, 25) / (540 * math.pi / 30))
    end
    return torque
end
