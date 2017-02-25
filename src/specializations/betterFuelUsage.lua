--
-- BetterFuelUsage
--
-- @author  TyKonKet
-- @date 27/10/2016
BetterFuelUsage = {};
BetterFuelUsage.name = "BetterFuelUsage";
BetterFuelUsage.debug = BetterFuelUsageRH.debug;

function BetterFuelUsage.prerequisitesPresent(specializations)
    if SpecializationUtil.hasSpecialization(SpecializationUtil.getSpecialization("motorized"), specializations) then
        return true;
    else
        return false;
    end
end

function BetterFuelUsage.initSpecialization()
end

function BetterFuelUsage.print(txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9)
    if BetterFuelUsage.debug then
        local args = {txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9};
        for i, v in ipairs(args) do
            if v then
                print("[" .. BetterFuelUsage.name .. "] -> " .. tostring(v));
            end
        end
    end
end

function BetterFuelUsage:preLoad(savegame)
    BetterFuelUsage.print("BetterFuelUsage:preLoad()");
    self.BetterFuelUsage = {};
    self.BetterFuelUsage.backup = {};
    self.BetterFuelUsage.useDefaultFuelUsageFunction = false;
    self.BetterFuelUsage.fuelUsed = 0;
    self.BetterFuelUsage.maxFuelUsage = 1000;
    self.BetterFuelUsage.fuelFillLevel = 0;
    self.BetterFuelUsage.lastFillLevel = 0;
    self.BetterFuelUsage.lastLoadFactor = 0;
    self.BetterFuelUsage.helperFuelUsed = 0;
end

function BetterFuelUsage:load(savegame)
    BetterFuelUsage.print(BetterFuelUsage.name .. " loaded on " .. self.typeName);
    self.setFuelUsageFunction = BetterFuelUsage.setFuelUsageFunction;
    local x = g_currentMission.vehicleHudBg.x + g_currentMission.vehicleHudBg.width * 0.518;
    local y = g_currentMission.vehicleHudBg.y + g_currentMission.vehicleHudBg.height * 0.798;
    self.fuelText = DynamicText:new({position = {x = x, y = y}, size = 0.02});
    self.lhText = DynamicText:new({size = 0.0112, text = " l/h", color = {r = 1, g = 1, b = 1, a = 0.08}});
end

function BetterFuelUsage:postLoad(savegame)
    BetterFuelUsage.print("BetterFuelUsage:postLoad()");
    self.BetterFuelUsage.backup.updateFuelUsage = self.updateFuelUsage;
    if savegame ~= nil and not savegame.resetVehicles then
        self.BetterFuelUsage.useDefaultFuelUsageFunction = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key .. "#useDefaultFuelUsageFunction"), self.BetterFuelUsage.useDefaultFuelUsageFunction);
    end
    self:setFuelUsageFunction(self.BetterFuelUsage.useDefaultFuelUsageFunction);
--for i, s in pairs(self.specializations) do
--    if s.driveControlFirstTimeRun then
--        self.driveControl.specialization = s;
--        break;
--    end
--end
--if self.driveControl and self.driveControl.specialization then
--    self.driveControl.specialization.overlay4WD.y = self.driveControl.specialization.overlay4WD.y + (0.00365 * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier);
--    self.driveControl.specialization.overlayDiffLockFront.y = self.driveControl.specialization.overlayDiffLockFront.y + (0.00365 * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier);
--    self.driveControl.specialization.overlayDiffLockBack.y = self.driveControl.specialization.overlayDiffLockBack.y + (0.00365 * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier);
--end
end

function BetterFuelUsage:getSaveAttributesAndNodes(nodeIdent)
    local attributes = string.format("useDefaultFuelUsageFunction=\"%s\"", self.BetterFuelUsage.useDefaultFuelUsageFunction);
    local nodes = nil;
    return attributes, nodes;
end

