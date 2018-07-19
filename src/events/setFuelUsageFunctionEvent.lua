--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 28/02/2017
SetFuelUsageFunctionEvent = {}
SetFuelUsageFunctionEvent_mt = Class(SetFuelUsageFunctionEvent, Event)

InitEventClass(SetFuelUsageFunctionEvent, "SetFuelUsageFunctionEvent")

function SetFuelUsageFunctionEvent:emptyNew()
    local self = Event:new(SetFuelUsageFunctionEvent_mt)
    return self
end

function SetFuelUsageFunctionEvent:new(default, vehicle)
    local self = SetFuelUsageFunctionEvent:emptyNew()
    self.default = default
    self.vehicle = vehicle
    return self
end

function SetFuelUsageFunctionEvent:writeStream(streamId, connection)
    streamWriteBool(streamId, self.default)
    writeNetworkNodeObject(streamId, self.vehicle)
end

function SetFuelUsageFunctionEvent:readStream(streamId, connection)
    self.default = streamReadBool(streamId)
    self.vehicle = readNetworkNodeObject(streamId)
    self:run(connection)
end

function SetFuelUsageFunctionEvent:run(connection)
    self.vehicle:setFuelUsageFunction(self.default)
end
