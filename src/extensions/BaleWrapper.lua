--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 03/04/2017
function BaleWrapper:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("BaleWrapper extension loaded on %s", self.typeName);
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, BaleWrapper.getConsumedPtoTorque);
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, BaleWrapper.getPtoRpm);
    end
end
BaleWrapper.postLoad = Utils.appendedFunction(BaleWrapper.postLoad, BaleWrapper.postPostLoad);

function BaleWrapper:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.baleWrapperState ~= BaleWrapper.STATE_NONE and self.baleWrapperState ~= BaleWrapper.STATE_WRAPPER_FINSIHED then
        local power = 40;
        if self.currentWrapper.currentBale ~= nil then
            local bale = networkGetObject(self.currentWrapper.currentBale);
            if bale ~= nil then
                power = bale:getFillLevel() / 100;
            end
        end
        torque = torque + (power / (540 * math.pi / 30));
    end
    return torque;
end

function BaleWrapper:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.baleWrapperState ~= BaleWrapper.STATE_NONE and self.baleWrapperState ~= BaleWrapper.STATE_WRAPPER_FINSIHED then
        ptoRpm = math.max(ptoRpm, 540);
    end
    return ptoRpm;
end
