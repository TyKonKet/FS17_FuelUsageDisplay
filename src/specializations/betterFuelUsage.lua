--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 27/10/2016
BetterFuelUsage = {};
BetterFuelUsage.name = "BetterFuelUsage";
BetterFuelUsage.debug = BetterFuelUsageRH.debug;
BetterFuelUsage.dir = g_currentModDirectory;
BetterFuelUsage.driveControl = nil;
BetterFuelUsage.motorizedOverwrites = {};

function BetterFuelUsage.print(text, ...)
    if BetterFuelUsage.debug then
        local start = string.format("[%s(%s)] -> ", BetterFuelUsage.name, getDate("%H:%M:%S"));
        local ptext = string.format(text, ...);
        print(string.format("%s%s", start, ptext));
    end
end

function BetterFuelUsage.prerequisitesPresent(specializations)
    if SpecializationUtil.hasSpecialization(SpecializationUtil.getSpecialization("motorized"), specializations) then
        return true;
    else
        return false;
    end
end

function BetterFuelUsage.initSpecialization()
    local gb = SpecializationUtil.getSpecialization("FS17_GearboxAddon.gearboxMogli");
    if gb ~= nil then
        gb.draw = Utils.prependedFunction(gb.draw, BetterFuelUsage.gbDraw);
        BetterFuelUsage.gearBox = gb;
    end
    local dc = SpecializationUtil.getSpecialization("ZZZ_driveControl.driveControl");
    if dc ~= nil then
        dc.load = Utils.appendedFunction(dc.load, BetterFuelUsage.dcLoad);
        BetterFuelUsage.driveControl = dc;
    end
    local xml = loadXMLFile("motorizedOverwritesXML", BetterFuelUsage.dir .. "motorizedOverwrites.xml");
    local index = 0;
    while true do
        local query = string.format("motorizedOverwrites.vehicle(%d)", index);
        if not hasXMLProperty(xml, query) then
            break;
        end
        local xmlC = getXMLString(xml, string.format("%s#xml", query));
        local fuelUsage = getXMLFloat(xml, string.format("%s#fuelUsage", query));
        BetterFuelUsage.motorizedOverwrites[xmlC] = {};
        BetterFuelUsage.motorizedOverwrites[xmlC].fuelUsage = fuelUsage;
        BetterFuelUsage.print("motorizedOverwrite -> xml:%s fuelUsage:%s", xmlC, fuelUsage);
        index = index + 1;
    end
end

function BetterFuelUsage:preLoad(savegame)
    BetterFuelUsage.print("BetterFuelUsage:preLoad()");
    self.BetterFuelUsage = {};
    self.BetterFuelUsage.backup = {};
    self.BetterFuelUsage.useDefaultFuelUsageFunction = false;
    self.BetterFuelUsage.fuelUsed = 0;
    self.BetterFuelUsage.fuelUsedDisplayTime = 0;
    self.BetterFuelUsage.maxFuelUsage = 1;
    self.BetterFuelUsage.fuelFillLevel = 0;
    self.BetterFuelUsage.lastFillLevel = 0;
    self.BetterFuelUsage.lastLoadFactor = 0;
    self.BetterFuelUsage.helperFuelUsed = 0;
    self.BetterFuelUsage.fuelDisplayed = 0;
    self.BetterFuelUsage.fuelFade = FadeEffect:new({position = {x = 0.483, y = 0.94}, size = 0.028, shadow = true, shadowPosition = {x = 0.0025, y = 0.0035}, statesTime = {0.85, 0.5, 0.45}});
    self.debugDrawTexts = {};
    self.isSelectable = true
end

function BetterFuelUsage:load(savegame)
    BetterFuelUsage.print("%s loaded on %s", BetterFuelUsage.name, self.typeName);
    self.setFuelUsageFunction = BetterFuelUsage.setFuelUsageFunction;
    local x = g_currentMission.vehicleHudBg.x + g_currentMission.vehicleHudBg.width * 0.518;
    local y = g_currentMission.vehicleHudBg.y + g_currentMission.vehicleHudBg.height * 0.798;
    self.fuelText = DynamicText:new({position = {x = x, y = y}, size = 14, color = {r = 1, g = 1, b = 1, a = 1}});
    self.lhText = DynamicText:new({size = 8, text = string.format(" %s", g_i18n:getText("BFU_LITERS_PER_HOUR")), color = {r = 0.0865, g = 0.0865, b = 0.0865, a = 1}});
