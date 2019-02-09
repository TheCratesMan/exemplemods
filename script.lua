--
-- Seitenschwader.lua
-- @author MB3D-Modelling
-- @date 07/04/14
--
-- original: 


Seitenschwader = {};

function Seitenschwader.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(AnimatedVehicle, specializations);
end;

function Seitenschwader:load(savegame)

    self.setRidgeMarkerState = Seitenschwader.setRidgeMarkerState;

    self.ridgeMarkerAnimationLeftName = getXMLString(self.xmlFile, "vehicle.Seitenschwader#DoppelschwadAnimation");
    self.ridgeMarkerAnimationRightName = getXMLString(self.xmlFile, "vehicle.Seitenschwader#EinzelschwadAnimation");

    local inputButtonStr = getXMLString(self.xmlFile, "vehicle.Seitenschwader#inputButton");
    if inputButtonStr ~= nil then
        self.ridgeMarkerInputButton = InputBinding[inputButtonStr];
    end;
    self.ridgeMarkerInputButton = Utils.getNoNil(self.ridgeMarkerInputButton, InputBinding.Doppelschwad_input);

    self.ridgeMarkerOnlyActiveWhenLowered = Utils.getNoNil(getXMLBool(self.xmlFile, "vehicle.Seitenschwader#onlyActiveWhenLowered"), true);


    local ridgeMarkerLeftArea = {};
    ridgeMarkerLeftArea.start = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerLeftArea#startIndex"));
    ridgeMarkerLeftArea.width = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerLeftArea#widthIndex"));
    ridgeMarkerLeftArea.height = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerLeftArea#heightIndex"));
    local ridgeMarkerLeftTestArea = {};
    ridgeMarkerLeftTestArea.start = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerLeftTestArea#startIndex"));
    ridgeMarkerLeftTestArea.width = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerLeftTestArea#widthIndex"));
    ridgeMarkerLeftTestArea.height = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerLeftTestArea#heightIndex"));
    if ridgeMarkerLeftArea.start ~= nil and ridgeMarkerLeftArea.width ~= nil and ridgeMarkerLeftArea.height ~= nil and
       ridgeMarkerLeftTestArea.start ~= nil and ridgeMarkerLeftTestArea.width ~= nil and ridgeMarkerLeftTestArea.height ~= nil
    then
        self.ridgeMarkerLeftArea = ridgeMarkerLeftArea;
        self.ridgeMarkerLeftTestArea = ridgeMarkerLeftTestArea;
    end;

    local ridgeMarkerRightArea = {};
    ridgeMarkerRightArea.start = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerRightArea#startIndex"));
    ridgeMarkerRightArea.width = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerRightArea#widthIndex"));
    ridgeMarkerRightArea.height = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerRightArea#heightIndex"));
    local ridgeMarkerRightTestArea = {};
    ridgeMarkerRightTestArea.start = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerRightTestArea#startIndex"));
    ridgeMarkerRightTestArea.width = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerRightTestArea#widthIndex"));
    ridgeMarkerRightTestArea.height = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.ridgeMarkerRightTestArea#heightIndex"));
    if ridgeMarkerRightArea.start ~= nil and ridgeMarkerRightArea.width ~= nil and ridgeMarkerRightArea.height ~= nil and
       ridgeMarkerRightTestArea.start ~= nil and ridgeMarkerRightTestArea.width ~= nil and ridgeMarkerRightTestArea.height ~= nil
    then
        self.ridgeMarkerRightArea = ridgeMarkerRightArea;
        self.ridgeMarkerRightTestArea = ridgeMarkerRightTestArea;
    end;

    self.ridgeMarkerState = 0; -- 0 = none, 1 = left, 2 = right
end;

function Seitenschwader:delete()
end;

function Seitenschwader:readStream(streamId, connection)
    local state = streamReadUIntN(streamId, 2);
    self:setRidgeMarkerState(state, true);
end;

function Seitenschwader:writeStream(streamId, connection)
    streamWriteUIntN(streamId, self.ridgeMarkerState, 2);
end;

function Seitenschwader:readUpdateStream(streamId, timestamp, connection)
end;

function Seitenschwader:writeUpdateStream(streamId, connection, dirtyMask)
end;

function Seitenschwader:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
    return BaseMission.VEHICLE_LOAD_OK;
end;

function Seitenschwader:setRelativePosition(positionX, offsetY, positionZ, yRot)
end;

function Seitenschwader:mouseEvent(posX, posY, isDown, isUp, button)
end;

function Seitenschwader:keyEvent(unicode, sym, modifier, isDown)
end;

function Seitenschwader:update(dt)
    if self.isClient and self:getIsActiveForInput() then
        if InputBinding.hasEvent(self.ridgeMarkerInputButton) then
            local newState = self.ridgeMarkerState + 1;
            if newState > 2 then
                newState = 0;
            end;
            self:setRidgeMarkerState(newState);
        end;
    end;
end;

