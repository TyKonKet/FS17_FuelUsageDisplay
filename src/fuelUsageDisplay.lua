--
-- FuelUsageDisplay
--
--
-- @author  TyKonKet
-- @date 27/10/2016

FuelUsageDisplay = {};
FuelUsageDisplay.name = "FuelUsageDisplay";
FuelUsageDisplay.debug = false;
FuelUsageDisplay.fuelUsageText = {};
FuelUsageDisplay.fuelUsageText.text1 = {};
FuelUsageDisplay.fuelUsageText.text2 = {};
FuelUsageDisplay.fuelUsageText.text1.x = 0.8955;
FuelUsageDisplay.fuelUsageText.text1.y = 0.173;
FuelUsageDisplay.fuelUsageText.text1.fontsize = 0.019;
FuelUsageDisplay.fuelUsageText.text2.y = 0.173;
FuelUsageDisplay.fuelUsageText.text2.fontsize = 0.0112;
FuelUsageDisplay.fuelUsageText.baseAspectRatio = 1.7777777777777;
FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier = g_screenAspectRatio / FuelUsageDisplay.fuelUsageText.baseAspectRatio;
FuelUsageDisplay.fuelUsageText.text1.y = FuelUsageDisplay.fuelUsageText.text1.y * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier;
FuelUsageDisplay.fuelUsageText.text2.y = FuelUsageDisplay.fuelUsageText.text2.y * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier;
FuelUsageDisplay.fuelUsageText.text1.fontsize = FuelUsageDisplay.fuelUsageText.text1.fontsize * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier;
FuelUsageDisplay.fuelUsageText.text2.fontsize = FuelUsageDisplay.fuelUsageText.text2.fontsize * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier;
--FuelUsageDisplay.currentVehicle = nil;

function FuelUsageDisplay.prerequisitesPresent(specializations)
    return true;
end

function FuelUsageDisplay.print(txt)
    --DebugUtil.printTableRecursively(txt, "FuelUsageDisplay -> (txt)", 0, 1);
    if FuelUsageDisplay.debug then
        print("[" .. FuelUsageDisplay.name .. "] -> " .. txt);
    end
end

function FuelUsageDisplay:preLoad(savegame)
    self.FuelUsageDisplay = {};
    self.FuelUsageDisplay.isActive = true;
    if self.isServer then
        self.FuelUsageDisplay.server = {};
        -- synchronized data
        self.FuelUsageDisplay.server.fuelUsed = 0;
        self.FuelUsageDisplay.server.fuelUsageFactor = 1;
        -- server only data
        self.FuelUsageDisplay.server.fuelFillLevel = 0;
        self.FuelUsageDisplay.server.lastFillLevel = 0;       
        self.FuelUsageDisplay.server.lastLoadFactor = 0;
        self.FuelUsageDisplay.server.helperFuelUsed = 0;
    end
    if self.isClient then
        self.FuelUsageDisplay.client = {};
        -- synchronized data
        self.FuelUsageDisplay.client.fuelUsed = 0;
        self.FuelUsageDisplay.client.fuelUsageFactor = 1;
    end
end

function FuelUsageDisplay:load(savegame)
    --DebugUtil.printTableRecursively(self, "FuelUsageDisplay -> (" .. self.typeName .. ")", 0, 1);
    FuelUsageDisplay.print("Specialization " .. FuelUsageDisplay.name .. " loaded on " .. self.typeName);
    FuelUsageDisplay.print("isServer " .. tostring(self.isServer) .. " isClient " .. tostring(self.isClient));
end

function FuelUsageDisplay:postLoad(savegame)
    self.updateFuelUsage = FuelUsageDisplay.updateFuelUsage;
    for i, s in pairs(self.specializations) do
        if s.driveControlFirstTimeRun then
            self.driveControl.specialization = s;
            break;
        end
    end
    if self.driveControl and self.driveControl.specialization then
        self.driveControl.specialization.overlay4WD.y = self.driveControl.specialization.overlay4WD.y + (0.00365 * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier);
        self.driveControl.specialization.overlayDiffLockFront.y = self.driveControl.specialization.overlayDiffLockFront.y + (0.00365 * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier);
        self.driveControl.specialization.overlayDiffLockBack.y = self.driveControl.specialization.overlayDiffLockBack.y + (0.00365 * FuelUsageDisplay.fuelUsageText.aspectRatioMultiplier);
    end
end