end

function BetterFuelUsage:dcLoad()
    BetterFuelUsage.print("driveControl loaded on %s", self.typeName);
    local overlay4WD = BetterFuelUsage.driveControl.overlay4WD;
    local overlayDiffLockFront = BetterFuelUsage.driveControl.overlayDiffLockFront;
    local overlayDiffLockBack = BetterFuelUsage.driveControl.overlayDiffLockBack;
    local height = g_currentMission.vehicleHudBg.height * 0.065 * g_gameSettings:getValue("uiScale");
    local width = height / g_screenAspectRatio;
    local yMuli = 0.13;
    overlay4WD.height = height;
    overlay4WD.width = width;
    overlayDiffLockFront.height = height;
    overlayDiffLockFront.width = width;
    overlayDiffLockBack.height = height;
    overlayDiffLockBack.width = width;
    overlay4WD.y = g_currentMission.vehicleHudBg.y + g_currentMission.vehicleHudBg.height * yMuli;
    overlayDiffLockFront.y = g_currentMission.vehicleHudBg.y + g_currentMission.vehicleHudBg.height * yMuli;
    overlayDiffLockBack.y = g_currentMission.vehicleHudBg.y + g_currentMission.vehicleHudBg.height * yMuli;
    overlay4WD.x = g_currentMission.vehicleHudBg.x + g_currentMission.vehicleHudBg.width * 0.47;
    overlayDiffLockFront.x = g_currentMission.vehicleHudBg.x + g_currentMission.vehicleHudBg.width * 0.51;
    overlayDiffLockBack.x = g_currentMission.vehicleHudBg.x + g_currentMission.vehicleHudBg.width * 0.55;
end

function BetterFuelUsage:postLoad(savegame)
    BetterFuelUsage.print("BetterFuelUsage:postLoad()");
    self.BetterFuelUsage.maxMotorPower = self.motor.maxMotorPower;
    if self.fuelFillLitersPerSecond ~= nil then
        self.fuelFillLitersPerSecond = self.fuelFillLitersPerSecond / 2;
    end
    self.BetterFuelUsage.backup.updateFuelUsage = self.updateFuelUsage;
    self.fuelUsage = (self.BetterFuelUsage.maxMotorPower / 2000) / (60 * 60 * 1000);
    if BetterFuelUsage.motorizedOverwrites[self.configFileName] ~= nil then
        self.fuelUsage = BetterFuelUsage.motorizedOverwrites[self.configFileName].fuelUsage / (60 * 60 * 1000);
    end
    if savegame ~= nil and not savegame.resetVehicles then
        self.BetterFuelUsage.useDefaultFuelUsageFunction = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key .. "#useDefaultFuelUsageFunction"), self.BetterFuelUsage.useDefaultFuelUsageFunction);
    end
    self:setFuelUsageFunction(self.BetterFuelUsage.useDefaultFuelUsageFunction, true);
end

function BetterFuelUsage:getSaveAttributesAndNodes(nodeIdent)
    local attributes = string.format("useDefaultFuelUsageFunction=\"%s\"", self.BetterFuelUsage.useDefaultFuelUsageFunction);
    local nodes = nil;
    return attributes, nodes;
end

