--
--Better Fuel Usage
--
--@author TyKonKet
--@date 30/03/2017
function AttacherJoints:postPostLoad(savegame)
    BetterFuelUsage.print("AttacherJoints extension loaded on %s", self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, AttacherJoints.getConsumedPtoTorque);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, AttacherJoints.getPtoRpm);
end
AttacherJoints.postLoad = Utils.appendedFunction(AttacherJoints.postLoad, AttacherJoints.postPostLoad);

function AttacherJoints:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    for _, j in pairs(self.attacherJoints) do
        if j.moveAlpha ~= nil and j.moveAlpha ~= j.lowerAlpha and j.moveAlpha ~= j.upperAlpha then
            torque = torque + (30 / (540 * math.pi / 30));
        end
    end
    return torque;
end

function AttacherJoints:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    local movingJoints = 0;
    for _, j in pairs(self.attacherJoints) do
        if j.moveAlpha ~= nil and j.moveAlpha ~= j.lowerAlpha and j.moveAlpha ~= j.upperAlpha then
            movingJoints = movingJoints + 1;
        end
    end
    if movingJoints > 0 then
        ptoRpm = math.max(ptoRpm, 120 + 160 * movingJoints);
    end
    return ptoRpm;
end
