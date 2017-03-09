--
-- BetterFuelUsage
--
-- @author  TyKonKet
-- @date 27/10/2016
BetterFuelUsage = {};
BetterFuelUsage.name = "BetterFuelUsage";
BetterFuelUsage.debug = BetterFuelUsageRH.debug;
BetterFuelUsage.dir = g_currentModDirectory;
BetterFuelUsage.driveControl = nil;
BetterFuelUsage.vehiclesOverwrites = {};

function BetterFuelUsage.prerequisitesPresent(specializations)
    if SpecializationUtil.hasSpecialization(SpecializationUtil.getSpecialization("motorized"), specializations) then
        return true;
    else
        return false;
    end
end

function BetterFuelUsage.initSpecialization()
    local dc = SpecializationUtil.getSpecialization("ZZZ_driveControl.driveControl");
    if dc ~= nil then
        dc.load = Utils.appendedFunction(dc.load, BetterFuelUsage.dcLoad);
        BetterFuelUsage.driveControl = dc;
    end
    local xml = loadXMLFile("vehiclesOverwritesXML", BetterFuelUsage.dir .. "vehiclesOverwrites.xml");
    local index = 0;
    while true do
        local query = string.format("vehiclesOverwrites.vehicle(%d)", index);
        if not hasXMLProperty(xml, query) then
            break;
        end
        local i3d = getXMLString(xml, string.format("%s#i3d", query));
        local fuelUsage = getXMLFloat(xml, string.format("%s#fuelUsage", query));
        BetterFuelUsage.vehiclesOverwrites[i3d] = {};
        BetterFuelUsage.vehiclesOverwrites[i3d].fuelUsage = fuelUsage;
        BetterFuelUsage.print(("vehiclesOverwrite -> i3d:%s fuelUsage:%s"):format(i3d, fuelUsage));
        index = index + 1;
    end
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
    self.BetterFuelUsage.fuelUsedDisplayTime = 0;
    self.BetterFuelUsage.maxFuelUsage = 1;
    self.BetterFuelUsage.fuelFillLevel = 0;
    self.BetterFuelUsage.lastFillLevel = 0;
    self.BetterFuelUsage.lastLoadFactor = 0;
    self.BetterFuelUsage.finalLoadFactor = 0;
    self.BetterFuelUsage.helperFuelUsed = 0;
    self.BetterFuelUsage.crushingLoad = 0;
    self.BetterFuelUsage.woodHarvesterLoad = 0;
    self.BetterFuelUsage.selfPropelledPotatoHarvesterLoad = 0;
    self.BetterFuelUsage.loaderVehicleLoad = 0;
    self.BetterFuelUsage.fuelFade = FadeEffect:new({position = {x = 0.483, y = 0.94}, size = 0.028, shadow = true, shadowPosition = {x = 0.0025, y = 0.0035}, statesTime = {0.85, 0.5, 0.45}});
end

function BetterFuelUsage:load(savegame)
    BetterFuelUsage.print(BetterFuelUsage.name .. " loaded on " .. self.typeName);
    self.setFuelUsageFunction = BetterFuelUsage.setFuelUsageFunction;
    local x = g_currentMission.vehicleHudBg.x + g_currentMission.vehicleHudBg.width * 0.518;
    local y = g_currentMission.vehicleHudBg.y + g_currentMission.vehicleHudBg.height * 0.798;
    self.fuelText = DynamicText:new({position = {x = x, y = y}, size = 0.02});
    self.lhText = DynamicText:new({size = 0.0112, text = " l/h", color = {r = 1, g = 1, b = 1, a = 0.08}});
end

