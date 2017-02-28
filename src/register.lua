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
BetterFuelUsageRH.debug = false;

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
        addConsoleCommand("AAAFUDPrintVheicle", "", "FUDPrintVheicle", self);
        addConsoleCommand("AAAFUDSetGraph", "", "FUDSetGraph", self);
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

function BetterFuelUsageRH.FUDPrintVheicle(self)
--DebugUtil.printTableRecursively(FuelUsageDisplay.currentVehicle, "", 0, 1);
end

function BetterFuelUsageRH.FUDSetGraph(self, t1x, t1y, t1fs, t2fs)
    if t1x == "-" then
        t1x = FuelUsageDisplay.fuelUsageText.text1.x;
    end
    if t1y == "-" then
        t1y = FuelUsageDisplay.fuelUsageText.text1.y;
    end
    if t1fs == "-" then
        t1fs = FuelUsageDisplay.fuelUsageText.text1.fontsize;
    end
    if t2fs == "-" then
        t2fs = FuelUsageDisplay.fuelUsageText.text2.fontsize;
    end
    FuelUsageDisplay.fuelUsageText.text1.x = tonumber(t1x);
    FuelUsageDisplay.fuelUsageText.text1.y = tonumber(t1y);
    FuelUsageDisplay.fuelUsageText.text1.fontsize = tonumber(t1fs);
    FuelUsageDisplay.fuelUsageText.text2.y = tonumber(t1y);
    FuelUsageDisplay.fuelUsageText.text2.fontsize = tonumber(t2fs);
    return string.format("x1 = %f, y1 = %f, fs1 = %f, y2 = %f, fs2 = %f", t1x, t1y, t1fs, t1y, t2fs);
end

addModEventListener(BetterFuelUsageRH);
