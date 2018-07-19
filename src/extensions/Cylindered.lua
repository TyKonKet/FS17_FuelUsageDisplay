--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 29/03/2017
function Cylindered:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Cylindered.getConsumedPtoTorque)
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Cylindered.getPtoRpm)
        self.movingToolsCount = 0
        BetterFuelUsage.print("Cylindered extension loaded on %s", self.typeName)
    end
end
Cylindered.postLoad = Utils.appendedFunction(Cylindered.postLoad, Cylindered.postPostLoad)

function Cylindered:getConsumedPtoTorque(superFunc)
    local torque = 0
    if superFunc ~= nil then
        torque = superFunc(self)
    end
    if not Utils.gearboxActive(self) then
        torque = torque + (self.movingToolsCount * Utils.getMotorPowerPercentage(self, 0.05, 5) / (540 * math.pi / 30))
    end
    return torque
end

function Cylindered:getPtoRpm(superFunc)
    local ptoRpm = 0
    if superFunc ~= nil then
        ptoRpm = superFunc(self)
    end
    if not Utils.gearboxActive(self) then
        if self.movingToolsCount > 0 then
            ptoRpm = math.max(ptoRpm, 320 + 110 * self.movingToolsCount)
        end
    end
    return ptoRpm
end

function Cylindered:postUpdate(dt)
    if not self.mrIsMrVehicle then
        if Utils.getIsEntered(self) then
            self.movingToolsCount = 0
            for _, tool in pairs(self.movingTools) do
                if tool.axisActionIndex ~= nil then
                    local move, _ = InputBinding.getInputAxis(tool.axisActionIndex)
                    move = math.abs(move)
                    tool.currentMove = 0
                    if not InputBinding.isAxisZero(move) then
                        self.movingToolsCount = self.movingToolsCount + move
                        tool.currentMove = move
                    end
                    if tool.currentMove ~= tool.lastMove then
                        tool.lastMove = tool.currentMove
                        Cylindered.setDirty(self, tool)
                        self:raiseDirtyFlags(self.cylinderedDirtyFlag)
                    end
                end
            end
        end
    end
end

function Cylindered:postReadUpdateStream(streamId, timestamp, connection)
    if not self.mrIsMrVehicle then
        if not connection:getIsServer() then
            self.movingToolsCount = streamReadFloat32(streamId)
        end
    end
end
Cylindered.readUpdateStream = Utils.appendedFunction(Cylindered.readUpdateStream, Cylindered.postReadUpdateStream)

function Cylindered:postWriteUpdateStream(streamId, connection, dirtyMask)
    if not self.mrIsMrVehicle then
        if connection:getIsServer() then
            streamWriteFloat32(streamId, self.movingToolsCount or 0)
        end
    end
end
Cylindered.writeUpdateStream = Utils.appendedFunction(Cylindered.writeUpdateStream, Cylindered.postWriteUpdateStream)
