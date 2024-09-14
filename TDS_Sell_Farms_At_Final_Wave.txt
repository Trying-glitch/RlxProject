if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 5591597781 then return end
local rf, id, StateReplicatorPath = game.ReplicatedStorage.RemoteFunction, game.Players.LocalPlayer.UserId
for i,v in pairs(game.ReplicatedStorage.StateReplicators:GetChildren()) do
	if v:GetAttribute("Wave") then
		StateReplicatorPath = v
		break
	end
end
StateReplicatorPath:GetAttributeChangedSignal("Wave"):Wait()
local FinalWaveAtDifferentMode = {["Easy"] = 25, ["Normal"] = 40, ["Intermediate"] = 30, ["Fallen"] = 40, ["Hardcore"] = 50}
local FinalWave = FinalWaveAtDifferentMode[game.ReplicatedStorage.State.Difficulty.Value]
StateReplicatorPath:GetAttributeChangedSignal("Wave"):Connect(function()
	if StateReplicatorPath:GetAttribute("Wave") == FinalWave then
		for i,v in ipairs(workspace.Towers:GetChildren()) do
			if v.Owner.Value == id and v.Replicator:GetAttribute("Type") == "Farm" then
				spawn(function()
					rf:InvokeServer("Troops","Sell",{["Troop"] = v})
				end)
			end
		end
	end
end)