function FuelUsageDisplay:updateFuelUsage(dt)
    local rpmFactor = (self.motor:getLastMotorRpm() - self.motor:getMinRpm()) / (self.motor:getMaxRpm() - self.motor:getMinRpm());
    local loadFactor = (self.actualLoadPercentage + (self.FuelUsageDisplay.server.lastLoadFactor * 100)) / 101;
    self.FuelUsageDisplay.server.lastLoadFactor = loadFactor;
    
    --FuelUsageDisplay.print("Rpm factor " .. tostring(rpmFactor));
    --FuelUsageDisplay.print("Load factor " .. tostring(self.actualLoadPercentage) .. " Smoothed load factor " .. tostring(loadFactor));
    self.FuelUsageDisplay.server.fuelUsageFactor = 1.5;
    if g_currentMission.missionInfo.fuelUsageLow then
        self.FuelUsageDisplay.server.fuelUsageFactor = 0.7;
    end
    
    local fuelUsed = self.FuelUsageDisplay.server.fuelUsageFactor * rpmFactor * (self.fuelUsage * dt) * 1.25 * loadFactor;
    -- adding minimum usage
    fuelUsed = fuelUsed + self.FuelUsageDisplay.server.fuelUsageFactor * 0.02 * (self.fuelUsage * dt) * 1.25;
    
    if fuelUsed > 0 then
        if not self:getIsHired() or not g_currentMission.missionInfo.helperBuyFuel then
            self:setFuelFillLevel(self.fuelFillLevel - fuelUsed);
            g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed);
        elseif self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
            local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL);
            g_currentMission.missionStats:updateStats("expenses", delta);
            g_currentMission:addSharedMoney(-delta, "purchaseFuel");
            self.FuelUsageDisplay.server.helperFuelUsed = self.FuelUsageDisplay.server.helperFuelUsed + fuelUsed;
        end
    end
    
    if self.fuelUsageHud ~= nil then
        VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsed * 1000 / dt * 60 * 60);
    end
    
    return true
end

function FuelUsageDisplay:setFuelFillLevel(fuelFillLevel)
    if self.isServer then
        self.FuelUsageDisplay.server.fuelFillLevel = fuelFillLevel;
    end
end

function FuelUsageDisplay:update(dt)
    if self.isServer and self.FuelUsageDisplay.isActive then
        if self:getIsMotorStarted() then
            -- fuelUsage is expressed in l/ms
            local fuelFillLevelDiff = self.FuelUsageDisplay.server.lastFillLevel - self.FuelUsageDisplay.server.fuelFillLevel;
            if self.FuelUsageDisplay.server.helperFuelUsed > 0 then
                fuelFillLevelDiff = fuelFillLevelDiff + self.FuelUsageDisplay.server.helperFuelUsed;
                self.FuelUsageDisplay.server.helperFuelUsed = 0;
            end
            if fuelFillLevelDiff >= 0 then
                self.FuelUsageDisplay.server.fuelUsed = fuelFillLevelDiff / dt;
            end
            self.FuelUsageDisplay.server.lastFillLevel = self.FuelUsageDisplay.server.fuelFillLevel;
        else
            self.FuelUsageDisplay.server.fuelUsed = 0;
        end
        --FuelUsageDisplay.print("Fuel usage (server): " .. (self.FuelUsageDisplay.server.fuelUsed * 1000 * 60 * 60) .. " l/h");
        if self.isClient then
            self.FuelUsageDisplay.client.fuelUsed = self.FuelUsageDisplay.server.fuelUsed;
            self.FuelUsageDisplay.client.fuelUsageFactor = self.FuelUsageDisplay.server.fuelUsageFactor;
        end
    end
end

function FuelUsageDisplay:writeStream(streamId, connection)
    --FuelUsageDisplay.print("writeStream -> " .. tostring(streamId));
end

function FuelUsageDisplay:readStream(streamId, connection)
    --FuelUsageDisplay.print("readStream -> " .. tostring(streamId));
end

function FuelUsageDisplay:writeUpdateStream(streamId, connection, dirtyMask)
    if self.isServer then
        streamWriteFloat32(streamId, self.FuelUsageDisplay.server.fuelUsed);
        streamWriteFloat32(streamId, self.FuelUsageDisplay.server.fuelUsageFactor);
        --FuelUsageDisplay.print("writeUpdateStream -> fU:" .. tostring(self.FuelUsageDisplay.server.fuelUsed) .. " fUF:" .. tostring(self.FuelUsageDisplay.server.fuelUsageFactor));
    end
end

function FuelUsageDisplay:readUpdateStream(streamId, timestamp, connection)
    if not self.isServer then
        self.FuelUsageDisplay.client.fuelUsed = streamReadFloat32(streamId);
        self.FuelUsageDisplay.client.fuelUsageFactor = streamReadFloat32(streamId);
        --FuelUsageDisplay.print("readUpdateStream -> fU:" .. tostring(self.FuelUsageDisplay.client.fuelUsed) .. " fUF:" .. tostring(self.FuelUsageDisplay.client.fuelUsageFactor));
    end
end

function FuelUsageDisplay:draw()
    if self.isClient and self.isEntered and self.FuelUsageDisplay.isActive then
        local fuelUsage = self.FuelUsageDisplay.client.fuelUsed;
        local maxFuelUsage = self.fuelUsage * self.FuelUsageDisplay.client.fuelUsageFactor;
        
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
        renderText(FuelUsageDisplay.fuelUsageText.text1.x, FuelUsageDisplay.fuelUsageText.text1.y, FuelUsageDisplay.fuelUsageText.text1.fontsize, fuelUsage);
        --setTextBold(false);
        setTextColor(1, 1, 1, 0.08);
        renderText(FuelUsageDisplay.fuelUsageText.text1.x + getTextWidth(FuelUsageDisplay.fuelUsageText.text1.fontsize, fuelUsage), FuelUsageDisplay.fuelUsageText.text2.y, FuelUsageDisplay.fuelUsageText.text2.fontsize, "  l/h");
        setTextColor(1, 1, 1, 1);
    end
end

-- useless callbacks
function FuelUsageDisplay:keyEvent(unicode, sym, modifier, isDown)
end

function FuelUsageDisplay:mouseEvent(posX, posY, isDown, isUp, button)
end

function FuelUsageDisplay:delete()
end