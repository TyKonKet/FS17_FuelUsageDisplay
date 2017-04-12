--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 05/04/2017
function Utils:getMotor()
    if self.motor ~= nil then
        return self.motor;
    end
    if self.attaccherVehicle ~= nil then
        return Utils.getMotor(vehicle.attaccherVehicle);
    end
    return nil;
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
