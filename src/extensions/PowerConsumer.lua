--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function PowerConsumer:postLoad(savegame)
    BetterFuelUsage.print("PowerConsumer extension loaded on " .. self.typeName);
    self.getPtoPowerMultiplier = PowerConsumer.getPtoPowerMultiplier;
    local m = 1.25;
    local mp = 1.5;
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
    return 1;
end
