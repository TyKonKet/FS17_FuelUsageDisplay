--
-- BetterFuelUsage
--
-- @author  TyKonKet
-- @date 27/10/2016
BetterFuelUsage = {};
BetterFuelUsage.name = "BetterFuelUsage";
BetterFuelUsage.debug = BetterFuelUsageRH.debug;
BetterFuelUsage.fuelUsageText = {};
BetterFuelUsage.fuelUsageText.text1 = {};
BetterFuelUsage.fuelUsageText.text2 = {};
BetterFuelUsage.fuelUsageText.text1.x = 0.8955;
BetterFuelUsage.fuelUsageText.text1.y = 0.173;
BetterFuelUsage.fuelUsageText.text1.fontsize = 0.019;
BetterFuelUsage.fuelUsageText.text2.y = 0.173;
BetterFuelUsage.fuelUsageText.text2.fontsize = 0.0112;
BetterFuelUsage.fuelUsageText.baseAspectRatio = 1.7777777777777;
BetterFuelUsage.fuelUsageText.aspectRatioMultiplier = g_screenAspectRatio / BetterFuelUsage.fuelUsageText.baseAspectRatio;
BetterFuelUsage.fuelUsageText.text1.y = BetterFuelUsage.fuelUsageText.text1.y * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier;
BetterFuelUsage.fuelUsageText.text2.y = BetterFuelUsage.fuelUsageText.text2.y * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier;
BetterFuelUsage.fuelUsageText.text1.fontsize = BetterFuelUsage.fuelUsageText.text1.fontsize * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier;
BetterFuelUsage.fuelUsageText.text2.fontsize = BetterFuelUsage.fuelUsageText.text2.fontsize * BetterFuelUsage.fuelUsageText.aspectRatioMultiplier;

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
    if self.isServer then
        self.BetterFuelUsage.server = {};
        -- synchronized data
        self.BetterFuelUsage.server.fuelUsed = 0;
        self.BetterFuelUsage.server.fuelUsageFactor = 1;
        -- server only data
        self.BetterFuelUsage.server.fuelFillLevel = 0;
        self.BetterFuelUsage.server.lastFillLevel = 0;
        self.BetterFuelUsage.server.lastLoadFactor = 0;
        self.BetterFuelUsage.server.helperFuelUsed = 0;
    end
    if self.isClient then
        self.BetterFuelUsage.client = {};
        -- synchronized data
        self.BetterFuelUsage.client.fuelUsed = 0;
        self.BetterFuelUsage.client.fuelUsageFactor = 1;
    end
end

function BetterFuelUsage:load(savegame)
    BetterFuelUsage.print(BetterFuelUsage.name .. " loaded on " .. self.typeName);
    self.setFuelUsageFunction = BetterFuelUsage.setFuelUsageFunction;
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
            self.updateFuelUsage = self.BetterFuelUsage.backup.updateFuelUsage;
        else
            self.updateFuelUsage = BetterFuelUsage.updateFuelUsage;
        end
    else
        g_currentMission:showBlinkingWarning(g_i18n:getText("BFU_SET_FUEL_USAGE_ERROR_TEXT_1"), 2500);
    end
end

function BetterFuelUsage:updateFuelUsage(dt)
    local rpmFactor = (self.motor:getLastMotorRpm() - self.motor:getMinRpm()) / (self.motor:getMaxRpm() - self.motor:getMinRpm());
    local loadFactor = (self.actualLoadPercentage + (self.BetterFuelUsage.server.lastLoadFactor * 100)) / 101;
    self.BetterFuelUsage.server.lastLoadFactor = loadFactor;
    
    --BetterFuelUsage.print("Rpm factor " .. tostring(rpmFactor));
    --BetterFuelUsage.print("Load factor " .. tostring(self.actualLoadPercentage) .. " Smoothed load factor " .. tostring(loadFactor));
    self.BetterFuelUsage.server.fuelUsageFactor = 1.5;
    if g_currentMission.missionInfo.fuelUsageLow then
        self.BetterFuelUsage.server.fuelUsageFactor = 0.7;
    end
    
    local fuelUsed = self.BetterFuelUsage.server.fuelUsageFactor * rpmFactor * (self.fuelUsage * dt) * 1.25 * loadFactor;
    -- adding minimum usage
    fuelUsed = fuelUsed + self.BetterFuelUsage.server.fuelUsageFactor * 0.02 * (self.fuelUsage * dt) * 1.25;
    
    if fuelUsed > 0 then
        if not self:getIsHired() or not g_currentMission.missionInfo.helperBuyFuel then
            self:setFuelFillLevel(self.fuelFillLevel - fuelUsed);
            g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed);
        elseif self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
            local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL);
            g_currentMission.missionStats:updateStats("expenses", delta);
            g_currentMission:addSharedMoney(-delta, "purchaseFuel");
            self.BetterFuelUsage.server.helperFuelUsed = self.BetterFuelUsage.server.helperFuelUsed + fuelUsed;
        end
    end
    
    if self.fuelUsageHud ~= nil then
        VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsed * 1000 / dt * 60 * 60);
    end
    
    return true
