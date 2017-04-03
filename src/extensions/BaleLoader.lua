--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 03/04/2017
function BaleLoader:postLoad(savegame)
    BetterFuelUsage.print("BaleLoader extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, BaleLoader.getConsumedPtoTorque);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, BaleLoader.getPtoRpm);
end

function BaleLoader:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.emptyState ~= BaleLoader.EMPTY_NONE and self.emptyState ~= BaleLoader.EMPTY_WAIT_TO_DROP and self.emptyState ~= BaleLoader.EMPTY_WAIT_TO_SINK and self.emptyState ~= BaleLoader.EMPTY_WAIT_TO_REDO then
        torque = torque + (200 / (980 * math.pi / 30));
    end
    if self.grabberMoveState ~= nil or self.frontBalePusherDirection ~= 0 or self.grabberIsMoving or self.rotatePlatformDirection ~= 0 or self:getIsAnimationPlaying("moveBalePlaces") then
        torque = torque + (75 / (540 * math.pi / 30));
    end
    return torque;
end

function BaleLoader:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.grabberMoveState ~= nil or self.frontBalePusherDirection ~= 0 or self.grabberIsMoving or self.rotatePlatformDirection ~= 0 or self:getIsAnimationPlaying("moveBalePlaces") then
        ptoRpm = math.max(ptoRpm, 540);
    end
    if self.emptyState ~= BaleLoader.EMPTY_NONE and self.emptyState ~= BaleLoader.EMPTY_WAIT_TO_DROP and self.emptyState ~= BaleLoader.EMPTY_WAIT_TO_SINK and self.emptyState ~= BaleLoader.EMPTY_WAIT_TO_REDO then
        ptoRpm = math.max(ptoRpm, 980);
    end
    return ptoRpm;
end
