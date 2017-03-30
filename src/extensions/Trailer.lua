--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Trailer:postLoad(savegame)
    --BetterFuelUsage.print("Trailer extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, Trailer.getPtoPowerMultiplier);
    self.getDoConsumePtoPower = Utils.overwrittenFunction(self.getDoConsumePtoPower, Trailer.getDoConsumePtoPower);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Trailer.getConsumedPtoTorque);
end

function Trailer:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 0;
    if superFunc ~= nil then
        powerMultiplier = superFunc(self);
    end
    if powerMultiplier == PowerConsumer:getPtoPowerMultiplier() then
        powerMultiplier = 0;
    end
    if self.getIsTurnedOn ~= nil and self:getIsTurnedOn() then
        powerMultiplier = powerMultiplier + 1;
    end
    if (self.tipState == Trailer.TIPSTATE_OPENING) then
        powerMultiplier = powerMultiplier + Utils.lerp(0.05, 0.40, self:getUnitFillLevel(self.trailer.fillUnitIndex) / self:getUnitCapacity(self.trailer.fillUnitIndex));
    end
    if (self.tipState == Trailer.TIPSTATE_OPEN) then
        powerMultiplier = powerMultiplier + Utils.lerp(0, 0.35, self:getUnitFillLevel(self.trailer.fillUnitIndex) / self:getUnitCapacity(self.trailer.fillUnitIndex));
    end
    if (self.tipState == Trailer.TIPSTATE_CLOSING) then
        powerMultiplier = powerMultiplier + 0.05;
    end
    return powerMultiplier;
end

function Trailer:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    local power = self:getUnitCapacity(self.trailer.fillUnitIndex) / 200;
    if torque == 0 and (self.tipState == Trailer.TIPSTATE_OPENING or self.tipState == Trailer.TIPSTATE_CLOSING) then
        torque = torque + (20 + (80 *  self:getUnitFillLevel(self.trailer.fillUnitIndex) / self:getUnitCapacity(self.trailer.fillUnitIndex)) / (540 * math.pi / 30));
    end
    return torque;
end

function Trailer:getDoConsumePtoPower(superFunc)
    local r = false;
    if superFunc ~= nil then
        r = superFunc(self);
    end
    return r or self.tipState ~= Trailer.TIPSTATE_CLOSED;
end