function BetterFuelUsage:setFuelUsageFunction(default, noSend)
    BetterFuelUsage.print("BetterFuelUsage:setFuelUsageFunction(default:%s)", default);
    if not self:getIsMotorStarted() then
        self.BetterFuelUsage.useDefaultFuelUsageFunction = default;
        if not noSend then
            if default then
                self.BetterFuelUsage.fuelFade:play(g_i18n:getText("BFU_FUEL_USAGE_DEFAULT_TEXT_1"));
            else
                self.BetterFuelUsage.fuelFade:play(g_i18n:getText("BFU_FUEL_USAGE_REALISTIC_TEXT_1"));
            end
        end
        if self.isServer or noSend then
            if default then
                self.updateFuelUsage = BetterFuelUsage.defaultUpdateFuelUsage;
            else
                self.updateFuelUsage = BetterFuelUsage.realisticUpdateFuelUsage;
            end
        else
            g_client:getServerConnection():sendEvent(SetFuelUsageFunctionEvent:new(default, self));
        end
    else
        g_currentMission:showBlinkingWarning(g_i18n:getText("BFU_SET_FUEL_USAGE_ERROR_TEXT_1"), 2500);
    end
end

function BetterFuelUsage:realisticUpdateFuelUsage(dt)
    local targetFactor = 0;
    if BetterFuelUsage.gearBox ~= nil and self.mrGbMS.IsOnOff then
        targetFactor = (self:mrGbMGetCurrentRPM() - self.mrGbMS.IdleRpm) / (self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm);
        targetFactor = (targetFactor + self.actualLoadPercentage) / 2;
    else
        targetFactor = self.actualLoadPercentage;
    end
    targetFactor = Utils.clamp(targetFactor, 0, 1);
    if self.BetterFuelUsage.lastLoadFactor < targetFactor then
        self.BetterFuelUsage.lastLoadFactor = math.min(targetFactor, self.BetterFuelUsage.lastLoadFactor + dt / 3000);
    elseif self.BetterFuelUsage.lastLoadFactor > targetFactor then
        self.BetterFuelUsage.lastLoadFactor = math.max(targetFactor, self.BetterFuelUsage.lastLoadFactor - dt / 3000);
    end
    local fuelUsageFactor = 1;
    if g_currentMission.missionInfo.fuelUsageLow then
        fuelUsageFactor = 0.7;
    end
    local fuelUsed = fuelUsageFactor * self.fuelUsage * dt * self.BetterFuelUsage.lastLoadFactor;
    fuelUsed = fuelUsed + fuelUsageFactor * 0.075 * self.fuelUsage * dt;
    self.BetterFuelUsage.maxFuelUsage = fuelUsageFactor * self.fuelUsage + fuelUsageFactor * 0.075 * self.fuelUsage;
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
    return true;
end

function BetterFuelUsage:setFuelFillLevel(fuelFillLevel)
    if self.isServer then
        self.BetterFuelUsage.fuelFillLevel = fuelFillLevel;
    end
end

function BetterFuelUsage:onEnter()
end

function BetterFuelUsage:startMotor()
    self.BetterFuelUsage.lastLoadFactor = 0;
end

function BetterFuelUsage:stopMotor()
    self.BetterFuelUsage.lastLoadFactor = 0;
end

function BetterFuelUsage:update(dt)
    if self.isEntered then
        if self:getIsActiveForInput() and InputBinding.hasEvent(InputBinding.BFU_SET_FUEL_USAGE, true) then
            self:setFuelUsageFunction(not self.BetterFuelUsage.useDefaultFuelUsageFunction);
        end
        self.BetterFuelUsage.fuelFade:update(dt);
    end
    if self.isServer then
        if self:getIsMotorStarted() then
            local fuelFillLevelDiff = self.BetterFuelUsage.lastFillLevel - self.BetterFuelUsage.fuelFillLevel;
            if self.BetterFuelUsage.helperFuelUsed > 0 then
                fuelFillLevelDiff = fuelFillLevelDiff + self.BetterFuelUsage.helperFuelUsed;
                self.BetterFuelUsage.helperFuelUsed = 0;
            end
            if fuelFillLevelDiff >= 0 then
                if self.BetterFuelUsage.fuelUsed == 0 or self.BetterFuelUsage.fuelUsedDisplayTime >= 200 then
                    self.BetterFuelUsage.fuelUsed = fuelFillLevelDiff / dt;
                    self.BetterFuelUsage.fuelUsedDisplayTime = 0;
                else
                    self.BetterFuelUsage.fuelUsedDisplayTime = self.BetterFuelUsage.fuelUsedDisplayTime + dt;
                end
            end
            self.BetterFuelUsage.lastFillLevel = self.BetterFuelUsage.fuelFillLevel;
        else
            self.BetterFuelUsage.fuelUsed = 0;
        end
    end
