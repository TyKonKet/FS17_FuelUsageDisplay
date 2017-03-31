--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function Cylindered:postLoad(savegame)
    BetterFuelUsage.print("Cylindered extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Cylindered.getConsumedPtoTorque);
end

function Cylindered:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    for _, tool in pairs(self.movingTools) do
        if tool.axisActionIndex ~= nil then
            local move, _ = InputBinding.getInputAxis(tool.axisActionIndex);
            move = math.abs(move);
            if not InputBinding.isAxisZero(move) then
                torque = torque + (move * 20 / (540 * math.pi / 30));
            end
        end
    end
    return torque;
end
