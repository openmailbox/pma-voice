--- removes a player from the call for everyone in the call.
---@param source number the player to remove from the call
---@param callChannel number the call channel to remove them from
function removePlayerFromCall(source, callChannel)
    debug.log(('[phone] Removed %s from call %s'):format(source, callChannel))

    callData[callChannel] = callData[callChannel] or {}
    for player, _ in pairs(callData[callChannel]) do
        TriggerClientEvent('pma-voice:removePlayerFromCall', player, source)
    end
    callData[callChannel][source] = nil
    voiceData[source] = voiceData[source] or defaultTable(source)
    voiceData[source].call = 0
end

--- adds a player to a call
---@param source number the player to add to the call 
---@param callChannel number the call channel to add them to
function addPlayerToCall(source, callChannel)
    debug.log(('[phone] Added %s to call %s'):format(source, callChannel))
    -- check if the channel exists, if it does set the varaible to it
    -- if not create it (basically if not callData make callData)
    callData[callChannel] = callData[callChannel] or {}
    for player, _ in pairs(callData[callChannel]) do
        -- don't need to send to the source because they're about to get sync'd!
        if player ~= source then
            TriggerClientEvent('pma-voice:addPlayerToCall', player, source)
        end
    end
    callData[callChannel][source] = false
    voiceData[source] = voiceData[source] or defaultTable(source)
    voiceData[source].call = callChannel
    TriggerClientEvent('pma-voice:syncCallData', source, callData[callChannel])
end

--- set the players call channel
---@param source number the player to set the call off
---@param callChannel number the channel to set the player to (or 0 to remove them from any call channel)
function setPlayerCall(source, callChannel)
	if GetConvarInt('voice_enablePhones', 1) ~= 1 then return end
    if GetInvokingResource() then
        -- got set in a export, need to update the client to tell them that their radio
        -- changed
        TriggerClientEvent('pma-voice:clSetPlayerCall', source, callChannel)
    end
    voiceData[source] = voiceData[source] or defaultTable(source)
    local plyVoice = voiceData[source]
    local callChannel = tonumber(callChannel)

    if callChannel ~= 0 and plyVoice.call == 0 then
        addPlayerToCall(source, callChannel)
    elseif callChannel == 0 then
        removePlayerFromCall(source, plyVoice.call)
    elseif plyVoice.call > 0 then
        removePlayerFromCall(source, plyVoice.call)
        addPlayerToCall(source, callChannel)
    end
end
exports('setPlayerCall', setPlayerCall)

RegisterNetEvent('pma-voice:setPlayerCall', function(callChannel)
    setPlayerCall(source, callChannel)
end)


function setTalkingOnCall(talking)
	if GetConvarInt('voice_enablePhones', 1) ~= 1 then return end
    local source = source
    voiceData[source] = voiceData[source] or defaultTable(source)
    local plyVoice = voiceData[source]
    local callTbl = callData[plyVoice.call]
    if callTbl then
        debug.log(('[phone] %s started talking in call %s'):format(source, plyVoice.call))
        for player, _ in pairs(callTbl) do
            if player ~= source then
                debug.verbose(('[call] Sending event to %s to tell them that %s is talking'):format(player, source))
                TriggerClientEvent('pma-voice:setTalkingOnCall', player, source, talking)
            end
        end
    else
        debug.log(('[phone] %s tried to talk in call %s, but it doesnt exist.'):format(source, plyVoice.call))
    end
end
RegisterNetEvent('pma-voice:setTalkingOnCall', setTalkingOnCall)