function BetterFuelUsage:setFuelUsageFunction(default)
    BetterFuelUsage.print(("BetterFuelUsage:setFuelUsageFunction(default:%s)"):format(default));
    if not self:getIsMotorStarted() then
        self.BetterFuelUsage.useDefaultFuelUsageFunction = default;
        if default then
            self.updateFuelUsage = BetterFuelUsage.defaultUpdateFuelUsage;
        else
            self.updateFuelUsage = BetterFuelUsage.realisticUpdateFuelUsage;
        end
    else
        g_currentMission:showBlinkingWarning(g_i18n:getText("BFU_SET_FUEL_USAGE_ERROR_TEXT_1"), 2500);
    end
end

function BetterFuelUsage:realisticUpdateFuelUsage(dt)
    local rpmFactor = (self.motor:getLastMotorRpm() - self.motor:getMinRpm()) / (self.motor:getMaxRpm() - self.motor:getMinRpm());
    local loadFactor = (self.actualLoadPercentage + (self.BetterFuelUsage.lastLoadFactor * 100)) / 101;
    self.BetterFuelUsage.lastLoadFactor = loadFactor;
    local fuelUsageFactor = 1.5;
    if g_currentMission.missionInfo.fuelUsageLow then
        fuelUsageFactor = 0.7;
    end
    local fuelUsed = fuelUsageFactor * rpmFactor * self.fuelUsage * dt * 1.25 * loadFactor;
    fuelUsed = fuelUsed + fuelUsageFactor * 0.02 * self.fuelUsage * dt * 1.25;
    self.BetterFuelUsage.maxFuelUsage = fuelUsageFactor * self.fuelUsage + fuelUsageFactor * 0.02 * self.fuelUsage * 1.25;
    if fuelUsed > 0 then
        if not self:getIsHired() or not g_currentMission.missionInfo.helperBuyFuel then
            self:setFuelFillLevel(self.fuelFillLevel - fuelUsed);
            g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed);
        elseif self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
            local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL);
            g_currentMission.missionStats:updateStats("expenses", delta);
            g_currentMission:addSharedMoney(-delta, "purchaseFuel");
            self.BetterFuelUsage.helperFuelUsed = self.BetterFuelUsage.helperFuelUsed + fuelUsed;
        end
    end
    if self.fuelUsageHud ~= nil then
        VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsed * 1000 / dt * 60 * 60);
    end
    return true
end

function BetterFuelUsage:defaultUpdateFuelUsage(dt)
    local rpmFactor = math.max(0.02, (self.motor:getLastMotorRpm() - self.motor:getMinRpm()) / (self.motor:getMaxRpm() - self.motor:getMinRpm()));
    local fuelUsageFactor = 1;
    if g_currentMission.missionInfo.fuelUsageLow then
        fuelUsageFactor = 0.7;
    end  
    local fuelUsed = fuelUsageFactor * rpmFactor * self.fuelUsage * dt;
    self.BetterFuelUsage.maxFuelUsage = fuelUsageFactor * self.fuelUsage;
    if fuelUsed > 0 then
        if not self:getIsHired() or not g_currentMission.missionInfo.helperBuyFuel then
            self:setFuelFillLevel(self.fuelFillLevel - fuelUsed);
            g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed);
        elseif self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
            local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL);
            g_currentMission.missionStats:updateStats("expenses", delta);
            g_currentMission:addSharedMoney(-delta, "purchaseFuel");
            self.BetterFuelUsage.helperFuelUsed = self.BetterFuelUsage.helperFuelUsed + fuelUsed;
        end
    end   
    if self.fuelUsageHud ~= nil then
        VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsed * 1000 / dt * 60 * 60);
    end
    return true;
end

function BetterFuelUsage:setFuelFillLevel(fuelFillLevel)
    if self.isServer then
        self.BetterFuelUsage.fuelFillLevel = fuelFillLevel;
    end
end

