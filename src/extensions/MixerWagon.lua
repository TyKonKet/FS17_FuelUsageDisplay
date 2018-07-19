--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 04/04/2017
function MixerWagon:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        BetterFuelUsage.print("MixerWagon extension loaded on %s", self.typeName)
        self.getDoConsumePtoPower = Utils.overwrittenFunction(self.getDoConsumePtoPower, MixerWagon.getDoConsumePtoPower)
        self.getPtoPowerMultiplier = Utils.overwrittenFunction(self.getPtoPowerMultiplier, MixerWagon.getPtoPowerMultiplier)
    end
end
MixerWagon.postLoad = Utils.appendedFunction(MixerWagon.postLoad, MixerWagon.postPostLoad)

function MixerWagon:getPtoPowerMultiplier(superFunc)
    local powerMultiplier = 1
    if superFunc ~= nil then
        powerMultiplier = superFunc(self)
    end
    if EffectManager:startedEffects(self.shovelFillEffects) then
        powerMultiplier = powerMultiplier + 0.3
    end
    return powerMultiplier
end

function MixerWagon:getDoConsumePtoPower(superFunc)
    local doConsumePower = superFunc(self)
    return self.mixingActiveTimer > 0 or doConsumePower
end