end

function BetterFuelUsage:updateTick(dt)
    if self.exhaustEffects ~= nil then
        for _, effect in pairs(self.exhaustEffects) do
            local r = Utils.lerp(1, -0.2, self.BetterFuelUsage.lastLoadFactor);
            local g = Utils.lerp(1, -0.2, self.BetterFuelUsage.lastLoadFactor);
            local b = Utils.lerp(1, -0.2, self.BetterFuelUsage.lastLoadFactor);
            local a = Utils.lerp(0.5, 4, self.BetterFuelUsage.lastLoadFactor);
            setShaderParameter(effect.effectNode, "exhaustColor", r, g, b, a, false);
        end
    end
end

function BetterFuelUsage:writeStream(streamId, connection)
    if not connection:getIsServer() then
        streamWriteFloat32(streamId, self.BetterFuelUsage.fuelUsed);
        streamWriteFloat32(streamId, self.BetterFuelUsage.maxFuelUsage);
        streamWriteFloat32(streamId, self.BetterFuelUsage.lastLoadFactor);
    end
end

function BetterFuelUsage:readStream(streamId, connection)
    if connection:getIsServer() then
        self.BetterFuelUsage.fuelUsed = streamReadFloat32(streamId);
        self.BetterFuelUsage.maxFuelUsage = streamReadFloat32(streamId);
        self.BetterFuelUsage.lastLoadFactor = streamReadFloat32(streamId);
    end
end

function BetterFuelUsage:writeUpdateStream(streamId, connection, dirtyMask)
    if not connection:getIsServer() then
        streamWriteFloat32(streamId, self.BetterFuelUsage.fuelUsed);
        streamWriteFloat32(streamId, self.BetterFuelUsage.maxFuelUsage);
        streamWriteFloat32(streamId, self.BetterFuelUsage.lastLoadFactor);
    end
end

function BetterFuelUsage:readUpdateStream(streamId, timestamp, connection)
    if connection:getIsServer() then
        self.BetterFuelUsage.fuelUsed = streamReadFloat32(streamId);
        self.BetterFuelUsage.maxFuelUsage = streamReadFloat32(streamId);
        self.BetterFuelUsage.lastLoadFactor = streamReadFloat32(streamId);
    end
end

function BetterFuelUsage:gbDraw()
    if self.BetterFuelUsage ~= nil then
        self.mrGbMD.Fuel = self.BetterFuelUsage.fuelDisplayed;
    end
end

function BetterFuelUsage:draw()
    if self.isEntered then
        if self:getIsActiveForInput() then
            if self.BetterFuelUsage.useDefaultFuelUsageFunction then
                g_currentMission:addHelpButtonText(g_i18n:getText("BFU_SET_FUEL_USAGE_TEXT_1"), InputBinding.BFU_SET_FUEL_USAGE, nil, GS_PRIO_HIGH);
            else
                g_currentMission:addHelpButtonText(g_i18n:getText("BFU_SET_FUEL_USAGE_TEXT_2"), InputBinding.BFU_SET_FUEL_USAGE, nil, GS_PRIO_HIGH);
            end
        end
        --BetterFuelUsage.drawRightMeter(self, self.BetterFuelUsage.fuelUsed / self.BetterFuelUsage.maxFuelUsage);
        BetterFuelUsage.drawLeftMeter(self, self.BetterFuelUsage.lastLoadFactor);
        BetterFuelUsage.debugDraw(self);
        self.BetterFuelUsage.fuelFade:draw();
        local fuelUsage = self.BetterFuelUsage.fuelUsed * 1000 * 60 * 60;
        local hoursFactor = 0.25;
        if self.operatingTime ~= nil then
            local opTime = Utils.clamp(self.operatingTime / (1000 * 60 * 60), 0, 300);
            hoursFactor = (opTime / 300) * 0.25;
        end
        fuelUsage = fuelUsage * (0.5 + hoursFactor);
        if self.fuelUsageHud ~= nil then
            VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsage);
        end
        self.BetterFuelUsage.fuelDisplayed = fuelUsage;
        if fuelUsage < 10 then
            fuelUsage = string.format("%.1f", fuelUsage);
        else
            fuelUsage = string.format("%.0f", fuelUsage);
        end
        self.fuelText:draw({text = fuelUsage});
        local x, y = self.fuelText:getTextEnd();
        self.lhText:draw({position = {x = x, y = y}});
    end
