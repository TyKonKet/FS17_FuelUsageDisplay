--
--Better Fuel Usage
--
--@author TyKonKet
--@date 29/03/2017
function Pipe:postPostLoad(savegame)
    BetterFuelUsage.print("Pipe extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Pipe.getConsumedPtoTorque);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Pipe.getPtoRpm);
end
Pipe.postLoad = Utils.appendedFunction(Pipe.postLoad, Pipe.postPostLoad);

function Pipe:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.pipeCurrentState == 0 then
        torque = torque + ((self.overloading.capacity / 8) / (540 * math.pi / 30));
    end
    return torque;
end

function Pipe:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.pipeCurrentState == 0 then
        ptoRpm = math.max(ptoRpm, 540);
    end
    return ptoRpm;
end
