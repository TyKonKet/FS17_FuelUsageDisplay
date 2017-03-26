--
-- Better Fuel Usage
--
-- @author TyKonKet
-- @date 26/03/2017
FSBaseMission.drawVehicleHud = function(self, vehicle)
    self.vehicleHudBg:render();
    self.vehicleSpeedBg:render();
    self.vehicleFillBg:render();
    -- speed display
    local kmh = math.max(0, vehicle:getLastSpeed() * vehicle.speedDisplayScale);
    if kmh < 0.5 then
        kmh = 0;
    end
    local speedI18N = string.format("%1d", g_i18n:getSpeed(kmh));
    local speedUnit = utf8ToUpper(g_i18n.globalI18N:getSpeedMeasuringUnit());
    self:drawSpeedMeter(Utils.clamp(kmh / (vehicle.cruiseControl.maxSpeed * 1.1), 0, 1));
    setTextColor(1, 1, 1, 1);
    setTextBold(false);
    setTextAlignment(RenderText.ALIGN_CENTER);
    renderText(self.vehicleSpeedBg.x + self.vehicleSpeedBg.width * 0.5, self.vehicleSpeedBg.y + self.speedTextOffsetY, self.speedTextSize, speedI18N);
    setTextColor(0.2122, 0.5271, 0.0307, 1);
    renderText(self.vehicleSpeedBg.x + self.vehicleSpeedBg.width * 0.5, self.vehicleSpeedBg.y + self.speedUnitTextOffsetY, self.speedUnitTextSize, speedUnit);
    setTextColor(1, 1, 1, 1);
    if vehicle.fuelUsage > 0 then
        -- fuel
        local currentFuelPercentage = 0;
        local fuelWarnPercentage = 20;
        if vehicle.fuelCapacity > 0 then
            currentFuelPercentage = (vehicle.fuelFillLevel / vehicle.fuelCapacity + 0.0001) * 100;
        end
        local fuel = string.format("%d", g_i18n:getFluid(vehicle.fuelFillLevel));
        local textColor = {1, 1, 1, 1};
        local barColor = {0.9046, 0.2874, 0.0123, 1};
        if currentFuelPercentage < fuelWarnPercentage then
            textColor = {0.8069, 0.0097, 0.0097, 1};
            barColor = {0.8069, 0.0097, 0.0097, 1};
            if currentFuelPercentage < (fuelWarnPercentage / 2) then
                if self.fuelLevelTextAlpha >= 1 then
                    self.fuelLevelTextAlphaDown = true;
                end
                if self.fuelLevelTextAlpha <= 0.2 then
                    self.fuelLevelTextAlphaDown = false;
                end
                if self.fuelLevelTextAlphaDown then
                    self.fuelLevelTextAlpha = self.fuelLevelTextAlpha - 0.02;
                else
                    self.fuelLevelTextAlpha = self.fuelLevelTextAlpha + 0.02;
                end
                textColor = {0.8069, 0.0097, 0.0097, self.fuelLevelTextAlpha};
            else
                self.fuelLevelTextAlpha = 1;
                self.fuelLevelTextAlphaDown = true;
            end
        end
        self.fuelLevelBar:setColor(unpack(barColor));
        self:drawLevelBar(self.fuelLevelBar, currentFuelPercentage / 100, fuel, textColor, g_i18n:getText("unit_liter"), {0.0865, 0.0865, 0.0865, 1}, self.fuelLevelIconOverlay);
    end
    -- fillLevels
    local fillLevelInformations = {};
    vehicle:getFillLevelInformation(fillLevelInformations);
    table.sort(fillLevelInformations, function(a, b) return a.fillLevel > b.fillLevel end);
    for i, fillLevelInformation in pairs(fillLevelInformations) do
        if fillLevelInformation ~= nil and fillLevelInformation.capacity > 0 then
            local value = 0;
            if fillLevelInformation.capacity > 0 then
                value = fillLevelInformation.fillLevel / fillLevelInformation.capacity;
            end
            local fillText = string.format("%d", fillLevelInformation.fillLevel);
            local fillLevel = string.format("%d", value * 100);
            local icon = self.fillTypeOverlays[fillLevelInformation.fillType];
            if vehicle.fuelUsage > 0 then
                if i == 1 then
                    self:drawLevelBar(self.fillLevel1Bar, value, fillText, {1, 1, 1, 1}, fillLevel .. "%", {0.0865, 0.0865, 0.0865, 1}, icon);
                else
                    self:drawLevelBar(self.fillLevel2Bar, value, fillText, {1, 1, 1, 1}, fillLevel .. "%", {0.0865, 0.0865, 0.0865, 1}, icon);
                    break;
                end
            else
                if i == 1 then
                    self:drawLevelBar(self.fuelLevelBar, value, fillText, {1, 1, 1, 1}, fillLevel .. "%", {0.0865, 0.0865, 0.0865, 1}, icon);
                elseif i == 2 then
                    self:drawLevelBar(self.fillLevel1Bar, value, fillText, {1, 1, 1, 1}, fillLevel .. "%", {0.0865, 0.0865, 0.0865, 1}, icon);
                else
                    self:drawLevelBar(self.fillLevel2Bar, value, fillText, {1, 1, 1, 1}, fillLevel .. "%", {0.0865, 0.0865, 0.0865, 1}, icon);
                    break;
                end
            end
        end
    end
    setTextAlignment(RenderText.ALIGN_LEFT);
    if vehicle.operatingTime ~= nil then
        local minutes = vehicle.operatingTime / (1000 * 60);
        local hours = math.floor(minutes / 60);
        minutes = math.floor((minutes - hours * 60) / 6);
        local width = getTextWidth(self.operatingTimeTextSize, hours .. "." .. minutes);
        width = width + self.operatingTimeOverlay.width + self.operatingTimeTextOffsetX;
        local pos = self.vehicleSpeedBg.x + (self.vehicleSpeedBg.width * 0.5) - width * 0.5;
        self.operatingTimeOverlay:setPosition(pos, nil);
        self.operatingTimeOverlay:render();
        pos = pos + self.operatingTimeOverlay.width;
        local width = getTextWidth(self.operatingTimeTextSize, hours .. ".");
        renderText(pos + self.operatingTimeTextOffsetX, self.operatingTimeOverlay.y + self.operatingTimeTextOffsetY, self.operatingTimeTextSize, hours .. ".");
        setTextColor(0.2832, 0.0091, 0.0091, 1);
        renderText(pos + self.operatingTimeTextOffsetX + width, self.operatingTimeOverlay.y + self.operatingTimeTextOffsetY, self.operatingTimeTextSize, tostring(minutes));
        setTextColor(1, 1, 1, 1);
        renderText(pos + self.operatingTimeTextOffsetX + width + self.operatingTimeTextUnitOffsetX, self.operatingTimeOverlay.y + self.operatingTimeTextOffsetY, self.operatingTimeTextSize * 0.75, "h");
    end
    -- cruise control
    setTextAlignment(RenderText.ALIGN_LEFT);
    if vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_FULL or vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE then
        self.cruiseControlOverlay:setColor(0.2122, 0.5271, 0.0307, 1);
        setTextColor(0.2122, 0.5271, 0.0307, 1);
    else
        self.cruiseControlOverlay:setColor(1, 1, 1, 1);
        setTextColor(1, 1, 1, 1);
    end
    self.cruiseControlOverlay:render();
    local speed = vehicle.cruiseControl.speed;
    if vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_FULL then
        speed = vehicle.cruiseControl.maxSpeed;
    end
    local speedLevel = string.format(g_i18n:getText("ui_cruiseControlSpeed"), g_i18n:getSpeed(speed));
    renderText(self.cruiseControlOverlay.x + self.cruiseControlOverlay.width + self.cruiseControlTextOffsetX, self.cruiseControlOverlay.y + self.cruiseControlTextOffsetY, self.cruiseControlTextSize, speedLevel);
    setTextBold(false);
    setTextColor(1, 1, 1, 1);
    setTextAlignment(RenderText.ALIGN_LEFT);
end
