--
--Better Fuel Usage
--
--@author TyKonKet
--@date 29/03/2017
function Foldable:postPostLoad(savegame)
    self.animPartsCount = 0;
    local countedParts = {};
    for _, foldingPart in pairs(self.foldingParts) do
        local anim = self.animations[foldingPart.animationName];
        for _, part in pairs(anim.parts) do
            if part.node ~= nil and not countedParts[part.node] then
                self.animPartsCount = self.animPartsCount + 1;
                countedParts[part.node] = true;
            end
            if part.componentJointIndex ~= nil and not countedParts[part.node] then
                self.animPartsCount = self.animPartsCount + 1;
                countedParts[part.componentJointIndex] = true;
            end
        end
    end
    countedParts = nil;
    BetterFuelUsage.print("Foldable extension loaded on " .. self.typeName .. " animPartsCount " .. self.animPartsCount);
    self.getConsumedPtoTorque = Utils.overwrittenFunction(self.getConsumedPtoTorque, Foldable.getConsumedPtoTorque);
end
Foldable.postLoad = Utils.appendedFunction(Foldable.postLoad, Foldable.postPostLoad);

function Foldable:getConsumedPtoTorque(superFunc)
    local torque = 0;
    if superFunc ~= nil then
        torque = superFunc(self);
    end
    if self.foldAnimTime > 0 and self.foldAnimTime < 1 and self.foldAnimTime ~= self.foldMiddleAnimTime then
        torque = torque + (8 * self.animPartsCount / (540 * math.pi / 30));
    end
    return torque;
end
