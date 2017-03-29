--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function WoodHarvester:postLoad(savegame)
    BetterFuelUsage.print("WoodHarvester extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, WoodHarvester.getConsumedPtoTorque);
end

function WoodHarvester:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self:getIsTurnedOn() then
        torque = torque + (60 / (540 * math.pi / 30));
        if self.cutParticleSystemsActive then
            torque = torque + (80 / (540 * math.pi / 30));
        elseif self.isAttachedSplitShapeMoving then
            torque = torque + (100 / (540 * math.pi / 30));
        end
    end
    return torque;
end
