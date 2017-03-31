--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function Overloading:postLoad(savegame)
    BetterFuelUsage.print("Overloading extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Overloading.getConsumedPtoTorque);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Overloading.getPtoRpm);
end

function Overloading:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.overloading.didOverload then
        torque = torque + ((self.overloading.capacity / 5) / (870 * math.pi / 30));
    end
    return torque;
end

function Overloading:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.overloading.didOverload then
        ptoRpm = math.max(ptoRpm, 870);
    end
    return ptoRpm;
end
