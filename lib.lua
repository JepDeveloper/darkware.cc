-- Viewmodels fix
for i,v in pairs(game.ReplicatedStorage.Viewmodels:GetChildren()) do
    if v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Transparency ~= 1 then
        v.HumanoidRootPart.Transparency = 1
    end
end

game.ReplicatedStorage.Viewmodels["v_oldM4A1-S"].Silencer.Transparency = 1
local fix = game.ReplicatedStorage.Viewmodels["v_oldM4A1-S"].Silencer:Clone()
fix.Parent = game.ReplicatedStorage.Viewmodels["v_oldM4A1-S"]
fix.Name = "Silencer2"
fix.Transparency = 0

local Hitboxes = {
	["Head"] = {"Head"},
	["Chest"] = {"UpperTorso", "LowerTorso"},
	["Arms"] = {"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand"},
	["Legs"] = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
}

local HexagonFolder = Instance.new("Folder", workspace)
HexagonFolder.Name = "darkwarefolder"

local oldOsPlatform = game.Players.LocalPlayer.OsPlatform
local oldMusicT = game.Players.LocalPlayer.PlayerGui.Music.ValveT:Clone()
local oldMusicCT = game.Players.LocalPlayer.PlayerGui.Music.ValveCT:Clone()

local Weapons = {}; for i,v in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do if v:FindFirstChild("Model") then table.insert(Weapons, v.Name) end end

local Sounds = {
	["TTT a"] = workspace.RoundEnd,
	["TTT b"] = workspace.RoundStart,
	["T Win"] = workspace.Sounds.T,
	["CT Win"] = workspace.Sounds.CT,
	["Planted"] = workspace.Sounds.Arm,
	["Defused"] = workspace.Sounds.Defuse,
	["Rescued"] = workspace.Sounds.Rescue,
	["Explosion"] = workspace.Sounds.Explosion,
	["Becky"] = workspace.Sounds.Becky,
	["Beep"] = workspace.Sounds.Beep
}
	
local FOVCircle = Drawing.new("Circle")
local Cases = {}; for i,v in pairs(game.ReplicatedStorage.Cases:GetChildren()) do table.insert(Cases, v.Name) end

local Configs = {}
local Inventories = loadstring("return "..readfile("hexagon/inventories.txt"))()
local Skyboxes = loadstring("return "..readfile("hexagon/skyboxes.txt"))()



-- Main
local SilentLegitbot = {target = nil}
local SilentRagebot = {target = nil, cooldown = false}
local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local cbClient = getsenv(LocalPlayer.PlayerGui:WaitForChild("Client"))
local oldInventory = cbClient.CurrentInventory
local nocw_s = {}
local nocw_m = {}
local curVel = 16
local isBhopping = false

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Pawel12d/hexagon/main/scripts/ESP.lua"))()
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Pawel12d/hexagon/main/scripts/UILibrary.lua"))()

local Window = library:CreateWindow(Vector2.new(500, 500), Vector2.new((workspace.CurrentCamera.ViewportSize.X/2)-250, (workspace.CurrentCamera.ViewportSize.Y/2)-250))



