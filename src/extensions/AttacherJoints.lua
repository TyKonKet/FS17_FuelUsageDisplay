--
--Better Fuel Usage
--
--@author TyKonKet
--@date 30/03/2017
function AttacherJoints:postPostLoad(savegame)
    BetterFuelUsage.print("AttacherJoints extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, AttacherJoints.getConsumedPtoTorque);
end
AttacherJoints.postLoad = Utils.appendedFunction(AttacherJoints.postLoad, AttacherJoints.postPostLoad);

function AttacherJoints:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    for _, j in pairs(self.attacherJoints) do
        if j.moveAlpha ~= nil and j.moveAlpha ~= 0 and j.moveAlpha ~= 1 then
            --torque = torque + (30 / (540 * math.pi / 30));
        end
    end
    return torque;
end
