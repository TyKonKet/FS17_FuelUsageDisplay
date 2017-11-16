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
        local power = Utils.getMotorPowerPercentage(self, 0.3, 30);
        local factor = self:getUnitFillLevel(self.trailer.fillUnitIndex) / self:getUnitCapacity(self.trailer.fillUnitIndex);
        if self.tipState == Trailer.TIPSTATE_CLOSING then
            factor = 0;
        end
        torque = torque + ((power / 10 + power * factor) / (650 * math.pi / 30));
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
        if self.tipState == Trailer.TIPSTATE_CLOSING then
            factor = 0;
        end
        ptoRpm = math.max(ptoRpm, 320 + 330 * factor);
    end
    return ptoRpm;
end
