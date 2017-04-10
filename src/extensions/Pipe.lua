--
--Better Fuel Usage
--
--@author TyKonKet
--@date 29/03/2017
function Pipe:postPostLoad(savegame)
    BetterFuelUsage.print("Pipe extension loaded on %s", self.typeName);
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
        torque = torque + ((self.overloading.capacity / 8) / (430 * math.pi / 30));
    end
    if self:getOverloadingActive() then
        torque = torque + ((self.overloading.capacity / 5) / (755 * math.pi / 30));
    end
    return torque;
end

function Pipe:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.pipeCurrentState == 0 then
        ptoRpm = math.max(ptoRpm, 430);
    end
    if self:getOverloadingActive() then
        if self.threshingScale ~= nil then
            ptoRpm = math.max(ptoRpm, 530);
        else
            ptoRpm = math.max(ptoRpm, 980);
        end
    end
    return ptoRpm;
end