function BetterFuelUsage:update(dt)
    if self.isEntered then
        if InputBinding.hasEvent(InputBinding.BFU_SET_FUEL_USAGE, true) then
            self:setFuelUsageFunction(not self.BetterFuelUsage.useDefaultFuelUsageFunction);
        end
    end
    if self.isServer then
        if self:getIsMotorStarted() then
            local fuelFillLevelDiff = self.BetterFuelUsage.lastFillLevel - self.BetterFuelUsage.fuelFillLevel;
            if self.BetterFuelUsage.helperFuelUsed > 0 then
                fuelFillLevelDiff = fuelFillLevelDiff + self.BetterFuelUsage.helperFuelUsed;
                self.BetterFuelUsage.helperFuelUsed = 0;
            end
            if fuelFillLevelDiff >= 0 then
                self.BetterFuelUsage.fuelUsed = fuelFillLevelDiff / dt;
            end
            self.BetterFuelUsage.lastFillLevel = self.BetterFuelUsage.fuelFillLevel;
        else
            self.BetterFuelUsage.fuelUsed = 0;
        end
    end
end

function BetterFuelUsage:writeStream(streamId, connection)
    if not connection:getIsServer() then
        streamWriteFloat32(streamId, self.BetterFuelUsage.fuelUsed);
        streamWriteFloat32(streamId, self.BetterFuelUsage.maxFuelUsage);
    end
end

function BetterFuelUsage:readStream(streamId, connection)
    if connection:getIsServer() then
        self.BetterFuelUsage.fuelUsed = streamReadFloat32(streamId);
        self.BetterFuelUsage.maxFuelUsage = streamReadFloat32(streamId);
    end
end

function BetterFuelUsage:writeUpdateStream(streamId, connection, dirtyMask)
    if not connection:getIsServer() then
        streamWriteFloat32(streamId, self.BetterFuelUsage.fuelUsed);
        streamWriteFloat32(streamId, self.BetterFuelUsage.maxFuelUsage);
    end
end

function BetterFuelUsage:readUpdateStream(streamId, timestamp, connection)
    if connection:getIsServer() then
        self.BetterFuelUsage.fuelUsed = streamReadFloat32(streamId);
        self.BetterFuelUsage.maxFuelUsage = streamReadFloat32(streamId);
    end
end

function BetterFuelUsage:draw()
    if self.isEntered then
        if not self:getIsMotorStarted() then
            if self.BetterFuelUsage.useDefaultFuelUsageFunction then
                g_currentMission:addHelpButtonText(g_i18n:getText("BFU_SET_FUEL_USAGE_TEXT_1"), InputBinding.BFU_SET_FUEL_USAGE, nil, GS_PRIO_HIGH);
            else
                g_currentMission:addHelpButtonText(g_i18n:getText("BFU_SET_FUEL_USAGE_TEXT_2"), InputBinding.BFU_SET_FUEL_USAGE, nil, GS_PRIO_HIGH);
            end
        end    
        local color = {};
        if self.BetterFuelUsage.fuelUsed < (self.BetterFuelUsage.maxFuelUsage * 0.1) then
            color = {0, 1, 0, 1};
        elseif self.BetterFuelUsage.fuelUsed < (self.BetterFuelUsage.maxFuelUsage * 0.3) then
            color = {1, 1, 1, 1};
        elseif self.BetterFuelUsage.fuelUsed < (self.BetterFuelUsage.maxFuelUsage * 0.65) then
            color = {1, 1, 0, 1};
        else
            color = {1, 0, 0, 1};
        end
        local fuelUsage = self.BetterFuelUsage.fuelUsed * 1000 * 60 * 60;
        if fuelUsage < 10 then
            fuelUsage = string.format("%.1f", fuelUsage);
        else
            fuelUsage = string.format("%.0f", fuelUsage);
        end      
        self.fuelText:draw({text = fuelUsage, color = {r = color[1], g = color[2], b = color[3], a = color[4]}});
        local x, y = self.fuelText:getTextEnd();
        self.lhText:draw({position = {x = x, y = y}});
    end
end

function BetterFuelUsage:keyEvent(unicode, sym, modifier, isDown)
end

function BetterFuelUsage:mouseEvent(posX, posY, isDown, isUp, button)
end

function BetterFuelUsage:delete()
end
