--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function Overloading:postLoad(savegame)
    BetterFuelUsage.print("Overloading extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Overloading.getConsumedPtoTorque);
end

function Overloading:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.overloading.didOverload then
        torque = torque + (100 / (540 * math.pi / 30));
    end
    return torque;
end
