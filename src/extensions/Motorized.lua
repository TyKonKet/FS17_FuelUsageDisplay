--
--Better Fuel Usage
--
--@author TyKonKet
--@date 30/03/2017
function Motorized:update(dt)
    if self.isClient then
        if self.isEntered and self:getIsActiveForInput(false) and not g_currentMission.missionInfo.automaticMotorStartEnabled then
            if InputBinding.hasEvent(InputBinding.TOGGLE_MOTOR_STATE) then
                if not self:getIsHired() then
                    if self.isMotorStarted then
                        self:stopMotor()
                    else
                        self:startMotor()
                    end
                end
            end
        end
    end
    
    Utils.updateRotationNodes(self, self.motorTurnedOnRotationNodes, dt, self:getIsMotorStarted());
    
    if self:getIsMotorStarted() then
        local accInput = 0;
        if self.axisForward ~= nil then
            accInput = -self.axisForward;
        end
        if self.cruiseControl ~= nil and self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_OFF then
            accInput = 1;
        end
        if self.isClient then
            if self:getIsActiveForSound() then
                if not SoundUtil.isSamplePlaying(self.sampleMotorStart, 1.5 * dt) then
                    SoundUtil.playSample(self.sampleMotor, 0, 0, nil);
                    SoundUtil.playSample(self.sampleMotorRun, 0, 0, 0);
                    SoundUtil.playSample(self.sampleMotorLoad, 0, 0, 0);
                    SoundUtil.playSample(self.sampleGearbox, 0, 0, 0);
                    SoundUtil.playSample(self.sampleRetarder, 0, 0, 0);
                    
                    if self.brakeLightsVisibility then
                        self.brakeLightsVisibilityWasActive = true;
                        self.maxDecelerationDuringBrake = math.max(self.maxDecelerationDuringBrake, math.abs(accInput));
                    end
                    if self.brakeLightsVisibilityWasActive and not self.brakeLightsVisibility then
                        self.brakeLightsVisibilityWasActive = false;
                        
                        local factor = self.maxDecelerationDuringBrake;
                        self.maxDecelerationDuringBrake = 0;
                        
                        local airConsumption = self:getMaximalAirConsumptionPerFullStop();
                        -- print( string.format(" -----> factor = %.2f // %.2f ", factor, airConsumption) );
                        airConsumption = factor * airConsumption;
                        self.brakeCompressor.fillLevel = math.max(0, self.brakeCompressor.fillLevel - airConsumption); --implementCount * self.brakeCompressor.capacity * 0.05);
                    end
                    
                    if self.brakeCompressor.fillLevel < self.brakeCompressor.refillFilllevel then
                        self.brakeCompressor.doFill = true;
                    end
                    if self.brakeCompressor.doFill and self.brakeCompressor.fillLevel == self.brakeCompressor.capacity then
                        self.brakeCompressor.doFill = false;
                    end
                    if self.brakeCompressor.doFill then
                        self.brakeCompressor.fillLevel = math.min(self.brakeCompressor.capacity, self.brakeCompressor.fillLevel + self.brakeCompressor.fillSpeed * dt);
                    end
                    
                    if Vehicle.debugRendering then
                        renderText(0.3, 0.16, getCorrectTextSize(0.02), string.format("brakeCompressor.fillLevel = %.1f", 100 * (self.brakeCompressor.fillLevel / self.brakeCompressor.capacity)));
                    end
                    
                    if not self.brakeCompressor.doFill then
                        if self.brakeCompressor.runSoundActive then
                            SoundUtil.stopSample(self.sampleBrakeCompressorRun, true);
                            SoundUtil.playSample(self.sampleBrakeCompressorStop, 1, 0, nil);
                            self.brakeCompressor.startSoundPlayed = false;
                            self.brakeCompressor.runSoundActive = false;
                        end
                    elseif not SoundUtil.isSamplePlaying(self.sampleBrakeCompressorStop, 1.5 * dt) then
                        if not self.brakeCompressor.startSoundPlayed then
                            self.brakeCompressor.startSoundPlayed = true;
                            SoundUtil.playSample(self.sampleBrakeCompressorStart, 1, 0, nil);
                        else
                            if not SoundUtil.isSamplePlaying(self.sampleBrakeCompressorStart, 1.5 * dt) and not self.brakeCompressor.runSoundActive then
                                self.brakeCompressor.runSoundActive = true;
                                SoundUtil.playSample(self.sampleBrakeCompressorRun, 0, 0, nil);
                            end
                        end
                    end
                end
                
                if self.compressionSoundTime <= g_currentMission.time then
                    SoundUtil.playSample(self.sampleAirReleaseValve, 1, 0, nil);
                    self.compressionSoundTime = g_currentMission.time + math.random(10000, 40000);
                end
                
                if self.sampleCompressedAir.sample ~= nil then
                    if self.movingDirection > 0 and self.lastSpeed > self.motor:getMaximumForwardSpeed() * 0.0002 then -- faster than 20% of max speed
                        if accInput < -0.05 then
                            -- play the compressor sound if we drive fast enough and brake
                            if not self.compressedAirSoundEnabled then
                                SoundUtil.playSample(self.sampleCompressedAir, 1, 0, nil);
                                self.compressedAirSoundEnabled = true;
                            end
                        else
                            self.compressedAirSoundEnabled = false;
                        end
                    end
                end
                
                SoundUtil.stop3DSample(self.sampleMotor);
                SoundUtil.stop3DSample(self.sampleMotorRun);
                SoundUtil.stop3DSample(self.sampleGearbox);
                SoundUtil.stop3DSample(self.sampleRetarder);
            else
                SoundUtil.play3DSample(self.sampleMotor);
                SoundUtil.play3DSample(self.sampleMotorRun);
            end
            
            -- adjust pitch and volume of samples
            if (self.wheels ~= nil and table.getn(self.wheels) > 0) or (self.dummyWheels ~= nil and table.getn(self.dummyWheels) > 0) then
                
                if self.sampleReverseDrive.sample ~= nil then
                    if (accInput < 0 or accInput == 0) and (self:getLastSpeed() > 3 and self.movingDirection ~= self.reverserDirection) then
                        if self:getIsActiveForSound() then
                            SoundUtil.playSample(self.sampleReverseDrive, 0, 0, nil);
                            SoundUtil.stop3DSample(self.sampleReverseDrive);
                        else
                            SoundUtil.play3DSample(self.sampleReverseDrive);
                            SoundUtil.stopSample(self.sampleReverseDrive);
                        end
                    else
                        SoundUtil.stopSample(self.sampleReverseDrive);
                        SoundUtil.stop3DSample(self.sampleReverseDrive);
                    end
                end
                
                local minRpm = self.motor:getMinRpm();
                local maxRpm = self.motor:getMaxRpm();
                
                local maxSpeed;
                if self.movingDirection >= 0 then
                    maxSpeed = self.motor:getMaximumForwardSpeed() * 0.001;
                else
                    maxSpeed = self.motor:getMaximumBackwardSpeed() * 0.001;
                end
                
                local motorRpm = self.motor:getEqualizedMotorRpm();
                -- Increase the motor rpm to the max rpm if faster than 75% of the full speed
                if self.movingDirection > 0 and self.lastSpeed > 0.75 * maxSpeed and motorRpm < maxRpm then
                    motorRpm = motorRpm + (maxRpm - motorRpm) * math.min((self.lastSpeed - 0.75 * maxSpeed) / (0.25 * maxSpeed), 1);
                end
                -- The actual rpm offset is 50% from the motor and 50% from the speed
                local targetRpmOffset = (motorRpm - minRpm) * 0.5 + math.min(self.lastSpeed / maxSpeed, 1) * (maxRpm - minRpm) * 0.5;
                
                --if Vehicle.debugRendering then
                renderText(0.3, 0.14, getCorrectTextSize(0.02), string.format("getLastMotorRpm() = %.2f", self.motor:getLastMotorRpm()));
                renderText(0.3, 0.12, getCorrectTextSize(0.02), string.format("getEqualziedMotorRpm() = %.2f", self.motor:getEqualizedMotorRpm()));
                renderText(0.3, 0.10, getCorrectTextSize(0.02), string.format("targetRpmOffset = %.2f", targetRpmOffset));
                --end
                local alpha = math.pow(0.01, dt * 0.001);
                local roundPerMinute = targetRpmOffset + alpha * (self.lastRoundPerMinute - targetRpmOffset);
                renderText(0.3, 0.08, getCorrectTextSize(0.02), string.format("roundPerMinute = %.2f", roundPerMinute));
                self.lastRoundPerMinute = roundPerMinute;
                
                local roundPerSecondSmoothed = roundPerMinute / 60;
                renderText(0.3, 0.06, getCorrectTextSize(0.02), string.format("roundPerSecondSmoothed = %.2f", roundPerSecondSmoothed));
                
                if self.sampleMotor.sample ~= nil then
                    local motorSoundPitch = math.min(self.sampleMotor.pitchOffset + self.motorSoundPitchScale * math.abs(roundPerSecondSmoothed), self.motorSoundPitchMax);
                    SoundUtil.setSamplePitch(self.sampleMotor, motorSoundPitch);
                    local deltaVolume = (self.sampleMotor.volume - self.motorSoundVolumeMin) * math.max(0.0, math.min(1.0, self:getLastSpeed() / self.motorSoundVolumeMinSpeed))
                    SoundUtil.setSampleVolume(self.sampleMotor, math.max(self.motorSoundVolumeMin, self.sampleMotor.volume - deltaVolume));
                end
                
                if self.sampleMotorRun.sample ~= nil then
                    if self.motorSoundLoadFactor < self.BetterFuelUsage.lastLoadFactor then
                        self.motorSoundLoadFactor = math.min(self.BetterFuelUsage.lastLoadFactor, self.motorSoundLoadFactor + dt / 3000);
                    elseif self.motorSoundLoadFactor > self.BetterFuelUsage.lastLoadFactor then
                        self.motorSoundLoadFactor = math.max(self.BetterFuelUsage.lastLoadFactor, self.motorSoundLoadFactor - dt / 2000);
                    end
                    if self.sampleMotorLoad.sample == nil then
                        self.motorSoundRunVolume = (self.motorSoundLoadFactor + roundPerMinute / (maxRpm - minRpm));
                        self.motorSoundRunVolume = Utils.clamp(self.motorSoundRunVolume, 0.0, 1.0);
                        if math.abs(accInput) < 0.01 or Utils.sign(accInput) ~= self.movingDirection then
                            self.motorSoundRunVolume = self.motorSoundRunVolume * 0.8;
                        end
                        self.motorSoundRunVolume = self.motorSoundRunVolume;
                        SoundUtil.setSampleVolume(self.sampleMotorRun, math.max(self.motorSoundRunMinimalVolumeFactor, self.motorSoundRunVolume * self.sampleMotorRun.volume));
                        if Vehicle.debugRendering then
                            renderText(0.3, 0.08, getCorrectTextSize(0.02), string.format("runVolume = %.2f", self.motorSoundRunVolume));
                        end
                    else
                        self.motorSoundRunVolume = roundPerMinute / (maxRpm - minRpm);
                        self.motorSoundLoadVolume = Utils.clamp(self.motorSoundLoadFactor + (0.3 * self.motorSoundRunVolume), 0.0, 1.0);
                        self.motorSoundRunPitch = self.sampleMotorRun.pitchOffset + (self.motorSoundRunPitchMax - self.sampleMotorRun.pitchOffset) * self.motorSoundRunVolume;
                        self.motorSoundLoadPitch = self.sampleMotorLoad.pitchOffset + (self.motorSoundLoadPitchMax - self.sampleMotorLoad.pitchOffset) * Utils.clamp(self.motorSoundLoadFactor + self.motorSoundRunVolume, 0.0, 1.0);
                        if math.abs(accInput) < 0.01 or Utils.sign(accInput) ~= self.movingDirection then
                            self.motorSoundRunVolume = self.motorSoundRunVolume * 0.9;
                            self.motorSoundLoadVolume = self.motorSoundLoadVolume * 0.9;
                        end
                        SoundUtil.setSampleVolume(self.sampleMotorRun, math.max(self.motorSoundRunMinimalVolumeFactor, self.motorSoundRunVolume * self.sampleMotorRun.volume));
                        SoundUtil.setSampleVolume(self.sampleMotorLoad, math.max(self.motorSoundLoadMinimalVolumeFactor, self.motorSoundLoadVolume * self.sampleMotorLoad.volume));
                        SoundUtil.setSamplePitch(self.sampleMotorRun, self.motorSoundRunPitch);
                        SoundUtil.setSamplePitch(self.sampleMotorLoad, self.motorSoundLoadPitch);
                    end
                end
                
                if self.sampleGearbox.sample ~= nil then
                    local speedFactor = Utils.clamp((self:getLastSpeed() - 1) / math.ceil(self.motor:getMaximumForwardSpeed() * 3.6), 0, 1);
                    local pitchGearbox = Utils.lerp(self.sampleGearbox.pitchOffset, self.gearboxSoundPitchMax, speedFactor ^ self.gearboxSoundPitchExponent);
                    local volumeGearbox = Utils.lerp(self.sampleGearbox.volume, self.gearboxSoundVolumeMax, speedFactor);
                    
                    if self.reverserDirection ~= self.movingDirection then
                        speedFactor = Utils.clamp((self:getLastSpeed() - 1) / math.ceil(self.motor:getMaximumBackwardSpeed() * 3.6), 0, 1);
                        pitchGearbox = Utils.lerp(self.sampleGearbox.pitchOffset, self.gearboxSoundReversePitchMax, speedFactor ^ self.gearboxSoundPitchExponent);
                        volumeGearbox = Utils.lerp(self.sampleGearbox.volume, self.gearboxSoundReverseVolumeMax, speedFactor);
                    end
                    
                    SoundUtil.setSamplePitch(self.sampleGearbox, pitchGearbox);
                    SoundUtil.setSampleVolume(self.sampleGearbox, volumeGearbox);
                end
                
                if self.sampleRetarder.sample ~= nil then
                    local speedFactor = Utils.clamp((self:getLastSpeed() - self.retarderSoundMinSpeed) / math.ceil(self.motor:getMaximumForwardSpeed() * 3.6), 0, 1);
                    local pitchGearbox = Utils.lerp(self.sampleRetarder.pitchOffset, self.retarderSoundPitchMax, speedFactor);
                    SoundUtil.setSamplePitch(self.sampleRetarder, pitchGearbox);
                    
                    local volumeRetarder = Utils.lerp(self.sampleRetarder.volume, self.retarderSoundVolumeMax, speedFactor);
                    local targetVolume = 0.0;
                    if accInput <= 0.0 and self:getLastSpeed() > self.retarderSoundMinSpeed and self.reverserDirection == self.movingDirection then
                        if accInput > -0.9 then
                            targetVolume = volumeRetarder;
                        else
                            targetVolume = self.sampleRetarder.volume;
                        end
                    end
                    
                    if self.retarderSoundActualVolume < targetVolume then
                        self.retarderSoundActualVolume = math.min(targetVolume, self.retarderSoundActualVolume + dt / self.axisSmoothTime);
                    elseif self.retarderSoundActualVolume > targetVolume then
                        self.retarderSoundActualVolume = math.max(targetVolume, self.retarderSoundActualVolume - dt / self.axisSmoothTime);
                    end
                    SoundUtil.setSampleVolume(self.sampleRetarder, self.retarderSoundActualVolume);
                    
                    if Vehicle.debugRendering then
                        renderText(0.8, 0.44, getCorrectTextSize(0.02), string.format("retarderSoundActualVolume = %.2f", self.retarderSoundActualVolume));
                        renderText(0.8, 0.42, getCorrectTextSize(0.02), string.format("getLastSpeed() = %.2f", self:getLastSpeed()));
                    end
                end
                
                if self.sampleBrakeCompressorRun.sample ~= nil then
                    local pitchCompressor = math.min(self.sampleBrakeCompressorRun.pitchOffset + self.brakeCompressorRunSoundPitchScale * math.abs(roundPerSecondSmoothed), self.brakeCompressorRunSoundPitchMax);
                    SoundUtil.setSamplePitch(self.sampleBrakeCompressorRun, pitchCompressor);
                end
            
            end
        end
        
        if self.isServer then
            if not self:getIsHired() then
                if self.lastMovedDistance > 0 then
                    g_currentMission.missionStats:updateStats("traveledDistance", self.lastMovedDistance * 0.001);
                end
            end
            
            self:updateFuelUsage(dt)
        end
    end
end
