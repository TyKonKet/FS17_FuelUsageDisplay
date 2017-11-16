--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function Trailer:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        --BetterFuelUsage.print("Trailer extension loaded on %s", self.typeName);
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Trailer.getConsumedPtoTorque);
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Trailer.getPtoRpm);
    end
end
Trailer.postLoad = Utils.appendedFunction(Trailer.postLoad, Trailer.postPostLoad);

function Trailer:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.tipState == Trailer.TIPSTATE_OPENING or self.tipState == Trailer.TIPSTATE_CLOSING or (#self.tipAnimations < 2 and self.tipState == Trailer.TIPSTATE_OPEN) then
        local power = self:getUnitCapacity(self.trailer.fillUnitIndex) / 200;
        local factor = self:getUnitFillLevel(self.trailer.fillUnitIndex) / self:getUnitCapacity(self.trailer.fillUnitIndex);
        torque = torque + ((5 + (power * factor)) / (760 * math.pi / 30));
    --    torque = torque + (self:getUnitCapacity(self.trailer.fillUnitIndex) / 500) / (760 * math.pi / 30));
    end
    return torque;
end

function Trailer:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.tipState == Trailer.TIPSTATE_OPENING or self.tipState == Trailer.TIPSTATE_CLOSING or (#self.tipAnimations < 2 and self.tipState == Trailer.TIPSTATE_OPEN) then
        local factor = self:getUnitFillLevel(self.trailer.fillUnitIndex) / self:getUnitCapacity(self.trailer.fillUnitIndex);
        ptoRpm = math.max(ptoRpm, 540 + 440 * factor);
    end
    return ptoRpm;
end
