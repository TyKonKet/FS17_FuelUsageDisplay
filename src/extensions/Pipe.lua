--
--Better Fuel Usage
--
--@author TyKonKet
--@date 29/03/2017
function Pipe:postPostLoad(savegame)
    BetterFuelUsage.print("Pipe extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Pipe.getConsumedPtoTorque);
end
Pipe.postLoad = Utils.appendedFunction(Pipe.postLoad, Pipe.postPostLoad);

function Pipe:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.pipeCurrentState == 0 then
        torque = torque + ((self.overloading.capacity / 5) / (540 * math.pi / 30));
    end
    return torque;
end