end

function BetterFuelUsage:setFuelFillLevel(fuelFillLevel)
    if self.isServer then
        self.BetterFuelUsage.server.fuelFillLevel = fuelFillLevel;
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
            -- fuelUsage is expressed in l/ms
            local fuelFillLevelDiff = self.BetterFuelUsage.server.lastFillLevel - self.BetterFuelUsage.server.fuelFillLevel;
            if self.BetterFuelUsage.server.helperFuelUsed > 0 then
                fuelFillLevelDiff = fuelFillLevelDiff + self.BetterFuelUsage.server.helperFuelUsed;
                self.BetterFuelUsage.server.helperFuelUsed = 0;
            end
            if fuelFillLevelDiff >= 0 then
                self.BetterFuelUsage.server.fuelUsed = fuelFillLevelDiff / dt;
            end
            self.BetterFuelUsage.server.lastFillLevel = self.BetterFuelUsage.server.fuelFillLevel;
        else
            self.BetterFuelUsage.server.fuelUsed = 0;
        end
        --BetterFuelUsage.print("Fuel usage (server): " .. (self.BetterFuelUsage.server.fuelUsed * 1000 * 60 * 60) .. " l/h");
        if self.isClient then
            self.BetterFuelUsage.client.fuelUsed = self.BetterFuelUsage.server.fuelUsed;
            self.BetterFuelUsage.client.fuelUsageFactor = self.BetterFuelUsage.server.fuelUsageFactor;
        end
    end
end

function BetterFuelUsage:writeStream(streamId, connection)
--BetterFuelUsage.print("writeStream -> " .. tostring(streamId));
end

function BetterFuelUsage:readStream(streamId, connection)
--BetterFuelUsage.print("readStream -> " .. tostring(streamId));
end

function BetterFuelUsage:writeUpdateStream(streamId, connection, dirtyMask)
    if self.isServer then
        streamWriteFloat32(streamId, self.BetterFuelUsage.server.fuelUsed);
        streamWriteFloat32(streamId, self.BetterFuelUsage.server.fuelUsageFactor);
    --BetterFuelUsage.print("writeUpdateStream -> fU:" .. tostring(self.BetterFuelUsage.server.fuelUsed) .. " fUF:" .. tostring(self.BetterFuelUsage.server.fuelUsageFactor));
    end
end

function BetterFuelUsage:readUpdateStream(streamId, timestamp, connection)
    if not self.isServer then
        self.BetterFuelUsage.client.fuelUsed = streamReadFloat32(streamId);
        self.BetterFuelUsage.client.fuelUsageFactor = streamReadFloat32(streamId);
    --BetterFuelUsage.print("readUpdateStream -> fU:" .. tostring(self.BetterFuelUsage.client.fuelUsed) .. " fUF:" .. tostring(self.BetterFuelUsage.client.fuelUsageFactor));
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

        local fuelUsage = self.BetterFuelUsage.client.fuelUsed;
        local maxFuelUsage = self.fuelUsage * self.BetterFuelUsage.client.fuelUsageFactor;
        
        -- chosing color of text
        if fuelUsage < (maxFuelUsage * 0.1) then
            setTextColor(0, 1, 0, 1);
        elseif fuelUsage < (maxFuelUsage * 0.45) then
            setTextColor(1, 1, 1, 1);
        elseif fuelUsage < (maxFuelUsage * 0.8) then
            setTextColor(1, 1, 0, 1);
        else
            setTextColor(1, 0, 0, 1);
        end
        
        -- converting fuelUsage in l/h
        fuelUsage = fuelUsage * 1000 * 60 * 60;
        
        if fuelUsage < 10 then
            fuelUsage = string.format("%.2f", fuelUsage);
        elseif fuelUsage < 100 then
            fuelUsage = string.format("%.1f", fuelUsage);
        else
            fuelUsage = string.format("%.0f", fuelUsage);
        end
        --setTextBold(true);
        renderText(BetterFuelUsage.fuelUsageText.text1.x, BetterFuelUsage.fuelUsageText.text1.y, BetterFuelUsage.fuelUsageText.text1.fontsize, fuelUsage);
        --setTextBold(false);
        setTextColor(1, 1, 1, 0.08);
        renderText(BetterFuelUsage.fuelUsageText.text1.x + getTextWidth(BetterFuelUsage.fuelUsageText.text1.fontsize, fuelUsage), BetterFuelUsage.fuelUsageText.text2.y, BetterFuelUsage.fuelUsageText.text2.fontsize, "  l/h");
        setTextColor(1, 1, 1, 1);
    end
end

-- useless callbacks
function BetterFuelUsage:keyEvent(unicode, sym, modifier, isDown)
end

function BetterFuelUsage:mouseEvent(posX, posY, isDown, isUp, button)
end

function BetterFuelUsage:delete()
end
