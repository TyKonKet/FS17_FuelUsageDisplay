--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function Cylindered:postPostLoad(savegame)
    BetterFuelUsage.print("Cylindered extension loaded on " .. self.typeName);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Cylindered.getConsumedPtoTorque);
    self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Cylindered.getPtoRpm);
    self.movingToolsCount = 0;
end
Cylindered.postLoad = Utils.appendedFunction(Cylindered.postLoad, Cylindered.postPostLoad);

function Cylindered:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    torque = torque + (self.movingToolsCount * 20 / (540 * math.pi / 30));
    return torque;
end

function Cylindered:postUpdate(dt)
    if Cylindered.getIsEntered(self) then
        self.movingToolsCount = 0;
        for _, tool in pairs(self.movingTools) do
            if tool.axisActionIndex ~= nil then
                local move, _ = InputBinding.getInputAxis(tool.axisActionIndex);
                move = math.abs(move);
                if not InputBinding.isAxisZero(move) then
                    self.movingToolsCount = self.movingToolsCount + move;
                end
            end
        end
    end
end
Cylindered.update = Utils.appendedFunction(Cylindered.update, Cylindered.postUpdate);

function Cylindered:getPtoRpm(superFunc)
    local ptoRpm = 0;
    if superFunc ~= nil then
        ptoRpm = superFunc(self);
    end
    if self.movingToolsCount > 0 then
        ptoRpm = math.max(ptoRpm, 320 + 110 * self.movingToolsCount);
    end
    return ptoRpm;
end

function Cylindered:postReadUpdateStream(streamId, timestamp, connection)
     if not connection:getIsServer() then
        self.movingToolsCount = streamReadFloat32(streamId);
    end
end
Cylindered.readUpdateStream = Utils.appendedFunction(Cylindered.readUpdateStream, Cylindered.postReadUpdateStream);

function Cylindered:postWriteUpdateStream(streamId, connection, dirtyMask)
    if connection:getIsServer() then
        streamWriteFloat32(streamId, self.movingToolsCount);
    end
end
Cylindered.writeUpdateStream = Utils.appendedFunction(Cylindered.writeUpdateStream, Cylindered.postWriteUpdateStream);

function Cylindered.getIsEntered(v)
        if v.isEntered then
            return true;
        end
        if v.attacherVehicle ~= nil then
            return Cylindered.getIsEntered(v.attacherVehicle);
        end
        return false;
    end
