--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 05/04/2017
function Utils:getMotor()
    if self.motor ~= nil then
        return self.motor;
    end
    if self.attacherVehicle ~= nil then
        return Utils.getMotor(self.attacherVehicle);
    end
    return nil;
end

function Utils:getMotorPowerPercentage(percentage, default)
    local motor = Utils.getMotor(self);
    if motor ~= nil and motor.vehicle.BetterFuelUsage ~= nil then
        return motor.vehicle.BetterFuelUsage.maxMotorPower * percentage / 1000;
    end
    return default;
end

function Utils:getMaxMotorTorque(default)
    default = default or math.huge;
    local motor = Utils.getMotor(self);
    if motor ~= nil then
        return motor.maxMotorTorque;
    end
    return default;
end

function Utils:getIsEntered()
    if self.isEntered then
        return true;
    end
    if self.attacherVehicle ~= nil then
        return Utils.getIsEntered(self.attacherVehicle);
    end
    return false;
end

function Utils:gearboxActive()
    if BetterFuelUsage.gearBox ~= nil then
        if self.mrGbMS ~= nil and self.mrGbMS.IsOnOff then
            return true;
        end
        if self.attacherVehicle ~= nil then
            return Utils.gearboxActive(self.attacherVehicle);
        end
    end
    return false;
end

function Utils.clearXmlDirectory(filename)
    local isMod = false;
    local filenameLower = filename:lower();
    local modsDirLen = g_modsDirectory:len();
    local modsDirLower = g_modsDirectory:lower();
    if filenameLower:sub(1, modsDirLen) == modsDirLower then
        filename = filename:sub(modsDirLen + 1);
        filename = filename:sub(filename:find("/") + 1);
    else
        for i = 1, table.getn(g_dlcsDirectories) do
            local dlcsDir = g_dlcsDirectories[i].path:lower();
            local dlcsDirLen = dlcsDir:len();
            if filenameLower:sub(1, dlcsDirLen) == dlcsDir then
                filename = filename:sub(dlcsDirLen + 1);
                break;
            end
        end
    end
    return filename;
end
