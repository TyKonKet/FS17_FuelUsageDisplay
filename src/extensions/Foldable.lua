--
--Better Fuel Usage
--
--@author TyKonKet
--@date 29/03/2017
function Foldable:postPostLoad(savegame)
    if not self.mrIsMrVehicle then
        self.foldAnimPartsCount = 0
        local countedParts = {}
        for _, foldingPart in pairs(self.foldingParts) do
            local anim = self.animations[foldingPart.animationName]
            if anim ~= nil then
                for _, part in pairs(anim.parts) do
                    if part.node ~= nil and not countedParts[part.node] then
                        self.foldAnimPartsCount = self.foldAnimPartsCount + 1
                        countedParts[part.node] = true
                    end
                    if part.componentJointIndex ~= nil and not countedParts[part.node] then
                        self.foldAnimPartsCount = self.foldAnimPartsCount + 1
                        countedParts[part.componentJointIndex] = true
                    end
                end
            else
                self.foldAnimPartsCount = self.foldAnimPartsCount + 1
            end
        end
        countedParts = nil
        BetterFuelUsage.print("Foldable extension loaded on %s foldAnimPartsCount %s", self.typeName, self.foldAnimPartsCount)
        self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Foldable.getConsumedPtoTorque)
        self.getPtoRpm = Utils.overwrittenFunction(self.getPtoRpm, Foldable.getPtoRpm)
    end
end
Foldable.postLoad = Utils.appendedFunction(Foldable.postLoad, Foldable.postPostLoad)

function Foldable:getConsumedPtoTorque(superFunc)
    local torque = 0
    if superFunc ~= nil then
        torque = superFunc(self)
    end
    if self.foldAnimTime > 0 and self.foldAnimTime < 1 and (self.foldMiddleAnimTime == nil or self.foldAnimTime < self.foldMiddleAnimTime - 0.02 or self.foldAnimTime > self.foldMiddleAnimTime + 0.02) then
        torque = torque + (Utils.getMotorPowerPercentage(self, 0.025, 2.5) * self.foldAnimPartsCount / (540 * math.pi / 30))
    end
    return torque
end

function Foldable:getPtoRpm(superFunc)
    local ptoRpm = 0
    if superFunc ~= nil then
        ptoRpm = superFunc(self)
    end
    if self.foldAnimTime > 0 and self.foldAnimTime < 1 and (self.foldMiddleAnimTime == nil or self.foldAnimTime < self.foldMiddleAnimTime - 0.02 or self.foldAnimTime > self.foldMiddleAnimTime + 0.02) then
        ptoRpm = math.max(ptoRpm, 540)
    end
    return ptoRpm
end
