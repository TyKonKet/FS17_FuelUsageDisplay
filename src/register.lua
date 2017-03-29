--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/10/2016
BetterFuelUsageRH = {};
BetterFuelUsageRH.name = "FuelUsageDisplayRH";
BetterFuelUsageRH.specialization = {};
BetterFuelUsageRH.specialization.title = "BetterFuelUsage";
BetterFuelUsageRH.specialization.name = "betterFuelUsage";
BetterFuelUsageRH.specialization.blackList = {conveyorTrailerHireable = true, conveyorTrailerDrivable = true, loadingTrailerDrivable = true};
BetterFuelUsageRH.debug = true;

function BetterFuelUsageRH:print(txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9)
    if self.debug then
        local args = {txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9};
        for i, v in ipairs(args) do
            if v then
                print("[" .. self.name .. "] -> " .. tostring(v));
            end
        end
    end
end

function BetterFuelUsageRH:registerSpecialization()
    local specialization = SpecializationUtil.getSpecialization(self.specialization.name);
    local powerConsumer = SpecializationUtil.getSpecialization("powerConsumer");
    for _, vehicleType in pairs(VehicleTypeUtil.vehicleTypes) do
        if vehicleType ~= nil then
            if specialization.prerequisitesPresent(vehicleType.specializations) and not self.specialization.blackList[vehicleType.name] then
                table.insert(vehicleType.specializations, specialization);
                self:print(self.specialization.title .. " added to " .. vehicleType.name);
            end
            if powerConsumer.prerequisitesPresent(vehicleType.specializations) and not SpecializationUtil.hasSpecialization(PowerConsumer, vehicleType.specializations) then
                table.insert(vehicleType.specializations, powerConsumer);
                self:print("PowerConsumer added to " .. vehicleType.name);
            end
        end
    end
end

function BetterFuelUsageRH:loadMap(name)
    if self.debug then
        addConsoleCommand("AAABFUToggleDebug", "", "FUToggleDebug", self);
        addConsoleCommand("AAAPrintVehicleValue", "", "PrintVehicleValue", self);
        addConsoleCommand("AAASetFuelFillLevel", "", "SetFuelFillLevel", self);
        addConsoleCommand("gsExportStoreItems", "Exports storeItem data", "consoleCommandExportStoreItems", g_currentMission);
        addConsoleCommand("gsStartBrandSale", "Starts a brand sale", "consoleStartBrandSale", g_currentMission);
        addConsoleCommand("gsStartVehicleSale", "Starts a vehicle sale", "consoleStartVehicleSale", g_currentMission);
        addConsoleCommand("gsStartGreatDemand", "Starts a great demand", "consoleStartGreatDemand", g_currentMission);
        addConsoleCommand("gsUpdateTipCollisions", "Updates the collisions for tipping on the ground around the current camera", "consoleCommandUpdateTipCollisions", g_currentMission);
        addConsoleCommand("gsTeleport", "Teleports to given field or x/z-position", "consoleCommandTeleport", g_currentMission);
        addConsoleCommand("gsActivateCameraPath", "Activate camera path", "consoleActivateCameraPath", g_currentMission);
    end
    g_currentMission.speedMeterRadiusX = g_currentMission.speedMeterRadiusX * 1.05;
    g_currentMission.speedMeterRadiusY = g_currentMission.speedMeterRadiusY * 1.05;
    g_currentMission.fuelLevelTextAlpha = 1;
    g_currentMission.fuelLevelTextAlphaDown = true;
    BetterFuelUsageRH:registerSpecialization();
end

function BetterFuelUsageRH:deleteMap()
end

function BetterFuelUsageRH:keyEvent(unicode, sym, modifier, isDown)
end

function BetterFuelUsageRH:mouseEvent(posX, posY, isDown, isUp, button)
end

function BetterFuelUsageRH:update(dt)
end

function BetterFuelUsageRH:draw()
end

function BetterFuelUsageRH.FUToggleDebug(self)
    self.debug = not self.debug;
    BetterFuelUsage.debug = self.debug;
    return "FUToggleDebug = " .. tostring(self.debug);
end

function BetterFuelUsageRH.PrintVehicleValue(self, ...)
    if g_currentMission.controlledVehicle == nil then
        return "controlledVehicle == nil";
    else
        local args = {...};
        local object = g_currentMission.controlledVehicle;
        for i, v in ipairs(args) do
            if tonumber(v) ~= nil then
                v = tonumber(v);
            end
            if i == #args then
                if object[v] == nil then
                    self:print(v .. " = nil");
                else
                    self:print(object[v]);
                end
            else
                object = object[v];
                if object == nil then
                    self:print(v .. " = nil");
                    break;
                end
            end
        end
    end
end

function BetterFuelUsageRH.SetFuelFillLevel(self, p1)
    if g_currentMission.controlledVehicle == nil then
        return "controlledVehicle == nil";
    else
        g_currentMission.controlledVehicle:setFuelFillLevel(tonumber(p1));
    end
end

addModEventListener(BetterFuelUsageRH);
