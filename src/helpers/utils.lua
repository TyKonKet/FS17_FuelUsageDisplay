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