end

function BetterFuelUsage:drawRightMeter(value)
    local step = math.rad(360 / 22);
    --table.insert(self.debugDrawTexts, string.format("Step --> %s", step));
    local offset = -0.455 * math.pi;
    --table.insert(self.debugDrawTexts, string.format("Offset --> %s", offset));
    value = (1 - value) * (2 * math.pi);
    local maxValue = 2 * math.pi;
    --table.insert(self.debugDrawTexts, string.format("Value --> %s", value));
    for i = math.pi + step, 2 * math.pi, step do
        local posX = math.cos(i - offset) * g_currentMission.speedMeterRadiusX * 0.835;
        local posY = math.sin(i - offset) * g_currentMission.speedMeterRadiusY * 0.835;
        local overlay = g_currentMission.speedMeterIconOverlay;
        --table.insert(self.debugDrawTexts, string.format("if %s > %s", (i - math.pi) * 2, value));
        local bColor = {overlay.r, overlay.g, overlay.b, overlay.a};
        if (i - math.pi) * 2 > value then
            if 1 - i / maxValue < 0.10 then
                overlay:setColor(0, 1, 0, 0.35);
            elseif 1 - i / maxValue < 0.35 then
                overlay:setColor(1, 1, 0, 0.35);
            else
                overlay:setColor(1, 0, 0, 0.35);
            end
        end
        overlay:setPosition(g_currentMission.vehicleSpeedBg.x + g_currentMission.vehicleSpeedBg.width * 0.5 + posX - g_currentMission.speedMeterIconOverlay.width * 0.5, g_currentMission.vehicleSpeedBg.y + g_currentMission.speedMeterCenterOffsetY + posY - g_currentMission.speedMeterIconOverlay.height * 0.5);
        overlay:render();
        overlay:setColor(unpack(bColor));
    end
end

function BetterFuelUsage:drawLeftMeter(value)
    local step = math.rad(360 / 22);
    --table.insert(self.debugDrawTexts, string.format("Step --> %s", step));
    local offset = -0.455 * math.pi;
    --table.insert(self.debugDrawTexts, string.format("Offset --> %s", offset));
    value = (1 - value) * (2 * math.pi);
    local maxValue = 2 * math.pi;
    --table.insert(self.debugDrawTexts, string.format("Value --> %s", value));
    for i = step, math.pi, step do
        local posX = math.cos(i - offset) * g_currentMission.speedMeterRadiusX * 0.835;
        local posY = math.sin(i - offset) * g_currentMission.speedMeterRadiusY * 0.835;
        local overlay = g_currentMission.speedMeterIconOverlay;
        --table.insert(self.debugDrawTexts, string.format("if %s > %s", i * 2, value));
        local bColor = {overlay.r, overlay.g, overlay.b, overlay.a};
        if i * 2 > value then
            if 1 - i / maxValue < 0.55 then
                overlay:setColor(0.0097, 0.8069, 0.0097, 1);
            elseif 1 - i / maxValue < 0.80 then
                overlay:setColor(0.8069, 0.8069, 0.0097, 1);
            else
                overlay:setColor(0.8069, 0.0097, 0.0097, 1);
            end
        end
        overlay:setPosition(g_currentMission.vehicleSpeedBg.x + g_currentMission.vehicleSpeedBg.width * 0.5 + posX - g_currentMission.speedMeterIconOverlay.width * 0.5, g_currentMission.vehicleSpeedBg.y + g_currentMission.speedMeterCenterOffsetY + posY - g_currentMission.speedMeterIconOverlay.height * 0.5);
        overlay:render();
        overlay:setColor(unpack(bColor));
    end
