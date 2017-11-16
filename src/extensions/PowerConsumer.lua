--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/03/2017
PowerConsumer.powerConsumerOverwrites = {};

function PowerConsumer.initSpecialization()
    local xml = loadXMLFile("powerConsumerOverwritesXML", BetterFuelUsage.dir .. "powerConsumerOverwrites.xml");
    local index = 0;
    while true do
        local query = string.format("powerConsumerOverwrites.vehicle(%d)", index);
        if not hasXMLProperty(xml, query) then
            break;
        end
        local xmlC = getXMLString(xml, string.format("%s#xml", query));
        local forceFactor = getXMLFloat(xml, string.format("%s#forceFactor", query));
        local maxForce = getXMLFloat(xml, string.format("%s#maxForce", query));
        local neededPtoPower = getXMLFloat(xml, string.format("%s#neededPtoPower", query));
        local ptoRpm = getXMLFloat(xml, string.format("%s#ptoRpm", query));
        PowerConsumer.powerConsumerOverwrites[xmlC] = {};
        PowerConsumer.powerConsumerOverwrites[xmlC].forceFactor = forceFactor;
        PowerConsumer.powerConsumerOverwrites[xmlC].maxForce = maxForce;
        PowerConsumer.powerConsumerOverwrites[xmlC].neededPtoPower = neededPtoPower;
        PowerConsumer.powerConsumerOverwrites[xmlC].ptoRpm = ptoRpm;
        BetterFuelUsage.print("powerConsumerOverwrite -> xml:%s, forceFactor:%s, maxForce:%s, neededPtoPower:%s, ptoRpm:%s", xmlC, forceFactor, maxForce, neededPtoPower, ptoRpm);
        index = index + 1;
    end
end

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
    PowerConsumer.getTotalConsumedPtoTorque = Utils.overwrittenFunction(PowerConsumer.getTotalConsumedPtoTorque, PowerConsumer.bfuGetTotalConsumedPtoTorque);
    PowerConsumer.getConsumedPtoTorque = Utils.overwrittenFunction(PowerConsumer.getConsumedPtoTorque, PowerConsumer.bfuGetConsumedPtoTorque);
end

function PowerConsumer:postLoad()
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("PowerConsumer extension loaded on %s", self.typeName);
        if PowerConsumer.powerConsumerOverwrites[Utils.clearXmlDirectory(self.configFileName)] ~= nil then
            local o = PowerConsumer.powerConsumerOverwrites[Utils.clearXmlDirectory(self.configFileName)];
            if o.forceFactor ~= nil then
                self.powerConsumer.forceFactor = o.forceFactor;
            end
            if o.maxForce ~= nil then
                self.powerConsumer.maxForce = o.maxForce;
            end
            if o.neededPtoPower ~= nil then
                self.powerConsumer.neededPtoPower = o.neededPtoPower;
            end
            if o.ptoRpm ~= nil then
                self.powerConsumer.ptoRpm = o.ptoRpm;
            end
        end
        local m = 1.2;
        local mp = 1.1;
        --BetterFuelUsage.print("self.powerConsumer.maxForce:%s -> %s", self.powerConsumer.maxForce, self.powerConsumer.maxForce * m);
        self.powerConsumer.maxForce = self.powerConsumer.maxForce * m;
        --BetterFuelUsage.print("self.powerConsumer.forceFactor:%s -> %s", self.powerConsumer.forceFactor, self.powerConsumer.forceFactor * m);
        self.powerConsumer.forceFactor = self.powerConsumer.forceFactor * m;
        --BetterFuelUsage.print("self.powerConsumer.neededPtoPower:%s -> %s", self.powerConsumer.neededPtoPower, self.powerConsumer.neededPtoPower * mp);
        self.powerConsumer.neededPtoPower = self.powerConsumer.neededPtoPower * mp;
    end
end

function PowerConsumer:bfuGetConsumedPtoTorque(superFunc)
    if not self.mrIsMrVehicle then
        if self:getDoConsumePtoPower() then
            local m = self:getPtoPowerMultiplier();
            if self.powerConsumer.ptoRpm > 0.001 then
                return self.powerConsumer.neededPtoPower / (self.powerConsumer.ptoRpm * math.pi / 30) * m;
            end
        end
        return 0;
    else
        if superFunc ~= nil then
            return superFunc(self);
        else
            return 0;
        end
    end
end

function PowerConsumer:getPtoPowerMultiplier()
    return 1;
end

function PowerConsumer.bfuGetTotalConsumedPtoTorque(self, superFunc, excludeVehicle)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self, excludeVehicle);
    end
    --torque = math.min(torque, Utils.getMaxMotorTorque(self) * 0.9);
    return torque;
end
