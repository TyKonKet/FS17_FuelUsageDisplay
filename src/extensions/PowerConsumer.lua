--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
function PowerConsumer:postLoad(savegame)
    local m = 1.25;
    local mp = 2;
    BetterFuelUsage.print(string.format("self.powerConsumer.maxForce:%s -> %s", self.powerConsumer.maxForce, self.powerConsumer.maxForce * m));
    self.powerConsumer.maxForce = self.powerConsumer.maxForce * m;
    BetterFuelUsage.print(string.format("self.powerConsumer.forceFactor:%s -> %s", self.powerConsumer.forceFactor, self.powerConsumer.forceFactor * m));
    self.powerConsumer.forceFactor = self.powerConsumer.forceFactor * m;
    BetterFuelUsage.print(string.format("self.powerConsumer.neededPtoPower:%s -> %s", self.powerConsumer.neededPtoPower, self.powerConsumer.neededPtoPower * mp));
    self.powerConsumer.neededPtoPower = self.powerConsumer.neededPtoPower * mp;
end
