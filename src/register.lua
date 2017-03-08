--
-- BetterFuelUsage
--
-- @author  TyKonKet
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
    for _, vehicleType in pairs(VehicleTypeUtil.vehicleTypes) do
        if vehicleType ~= nil then
            if specialization.prerequisitesPresent(vehicleType.specializations) and not self.specialization.blackList[vehicleType.name] then
                table.insert(vehicleType.specializations, specialization);
                self:print(self.specialization.title .. " added to " .. vehicleType.name);
            end
        end
    end
end

function BetterFuelUsageRH:loadMap(name)
    if self.debug then
        addConsoleCommand("AAABFUToggleDebug", "", "FUToggleDebug", self);
        addConsoleCommand("AAAPrintVehicleValue", "", "PrintVehicleValue", self);
    end
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
    return "FUToggleDebug = " ..  tostring(self.debug);
end

function BetterFuelUsageRH.PrintVehicleValue(self, p1)
    if g_currentMission.controlledVehicle == nil then
        return "controlledVehicle == nil";
    else
        self:print(tostring(g_currentMission.controlledVehicle[p1]));
    end
end

addModEventListener(BetterFuelUsageRH);