function BetterFuelUsage:dcLoad()
    BetterFuelUsage.print("driveControl loaded on " .. self.typeName);
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
    self.BetterFuelUsage.backup.updateFuelUsage = self.updateFuelUsage;
    self.fuelUsage = (self.motor.maxMotorPower / 2000) / (60 * 60 * 1000);
    if BetterFuelUsage.vehiclesOverwrites[self.i3dFilename] ~= nil then
        self.fuelUsage = BetterFuelUsage.vehiclesOverwrites[self.i3dFilename].fuelUsage / (60 * 60 * 1000);
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
    BetterFuelUsage.print(("BetterFuelUsage:setFuelUsageFunction(default:%s)"):format(default));
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
    local rpmFactor = (self.motor:getLastMotorRpm() - self.motor:getMinRpm()) / (self.motor:getMaxRpm() - self.motor:getMinRpm());
    local smoothFactor = 100;
    local loadFactor = (self.actualLoadPercentage + (self.BetterFuelUsage.lastLoadFactor * (50 * rpmFactor + 10))) / (50 * rpmFactor + 11);
    self.BetterFuelUsage.lastLoadFactor = loadFactor;
    if self.crushingTime ~= nil then
        local crushingLoad = 0;
        if self.crushingTime > 0 then
            crushingLoad = 0.75;
        end
        self.BetterFuelUsage.crushingLoad = (crushingLoad + (self.BetterFuelUsage.crushingLoad * smoothFactor)) / (smoothFactor + 1);
        loadFactor = loadFactor + self.BetterFuelUsage.crushingLoad;
    end
    if self.typeName == "woodHarvester" then
        local woodHarvesterLoad = 0;
        if self:getIsTurnedOn() then
            if self.cutParticleSystemsActive then
                woodHarvesterLoad = 0.75;
            else
                woodHarvesterLoad = 0.18;
            end
        end
        self.BetterFuelUsage.woodHarvesterLoad = (woodHarvesterLoad + (self.BetterFuelUsage.woodHarvesterLoad * smoothFactor)) / (smoothFactor + 1);
        loadFactor = loadFactor + self.BetterFuelUsage.woodHarvesterLoad;
    end
    if self.typeName == "selfPropelledPotatoHarvester" then
        local selfPropelledPotatoHarvesterLoad = 0;
        if self:getIsTurnedOn() then
            selfPropelledPotatoHarvesterLoad = 0.3;
        end
        self.BetterFuelUsage.selfPropelledPotatoHarvesterLoad = (selfPropelledPotatoHarvesterLoad + (self.BetterFuelUsage.selfPropelledPotatoHarvesterLoad * smoothFactor)) / (smoothFactor + 1);
        loadFactor = loadFactor + self.BetterFuelUsage.selfPropelledPotatoHarvesterLoad;
    end
    if self.typeName == "loaderVehicle" then
        local loaderVehicleLoad = 0;
        if self:getIsTurnedOn() then
            loaderVehicleLoad = 0.2;
        end
        self.BetterFuelUsage.loaderVehicleLoad = (loaderVehicleLoad + (self.BetterFuelUsage.loaderVehicleLoad * smoothFactor)) / (smoothFactor + 1);
        loadFactor = loadFactor + self.BetterFuelUsage.loaderVehicleLoad;
    end
    self.BetterFuelUsage.finalLoadFactor = loadFactor;
    local fuelUsageFactor = 1.1;
    if g_currentMission.missionInfo.fuelUsageLow then
        fuelUsageFactor = 0.7;
    end
    local fuelUsed = fuelUsageFactor * self.fuelUsage * dt * loadFactor;
    fuelUsed = fuelUsed + fuelUsageFactor * 0.05 * self.fuelUsage * dt;
    self.BetterFuelUsage.maxFuelUsage = fuelUsageFactor * self.fuelUsage + fuelUsageFactor * 0.05 * self.fuelUsage;
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
--if self.BetterFuelUsage.useDefaultFuelUsageFunction then
--    self.BetterFuelUsage.fuelFade:play(g_i18n:getText("BFU_FUEL_USAGE_DEFAULT_TEXT_1"));
--else
--    self.BetterFuelUsage.fuelFade:play(g_i18n:getText("BFU_FUEL_USAGE_REALISTIC_TEXT_1"));
--end
end

function BetterFuelUsage:update(dt)
    if self.isEntered then
        if InputBinding.hasEvent(InputBinding.BFU_SET_FUEL_USAGE, true) then
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
                if self.BetterFuelUsage.fuelUsed == 0 or self.BetterFuelUsage.fuelUsedDisplayTime >= 70 then
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
    BetterFuelUsage.debugDraw(self);
    self.BetterFuelUsage.fuelFade:draw();
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
    if self.fuelUsageHud ~= nil then
        VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsage);
    end
    if fuelUsage < 10 then
        fuelUsage = string.format("%.1f", fuelUsage);
    else
        fuelUsage = string.format("%.0f", fuelUsage);
    end
    self.fuelText:draw({text = fuelUsage, color = {r = color[1], g = color[2], b = color[3], a = color[4]}});
    local x, y = self.fuelText:getTextEnd();
    self.lhText:draw({position = {x = x, y = y}});
end

function BetterFuelUsage:debugDraw()
    if BetterFuelUsage.debug then
        local x = 0.01;
        local y = 0.99;
        local size = 0.015;
        local l_space = getTextHeight(size, "#");
        local texts = {
            string.format("Vehicle name --> %s", self.i3dFilename),
            string.format("Vehicle Type --> %s", self.typeName),
            string.format("Vehicle Power --> %s", self.motor.maxMotorPower),
            string.format("Fuel Usage --> %s (%s)", self.fuelUsage, self.fuelUsage * 1000 * 60 * 60),
            string.format("Final Fuel Usage --> %s (%s)", self.BetterFuelUsage.maxFuelUsage, self.BetterFuelUsage.maxFuelUsage * 1000 * 60 * 60),
            string.format("Motor Rpm --> min:%s cur:%s max:%s", self.motor:getMinRpm(), self.motor:getLastMotorRpm(), self.motor:getMaxRpm()),
            string.format("Motor Load --> %s", self.actualLoadPercentage),
            string.format("Final Motor Load --> %s", self.BetterFuelUsage.finalLoadFactor)
        };
        if self.getIsTurnedOn ~= nil then
            table.insert(texts, 9, string.format("Get is turned on --> %s", self:getIsTurnedOn()));
        end
        for i, v in ipairs(texts) do
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
