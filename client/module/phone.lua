---function createPhoneThread
---creates a phone thread to listen for key presses
local function createPhoneThread()
	Citizen.CreateThread(function()
		local changed = false
		while callChannel ~= 0 do
			-- check if they're pressing voice keybinds
			if NetworkIsPlayerTalking(PlayerId()) and not changed then
				changed = true
				playerTargets(radioPressed and radioData or {}, callData)
				TriggerServerEvent('pma-voice:setTalkingOnCall', true)
			elseif changed and NetworkIsPlayerTalking(PlayerId()) ~= 1 then
				changed = false
				MumbleClearVoiceTargetPlayers(1)
				TriggerServerEvent('pma-voice:setTalkingOnCall', false)
			end
			Wait(0)
		end
	end)
end

RegisterNetEvent('pma-voice:syncCallData', function(callTable, channel)
	callData = callTable
	for tgt, enabled in pairs(callTable) do
		if tgt ~= playerServerId then
			toggleVoice(tgt, enabled, 'phone')
		end
	end
end)

RegisterNetEvent('pma-voice:setTalkingOnCall', function(tgt, enabled)
	if tgt ~= playerServerId then
		callData[tgt] = enabled
		toggleVoice(tgt, enabled, 'phone')
	end
end)

RegisterNetEvent('pma-voice:addPlayerToCall', function(plySource)
	callData[plySource] = false
end)

RegisterNetEvent('pma-voice:removePlayerFromCall', function(plySource)
	if plySource == playerServerId then
		for tgt, enabled in pairs(callData) do
			if tgt ~= playerServerId then
				toggleVoice(tgt, false, 'phone')
			end
		end
		callData = {}
		playerTargets(radioPressed and radioData or {}, callData)
	else
		callData[plySource] = nil
		toggleVoice(plySource, false, 'phone')
		playerTargets(radioPressed and radioData, callData)
	end
end)

function setCallChannel(channel)
	if GetConvarInt('voice_enablePhones', 1) ~= 1 then return end
	TriggerServerEvent('pma-voice:setPlayerCall', channel)
	callChannel = channel
	if GetConvarInt('voice_enableUi', 1) == 1 then
		SendNUIMessage({
			callInfo = channel
		})
	end
	createPhoneThread()
end

exports('setCallChannel', setCallChannel)
exports('SetCallChannel', setCallChannel)

exports('addPlayerToCall', function(call)
	local call = tonumber(call)
	if call then
		setCallChannel(call)
	end
end)
exports('removePlayerFromCall', function()
	setCallChannel(0)
end)

RegisterNetEvent('pma-voice:clSetPlayerCall', function(_callChannel)
	if GetConvarInt('voice_enablePhones', 1) ~= 1 then return end
	callChannel = _callChannel
	createPhoneThread()
end)
