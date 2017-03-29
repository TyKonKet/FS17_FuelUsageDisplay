--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function PowerConsumer:preLoad(savegame)
    assert(self.getPowerMultiplier == nil, "PowerConsumer needs to be the first specialization which implements getPowerMultiplier");
    self.getConsumedPtoTorque = PowerConsumer.getConsumedPtoTorque;
    self.getPtoRpm = PowerConsumer.getPtoRpm;
    self.getDoConsumePtoPower = PowerConsumer.getDoConsumePtoPower;
    self.getPowerMultiplier = PowerConsumer.getPowerMultiplier;
    self.getCanBeTurnedOn = Utils.overwrittenFunction(self.getCanBeTurnedOn, PowerConsumer.getCanBeTurnedOn);
    self.getIsTurnedOnAllowed = Utils.overwrittenFunction(self.getIsTurnedOnAllowed, PowerConsumer.getIsTurnedOnAllowed);
    self.getTurnedOnNotAllowedWarning = Utils.overwrittenFunction(self.getTurnedOnNotAllowedWarning, PowerConsumer.getTurnedOnNotAllowedWarning);
    self.getPtoPowerMultiplier = PowerConsumer.getPtoPowerMultiplier;
end

function PowerConsumer:postLoad()
    BetterFuelUsage.print("PowerConsumer extension loaded on " .. self.typeName);
    local m = 1.3;
    local mp = 1.4;
    --BetterFuelUsage.print(string.format("self.powerConsumer.maxForce:%s -> %s", self.powerConsumer.maxForce, self.powerConsumer.maxForce * m));
    self.powerConsumer.maxForce = self.powerConsumer.maxForce * m;
    --BetterFuelUsage.print(string.format("self.powerConsumer.forceFactor:%s -> %s", self.powerConsumer.forceFactor, self.powerConsumer.forceFactor * m));
    self.powerConsumer.forceFactor = self.powerConsumer.forceFactor * m;
    --BetterFuelUsage.print(string.format("self.powerConsumer.neededPtoPower:%s -> %s", self.powerConsumer.neededPtoPower, self.powerConsumer.neededPtoPower * mp));
    self.powerConsumer.neededPtoPower = self.powerConsumer.neededPtoPower * mp;
end

function PowerConsumer:getConsumedPtoTorque()
    if self:getDoConsumePtoPower() then
        local m = self:getPtoPowerMultiplier();
        if self.powerConsumer.ptoRpm > 0.001 then
            return self.powerConsumer.neededPtoPower / (self.powerConsumer.ptoRpm * math.pi / 30) * m;
        end
    end
    return 0;
end

function PowerConsumer:getPtoPowerMultiplier()
    return 0.8;
end
