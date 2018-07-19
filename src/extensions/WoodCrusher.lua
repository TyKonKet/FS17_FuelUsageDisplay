--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 28/03/2017
function WoodCrusher:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("WoodCrusher extension loaded on %s", self.typeName)
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, WoodCrusher.getPtoPowerMultiplier)
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, WoodCrusher.getPtoRpm)
    end
end
WoodCrusher.postLoad = Utils.appendedFunction(WoodCrusher.postLoad, WoodCrusher.postPostLoad)

function WoodCrusher:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1
    if superFunc ~= nil then
        powerMultiplier = superFunc(self)
    end
    if self.crushingTime > 0 then
        powerMultiplier = powerMultiplier + 1.8
    end
    return powerMultiplier
end

function WoodCrusher:getPtoRpm(superFunc)
    local ptoRpm = 0
    if superFunc ~= nil then
        ptoRpm = superFunc(self)
    end
    if self:getIsTurnedOn() then
        ptoRpm = 430
        if self.crushingTime > 0 then
            ptoRpm = 870
        end
    end
    return ptoRpm
end