-- Functions
local function RandomString(length, strings)
	local strings = strings or {
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
		"0","1","2","3","4","5","6","7","8","9",
	}
	local output = ""
	for i = 1,length do
		output = tostring(output..""..strings[math.random(1,#strings)])
		if i == length then
			return output
		end
	end
end

local function IsAlive(plr)
	if plr and plr.Character and plr.Character.FindFirstChild(plr.Character, "Humanoid") and plr.Character.Humanoid.Health > 0 then
		return true
	end

	return false
end

local function IsVisible(pos, ignoreList)
	return #workspace.CurrentCamera:GetPartsObscuringTarget({LocalPlayer.Character.Head.Position, pos}, ignoreList) == 0 and true or false
end

local function GetTeam(plr)
	return game.Teams[plr.Team.Name]
end

local function GetSite()
	if (LocalPlayer.Character.HumanoidRootPart.Position - workspace.Map.SpawnPoints.C4Plant.Position).magnitude > (LocalPlayer.Character.HumanoidRootPart.Position - workspace.Map.SpawnPoints.C4Plant2.Position).magnitude then
		return "A"
	else
		return "B"
	end
end

local function CharacterAdded()
	wait(0.5)
	if IsAlive(LocalPlayer) then
		LocalPlayer.Character.Humanoid.StateChanged:Connect(function(state)
			if library.pointers.MiscellaneousTabCategoryBunnyHopEnabled.value == true then
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) == false then
					isBhopping = false
					curVel = library.pointers.MiscellaneousTabCategoryBunnyHopMinVelocity.value
				elseif state == Enum.HumanoidStateType.Landed and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				elseif state == Enum.HumanoidStateType.Jumping then
					isBhopping = true
					curVel = (curVel + library.pointers.MiscellaneousTabCategoryBunnyHopAcceleration.value) >= library.pointers.MiscellaneousTabCategoryBunnyHopMaxVelocity.value and library.pointers.MiscellaneousTabCategoryBunnyHopMaxVelocity.value or curVel + library.pointers.MiscellaneousTabCategoryBunnyHopAcceleration.value
				end
			end
		end)
	end
end

local function PlayerAdded()
	
end

local function PlantC4()
	pcall(function()
	if IsAlive(LocalPlayer) and workspace.Map.Gamemode.Value == "defusal" and workspace.Status.Preparation.Value == false and not planting then 
		planting = true
		local pos = LocalPlayer.Character.HumanoidRootPart.CFrame 
		workspace.CurrentCamera.CameraType = "Fixed"
		LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Map.SpawnPoints.C4Plant.CFrame
		wait(0.2)
		game.ReplicatedStorage.Events.PlantC4:FireServer((pos + Vector3.new(0, -2.75, 0)) * CFrame.Angles(math.rad(90), 0, math.rad(180)), GetSite())
		wait(0.2)
		LocalPlayer.Character.HumanoidRootPart.CFrame = pos
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		game.Workspace.CurrentCamera.CameraType = "Custom"
		planting = false
	end
	end)
end

local function DefuseC4()
	pcall(function()
	if IsAlive(LocalPlayer) and workspace.Map.Gamemode.Value == "defusal" and not defusing and workspace:FindFirstChild("C4") then 
		defusing = true
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		local pos = LocalPlayer.Character.HumanoidRootPart.CFrame 
		workspace.CurrentCamera.CameraType = "Fixed"
		LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.C4.Handle.CFrame + Vector3.new(0, 2, 0)
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		wait(0.1)
		LocalPlayer.Backpack.PressDefuse:FireServer(workspace.C4)
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		wait(0.25)
		if IsAlive(LocalPlayer) and workspace:FindFirstChild("C4") and workspace.C4:FindFirstChild("Defusing") and workspace.C4.Defusing.Value == LocalPlayer then
			LocalPlayer.Backpack.Defuse:FireServer(workspace.C4)
		end
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		wait(0.2)
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		LocalPlayer.Character.HumanoidRootPart.CFrame = pos
		LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		game.Workspace.CurrentCamera.CameraType = "Custom"
		defusing = false
	end
	end)
end

function GetSpectators()
	local CurrentSpectators = {}
	
	for i,v in pairs(game:GetService("Players"):GetChildren()) do 
		if v ~= game:GetService("Players").LocalPlayer then
			if not v.Character and v:FindFirstChild("CameraCF") and (v.CameraCF.Value.Position - workspace.CurrentCamera.CFrame.p).Magnitude < 10 then 
				table.insert(CurrentSpectators, v)
			end
		end
	end
	
	return CurrentSpectators
end

local function GetLegitbotTarget()
	local target,oldval = nil,math.huge
	
	for i,v in pairs(game.Players:GetPlayers()) do
		if IsAlive(v) and v ~= LocalPlayer and not v.Character:FindFirstChild("ForceField") then
			if library.pointers.AimbotTabCategoryLegitbotTeamCheck.value == false or GetTeam(v) ~= GetTeam(LocalPlayer) then
				if library.pointers.AimbotTabCategoryLegitbotVisibilityCheck.value == false or IsVisible(v.Character.Head.Position, {v.Character, LocalPlayer.Character, HexagonFolder, workspace.CurrentCamera}) == true then
					local Vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
					local FOV = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
					
					if FOV < library.pointers.AimbotTabCategoryLegitbotFOV.value or library.pointers.AimbotTabCategoryLegitbotFOV.value == 0 then
						if math.floor((LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude) < library.pointers.AimbotTabCategoryLegitbotDistance.value or library.pointers.AimbotTabCategoryLegitbotDistance.value == 0 then
							if library.pointers.AimbotTabCategoryLegitbotTargetPriority.value == "FOV" then
								local Vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
								local FOV = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
									
								if FOV < oldval then
									target = v
									oldval = FOV
								end
							elseif library.pointers.AimbotTabCategoryLegitbotTargetPriority.value == "Distance" then
								local Distance = math.floor((v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude)
								
								if Distance < oldval then
									target = v
									oldval = Distance
								end
							end
						end
					end
				end
			end
		end
	end
	
	if target ~= nil then
		return target
	end
	
	return nil
end

local function GetLegitbotHitbox(plr)
	local target,oldval = nil,math.huge
	
	for i,v in pairs(library.pointers.AimbotTabCategoryLegitbotHitbox.value) do
		for i2,v2 in pairs(Hitboxes[v]) do
			targetpart = plr.Character:FindFirstChild(v2)
			
			if targetpart ~= nil then
				if library.pointers.AimbotTabCategoryLegitbotHitboxPriority.value == "FOV" then
					local Vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetpart.Position)
					local FOV = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
					
					if FOV < oldval then
						target = targetpart
						oldval = FOV
					end
				elseif library.pointers.AimbotTabCategoryLegitbotHitboxPriority.value == "Distance" then
					local Distance = math.floor((targetpart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude)
					
					if Distance < oldval then
						target = targetpart
						oldval = Distance
					end
				end
			end
		end
	end
	
	if target ~= nil then
		return target
	end
	
	return nil
end

local function TableToNames(tbl, alt)
	local otp = {}
	
	if alt then
		for i,v in pairs(tbl) do
			table.insert(otp, v.weaponname)
		end
	else
		for i,v in pairs(tbl) do
			table.insert(otp, i)
		end
	end
	
	return otp
end

local function AddCustomSkin(tbl) 
	if tbl and tbl.weaponname and tbl.skinname and tbl.model then
		local isGlove = false
		
		if table.find({"Strapped Glove", "Handwraps", "Sports Glove", "Fingerless Glove"}, tbl.weaponname) then
			isGlove = true
		end
		
		newfolder = Instance.new("Folder")
		newfolder.Name = tbl.skinname
		newfolder.Parent = (isGlove == true and game.ReplicatedStorage.Gloves) or (game.ReplicatedStorage.Skins[tbl.weaponname])
			
		if tbl.skinimage ~= nil then
			newvalue1 = Instance.new("StringValue")
			newvalue1.Name = tbl.skinname
			newvalue1.Value = tbl.skinimage
			newvalue1.Parent = LocalPlayer.PlayerGui.Client.Images[tbl.weaponname]
		end

		if tbl.skinrarity ~= nil then
			newvalue2 = Instance.new("StringValue")
			newvalue2.Name = "Quality"
			newvalue2.Value = tbl.skinrarity
			newvalue2.Parent = (isGlove == false and newvalue1) or nil
			
			newvalue3 = Instance.new("StringValue")
			newvalue3.Name = tostring(tbl.weaponname.."_"..tbl.skinname)
			newvalue3.Value = tbl.skinrarity
			newvalue3.Parent = LocalPlayer.PlayerGui.Client.Rarities
		end

		if isGlove == true then
			newtextures = Instance.new("SpecialMesh")
			newtextures.Name = "Textures"
			newtextures.MeshId = game.ReplicatedStorage.Gloves.Models[tbl.weaponname].RGlove.Mesh.MeshId
			newtextures.TextureId = tbl.model.Handle
			newtextures.Parent = newfolder
			
			newtype = Instance.new("StringValue")
			newtype.Name = "Type"
			newtype.Value = tbl.weaponname
			newtype.Parent = newfolder
		else
			for i,v in pairs(tbl.model) do
				if i == "Main" then
					for i2,v2 in pairs(game.ReplicatedStorage.Viewmodels["v_"..tbl.weaponname]:GetChildren()) do
						if v2:IsA("BasePart") and not table.find({"Right Arm", "Left Arm", "Flash"}, v2.Name) and v2.Transparency ~= 1 then
							newvalue = Instance.new("StringValue")
							newvalue.Name = v2.Name
							newvalue.Value = v
							newvalue.Parent = newfolder
						end
					end
				end
				
				newvalue = Instance.new("StringValue")
				newvalue.Name = i
				newvalue.Value = v
				newvalue.Parent = newfolder
			end
		end
		table.insert(nocw_s, {tostring(tbl.weaponname.."_"..tbl.skinname)})
			
		print("Custom skin: "..tostring(tbl.weaponname.."_"..tbl.skinname).." successfully injected!")
	end
end

local function AddCustomModel(tbl)
	if tbl and tbl.weaponname and tbl.modelname and tbl.model and game.ReplicatedStorage.Weapons:FindFirstChild(tbl.modelname) then
		if game.ReplicatedStorage.Viewmodels:FindFirstChild("v_"..tbl.modelname) then
			game.ReplicatedStorage.Viewmodels["v_"..tbl.modelname]:Destroy()
		end
		
		newmodel = tbl.model
		newmodel.Name = "v_"..tbl.modelname
		newmodel.Parent = game.ReplicatedStorage.Viewmodels
		
		table.insert(nocw_m, {tostring(tbl.modelname)})
	end
end