function Seitenschwader:updateTick(dt)
    if self:getIsActive() then
        if self.isServer and (not self.ridgeMarkerOnlyActiveWhenLowered or self:isLowered(false)) then
            local area;
            local testArea;
            if self.ridgeMarkerState == 1 then
                if self:getAnimationTime(self.ridgeMarkerAnimationLeftName) > 0.99 then
                    area = self.ridgeMarkerLeftArea;
                    testArea = self.ridgeMarkerLeftTestArea;
                end;
            elseif self.ridgeMarkerState == 2 then
                if self:getAnimationTime(self.ridgeMarkerAnimationRightName) > 0.99 then
                    area = self.ridgeMarkerRightArea;
                    testArea = self.ridgeMarkerRightTestArea;
                end;
            end;
            if area ~= nil then
                local x,_,z = getWorldTranslation(testArea.start);
                if g_currentMission:getIsFieldOwnedAtWorldPos(x,z) then
                    local x1,_,z1 = getWorldTranslation(testArea.width);
                    local x2,_,z2 = getWorldTranslation(testArea.height);

                    local cultivatorArea = Utils.getDensity(g_currentMission.terrainDetailId, g_currentMission.cultivatorChannel, x, z, x1, z1, x2, z2);
                    local ploughArea = Utils.getDensity(g_currentMission.terrainDetailId, g_currentMission.ploughChannel, x, z, x1, z1, x2, z2);

                    local x,_,z = getWorldTranslation(area.start);
                    local x1,_,z1 = getWorldTranslation(area.width);
                    local x2,_,z2 = getWorldTranslation(area.height);

                    local wx,wz = x1-x, z1-z;
                    local hx,hz = x2-x, z2-z;

                    local worldToDensity = g_currentMission.terrainDetailMapSize / g_currentMission.terrainSize;
                    x = math.floor(x*worldToDensity+0.5)/worldToDensity;
                    z = math.floor(z*worldToDensity+0.5)/worldToDensity;

                    x1, z1 = x+wx, z+wz;
                    x2, z2 = x+hx, z+hz;

                    local cuttingAreasSend = {};
                    table.insert(cuttingAreasSend, {x,z,x1,z1,x2,z2});

                    if cultivatorArea >= ploughArea then
                        PloughAreaEvent.runLocally(cuttingAreasSend, true);
                        g_server:broadcastEvent(PloughAreaEvent:new(cuttingAreasSend, true, true));
                    else
                        CultivatorAreaEvent.runLocally(cuttingAreasSend, true);
                        g_server:broadcastEvent(CultivatorAreaEvent:new(cuttingAreasSend, true, true));
                    end;
                end
            end;
        end;
    end;
end;

function Seitenschwader:draw()
    if self.ridgeMarkerAnimationLeftName ~= nil and self.ridgeMarkerAnimationRightName ~= nil then
        if self:getIsActiveForInput(true) then
            g_currentMission:addHelpButtonText(g_i18n:getText("SeitenschwaderHelpText"), self.ridgeMarkerInputButton);
        end
    end;
end;

--[[function Seitenschwader:onDetach()
    if self.deactivateOnDetach then
        Seitenschwader.onDeactivate(self);
    end;
end;

function Seitenschwader:onLeave()
    if self.deactivateOnLeave then
        Seitenschwader.onDeactivate(self);
    end;
end;

function Seitenschwader:onDeactivate()
end;]]

function Seitenschwader:aiTurnOn()
    self:setRidgeMarkerState(0, true);
end

function Seitenschwader:aiRotateLeft()
    --self:setRidgeMarkerState(2, true);
end;

function Seitenschwader:aiRotateRight()
    --self:setRidgeMarkerState(1, true);
end;

function Seitenschwader:setIsTurnedOn(turnedOn, noEventSend)
    if not turnedOn then
        self:setRidgeMarkerState(0, true);
    elseif self.ridgeMarkerState == 0 then
        --self:setRidgeMarkerState(1, true);
    end;
end;

function Seitenschwader:setRidgeMarkerState(state, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(RidgeMarkerSetStateEvent:new(self, state), nil, nil, self);
        else
            g_client:getServerConnection():sendEvent(RidgeMarkerSetStateEvent:new(self, state));
        end;
    end
    self.ridgeMarkerState = state;
    if self.ridgeMarkerAnimationLeftName ~= nil then
        if self.ridgeMarkerState == 1 then
            self:playAnimation(self.ridgeMarkerAnimationLeftName, 1, nil, true);
        else
            self:playAnimation(self.ridgeMarkerAnimationLeftName, -1, nil, true);
        end;
    end;
    if self.ridgeMarkerAnimationRightName ~= nil then
        if self.ridgeMarkerState == 2 then
            self:playAnimation(self.ridgeMarkerAnimationRightName, 1, nil, true);
        else
            self:playAnimation(self.ridgeMarkerAnimationRightName, -1, nil, true);
        end;
    end;
end;