end

function BetterFuelUsage:debugDraw()
    if BetterFuelUsage.debug then
        local x = 0.01;
        local y = 0.99;
        local size = 0.015;
        local l_space = getTextHeight(size, "#");
        local dbgObj = self;
        if self.selectedImplement ~= nil then
            dbgObj = self.selectedImplement.object;
        end
        if dbgObj.BetterFuelUsage ~= nil then
            self.debugDrawTexts = {
                string.format("Vehicle --> %s", Utils.clearXmlDirectory(dbgObj.configFileName)),
                string.format("Vehicle Type --> %s", dbgObj.typeName),
                string.format("Vehicle Power --> %s", dbgObj.BetterFuelUsage.maxMotorPower),
                string.format("Max Fuel Usage --> %.0f (%.0f)", dbgObj.fuelUsage * 1000 * 60 * 60, dbgObj.BetterFuelUsage.maxFuelUsage * 1000 * 60 * 60),
                string.format("Motor Load --> %.2f", dbgObj.actualLoadPercentage),
                string.format("Final Motor Load --> %.2f", dbgObj.BetterFuelUsage.lastLoadFactor),
                string.format("Fuel Usage --> %.1f", dbgObj.BetterFuelUsage.fuelUsed * 1000 * 60 * 60)
            };
        else
            self.debugDrawTexts = {
                string.format("Vehicle --> %s", Utils.clearXmlDirectory(dbgObj.configFileName)),
                string.format("Vehicle Type --> %s", dbgObj.typeName)
            };
        end
        if BetterFuelUsage.gearBox ~= nil then
            local rpmRateo = (dbgObj:mrGbMGetCurrentRPM() - dbgObj.mrGbMS.IdleRpm) / (dbgObj.mrGbMS.RatedRpm - dbgObj.mrGbMS.IdleRpm);
            table.insert(self.debugDrawTexts, string.format("Motor Rpm --> min:%.0f cur:%.0f max:%.0f factor:%.2f", dbgObj.mrGbMS.IdleRpm, dbgObj:mrGbMGetCurrentRPM(), dbgObj.mrGbMS.RatedRpm, rpmRateo));
        elseif dbgObj.motor ~= nil then
            table.insert(self.debugDrawTexts, string.format("Motor Rpm --> min:%.0f cur:%.0f max:%.0f factor:%.2f", dbgObj.motor:getMinRpm(), dbgObj.motor:getEqualizedMotorRpm(), dbgObj.motor:getMaxRpm(), (dbgObj.motor:getEqualizedMotorRpm() - dbgObj.motor:getMinRpm()) / (dbgObj.motor:getMaxRpm() - dbgObj.motor:getMinRpm())));
        end
        if dbgObj.getIsTurnedOn ~= nil then
            table.insert(self.debugDrawTexts, string.format("Get is turned on --> %s", dbgObj:getIsTurnedOn()));
        end
        if dbgObj.exhaustEffects ~= nil then
            for i, effect in pairs(dbgObj.exhaustEffects) do
                local r = Utils.lerp(1, -0.15, dbgObj.BetterFuelUsage.lastLoadFactor);
                local g = Utils.lerp(1, -0.15, dbgObj.BetterFuelUsage.lastLoadFactor);
                local b = Utils.lerp(1, -0.15, dbgObj.BetterFuelUsage.lastLoadFactor);
                local a = Utils.lerp(0.5, 5, dbgObj.BetterFuelUsage.lastLoadFactor);
                table.insert(self.debugDrawTexts, string.format("Exhaust Effect [%s]--> r:%.2f, g:%.2f, b:%.2f, a:%.2f", i, r, g, b, a));
            end
        end
        for i, v in ipairs(self.debugDrawTexts) do
            renderText(x, y - (l_space * i), size, v);
        end
    end
end

function BetterFuelUsage:keyEvent(unicode, sym, modifier, isDown)
end

function BetterFuelUsage:mouseEvent(posX, posY, isDown, isUp, button)
end

function BetterFuelUsage:delete()
end
