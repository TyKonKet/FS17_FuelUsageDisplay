--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 04/04/2017
function Plough:postPostLoad(savegame)
    BetterFuelUsage.print("Plough extension loaded on %s", self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Plough.getConsumedPtoTorque);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Plough.getPtoRpm);
end
Plough.postLoad = Utils.appendedFunction(Plough.postLoad, Plough.postPostLoad);

function Plough:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    local power = 20;
    if self.foldAnimPartsCount ~= nil and self.foldAnimPartsCount > 0 then
        power = 7.5 * self.foldAnimPartsCount;
    end
    if self.rotationPart.turnAnimation ~= nil and self:getIsAnimationPlaying(self.rotationPart.turnAnimation) then
        torque = torque + (power / (540 * math.pi / 30));
    end
    return torque;
end

function Plough:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.rotationPart.turnAnimation ~= nil and self:getIsAnimationPlaying(self.rotationPart.turnAnimation) then
        ptoRpm = math.max(ptoRpm, 540);
    end
    return ptoRpm;
end
