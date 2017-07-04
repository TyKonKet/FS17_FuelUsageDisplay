--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function WoodHarvester:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("WoodHarvester extension loaded on %s", self.typeName);
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, WoodHarvester.getConsumedPtoTorque);
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, WoodHarvester.getPtoRpm);
    end
end
WoodHarvester.postLoad = Utils.appendedFunction(WoodHarvester.postLoad, WoodHarvester.postPostLoad);

function WoodHarvester:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self:getIsTurnedOn() then
        torque = torque + ((100 * self.cutMaxRadius) / (540 * math.pi / 30));
        if self.cutParticleSystemsActive then
            torque = torque + ((400 * self.cutMaxRadius) / (980 * math.pi / 30));
        elseif self.isAttachedSplitShapeMoving then
            torque = torque + ((300 * self.cutMaxRadius) / (980 * math.pi / 30));
        end
    end
    return torque;
end

function WoodHarvester:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self:getIsTurnedOn() then
        ptoRpm = math.max(ptoRpm, 540);
        if self.cutParticleSystemsActive or self.isAttachedSplitShapeMoving then
            ptoRpm = math.max(ptoRpm, 980);
        end
    end
    return ptoRpm;
end
