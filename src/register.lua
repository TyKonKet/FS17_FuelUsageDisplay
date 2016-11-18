--
-- FuelUsageDisplay Registration
--
--
-- @author  TyKonKet
-- @date 27/10/2016

RegistrationHelper_FUD = {};
RegistrationHelper_FUD.isLoaded = false;
RegistrationHelper_FUD.name = "FuelUsageDisplayRH";
RegistrationHelper_FUD.specializationTitle = "FuelUsageDisplay";
RegistrationHelper_FUD.specializationName = "fuelUsageDisplay";
RegistrationHelper_FUD.specializationScript = g_currentModDirectory .. "fuelUsageDisplay.lua";
RegistrationHelper_FUD.debug = false;

function RegistrationHelper_FUD:print(txt)
    if RegistrationHelper_FUD.debug then
        print("[" .. self.name .. "] -> " .. txt);
    end
end

if SpecializationUtil.specializations[RegistrationHelper_FUD.specializationName] == nil then
    SpecializationUtil.registerSpecialization(RegistrationHelper_FUD.specializationName, RegistrationHelper_FUD.specializationTitle, RegistrationHelper_FUD.specializationScript)
    RegistrationHelper_FUD.isLoaded = false;
    RegistrationHelper_FUD:print("Specialization " .. RegistrationHelper_FUD.specializationTitle .. " registered!");
end

function RegistrationHelper_FUD:loadMap(name)
    --DebugUtil.printTableRecursively(self, self.name .. " -> ", 0, 1);
    if not g_currentMission.registrationHelper_FUD_isLoaded then
        if not self.isLoaded then
            self:register();
        end
        g_currentMission.registrationHelper_FUD_isLoaded = true;
        self.isLoaded = true;
        if self.debug then
            addConsoleCommand("AAAFUDPrintVheicle", "", "FUDPrintVheicle", self);
            addConsoleCommand("AAAFUDSetGraph", "", "FUDSetGraph", self);
        end
    else
        self:print("Error: " .. self.specializationTitle .. " has been loaded already!");
    end
end

function RegistrationHelper_FUD:deleteMap()
    g_currentMission.registrationHelper_FUD_isLoaded = false;
end

function RegistrationHelper_FUD:keyEvent(unicode, sym, modifier, isDown)
end

function RegistrationHelper_FUD:mouseEvent(posX, posY, isDown, isUp, button)
end

function RegistrationHelper_FUD:update(dt)
end

function RegistrationHelper_FUD:draw()
end

function RegistrationHelper_FUD:register()
    for _, vehicle in pairs(VehicleTypeUtil.vehicleTypes) do
        if vehicle ~= nil then
            if SpecializationUtil.hasSpecialization(SpecializationUtil.getSpecialization("motorized"), vehicle.specializations) then
                table.insert(vehicle.specializations, SpecializationUtil.getSpecialization(self.specializationName));
                self:print("Specialization " .. self.specializationTitle .. " registered on " .. vehicle.name);
		    end     
        end
    end
end

function RegistrationHelper_FUD.FUDPrintVheicle(self)
    --DebugUtil.printTableRecursively(FuelUsageDisplay.currentVehicle, "", 0, 1);
end

function RegistrationHelper_FUD.FUDSetGraph(self, t1x, t1y, t1fs, t2fs)
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
    return string.format( "x1 = %f, y1 = %f, fs1 = %f, y2 = %f, fs2 = %f", t1x, t1y, t1fs, t1y, t2fs);
end



addModEventListener(RegistrationHelper_FUD)