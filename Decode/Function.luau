local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local cachedGardenSyncController = nil
local currentLockedTarget = nil
local currentLockedPrompt = nil
local _G_ActiveStockMultipliers = {}
local currentHighMultiText = ""
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local Controllers = PlayerScripts:WaitForChild("Controllers")
local GardenSyncModule = Controllers:WaitForChild("GardenSyncController")
local rawGardenSyncModule = {GardenSyncModule}
local GardenSync = require(rawGardenSyncModule[1])
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local SprinklerDataModule = SharedModules:WaitForChild("SprinklerData")
local rawSprinklerModule = {SprinklerDataModule}
local SprinklerData = require(rawSprinklerModule[1])
local VirtualUser = game:GetService("VirtualUser")
_G.DecodeAPI = _G.DecodeAPI or {}
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer or Players:WaitForChild("LocalPlayer", 5) or Players.PlayerAdded:Wait()
local runThread
local v_u_2 = game:GetService("Players")
local v5 = game:GetService("ReplicatedStorage")
local v_u_11 = v_u_2.LocalPlayer
local v_u_17 = workspace:WaitForChild("Gardens")

task.spawn(function()
    local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 10)
    if playerScripts then
        for _, obj in ipairs(playerScripts:GetDescendants()) do
            if obj:IsA("ModuleScript") and obj.Name == "GardenSyncController" then
                local success, result = pcall(require, obj)
                if success then cachedGardenSyncController = result end
                break
            end
        end
    end
end)

local function checkBackpackIsMax()
    local isMax = false
    
    pcall(function()
        local currentFruits = LocalPlayer:GetAttribute("FruitCount") or LocalPlayer:GetAttribute("Fruits") or LocalPlayer:GetAttribute("CurrentFruits") or 0
        local maxFruits = LocalPlayer:GetAttribute("MaxFruits") or LocalPlayer:GetAttribute("MaxFruit") or LocalPlayer:GetAttribute("FruitCapacity") or 0
        
        if currentFruits == 0 or maxFruits == 0 then
            for key, val in pairs(LocalPlayer:GetAttributes()) do
                local lowerKey = tostring(key):lower()
                if lowerKey:find("fruit") then
                    if lowerKey:find("max") or lowerKey:find("cap") then
                        maxFruits = tonumber(val) or maxFruits
                    else
                        currentFruits = tonumber(val) or currentFruits
                    end
                end
            end
        end
        
        if maxFruits > 0 and currentFruits >= maxFruits then
            isMax = true
        end
    end)

    if not isMax then
        pcall(function()
            local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
            if mainGui then
                local weightBar = mainGui:FindFirstChild("Frames") 
                    and mainGui.Frames:FindFirstChild("Inventory") 
                    and mainGui.Frames.Inventory:FindFirstChild("WeightBar") 
                    and mainGui.Frames.Inventory.WeightBar:FindFirstChild("TextLabel")
                    
                if weightBar and weightBar.Text then
                    local cleanText = weightBar.Text:gsub("%s+", "")
                    local current, max = cleanText:match("(%d+)/(%d+)")
                    if current and max and tonumber(current) >= tonumber(max) then
                        isMax = true
                    end
                    if weightBar.Text:upper():find("FULL") or weightBar.Text:upper():find("MAX") then
                        isMax = true
                    end
                end
            end
        end)
    end
    
    if not isMax then
        pcall(function()
            local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
            local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
            if networkingMod then
                local success, network = pcall(require, networkingMod)
                if success and network and network.NPCS and network.NPCS.PreviewSellAll then
                    local preview = network.NPCS.PreviewSellAll:Fire()
                    if preview and preview.FruitCount and preview.FruitCount >= 100 then
                        isMax = true
                    end
                end
            end
        end)
    end
   
    return isMax
end

local function getUnharvestedFruitKg(instanceObject)
    local kg = 0
    pcall(function()
        local plantModules = ReplicatedStorage:WaitForChild("PlantGenerationModules")
        if instanceObject:GetAttribute("CorePartName") then
            local fruitName = instanceObject:GetAttribute("CorePartName") or instanceObject.Name
            local fruitFolder = plantModules:WaitForChild("Fruits")
            local module = fruitFolder:FindFirstChild(fruitName)
            if not module then return end
            local data = require(module)
            local baseWeight = data.GrowData and data.GrowData.BaseWeight or 0
            local sizeMulti = instanceObject:GetAttribute("SizeMulti") or 1
            local overtimeGrowth = instanceObject:GetAttribute("OvertimeGrowth") or instanceObject:GetAttribute("GrowRateMulti") or 1
            kg = baseWeight * sizeMulti * overtimeGrowth
            return
        end
        local seedName = instanceObject:GetAttribute("SeedName") or instanceObject.Name
        local plantFolder = plantModules:WaitForChild("Plants")
        local module = plantFolder:FindFirstChild(seedName)
        if not module then return end
        local data = require(module)
        local baseWeight = data.GrowData and data.GrowData.BaseWeight
        if not baseWeight then return end
        local sizeMultiplier = 1
        local overtimeGrowth = 1
        local userId = tonumber(instanceObject:GetAttribute("UserId"))
        local plantId = instanceObject:GetAttribute("PlantId")
        
        if userId and plantId and cachedGardenSyncController then
            pcall(function()
                local plantData = cachedGardenSyncController:GetPlant(userId, tostring(plantId))
                if plantData then
                    sizeMultiplier = plantData.SizeMultiplier or 1
                    overtimeGrowth = plantData.OvertimeGrowth or 1
                end
            end)
        end
        kg = baseWeight * sizeMultiplier * overtimeGrowth
    end)
    return kg
end

local function harvestAllFruits()
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    if not Configs then return end

    local gardens = Workspace:FindFirstChild("Gardens")
    if not gardens then return end

    pcall(function()
        local validPromptsToTrigger = {}
        local promptCount = 0
        local localPlayerName = LocalPlayer.Name
        local localPlayerUserId = LocalPlayer.UserId

        for _, plot in ipairs(gardens:GetChildren()) do
            
            local isMyPlot = (plot.Name == localPlayerName) 
                or (plot:GetAttribute("Owner") == localPlayerName) 
                or (plot:GetAttribute("OwnerId") == localPlayerUserId)
                or (plot:FindFirstChild("Owner") and plot.Owner.Value == localPlayerName)
            if not isMyPlot then continue end

            local plantsFolder = plot:FindFirstChild("Plants")
            if not plantsFolder then continue end

            for _, plant in ipairs(plantsFolder:GetChildren()) do
                
                local plantSeedName = plant:GetAttribute("SeedName") or plant.Name
                local rawPlantMutation = plant:GetAttribute("Mutation")
                local plantMutation = (rawPlantMutation and rawPlantMutation ~= "") and tostring(rawPlantMutation) or "Normal"
                local fruitsFolder = plant:FindFirstChild("Fruits")
                
                if fruitsFolder then
                    for _, fruit in ipairs(fruitsFolder:GetChildren()) do

                        local rawFruitName = fruit:GetAttribute("CorePartName") or plantSeedName or fruit.Name
                        local rawFruitMutation = fruit:GetAttribute("Mutation")
                        local fruitMutation = (rawFruitMutation and rawFruitMutation ~= "") and tostring(rawFruitMutation) or "Normal"

                        local shouldHarvest = false
                        if Configs.HarvestAllFruits then
                            shouldHarvest = true
                        elseif Configs.HarvestFruits then
                            local matchFruit = Configs.HarvestFruitFilter and table.find(Configs.HarvestFruitFilter, rawFruitName)
                            local matchMut = Configs.HarvestMutationFilter and table.find(Configs.HarvestMutationFilter, fruitMutation)
                            if matchFruit or matchMut then shouldHarvest = true end
                        end

                        if shouldHarvest and Configs.ThresholdMode and Configs.ThresholdMode ~= "" then
                            local targetValue = tonumber(Configs.WeightThreshold) or 0
                            if targetValue > 0 then
                                local currentFruitKg = getUnharvestedFruitKg(fruit)
                                if Configs.ThresholdMode == "Below" and currentFruitKg > targetValue then shouldHarvest = false
                                elseif Configs.ThresholdMode == "Above" and currentFruitKg < targetValue then shouldHarvest = false end
                            end
                        end

                        if shouldHarvest then
                            local harvestPart = fruit:FindFirstChild("HarvestPart")
                            local prompt = harvestPart and harvestPart:FindFirstChild("HarvestPrompt")
                            if prompt and prompt:IsA("ProximityPrompt") then
                                promptCount = promptCount + 1
                                validPromptsToTrigger[promptCount] = prompt
                            end
                        end
                    end
                else
                    if plant:GetAttribute("PlantGrowthReady") == true then
                        local shouldHarvest = false

                        if Configs.HarvestAllFruits then
                            shouldHarvest = true
                        elseif Configs.HarvestFruits then
                            local matchFruit = Configs.HarvestFruitFilter and table.find(Configs.HarvestFruitFilter, plantSeedName)
                            local matchMut = Configs.HarvestMutationFilter and table.find(Configs.HarvestMutationFilter, plantMutation)
                            if matchFruit or matchMut then shouldHarvest = true end
                        end

                        if shouldHarvest and Configs.ThresholdMode and Configs.ThresholdMode ~= "" then
                            local targetValue = tonumber(Configs.WeightThreshold) or 0
                            if targetValue > 0 then
                                local currentFruitKg = getUnharvestedFruitKg(plant)
                                if Configs.ThresholdMode == "Below" and currentFruitKg > targetValue then shouldHarvest = false
                                elseif Configs.ThresholdMode == "Above" and currentFruitKg < targetValue then shouldHarvest = false end
                            end
                        end

                        if shouldHarvest then
                            local harvestPart = plant:FindFirstChild("HarvestPart") or plant
                            local prompt = harvestPart:FindFirstChildOfClass("ProximityPrompt") or plant:FindFirstChildOfClass("ProximityPrompt")
                            if prompt and prompt:IsA("ProximityPrompt") then
                                promptCount = promptCount + 1
                                validPromptsToTrigger[promptCount] = prompt
                            end
                        end
                    end
                end
            end
        end

        if promptCount > 0 then
            local rawEnv = getfenv()
            local triggerPrompt = rawEnv["fireproximityprompt"] or _G.fireproximityprompt
            for i = 1, promptCount do
                local prompt = validPromptsToTrigger[i]
                if triggerPrompt then
                    triggerPrompt(prompt)
                else
                    prompt:InputHoldBegin()
                    prompt:InputHoldEnd()
                end
            end
        end
    end)
end

local function updateHarvestPrompts()
	local configs = _G.DecodeAPI and _G.DecodeAPI.Configs
	local disableCollect = configs and configs.DisableCollectPrompt

	local gardens = workspace:FindFirstChild("Gardens")
	if not gardens then return end

	for i = 1, 8 do
		local plot = gardens:FindFirstChild("Plot" .. i)
		if plot and plot:GetAttribute("OwnerUserId") == localPlayer.UserId then
			local plants = plot:FindFirstChild("Plants")
			if plants then
				for _, plant in ipairs(plants:GetChildren()) do
					for _, desc in ipairs(plant:GetDescendants()) do
						if desc:IsA("ProximityPrompt") then
							if desc.Name == "Harvest" or desc.ActionText == "Harvest" or desc.ObjectText == "Harvest" or desc.Name == "HarvestPrompt" then
								if disableCollect then
									desc.MaxActivationDistance = 0
									desc.Style = Enum.ProximityPromptStyle.Custom
								else
									desc.MaxActivationDistance = 10
									desc.Style = Enum.ProximityPromptStyle.Default
								end
							end
						end
					end
				end
			end
			break 
		end
	end
end

task.spawn(function()
	while true do
		updateHarvestPrompts()
		task.wait(0.2)
	end
end)

local function fireSellRemote()
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    if not Configs then return end
    local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
    local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
    
    if networkingMod then
        local success, network = pcall(require, networkingMod)
        if success and network and network.NPCS then
            local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChildOfClass("Backpack")
            local character = LocalPlayer.Character
            
            if backpack and character then
                local itemsToProcess = {}
                for _, item in ipairs(backpack:GetChildren()) do table.insert(itemsToProcess, item) end
                for _, item in ipairs(character:GetChildren()) do table.insert(itemsToProcess, item) end
                
                if Configs.SellAllFruits then
                    if Configs.SellThresholdMode == "" or (tonumber(Configs.SellWeightThreshold) or 0) == 0 then
                        if network.NPCS.SellAll then
                            local preview = network.NPCS.PreviewSellAll:Fire()
                            if preview and (preview.FruitCount or 0) > 0 then network.NPCS.SellAll:Fire() end
                        end
                        return
                    end
                end

                for _, item in ipairs(itemsToProcess) do
                    local trueServerIdToken = item:GetAttribute("Id")
                    if trueServerIdToken and trueServerIdToken ~= "" then
                        local shouldSellThisItem = false
                        
                        if Configs.SellAllFruits then
                            shouldSellThisItem = true
                        elseif Configs.SellFruits then
                            local rawFruitName = item:GetAttribute("Fruit") or item.Name
                            local targetFruitLower = tostring(rawFruitName):lower()
                            local rawMutation = item:GetAttribute("Mutation")
                            local fruitMutation = (rawMutation and rawMutation ~= "") and tostring(rawMutation):lower():gsub("%s+", "") or "normal"
                            
                            if Configs.SellMutationFilter and #Configs.SellMutationFilter > 0 then
                                for _, allowedMut in ipairs(Configs.SellMutationFilter) do
                                    if fruitMutation == tostring(allowedMut):lower():gsub("%s+", "") then
                                        shouldSellThisItem = true
                                        break
                                    end
                                end
                            end
                            if not shouldSellThisItem and Configs.SellFruitFilter and #Configs.SellFruitFilter > 0 then
                                for _, allowedFruit in ipairs(Configs.SellFruitFilter) do
                                    if targetFruitLower == tostring(allowedFruit):lower() then
                                        shouldSellThisItem = true
                                        break
                                    end
                                end
                            end
                        end

                        if shouldSellThisItem and Configs.SellThresholdMode and Configs.SellThresholdMode ~= "" then
                            local targetValue = tonumber(Configs.SellWeightThreshold) or 0
                            if targetValue > 0 then
                                local currentItemKg = tonumber(item:GetAttribute("Weight")) or 0
                                if Configs.SellThresholdMode == "Below" and currentItemKg > targetValue then shouldSellThisItem = false
                                elseif Configs.SellThresholdMode == "Above" and currentItemKg < targetValue then shouldSellThisItem = false end
                            end
                        end

                        if shouldSellThisItem and network.NPCS.SellFruit then
                            task.spawn(function()
                                pcall(function() network.NPCS.SellFruit:Fire(trueServerIdToken, LocalPlayer) end)
                            end)
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and (Configs.HarvestAllFruits or Configs.HarvestFruits) then
            if Configs.StopCollectIfFull and checkBackpackIsMax() then
                task.wait(0.1)
            else
                task.spawn(harvestAllFruits)
                local harvestDelay = tonumber(Configs.CollectDelay) or 0.01
                task.wait(math.max(harvestDelay, 0.01))
            end
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and (Configs.SellAllFruits or Configs.SellFruits) then
            if Configs.AllowSellIfFull and checkBackpackIsMax() then
                task.spawn(fireSellRemote)
                local sellDelay = tonumber(Configs.SellDelay) or 0.01
                task.wait(math.max(sellDelay, 0.01))
            elseif not Configs.AllowSellIfFull then
                task.spawn(fireSellRemote)
                local sellDelay = tonumber(Configs.SellDelay) or 0.01
                task.wait(math.max(sellDelay, 0.01))
            else
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end
end)

local function getActiveFilterSignature()
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    if not Configs then return "" end
    
    local signature = tostring(Configs.AutoBuyPets) .. tostring(Configs.PetTweenSpeed)
    if Configs.SelectedPetsFilter then
        for _, val in ipairs(Configs.SelectedPetsFilter) do signature = signature .. tostring(val) end
    end
    if Configs.SelectedPetSizeFilter then
        for _, val in ipairs(Configs.SelectedPetSizeFilter) do signature = signature .. tostring(val) end
    end
    return signature
end

local function processAutoWalkPurchaseLoop()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if not Configs or not Configs.AutoBuyPets then 
            task.wait(0.5)
            continue 
        end
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        
        if not rootPart or not humanoid then 
            task.wait(0.5)
            continue 
        end
        
        local startingFilterSignature = getActiveFilterSignature()
        local mapFolder = workspace:FindFirstChild("Map")
        local wildPetSpawns = mapFolder and mapFolder:FindFirstChild("WildPetSpawns")
        local wildPetRef = mapFolder and mapFolder:FindFirstChild("WildPetRef")
        local targetPrompt = nil
        local targetPart = nil
        
        if wildPetSpawns then
            for _, spawnInstance in ipairs(wildPetSpawns:GetChildren()) do
                local prompt = spawnInstance:FindFirstChild("BuyPrompt", true) or spawnInstance:FindFirstChildOfClass("ProximityPrompt", true)
                
                if prompt and prompt:IsA("ProximityPrompt") then
                    local root = prompt.Parent:IsA("BasePart") and prompt.Parent or spawnInstance:FindFirstChildOfClass("BasePart")
                    
                    if root then
                        local spawnedGuid = spawnInstance.Name:match("([%x%-]+)$")
                        local companionRefInstance = spawnedGuid and wildPetRef and wildPetRef:FindFirstChild("WildPet_" .. spawnedGuid)
                        
                        local currentSize = ""
                        local currentType = ""
                        
                        if companionRefInstance then
                            local rawSize = companionRefInstance:GetAttribute("PetSize") or companionRefInstance:GetAttribute("Size")
                            local rawType = companionRefInstance:GetAttribute("PetType") or companionRefInstance:GetAttribute("Type")
                            
                            if rawSize and tostring(rawSize) ~= "" and tostring(rawSize):lower() ~= "normal" then 
                                currentSize = tostring(rawSize):lower() 
                            end
                            if rawType and tostring(rawType) ~= "" and tostring(rawType):lower() ~= "normal" then 
                                currentType = tostring(rawType):lower() 
                            end
                        end
                        
                        local petFilterActive = Configs.SelectedPetsFilter and #Configs.SelectedPetsFilter > 0
                        local sizeTypeFilterActive = Configs.SelectedPetSizeFilter and #Configs.SelectedPetSizeFilter > 0
                        
                        local matchesPet = false
                        local matchesSizeOrType = false
                        
                        local rawSpawnNameLower = spawnInstance.Name:lower()

                        if petFilterActive then
                            for _, whitelistedName in ipairs(Configs.SelectedPetsFilter) do
                                if string.find(rawSpawnNameLower, tostring(whitelistedName):lower(), 1, true) then
                                    matchesPet = true
                                    break
                                end
                            end
                        end
                        
                        if sizeTypeFilterActive then
                            for _, allowedCriteria in ipairs(Configs.SelectedPetSizeFilter) do
                                local lowerCriteria = tostring(allowedCriteria):lower()
                                if currentSize:lower() == lowerCriteria or currentType:lower() == lowerCriteria then
                                    matchesSizeOrType = true
                                    break
                                end
                            end
                        end
                        
                        local shouldTargetPet = false
                        
                        if petFilterActive or sizeTypeFilterActive then
                            local matchesPetCondition = petFilterActive and matchesPet
                            local matchesSizeCondition = sizeTypeFilterActive and matchesSizeOrType
                            
                            if matchesPetCondition or matchesSizeCondition then 
                                shouldTargetPet = true 
                            end
                        else
                            shouldTargetPet = false
                        end
                        
                        if shouldTargetPet then
                            targetPrompt = prompt
                            targetPart = root
                            break
                        end
                    end
                end
            end
        end

        if targetPart and targetPrompt then
            local originalCollisions = {}
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalCollisions[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
            
            local currentHeightOffset = 3.2
            local currentPos = rootPart.Position
            local targetPos = targetPart.Position + Vector3.new(0, currentHeightOffset, 0)
            
            local distance = (targetPos - currentPos).Magnitude
            local speed = tonumber(Configs.PetTweenSpeed) or 50
            if speed <= 0 then speed = 50 end
            local duration = distance / speed
            
            rootPart.CFrame = CFrame.lookAt(currentPos, Vector3.new(targetPos.X, currentPos.Y, targetPos.Z))
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(rootPart.Orientation.Y), 0)
            local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
            
            tween:Play()
            
            local wasCancelled = false

            while tween.PlaybackState == Enum.PlaybackState.Playing do
                if startingFilterSignature ~= getActiveFilterSignature() or not Configs.AutoBuyPets then
                    tween:Cancel()
                    wasCancelled = true
                    break
                end
                task.wait()
            end

            if wasCancelled or not Configs.AutoBuyPets then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                for part, originalState in pairs(originalCollisions) do
                    if part and part.Parent then part.CanCollide = originalState end
                end
                humanoid.Jump = true
                if startingFilterSignature ~= getActiveFilterSignature() then
                    task.wait(0.1)
                    continue
                end
                break
            end
            
            if Configs.AutoBuyPets and targetPart:IsDescendantOf(workspace) then
                targetPrompt.RequiresLineOfSight = false 
                targetPrompt.ClickablePrompt = true       
                
                while Configs.AutoBuyPets and targetPart:IsDescendantOf(workspace) and targetPrompt:IsDescendantOf(workspace) do
                    if startingFilterSignature ~= getActiveFilterSignature() or not Configs.AutoBuyPets then 
                        targetPrompt:InputHoldEnd()
                        break 
                    end

                    local escortPetCFrame = targetPart.CFrame
                    local balancedEscortPos = escortPetCFrame.Position + Vector3.new(0, 3.2, 0)
                    rootPart.CFrame = CFrame.new(balancedEscortPos) * CFrame.Angles(0, math.rad(escortPetCFrame.Rotation.Y), 0)
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                    targetPrompt:InputHoldBegin()
                    local rawEnv = getfenv()
                    local triggerPrompt = rawEnv["fireproximityprompt"] or _G.fireproximityprompt
                    if triggerPrompt then
                        triggerPrompt(targetPrompt)
                    else
                        targetPrompt:InputHoldEnd()
                    end
                    
                    task.wait() 
                end
            end
            
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            for part, originalState in pairs(originalCollisions) do
                if part and part.Parent then
                    part.CanCollide = originalState
                end
            end
            
            humanoid.Jump = true
            task.wait(0.1)
        else
            task.wait(0.3)
        end
    end
end

task.spawn(function()
    pcall(processAutoWalkPurchaseLoop)
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.AutoCollectEventSeeds == true then
            pcall(function()
                local mapFolder = workspace:FindFirstChild("Map")
                local clientFolder = mapFolder and mapFolder:FindFirstChild("SeedPackSpawnClient")
                local serverLocations = mapFolder and mapFolder:FindFirstChild("SeedPackSpawnServerLocations")
                
                if not clientFolder or not serverLocations then return end
                
                local localCharacter = LocalPlayer.Character
                local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
                
                if not localRoot or not localHumanoid or localHumanoid.Health <= 0 then return end
                
                local stillValid = false
                if currentLockedTarget and currentLockedTarget.Parent and currentLockedPrompt and currentLockedPrompt.Parent then
                    stillValid = true
                else
                    currentLockedTarget = nil
                    currentLockedPrompt = nil
                end
                
                if not stillValid then
                    local activeDrops = clientFolder:GetChildren()
                    local closestDistance = math.huge
                    
                    for idx = 1, #activeDrops do
                        local container = activeDrops[idx]
                        local visualPart = container:IsA("BasePart") and container or container:FindFirstChildOfClass("BasePart", true)
                        
                        if visualPart then
                            local dropPosition = visualPart.Position
                            local distanceToPlayer = (dropPosition - localRoot.Position).Magnitude
                            
                            if distanceToPlayer < closestDistance then
                                local closestPrompt = nil
                                local shortestPromptDistance = math.huge
                                
                                for _, locationPart in ipairs(serverLocations:GetChildren()) do
                                    if locationPart:IsA("BasePart") then
                                        local prompt = locationPart:FindFirstChildOfClass("ProximityPrompt")
                                        if prompt then
                                            local distanceToPrompt = (locationPart.Position - dropPosition).Magnitude
                                            if distanceToPrompt < shortestPromptDistance and distanceToPrompt < 8 then
                                                shortestPromptDistance = distanceToPrompt
                                                closestPrompt = prompt
                                            end
                                        end
                                    end
                                end
                                
                                if closestPrompt then
                                    closestDistance = distanceToPlayer
                                    currentLockedTarget = visualPart
                                    currentLockedPrompt = closestPrompt
                                end
                            end
                        end
                    end
                end

                if currentLockedTarget and currentLockedPrompt then
                    local targetPosition = currentLockedTarget.Position
                    local distance = (targetPosition - localRoot.Position).Magnitude
                    local speed = tonumber(Configs.CollectTweenSpeed) or 16
                    
                    if distance > 3 then
                        if speed > 50 then
                            localRoot.CFrame = CFrame.new(targetPosition)
                            task.wait(0.05)
                        else
                            if speed <= 5 then speed = 16 end
                            local startCFrame = localRoot.CFrame
                            local targetCFrame = CFrame.new(targetPosition)
                            local duration = distance / speed
                            local elapsed = 0
                            
                            local antiGravityConn
                            antiGravityConn = game:GetService("RunService").PostSimulation:Connect(function()
                                if localRoot then 
                                    localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
                                end
                            end)
                            
                            while elapsed < duration and Configs.AutoCollectEventSeeds == true and localHumanoid.Health > 0 do
                                if not currentLockedTarget or not currentLockedTarget.Parent or not currentLockedPrompt or not currentLockedPrompt.Parent then
                                    currentLockedTarget = nil
                                    currentLockedPrompt = nil
                                    break
                                end
                                
                                elapsed = elapsed + task.wait()
                                local alpha = math.clamp(elapsed / duration, 0, 1)
                                localRoot.CFrame = startCFrame:Lerp(targetCFrame, alpha)
                            end
                            
                            if antiGravityConn then antiGravityConn:Disconnect() end
                        end
                    end

                    if currentLockedTarget and currentLockedTarget.Parent and currentLockedPrompt and currentLockedPrompt.Parent and Configs.AutoCollectEventSeeds == true and localHumanoid.Health > 0 then
                        currentLockedPrompt.RequiresLineOfSight = false
                        currentLockedPrompt.ClickablePrompt = true
                        
                        local oldHold = currentLockedPrompt.HoldDuration
                        currentLockedPrompt.HoldDuration = 0
                        
                        currentLockedPrompt.Enabled = false
                        task.wait()
                        currentLockedPrompt.Enabled = true

                        local maximumRetryTimeout = 0
                        while currentLockedTarget and currentLockedTarget.Parent and currentLockedPrompt and currentLockedPrompt.Parent and maximumRetryTimeout < 15 do
                            if Configs.AutoCollectEventSeeds ~= true or localHumanoid.Health <= 0 then break end
                            
                            local rawEnv = getfenv()
                            local triggerPrompt = rawEnv["fireproximityprompt"] or _G.fireproximityprompt
                            if triggerPrompt then
                                triggerPrompt(currentLockedPrompt, 1)
                            else
                                currentLockedPrompt:InputHoldBegin()
                                task.wait(0.01)
                                currentLockedPrompt:InputHoldEnd()
                            end
                            
                            maximumRetryTimeout = maximumRetryTimeout + 1
                            task.wait(0.03)
                        end
                        
                        pcall(function() currentLockedPrompt.HoldDuration = oldHold end)
                        
                        currentLockedTarget = nil
                        currentLockedPrompt = nil
                        task.wait(0.1) 
                    end
                end
            end)
            task.wait(0.05)
        else
            currentLockedTarget = nil
            currentLockedPrompt = nil
            task.wait(1.0)
        end
    end
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.SendMailEnabled == true then
            local processingSuccess = false
            
            pcall(function()
                local targetUser = tostring(Configs.MailTargetUser or ""):gsub("%s+", "")
                local maxQuantity = math.floor(tonumber(Configs.MailSendQuantity) or 1)
                
                if targetUser == "" or targetUser == "username" or targetUser == "@Username" then
                    return
                end
                
                local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
                local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
                if networkingMod then
                    local netSuccess, network = pcall(require, networkingMod)
                    if netSuccess and network and network.Mailbox and network.Mailbox.LookupPlayer and network.Mailbox.SendBatch then
                        
                        local uidLookup = network.Mailbox.LookupPlayer:Fire(targetUser)
                        if not uidLookup or uidLookup <= 0 then
                            return
                        end
                        
                        local targetItemToProcess = nil
                        local itemsToBatch = {}
                        local currentBatchCount = 0
                        
                        local scanningBlueprint = {}
                        if Configs.MailPetsFilter then for _, v in ipairs(Configs.MailPetsFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "Pets"}) end end
                        if Configs.MailFruitsFilter then for _, v in ipairs(Configs.MailFruitsFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "HarvestedFruits"}) end end
                        if Configs.MailSeedsFilter then for _, v in ipairs(Configs.MailSeedsFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "Seeds"}) end end
                        if Configs.MailSprinklersFilter then for _, v in ipairs(Configs.MailSprinklersFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "Sprinklers"}) end end
                        if Configs.MailWateringCansFilter then for _, v in ipairs(Configs.MailWateringCansFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "WateringCans"}) end end
                        if Configs.MailCratesFilter then for _, v in ipairs(Configs.MailCratesFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "Crates"}) end end
                        if Configs.MailSeedPacksFilter then for _, v in ipairs(Configs.MailSeedPacksFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "SeedPacks"}) end end
                        if Configs.MailEggsFilter then for _, v in ipairs(Configs.MailEggsFilter) do table.insert(scanningBlueprint, {ItemKey = v, Category = "Eggs"}) end end
                        if Configs.MailToolsFilter then 
                            for _, v in ipairs(Configs.MailToolsFilter) do 
                                local assignedCategory = "Tools"
                                if v == "Trowel" then assignedCategory = "Trowels"
                                elseif v == "Basic Pot" then assignedCategory = "EmptyPots" end
                                table.insert(scanningBlueprint, {ItemKey = v, Category = assignedCategory}) 
                            end 
                        end
                        for _, giftConfig in pairs(scanningBlueprint) do
                            if Configs.SendMailEnabled ~= true then break end
                            local itemName = giftConfig.ItemKey
                            local serverCategory = giftConfig.Category
                            
                            if serverCategory == "Pets" or serverCategory == "HarvestedFruits" then
                                maxQuantity = math.min(maxQuantity, 20)
                                
                                local targetFolder = LocalPlayer:FindFirstChild("Backpack") 
                                    or LocalPlayer:FindFirstChild(serverCategory)
                                    or LocalPlayer:FindFirstChild("Pets")
                                
                                if targetFolder then
                                    local children = targetFolder:GetChildren()
                                    local cleanNamePattern = itemName:gsub("([^%w])", "%%%1")
                                    
                                    for cIdx = 1, #children do
                                        if currentBatchCount >= maxQuantity then break end
                                        local instanceObj = children[cIdx]
                                        
                                        if string.find(instanceObj.Name, "^" .. cleanNamePattern) then
                                            local isFavorited = instanceObj:GetAttribute("isFavorite") or instanceObj:GetAttribute("IsFavorite") or instanceObj:GetAttribute("favorite") or instanceObj:GetAttribute("Locked")
                                            if isFavorited ~= true then
                                                local extractedUniqueKey = nil
                                                if serverCategory == "Pets" then
                                                    extractedUniqueKey = instanceObj:GetAttribute("PetId")
                                                else
                                                    extractedUniqueKey = instanceObj:GetAttribute("Id") or instanceObj:GetAttribute("UUID")
                                                end
                                                
                                                if extractedUniqueKey then
                                                    local uniqueStrKey = tostring(extractedUniqueKey)
                                                    local alreadyInBatch = false
                                                    for bIdx = 1, #itemsToBatch do
                                                        if itemsToBatch[bIdx].ItemKey == uniqueStrKey then
                                                            alreadyInBatch = true
                                                            break
                                                        end
                                                    end
                                                    
                                                    if not alreadyInBatch then
                                                        targetItemToProcess = {Name = itemName, Category = serverCategory}
                                                        table.insert(itemsToBatch, {
                                                            ["Category"] = serverCategory,
                                                            ["ItemKey"] = uniqueStrKey,
                                                            ["Count"] = 1
                                                        })
                                                        currentBatchCount = currentBatchCount + 1
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:FindFirstChild(serverCategory .. "Inventory") or LocalPlayer:FindFirstChild(serverCategory)
                                if backpack then
                                    local foundTool = backpack:FindFirstChild(itemName)
                                    if foundTool then
                                        local isToolFavorited = foundTool:GetAttribute("isFavorite") or foundTool:GetAttribute("IsFavorite") or foundTool:GetAttribute("favorite") or foundTool:GetAttribute("Locked")
                                        if isToolFavorited ~= true then
                                            local totalAvailableToPull = 0
                                            local countAttr = foundTool:GetAttribute("Count") or foundTool:GetAttribute("Amount") or foundTool:GetAttribute("Quantity")
                                            if countAttr then
                                                totalAvailableToPull = tonumber(countAttr) or 1
                                            else
                                                totalAvailableToPull = 1
                                            end
                                            
                                            local actualToSendCount = math.min(maxQuantity, totalAvailableToPull)
                                            targetItemToProcess = {Name = itemName, Category = serverCategory}
                                            table.insert(itemsToBatch, {
                                                ["Category"] = serverCategory,
                                                ["ItemKey"] = itemName,
                                                ["Count"] = actualToSendCount
                                            })
                                            currentBatchCount = actualToSendCount
                                        end
                                    end
                                end
                            end
                            if targetItemToProcess and #itemsToBatch > 0 then break end
                        end
                        
                        if not targetItemToProcess or #itemsToBatch == 0 then return end
                        
                        local batchSuccess = network.Mailbox.SendBatch:Fire(uidLookup, itemsToBatch, "")
                        if batchSuccess then
                            processingSuccess = true
                            if _G.PostMailboxTerminalAlert then
                                _G.PostMailboxTerminalAlert("Mailbox", "Sent " .. tostring(currentBatchCount) .. "x " .. tostring(targetItemToProcess and targetItemToProcess.Name or "Items") .. " successfully!", false) 
                            end
                        end
                    end
                end
            end)
            local sleepDuration = tonumber(Configs.MailSendInterval) or 5
            if processingSuccess then
                task.wait(math.max(sleepDuration, 0.5))
            else
                task.wait(math.max(sleepDuration, 1.0))
            end
        else
            task.wait(1.0)
        end
    end
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.ClaimMailEnabled == true then
            pcall(function()
                local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
                local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
                if networkingMod then
                    local success, network = pcall(require, networkingMod)
                    if success and network and network.Mailbox and network.Mailbox.OpenInbox and network.Mailbox.Claim then
                        local inboxData = network.Mailbox.OpenInbox:Fire()
                        if inboxData and type(inboxData) == "table" then
                            for mailId, _ in pairs(inboxData) do
                                if Configs.ClaimMailEnabled ~= true then break end
                                network.Mailbox.Claim:Fire(tostring(mailId))
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
            task.wait(2.0)
        else
            task.wait(1.0)
        end
    end
end)

task.spawn(function()
    local ActiveLotsTrackingProfile = {}
    local PurchaseSuccessCounts = {}
    local LastKnownLotIdentities = {}
    
    _G.LiveAuctionLotsCache = _G.LiveAuctionLotsCache or {}
    _G.LiveAuctionStockCache = _G.LiveAuctionStockCache or {}

    pcall(function()
        local sharedMod = game:GetService("ReplicatedStorage"):FindFirstChild("SharedModules")
        local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
        if networkingMod then
            local successNet, network = pcall(require, networkingMod)
            if successNet and network and network.Auctioneer then
                network.Auctioneer.Snapshot.OnClientEvent:Connect(function(dataPayload)
                    if type(dataPayload) == "table" and dataPayload.manifest and type(dataPayload.manifest.lots) == "table" then
                        _G.LiveAuctionLotsCache = dataPayload.manifest.lots
                        if type(dataPayload.stock) == "table" then
                            _G.LiveAuctionStockCache = dataPayload.stock
                        end
                    end
                end)
                network.Auctioneer.StockUpdate.OnClientEvent:Connect(function(updatePayload)
                    if type(updatePayload) == "table" and type(updatePayload.stock) == "table" then
                        _G.LiveAuctionStockCache = updatePayload.stock
                    elseif type(updatePayload) == "table" and updatePayload.Id then
                        local targetId = updatePayload.Id
                        _G.LiveAuctionStockCache[targetId] = updatePayload.Stock or updatePayload.Amount or updatePayload.Quantity or _G.LiveAuctionStockCache[targetId]
                    end
                end)
                network.Auctioneer.PurchaseResult.OnClientEvent:Connect(function(lotId, purchaseSuccess, errorReason)
                    if purchaseSuccess == true then
                        PurchaseSuccessCounts[lotId] = (PurchaseSuccessCounts[lotId] or 0) + 1
                    else
                        ActiveLotsTrackingProfile[lotId] = nil
                    end
                end)
            end
        end
    end)

    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.AutoBuyAuctionItems == true then
            pcall(function()
                if _G.ResetAuctionSniperTrackingHistory == true then
                    _G.ResetAuctionSniperTrackingHistory = nil
                    PurchaseSuccessCounts = {}
                    ActiveLotsTrackingProfile = {}
                    LastKnownLotIdentities = {}
                end

                local sharedMod = game:GetService("ReplicatedStorage"):FindFirstChild("SharedModules")
                local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
                local network = networkingMod and require(networkingMod)
                if network and network.Auctioneer and network.Auctioneer.RequestSnapshot then
                    pcall(function() network.Auctioneer.RequestSnapshot:Fire() end)
                end
                
                local activeLotsTable = _G.LiveAuctionLotsCache or {}
                local currentLiveStockTable = _G.LiveAuctionStockCache or {}
                local targetLots = activeLotsTable.lots or (activeLotsTable.manifest and activeLotsTable.manifest.lots) or activeLotsTable
                
                local getSyncTimeSuccess, currentServerTime = pcall(function() return workspace:GetServerTimeNow() end)
                if not getSyncTimeSuccess or not currentServerTime then currentServerTime = os.time() end
                
                local combinedFilters = {}
                if Configs.AuctionEggsFilter then for _, v in ipairs(Configs.AuctionEggsFilter) do combinedFilters[v] = true end end
                if Configs.AuctionSprinklersFilter then for _, v in ipairs(Configs.AuctionSprinklersFilter) do combinedFilters[v] = true end end
                if Configs.AuctionWateringCansFilter then for _, v in ipairs(Configs.AuctionWateringCansFilter) do combinedFilters[v] = true end end
                if Configs.AuctionSeedPacksFilter then for _, v in ipairs(Configs.AuctionSeedPacksFilter) do combinedFilters[v] = true end end
                if Configs.AuctionSeedsFilter then for _, v in ipairs(Configs.AuctionSeedsFilter) do combinedFilters[v] = true end end
                if Configs.AuctionCratesFilter then for _, v in ipairs(Configs.AuctionCratesFilter) do combinedFilters[v] = true end end

                for lotIndex, lotData in pairs(targetLots) do
                    if type(lotData) == "table" and lotData.lotId then
                        local lotId = lotData.lotId
                        local itemName = tostring(lotData.item or "")
                        
                        if LastKnownLotIdentities[lotIndex] ~= lotId then
                            LastKnownLotIdentities[lotIndex] = lotId
                            PurchaseSuccessCounts[lotId] = 0 
                            ActiveLotsTrackingProfile[lotId] = nil 
                        end

                        local isItemWhitelisted = false
                        for savedKey, _ in pairs(combinedFilters) do
                            local cleanSavedKey = tostring(savedKey)
                            if cleanSavedKey == itemName or cleanSavedKey:find(itemName, 1, true) or itemName:find(cleanSavedKey, 1, true) or cleanSavedKey:gsub("^%w+_", "") == itemName then
                                isItemWhitelisted = true
                                break
                            end
                        end
                        if isItemWhitelisted then
                            local currentStockLeft = tonumber(currentLiveStockTable[lotId] or lotData.stockQuantity or lotData.Stock or 0)
                            local remainingSeconds = math.max(0, (tonumber(lotData.expiresAt) or currentServerTime) - currentServerTime)
                            
                            local currentLivePrice = 0
                            if lotData.decrementIntervalSeconds and lotData.decrementIntervalSeconds > 0 then
                                local elapsed = currentServerTime - lotData.rolledAt
                                local ticks = math.floor((elapsed < 0 and 0 or elapsed) / lotData.decrementIntervalSeconds)
                                currentLivePrice = lotData.startPrice - math.round(lotData.startPrice * lotData.decrementPercent / 100) * ticks
                                if currentLivePrice < lotData.minPrice then 
                                    currentLivePrice = lotData.minPrice 
                                end
                            else
                                currentLivePrice = lotData.startPrice or 0
                            end
                            
                            if currentStockLeft <= 0 or remainingSeconds <= 0 or currentLivePrice <= 0 then
                                ActiveLotsTrackingProfile[lotId] = nil 
                                continue 
                            end
                                
                            local targetQuantityToProcure = math.max(1, math.floor(tonumber(Configs.AuctionBuyQuantity) or 1))
                            local currentSuccessfullyBought = PurchaseSuccessCounts[lotId] or 0
                            
                            if currentSuccessfullyBought < targetQuantityToProcure then
                                local shouldBuyLot = false
                                local setSheckles = tonumber(Configs.AuctionBelowSheckles) or 0
                                local setTimer = tonumber(Configs.AuctionBelowTimer) or 0
                                
                                if setSheckles > 0 and setTimer == 0 then
                                    if currentLivePrice <= setSheckles then
                                        shouldBuyLot = true
                                    end
                                elseif setTimer > 0 and setSheckles == 0 then
                                    if remainingSeconds <= setTimer then
                                        shouldBuyLot = true
                                    end
                                elseif setSheckles > 0 and setTimer > 0 then
                                    if currentLivePrice <= setSheckles and remainingSeconds <= setTimer then
                                        shouldBuyLot = true
                                    end
                                end

                                if shouldBuyLot and not ActiveLotsTrackingProfile[lotId] then
                                    local remainingQuantityNeeded = targetQuantityToProcure - currentSuccessfullyBought
                                    local batchFireLimit = math.min(remainingQuantityNeeded, currentStockLeft)
                                    
                                    if batchFireLimit > 0 then
                                        ActiveLotsTrackingProfile[lotId] = true
                                        if network and network.Auctioneer and network.Auctioneer.PurchaseLot then
                                            for batchIndex = 1, batchFireLimit do
                                                task.spawn(function()
                                                    pcall(function()
                                                        network.Auctioneer.PurchaseLot:Fire(lotId, currentLivePrice)
                                                    end)
                                                end)
                                            end
                                        end
                                        
                                        local alertFunc = _G.PostAuctionTerminalAlert or _G.PostMailboxTerminalAlert
                                        if alertFunc then
                                            alertFunc("Auction", string.format("Fired x%d for %s!", batchFireLimit, lotData.item or "Item"), false)
                                        end
                                        
                                        task.wait(0.2)
                                        ActiveLotsTrackingProfile[lotId] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and (Configs.BuyGears or Configs.BuyAllGears) then
            pcall(function()
                local stockValuesFolder = ReplicatedStorage:FindFirstChild("StockValues")
                local gearShopStock = stockValuesFolder and stockValuesFolder:FindFirstChild("GearShop") and stockValuesFolder.GearShop:FindFirstChild("Items")
                local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
                local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
                
                if networkingMod and gearShopStock then
                    local success, network = pcall(require, networkingMod)
                    if success and network and network.GearShop and network.GearShop.PurchaseGear then
                        
                        local targetGearToBuyList = {}
                        if Configs.BuyAllGears then
                            for _, item in ipairs(gearShopStock:GetChildren()) do table.insert(targetGearToBuyList, item.Name) end
                        elseif Configs.ShopGearsFilter then
                            for _, gearName in ipairs(Configs.ShopGearsFilter) do table.insert(targetGearToBuyList, tostring(gearName)) end
                        end

                        local batchCount = 0
                        local totalStockAvailableToBuy = 0
                        
                        for i = 1, #targetGearToBuyList do
                            if not Configs.BuyGears and not Configs.BuyAllGears then break end
                            local selectedGearName = targetGearToBuyList[i]
                            local itemStockFolder = gearShopStock:FindFirstChild(selectedGearName)
                            local currentStockLeft = 0
                            
                            if itemStockFolder then
                                local amountObj = itemStockFolder:FindFirstChild("Amount") or itemStockFolder:FindFirstChild("Stock") or itemStockFolder:FindFirstChild("Value")
                                if amountObj then currentStockLeft = tonumber(amountObj.Value) or 0
                                else
                                    local fallbackVal = itemStockFolder:IsA("ValueBase") and itemStockFolder.Value
                                    if fallbackVal then currentStockLeft = tonumber(fallbackVal) or 0
                                    else
                                        local attrStock = itemStockFolder:GetAttribute("Amount") or itemStockFolder:GetAttribute("Stock") or itemStockFolder:GetAttribute("Value")
                                        if attrStock then currentStockLeft = tonumber(attrStock) or 0 end
                                    end
                                end
                            end
                            
                            if currentStockLeft <= 0 then continue end
                            totalStockAvailableToBuy = totalStockAvailableToBuy + 1
                            batchCount = batchCount + 1
                            
                            task.spawn(function()
                                pcall(function() network.GearShop.PurchaseGear:Fire(selectedGearName) end)
                            end)
                            
                            if batchCount >= 10 then
                                batchCount = 0
                                task.wait(0.1)
                            end
                        end
                        
                        if totalStockAvailableToBuy == 0 then task.wait(1.5) end
                    end
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and (Configs.BuySeeds or Configs.BuyAllSeeds) then
            pcall(function()
                local stockValuesFolder = ReplicatedStorage:FindFirstChild("StockValues")
                local seedShopStock = stockValuesFolder and stockValuesFolder:FindFirstChild("SeedShop") and stockValuesFolder.SeedShop:FindFirstChild("Items")
                local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
                local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
                
                if networkingMod and seedShopStock then
                    local success, network = pcall(require, networkingMod)
                    if success and network and network.SeedShop and network.SeedShop.PurchaseSeed then
                        
                        local targetSeedsToBuyList = {}
                        if Configs.BuyAllSeeds then
                            for _, item in ipairs(seedShopStock:GetChildren()) do table.insert(targetSeedsToBuyList, item.Name) end
                        elseif Configs.ShopSeedsFilter then
                            for _, seedName in ipairs(Configs.ShopSeedsFilter) do table.insert(targetSeedsToBuyList, tostring(seedName)) end
                        end

                        local batchCount = 0
                        local totalStockAvailableToBuy = 0
                        
                        for i = 1, #targetSeedsToBuyList do
                            if not Configs.BuySeeds and not Configs.BuyAllSeeds then break end
                            local selectedSeedName = targetSeedsToBuyList[i]
                            local itemStockFolder = seedShopStock:FindFirstChild(selectedSeedName)
                            local currentStockLeft = 0
                            
                            if itemStockFolder then
                                local amountObj = itemStockFolder:FindFirstChild("Amount") or itemStockFolder:FindFirstChild("Stock") or itemStockFolder:FindFirstChild("Value")
                                if amountObj then currentStockLeft = tonumber(amountObj.Value) or 0
                                else
                                    local fallbackVal = itemStockFolder:IsA("ValueBase") and itemStockFolder.Value
                                    if fallbackVal then currentStockLeft = tonumber(fallbackVal) or 0
                                    else
                                        local attrStock = itemStockFolder:GetAttribute("Amount") or itemStockFolder:GetAttribute("Stock") or itemStockFolder:GetAttribute("Value")
                                        if attrStock then currentStockLeft = tonumber(attrStock) or 0 end
                                    end
                                end
                            end
                            
                            if currentStockLeft <= 0 then continue end
                            totalStockAvailableToBuy = totalStockAvailableToBuy + 1
                            batchCount = batchCount + 1
                            
                            task.spawn(function()
                                pcall(function() network.SeedShop.PurchaseSeed:Fire(selectedSeedName) end)
                            end)
                            
                            if batchCount >= 10 then
                                batchCount = 0
                                task.wait(0.1)
                            end
                        end
                        
                        if totalStockAvailableToBuy == 0 then task.wait(1.5) end
                    end
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and (Configs.BuyProps or Configs.BuyAllProps) then
            pcall(function()
                local stockValuesFolder = ReplicatedStorage:FindFirstChild("StockValues")
                local crateShopStock = stockValuesFolder and stockValuesFolder:FindFirstChild("CrateShop") and stockValuesFolder.CrateShop:FindFirstChild("Items")
                local sharedMod = ReplicatedStorage:FindFirstChild("SharedModules")
                local networkingMod = sharedMod and sharedMod:FindFirstChild("Networking")
                
                if networkingMod and crateShopStock then
                    local success, network = pcall(require, networkingMod)
                    if success and network and network.CrateShop and network.CrateShop.PurchaseCrate then
                        
                        local targetCratesToBuyList = {}
                        if Configs.BuyAllProps then
                            for _, item in ipairs(crateShopStock:GetChildren()) do table.insert(targetCratesToBuyList, item.Name) end
                        elseif Configs.ShopPropsFilter then
                            for _, crateName in ipairs(Configs.ShopPropsFilter) do table.insert(targetCratesToBuyList, tostring(crateName)) end
                        end

                        local batchCount = 0
                        local totalStockAvailableToBuy = 0
                        
                        for i = 1, #targetCratesToBuyList do
                            if not Configs.BuyProps and not Configs.BuyAllProps then break end
                            local selectedCrateName = targetCratesToBuyList[i]
                            local itemStockFolder = crateShopStock:FindFirstChild(selectedCrateName)
                            local currentStockLeft = 0
                            
                            if itemStockFolder then
                                local amountObj = itemStockFolder:FindFirstChild("Amount") or itemStockFolder:FindFirstChild("Stock") or itemStockFolder:FindFirstChild("Value")
                                if amountObj then currentStockLeft = tonumber(amountObj.Value) or 0
                                else
                                    local fallbackVal = itemStockFolder:IsA("ValueBase") and itemStockFolder.Value
                                    if fallbackVal then currentStockLeft = tonumber(fallbackVal) or 0
                                    else
                                        local attrStock = itemStockFolder:GetAttribute("Amount") or itemStockFolder:GetAttribute("Stock") or itemStockFolder:GetAttribute("Value")
                                        if attrStock then currentStockLeft = tonumber(attrStock) or 0 end
                                    end
                                end
                            end
                            
                            if currentStockLeft <= 0 then continue end
                            totalStockAvailableToBuy = totalStockAvailableToBuy + 1
                            batchCount = batchCount + 1
                            
                            task.spawn(function()
                                pcall(function() network.CrateShop.PurchaseCrate:Fire(selectedCrateName) end)
                            end)
                            
                            if batchCount >= 10 then
                                batchCount = 0
                                task.wait(0.1)
                            end
                        end
                        
                        if totalStockAvailableToBuy == 0 then task.wait(1.5) end
                    end
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    local cachedObstacles = {}
    local myCachedPlotModel = nil
    
    local sharedModules = game:GetService("ReplicatedStorage"):FindFirstChild("SharedModules")
    local sprinklerDataModule = sharedModules and sharedModules:FindFirstChild("SprinklerData")
    local sprinklerRanges = {
        ["Common Sprinkler"] = 18,
        ["Uncommon Sprinkler"] = 23,
        ["Rare Sprinkler"] = 28,
        ["Legendary Sprinkler"] = 38,
        ["Super Sprinkler"] = 53
    }
    
    if sprinklerDataModule and sprinklerDataModule:IsA("ModuleScript") then
        local sSuccess, sprinklerList = pcall(require, sprinklerDataModule)
        if sSuccess and type(sprinklerList) == "table" then
            for i = 1, #sprinklerList do
                local profile = sprinklerList[i]
                if type(profile) == "table" and profile.SprinklerName and profile.Radius then
                    sprinklerRanges[profile.SprinklerName] = (tonumber(profile.Radius) or 2) - 2
                end
            end
        end
    end

    task.spawn(function()
        while true do
            local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
            if Configs and Configs.AutoPlantEnabled then
                local tempObstacles = {}
                local gardensFolder = workspace:FindFirstChild("Gardens")
                if gardensFolder then
                    for _, plotModel in ipairs(gardensFolder:GetChildren()) do
                        local plantsFolder = plotModel:FindFirstChild("Plants")
                        if plantsFolder then
                            for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                                local primaryPart = plantModel:IsA("BasePart") and plantModel or plantModel:FindFirstChildOfClass("BasePart")
                                if primaryPart then
                                    tempObstacles[math.round(primaryPart.Position.X) .. "_" .. math.round(primaryPart.Position.Z)] = true
                                end
                            end
                        end
                    end
                end
                cachedObstacles = tempObstacles
            end
            task.wait(0.1)
        end
    end)

    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.AutoPlantEnabled then
            pcall(function()
                local Character = LocalPlayer.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                local Backpack = LocalPlayer:FindFirstChild("Backpack")
                if not Root or not Backpack then return end
                
                local networkingModule = game:GetService("ReplicatedStorage"):FindFirstChild("Networking", true)
                local success, Network = pcall(require, networkingModule)
                if not success or type(Network) ~= "table" or not Network.Plant or not Network.Plant.PlantSeed then return end
                
                local PlantSeedObj = Network.Plant.PlantSeed
                local methodHook = type(PlantSeedObj.FireServer) == "function" and "FireServer" or "Fire"
                
                local targetCategoryName = nil
                local targetTool = nil
                
                if Configs.PlantSeedsFilter and #Configs.PlantSeedsFilter > 0 then
                    for _, allowedSeed in ipairs(Configs.PlantSeedsFilter) do
                        local cleanToolName = tostring(allowedSeed):gsub("^Seeds_", ""):gsub("^Seeds Packs_", "")
                        local foundTool = Backpack:FindFirstChild(cleanToolName) or Character:FindFirstChild(cleanToolName)
                        if foundTool then
                            targetTool = foundTool
                            targetCategoryName = cleanToolName
                            break
                        end
                    end
                end
                if targetTool and targetCategoryName then
                    local batchLimit = 150
                    
                    if not myCachedPlotModel or not myCachedPlotModel.Parent then
                        local gardensFolder = workspace:FindFirstChild("Gardens")
                        if gardensFolder then
                            for _, plotModel in ipairs(gardensFolder:GetChildren()) do
                                local ownerValue = plotModel:FindFirstChild("Owner") or plotModel:FindFirstChild("Player")
                                local ownerAttr = plotModel:GetAttribute("Owner") or plotModel:GetAttribute("Player") or plotModel:GetAttribute("UserId")
                                if (ownerValue and (ownerValue.Value == LocalPlayer.Name or ownerValue.Value == tostring(LocalPlayer.UserId))) or
                                   (ownerAttr and (tostring(ownerAttr) == LocalPlayer.Name or tostring(ownerAttr) == tostring(LocalPlayer.UserId))) then
                                    myCachedPlotModel = plotModel
                                    break
                                end
                            end
                        end
                    end

                    for batchCount = 1, batchLimit do
                        local finalCalculatedPosition = nil
                        
                        if Configs.PlantPositionMode == "Sprinkler Radius" then
                            if myCachedPlotModel and myCachedPlotModel:FindFirstChild("Sprinklers") then
                                local highestRadiusFound = -1
                                local targetSprinklersList = {}
                                
                                for _, sprinkler in ipairs(myCachedPlotModel.Sprinklers:GetChildren()) do
                                    local sprinklerRoot = sprinkler:FindFirstChild("Root")
                                    if sprinklerRoot and sprinklerRoot:IsA("BasePart") then
                                        local sprinklerNameString = sprinkler:GetAttribute("SprinklerName") or sprinkler.Name
                                        local currentRadiusValue = sprinklerRanges[sprinklerNameString] or 28
                                        
                                        if currentRadiusValue > highestRadiusFound then
                                            highestRadiusFound = currentRadiusValue
                                            targetSprinklersList = {sprinkler}
                                        elseif currentRadiusValue == highestRadiusFound then
                                            table.insert(targetSprinklersList, sprinkler)
                                        end
                                    end
                                end
                                
                                if #targetSprinklersList > 0 then
                                    local randomizedShuffledList = {}
                                    local indicesList = {}
                                    for i = 1, #targetSprinklersList do table.insert(indicesList, i) end
                                    while #indicesList > 0 do
                                        local removedIdx = table.remove(indicesList, math.random(1, #indicesList))
                                        local validIndex = tonumber(removedIdx) or 1
                                        table.insert(randomizedShuffledList, targetSprinklersList[validIndex])
                                    end

                                    
                                    local foundValidSpotMatch = false
                                    for sIdx = 1, #randomizedShuffledList do
                                        local activeSprinkler = randomizedShuffledList[sIdx]
                                        local activeRoot = activeSprinkler:FindFirstChild("Root")
                                        local maxVisualRadius = highestRadiusFound * 0.5
                                        
                                        for attempt = 1, 5 do
                                            local randomAngle = math.random() * math.pi * 2
                                            local randomDistance = math.random() * maxVisualRadius
                                            
                                            local offsetX = math.cos(randomAngle) * randomDistance
                                            local offsetZ = math.sin(randomAngle) * randomDistance
                                            
                                            local testPos = Vector3.new(activeRoot.Position.X + offsetX, 142.355438, activeRoot.Position.Z + offsetZ)
                                            local checkKey = math.round(testPos.X) .. "_" .. math.round(testPos.Z)
                                            
                                            if not cachedObstacles[checkKey] then
                                                finalCalculatedPosition = testPos
                                                foundValidSpotMatch = true
                                                cachedObstacles[checkKey] = true
                                                break
                                            end
                                        end
                                        if foundValidSpotMatch then break end
                                    end
                                end
                            end
                        elseif Configs.PlantPositionMode == "Random" then
                            if myCachedPlotModel then
                                local chosenReferencePart = myCachedPlotModel:FindFirstChild("PlotSizeReference")
                                if chosenReferencePart and chosenReferencePart:IsA("BasePart") then
                                    local size = chosenReferencePart.Size
                                    local pos = chosenReferencePart.Position
                                    local minX = pos.X - (size.X / 2) + 1.5
                                    local block_limit_maxX = pos.X + (size.X / 2) - 1.5
                                    local minZ = pos.Z - (size.Z / 2) + 1.5
                                    local maxZ = pos.Z + (size.Z / 2) - 1.5
                                    
                                    for attempt = 1, 5 do
                                        local rx = math.random() * (block_limit_maxX - minX) + minX
                                        local rz = math.random() * (maxZ - minZ) + minZ
                                        local testPos = Vector3.new(rx, 142.355438, rz)
                                        local checkKey = math.round(testPos.X) .. "_" .. math.round(testPos.Z)
                                        
                                        if not cachedObstacles[checkKey] then
                                            finalCalculatedPosition = testPos
                                            cachedObstacles[checkKey] = true
                                            break
                                        end
                                    end
                                end
                            end
                        elseif Configs.PlantPositionMode == "Player Front" then
                            local forward = Root.CFrame.LookVector
                            local right = Root.CFrame.RightVector
                            local centerPos = Root.Position + (forward * 4)
                            
                            for attempt = 1, 5 do
                                local rx = (math.random() - 0.5) * 30
                                local rz = (math.random() - 0.5) * 30
                                local testPos = centerPos + (forward * (math.random() * 10)) + (right * rx) + (forward * rz)
                                local flatTestPos = Vector3.new(testPos.X, 142.355438, testPos.Z)
                                local checkKey = math.round(flatTestPos.X) .. "_" .. math.round(flatTestPos.Z)
                                
                                if not cachedObstacles[checkKey] then
                                    finalCalculatedPosition = flatTestPos
                                    cachedObstacles[checkKey] = true
                                    break
                                end
                            end
                        end
                        
                        if finalCalculatedPosition then
                            pcall(function()
                                PlantSeedObj[methodHook](PlantSeedObj, finalCalculatedPosition, targetCategoryName, targetTool)
                            end)
                        end
                    end
                end
            end)
            
            local plantIntervalRate = tonumber(Configs.PlantInterval) or 0.05
            task.wait(math.max(plantIntervalRate, 0.01))
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local networkingModule = ReplicatedStorage:FindFirstChild("SharedModules")
    networkingModule = networkingModule and networkingModule:FindFirstChild("Networking")
    local hasNet, Network = pcall(require, networkingModule)

    while true do
        task.wait(0.1)
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs

        if Configs and Configs.AutoPotToggleState and hasNet and type(Network) == "table" then
            local character = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChild("Backpack")

            if character and backpack then
                local placementPosition = Vector3.new(0, 0, 0)
                if Configs.PotSavedCFrame and #Configs.PotSavedCFrame >= 12 then
                    placementPosition = CFrame.new(unpack(Configs.PotSavedCFrame)).Position
                end

                local currentMode = tostring(Configs.PotModeSelection or ""):upper()

                if currentMode == "PLACE" and placementPosition.Magnitude > 0 then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    local rayResult = Workspace:Raycast(placementPosition + Vector3.new(0, 2, 0), Vector3.new(0, -15, 0), raycastParams)
                    local exactFloorY = rayResult and rayResult.Position.Y or placementPosition.Y
                    local finalPlacementPos = Vector3.new(placementPosition.X, exactFloorY, placementPosition.Z)
                    local placementRotation = 0.0

                    local itemsToPlaceBatch = {}
                    local combinedInventory = {}
                    
                    for _, item in ipairs(backpack:GetChildren()) do table.insert(combinedInventory, item) end
                    for _, item in ipairs(character:GetChildren()) do table.insert(combinedInventory, item) end

                    for _, tool in ipairs(combinedInventory) do
                        if tool:IsA("Tool") then
                            local plantId = tool:GetAttribute("Id") or tool:GetAttribute("PlantId")
                            if plantId and plantId ~= "" then
                                local cleanName = tool.Name:gsub(" %s*%[Potted%]", ""):gsub("%s* %[Potted%]", "")
                                
                                if Configs.PotPlantsFilter and table.find(Configs.PotPlantsFilter, cleanName) then
                                    table.insert(itemsToPlaceBatch, plantId)
                                end
                            end
                        end
                    end

                    for index = 1, #itemsToPlaceBatch do
                        if not Configs.AutoPotToggleState or tostring(Configs.PotModeSelection or ""):upper() ~= "PLACE" then break end
                        local targetId = itemsToPlaceBatch[index]

                        pcall(function()
                            if Network.PotPlacement and Network.PotPlacement.PlacePottedPlant then
                                local placeObj = Network.PotPlacement.PlacePottedPlant
                                local methodHook = type(placeObj.FireServer) == "function" and "FireServer" or "Fire"
                                placeObj[methodHook](placeObj, finalPlacementPos, placementRotation, targetId)
                            elseif type(Network.Fire) == "function" then
                                Network.Fire("PotPlacementPlacePottedPlant", finalPlacementPos, placementRotation, targetId)
                            end
                        end)
                        task.wait(0.3)
                    end

                elseif currentMode == "PICKUP" then
                    local userIdString = tostring(LocalPlayer.UserId)
                    local gardensFolder = Workspace:FindFirstChild("Gardens")

                    if gardensFolder then
                        for _, plotModel in ipairs(gardensFolder:GetChildren()) do
                            local plantsFolder = plotModel:FindFirstChild("Plants")
                            if plantsFolder then
                                for _, plantInstance in ipairs(plantsFolder:GetChildren()) do
                                    if not Configs.AutoPotToggleState or tostring(Configs.PotModeSelection or ""):upper() ~= "PICKUP" then break end
                                    
                                    if plantInstance.Name:sub(1, #userIdString) == userIdString and plantInstance:FindFirstChild("PotVisual") then
                                        local plantSeedNameAttr = plantInstance:GetAttribute("PlantName") or plantInstance:GetAttribute("SeedName") or ""
                                        
                                        if Configs.PotPlantsFilter and table.find(Configs.PotPlantsFilter, tostring(plantSeedNameAttr)) then
                                            local targetPlantId = plantInstance:GetAttribute("Id") or plantInstance:GetAttribute("PlantId")
                                            if not targetPlantId or targetPlantId == "" then
                                                local splitName = plantInstance.Name:split("_")
                                                if splitName and #splitName >= 2 then targetPlantId = splitName[2] end
                                            end

                                            if targetPlantId and targetPlantId ~= "" then
                                                pcall(function()
                                                    if Network.PotPlacement and Network.PotPlacement.PickUpPottedPlant then
                                                        local pickUpObj = Network.PotPlacement.PickUpPottedPlant
                                                        local methodHook = type(pickUpObj.FireServer) == "function" and "FireServer" or "Fire"
                                                        pickUpObj[methodHook](pickUpObj, targetPlantId)
                                                    elseif type(Network.Fire) == "function" then
                                                        Network.Fire("PotPlacementPickUpPottedPlant", targetPlantId)
                                                    end
                                                end)
                                                task.wait(0.01)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

runThread = coroutine.create(function()
    while true do
        task.wait(0.1)

        local configurationsTable = nil
        pcall(function() 
            if _G.DecodeAPI and _G.DecodeAPI.Configs then
                configurationsTable = _G.DecodeAPI.Configs
            end
        end)
        
        if type(configurationsTable) == "table" and configurationsTable.AutoTrowelToggleState and configurationsTable.SavedTrowelPositions then
            local TrowelRemote = nil
            pcall(function()
                local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
                local targetModule = sharedModules and sharedModules:FindFirstChild("Networking")
                if targetModule then
                    local networkData = require(targetModule)
                    if networkData and networkData.Trowel then
                        TrowelRemote = networkData.Trowel.MovePlant
                    end
                end
            end)

            if TrowelRemote then
                local Character = localPlayer.Character
                local Backpack = localPlayer:FindFirstChild("Backpack")

                if Character and Backpack then
                    local ownPlotId = localPlayer:GetAttribute("PlotId")
                    local gardens = workspace:FindFirstChild("Gardens")

                    if gardens then
                        local myPlot = nil
                        if ownPlotId then
                            myPlot = gardens:FindFirstChild("Plot" .. tostring(ownPlotId))
                        end
                        if not myPlot then
                            local gardensList = gardens:GetChildren()
                            for i = 1, #gardensList do
                                local plot = gardensList[i]
                                if string.find(string.lower(plot.Name), string.lower(localPlayer.Name), 1, true) then
                                    myPlot = plot
                                    break
                                end
                            end
                        end

                        if myPlot then
                            local plantsFolder = myPlot:FindFirstChild("Plants")
                            local plotAnchor = myPlot.PrimaryPart or myPlot:FindFirstChild("Floor") or myPlot:FindFirstChildOfClass("BasePart") or myPlot:FindFirstChildOfClass("MeshPart")

                            if plantsFolder and plotAnchor then
                                local targetX, targetY, targetZ = nil, nil, nil
                                pcall(function()
                                    local posData = configurationsTable.SavedTrowelPositions
                                    if posData and type(posData) == "table" then
                                        local unpackedCFrame = CFrame.new(unpack(posData))
                                        local offsetCFrame = plotAnchor.CFrame * unpackedCFrame * CFrame.new(0, -3.2, 0)
                                        local basePos = offsetCFrame.Position
                                        if basePos then
                                            targetX, targetY, targetZ = basePos.X, basePos.Y, basePos.Z
                                        end
                                    end
                                end)

                                if type(targetX) == "number" and type(targetY) == "number" and type(targetZ) == "number" then
                                    local interval = tonumber(configurationsTable.TrowelInterval) or 0
                                    local waitDelay = 0.1
                                    if interval > 0 then
                                        waitDelay = interval
                                    end
                                    local plantsList = plantsFolder:GetChildren()

                                    for i = 1, #plantsList do
                                        local plant = plantsList[i]
                                        local isReady = plant:GetAttribute("PlantGrowthReady")
                                        local plantId = plant:GetAttribute("PlantId")
                                        local seedName = plant:GetAttribute("SeedName")

                                        if isReady and plantId and seedName then
                                            local isWhitelisted = false
                                            local filterList = configurationsTable.TrowelPlantsFilter
                                            if type(filterList) == "table" then
                                                for j = 1, #filterList do
                                                    if filterList[j] == seedName then
                                                        isWhitelisted = true
                                                        break
                                                    end
                                                end
                                            end

                                            if isWhitelisted then
                                                local primaryPart = plant.PrimaryPart or plant:FindFirstChildOfClass("BasePart")
                                                if primaryPart then
                                                    local currentPos = primaryPart.Position
                                                    if currentPos then
                                                        local dx = currentPos.X - targetX
                                                        local dy = currentPos.Y - targetY
                                                        local dz = currentPos.Z - targetZ
                                                        local distanceSquare = (dx * dx) + (dy * dy) + (dz * dz)

                                                        if distanceSquare > 2.25 then
                                                            local trowelTool = Character:FindFirstChild("Trowel")
                                                            if not trowelTool then
                                                                trowelTool = Backpack:FindFirstChild("Trowel")
                                                                if trowelTool then
                                                                    trowelTool.Parent = Character
                                                                    task.wait(0.05)
                                                                end
                                                            end

                                                            local finalTargetVector = Vector3.new(targetX, targetY, targetZ)
                                                            pcall(function()
                                                                if typeof(TrowelRemote) == "table" and type(TrowelRemote.Fire) == "function" then
                                                                    TrowelRemote:Fire(plantId, finalTargetVector, 0)
                                                                elseif typeof(TrowelRemote) == "userdata" or typeof(TrowelRemote) == "Instance" then
                                                                    TrowelRemote:FireServer(plantId, finalTargetVector, 0)
                                                                elseif type(TrowelRemote) == "function" then
                                                                    TrowelRemote(plantId, finalTargetVector, 0)
                                                                end
                                                            end)
                                                            task.wait(waitDelay)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
coroutine.resume(runThread)

_G.TrowelAutomationLoop = {
    Disconnect = function()
        if runThread and coroutine.status(runThread) ~= "dead" then
            runThread = nil
        end
    end
}

local sprinklerInfo = {}
local filterList = SprinklerData
if type(filterList) == "table" then
    for i = 1, #filterList do
        local info = filterList[i]
        if info and info.SprinklerName then
            sprinklerInfo[info.SprinklerName] = info
        end
    end
end

local function formatTime(sec)
    sec = math.max(0, math.floor(sec))
    if sec <= 0 then return "0s" end

    local yrs = math.floor(sec / 31536000)
    sec = sec % 31536000
    local mos = math.floor(sec / 2592000)
    sec = sec % 2592000
    local days = math.floor(sec / 86400)
    sec = sec % 86400
    local hrs = math.floor(sec / 3600)
    sec = sec % 3600
    local mins = math.floor(sec / 60)
    local secs = sec % 60

    local output = {}
    if yrs > 0 then table.insert(output, yrs .. "yrs") end
    if mos > 0 then table.insert(output, mos .. "months") end
    if days > 0 then table.insert(output, days .. "days") end
    if hrs > 0 then table.insert(output, hrs .. "h") end
    if mins > 0 then table.insert(output, mins .. "m") end
    if secs > 0 or #output == 0 then table.insert(output, secs .. "s") end

    return table.concat(output, " ")
end

local function getBillboard(model, guiName, textColor)
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return nil end

    local gui = part:FindFirstChild(guiName)
    if gui then 
        if textColor then gui.Timer.TextColor3 = textColor end
        return gui 
    end

    gui = Instance.new("BillboardGui")
    gui.Name = guiName
    gui.Size = UDim2.fromOffset(200, 36)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 250
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "Timer"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextScaled = false
    label.TextSize = 15
    label.Font = Enum.Font.SourceSans
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextColor3 = textColor or Color3.fromRGB(0, 165, 255)
    label.Parent = gui

    return gui
end

local function checkIsWhitelisted(category, itemName, currentMutation)
    if not itemName or itemName == "" then return false end
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    if not Configs then return false end
    
    if category == "Sprinklers" then
        local filter = Configs.EspSprinklersFilter
        if type(filter) == "table" then
            for j = 1, #filter do
                if filter[j] == itemName then return true end
            end
            if #filter == 0 then return true end
        end
    end

    if category == "Fruits" then
        local filter = Configs.EspFruitsFilter
        if type(filter) == "table" and #filter > 0 then
            for j = 1, #filter do
                if filter[j] == itemName then return true end
            end
        end
    end

    if category == "Plants" then
        local filter = Configs.EspPlantsFilter
        if type(filter) == "table" and #filter > 0 then
            for j = 1, #filter do
                if filter[j] == itemName then return true end
            end
        end
    end
    
    return false
end

local function getESPCropWeightKg(instanceObject)
    local plantModules = ReplicatedStorage:FindFirstChild("PlantGenerationModules")
    if not plantModules then return 0 end
    local kg = 0

    pcall(function()
        if instanceObject:GetAttribute("CorePartName") then
            local fruitName = instanceObject:GetAttribute("CorePartName") or instanceObject.Name
            local fruitFolder = plantModules:FindFirstChild("Fruits")
            local module = fruitFolder and fruitFolder:FindFirstChild(fruitName)
            if not module then return end
            
            local data = require(module)
            local baseWeight = data.GrowData and data.GrowData.BaseWeight or 0
            local sizeMulti = instanceObject:GetAttribute("SizeMulti") or 1
            local overtimeGrowth = instanceObject:GetAttribute("OvertimeGrowth") or instanceObject:GetAttribute("GrowRateMulti") or 1
            kg = baseWeight * sizeMulti * overtimeGrowth
            return
        end
        
        local seedName = instanceObject:GetAttribute("SeedName") or instanceObject:GetAttribute("CorePartName") or instanceObject.Name
        local plantFolder = plantModules:FindFirstChild("Plants")
        local module = plantFolder and plantFolder:FindFirstChild(seedName)
        if not module then return end
        
        local data = require(module)
        local baseWeight = data.GrowData and data.GrowData.BaseWeight
        if not baseWeight then return end
        
        local sizeMultiplier = 1
        local overtimeGrowth = 1
        local userId = tonumber(instanceObject:GetAttribute("UserId"))
        local plantId = instanceObject:GetAttribute("PlantId")
        
        if not userId or not plantId then
            local split = string.split(instanceObject.Name, "_")
            if #split >= 2 then
                userId = tonumber(split[1])
                plantId = split[2]
            end
        end
        
        if userId and plantId and GardenSync then
            pcall(function()
                local plantData = GardenSync:GetPlant(userId, tostring(plantId))
                if plantData then
                    sizeMultiplier = plantData.SizeMultiplier or 1
                    overtimeGrowth = plantData.OvertimeGrowth or 1
                end
            end)
        end
        kg = baseWeight * sizeMultiplier * overtimeGrowth
    end)
    return kg
end

local function getRemoteHeight(targetPlant)
    if not targetPlant then return nil end

    if not targetPlant:FindFirstChildWhichIsA("BasePart", true) then
        v_u_11:RequestStreamAroundAsync(targetPlant:GetPivot().Position)
        task.wait(0.05)
    end

    local ignoreFolders = {
        Fruits = true,
        FruitSpawnLocations = true,
    }

    local highest = -math.huge
    local lowest = math.huge
    local hasParts = false

    for _, part in ipairs(targetPlant:GetDescendants()) do
        if part:IsA("BasePart") then
            local parent = part.Parent
            local ignore = false

            while parent and parent ~= targetPlant do
                if ignoreFolders[parent.Name] then
                    ignore = true
                    break
                end
                parent = parent.Parent
            end

            if not ignore then
                hasParts = true
                local top = (part.CFrame * CFrame.new(0, part.Size.Y/2, 0)).Position.Y
                local bottom = (part.CFrame * CFrame.new(0, -part.Size.Y/2, 0)).Position.Y

                highest = math.max(highest, top)
                lowest = math.min(lowest, bottom)
            end
        end
    end

    if not hasParts then
        return 0
    end

    if highest > -math.huge then
        return highest - lowest
    end
    return 0
end

local mainAutomationThread
mainAutomationThread = coroutine.create(function()
    while true do
        task.wait(1)

        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        local isObjectsEnabled = Configs and Configs.EspObjectsToggleState == true
        local targetMode = Configs and Configs.EspPlotModeSelection or "All Plots"
        local minWeightThreshold = Configs and tonumber(Configs.EspAboveWeightValue) or 0
        local minHeightThreshold = Configs and tonumber(Configs.EspAboveHeightValue) or 0

        if not isObjectsEnabled then
            local gardensFolder = workspace:FindFirstChild("Gardens")
            if gardensFolder then
                local plotsList = gardensFolder:GetChildren()
                for i = 1, #plotsList do
                    local plot = plotsList[i]
                    local folder = plot:FindFirstChild("Sprinklers")
                    if folder then
                        local sprinklerList = folder:GetChildren()
                        for j = 1, #sprinklerList do
                            local model = sprinklerList[j]
                            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                            local gui = part and part:FindFirstChild("DebugSprinklerTimer") or model:FindFirstChild("DebugSprinklerTimer")
                            if gui then gui:Destroy() end
                        end
                    end
                    local plantsFolder = plot:FindFirstChild("Plants")
                    if plantsFolder then
                        local plantsList = plantsFolder:GetChildren()
                        for j = 1, #plantsList do
                            local plantModel = plantsList[j]
                            local part = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
                            local gui = part and part:FindFirstChild("DebugPlantFruitESP") or plantModel:FindFirstChild("DebugPlantFruitESP")
                            if gui then gui:Destroy() end
                            local hGui = part and part:FindFirstChild("DebugPlantHeightESP") or plantModel:FindFirstChild("DebugPlantHeightESP")
                            if hGui then hGui:Destroy() end
                            local subFruits = plantModel:FindFirstChild("Fruits")
                            if subFruits then
                                local subFruitsList = subFruits:GetChildren()
                                for k = 1, #subFruitsList do
                                    local fruitModel = subFruitsList[k]
                                    local fPart = fruitModel.PrimaryPart or fruitModel:FindFirstChildWhichIsA("BasePart")
                                    local fGui = fPart and fPart:FindFirstChild("DebugPlantFruitESP") or fruitModel:FindFirstChild("DebugPlantFruitESP")
                                    if fGui then fGui:Destroy() end
                                end
                            end
                        end
                    end
                end
            end
        else
            local ownPlotId = LocalPlayer:GetAttribute("PlotId")
            local ownPlotName = ownPlotId and ("Plot" .. tostring(ownPlotId)) or nil

            local gardensFolder = workspace:FindFirstChild("Gardens")
            if gardensFolder then
                local syncedData = {}
                pcall(function()
                    syncedData[tostring(LocalPlayer.UserId)] = GardenSync:GetSprinklers(LocalPlayer.UserId)
                    if targetMode == "All Plots" or targetMode == "" then
                        local pList = Players:GetPlayers()
                        for i = 1, #pList do
                            local p = pList[i]
                            syncedData[tostring(p.UserId)] = GardenSync:GetSprinklers(p.UserId)
                        end
                    end
                end)

                local plotsList = gardensFolder:GetChildren()
                for i = 1, #plotsList do
                    local plot = plotsList[i]
                    if plot.Name:sub(1, 4) == "Plot" then
                        local isAllowedTarget = false
                        if targetMode == "All Plots" or targetMode == "" then
                            isAllowedTarget = true
                        elseif targetMode == "Own Plot" and ownPlotName and plot.Name == ownPlotName then
                            isAllowedTarget = true
                        end
                        local folder = plot:FindFirstChild("Sprinklers")
                        if folder then
                            local sprinklerList = folder:GetChildren()
                            for j = 1, #sprinklerList do
                                local model = sprinklerList[j]
                                local sName = model:GetAttribute("SprinklerName") or ""
                                local sUid = tostring(model:GetAttribute("UserId") or "")
                                
                                local splitName = string.split(model.Name, "_")
                                if sUid == "" and #splitName >= 2 then sUid = tostring(splitName[1]) end
                                local sId = splitName[2] or model.Name

                                local isWhitelisted = checkIsWhitelisted("Sprinklers", sName, nil)

                                if isAllowedTarget and isWhitelisted then
                                    local remaining = 0
                                    local pData = syncedData[sUid]
                                    if pData and pData[sId] then
                                        local cfg = sprinklerInfo[sName]
                                        if cfg then
                                            local placed = pData[sId].PlacedAt
                                            if type(placed) == "number" then
                                                remaining = math.max(0, cfg.Lifetime - (os.time() - placed))
                                            end
                                        end
                                    end

                                    local gui = getBillboard(model, "DebugSprinklerTimer", Color3.fromRGB(255, 20, 147))
                                    if gui then
                                        gui.Enabled = true
                                        gui.Timer.Text = sName .. " | " .. formatTime(remaining)
                                    end
                                else
                                    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                                    local gui = part and part:FindFirstChild("DebugSprinklerTimer") or model:FindFirstChild("DebugSprinklerTimer")
                                    if gui then gui:Destroy() end
                                end
                            end
                        end
                        local plantsFolder = plot:FindFirstChild("Plants")
                        if plantsFolder then
                            local plantsList = plantsFolder:GetChildren()
                            for j = 1, #plantsList do
                                local plantModel = plantsList[j]
                                local seedName = plantModel:GetAttribute("SeedName") or plantModel:GetAttribute("CorePartName") or plantModel.Name
                                local mutation = plantModel:GetAttribute("Mutation") or "None"
                                local fruitsSubFolder = plantModel:FindFirstChild("Fruits")
                                
                                local isFruitWhitelisted = checkIsWhitelisted("Fruits", seedName, mutation)
                                local isPlantWhitelisted = checkIsWhitelisted("Plants", seedName, mutation)
                                local fruitsChildren = fruitsSubFolder and fruitsSubFolder:GetChildren()
                                local hasFruits = fruitsChildren and #fruitsChildren > 0

                                if isAllowedTarget then
                                    if hasFruits and isFruitWhitelisted then
                                        local pPart = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
                                        local pGui = pPart and pPart:FindFirstChild("DebugPlantFruitESP") or plantModel:FindFirstChild("DebugPlantFruitESP")
                                        if pGui then pGui:Destroy() end

                                        for k = 1, #fruitsChildren do
                                            local fruitModel = fruitsChildren[k]
                                            local fName = fruitModel:GetAttribute("CorePartName") or seedName
                                            local weight = getESPCropWeightKg(fruitModel)
                                            local fMutation = fruitModel:GetAttribute("Mutation") or mutation
                                            
                                            local subFruitWhitelisted = checkIsWhitelisted("Fruits", fName, fMutation)

                                            if subFruitWhitelisted and weight >= minWeightThreshold and weight > 0.05 then
                                                local gui = getBillboard(fruitModel, "DebugPlantFruitESP", Color3.fromRGB(0, 165, 255))
                                                if gui then
                                                    gui.Enabled = true
                                                    local displayMut = (fMutation ~= "None" and fMutation ~= "") and (" [" .. fMutation .. "]") or ""
                                                    gui.Timer.Text = string.format("%s%s\n%.2f kg", fName, displayMut, weight)
                                                end
                                            else
                                                local fPart = fruitModel.PrimaryPart or fruitModel:FindFirstChildWhichIsA("BasePart")
                                                local fGui = fPart and fPart:FindFirstChild("DebugPlantFruitESP") or fruitModel:FindFirstChild("DebugPlantFruitESP")
                                                if fGui then fGui:Destroy() end
                                            end
                                        end
                                    else
                                        local weight = getESPCropWeightKg(plantModel)

                                        if isFruitWhitelisted and weight >= minWeightThreshold and weight > 0.05 then
                                            local gui = getBillboard(plantModel, "DebugPlantFruitESP", Color3.fromRGB(255, 215, 0))
                                            if gui then
                                                gui.Enabled = true
                                                local displayMut = (mutation ~= "None" and mutation ~= "") and (" [" .. mutation .. "]") or ""
                                                gui.Timer.Text = string.format("%s%s\n%.2f kg", seedName, displayMut, weight)
                                            end
                                        else
                                            local part = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
                                            local gui = part and part:FindFirstChild("DebugPlantFruitESP") or plantModel:FindFirstChild("DebugPlantFruitESP")
                                            if gui then gui:Destroy() end
                                        end
                                    end

                                    if isPlantWhitelisted then
                                        local height = getRemoteHeight(plantModel) or 0
                                        local roundedHeight = math.round(height)

                                        if roundedHeight >= minHeightThreshold and roundedHeight > 0 then
                                            local gui = getBillboard(plantModel, "DebugPlantHeightESP", Color3.fromRGB(0, 230, 115))
                                            if gui then
                                                gui.Enabled = true
                                                gui.StudsOffset = Vector3.new(0, 5.0, 0)
                                                local displayMut = (mutation ~= "None" and mutation ~= "") and (" [" .. mutation .. "]") or ""
                                                gui.Timer.Text = string.format("%s%s\n%d height", seedName, displayMut, roundedHeight)
                                            end
                                        else
                                            local part = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
                                            local gui = part and part:FindFirstChild("DebugPlantHeightESP") or plantModel:FindFirstChild("DebugPlantHeightESP")
                                            if gui then gui:Destroy() end
                                        end
                                    else
                                        local part = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
                                        local gui = part and part:FindFirstChild("DebugPlantHeightESP") or plantModel:FindFirstChild("DebugPlantHeightESP")
                                        if gui then gui:Destroy() end
                                    end
                                else
                                    local part = plantModel.PrimaryPart or plantModel:FindFirstChildWhichIsA("BasePart")
                                    local gui = part and part:FindFirstChild("DebugPlantFruitESP") or plantModel:FindFirstChild("DebugPlantFruitESP")
                                    if gui then gui:Destroy() end

                                    local hGui = part and part:FindFirstChild("DebugPlantHeightESP") or plantModel:FindFirstChild("DebugPlantHeightESP")
                                    if hGui then hGui:Destroy() end

                                    if fruitsSubFolder then
                                        local subFruitsList = fruitsSubFolder:GetChildren()
                                        for k = 1, #subFruitsList do
                                            local fruitModel = subFruitsList[k]
                                            local fPart = fruitModel.PrimaryPart or fruitModel:FindFirstChildWhichIsA("BasePart")
                                            local fGui = fPart and fPart:FindFirstChild("DebugPlantFruitESP") or fruitModel:FindFirstChild("DebugPlantFruitESP")
                                            if fGui then fGui:Destroy() end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
coroutine.resume(mainAutomationThread)

local networkingSetupThread
networkingSetupThread = coroutine.create(function()
    local sharedModules = game:GetService("ReplicatedStorage"):WaitForChild("SharedModules", 5)
    local netModule = sharedModules and sharedModules:WaitForChild("Networking", 5)
    local Networking = netModule and require(netModule)
    
    if Networking and Networking.FruitStock then
        local function parseIncomingSnapshot(p58)
            if typeof(p58) == "table" and typeof(p58.entries) == "table" then
                local freshData = {}
                local highAlerts = {}
                for fruitName, dataBlock in pairs(p58.entries) do
                    if typeof(fruitName) == "string" and typeof(dataBlock) == "table" then
                        local m = typeof(dataBlock.multiplier) == "number" and dataBlock.multiplier or 1
                        freshData[fruitName] = m
                        if m >= 4 then
                            table.insert(highAlerts, string.format("%s %.2fx VALUE!", tostring(fruitName), m))
                        end
                    end
                end
                _G_ActiveStockMultipliers = freshData
                currentHighMultiText = #highAlerts > 0 and table.concat(highAlerts, " | ") or ""
            end
        end
        
        pcall(function()
            local snapObj = Networking.FruitStock.Snapshot
            if snapObj then
                if typeof(snapObj.Connect) == "function" then
                    snapObj:Connect(parseIncomingSnapshot)
                elseif snapObj.OnClientEvent then
                    snapObj.OnClientEvent:Connect(parseIncomingSnapshot)
                end
            end
        end)
        local checkImmediateThread
        checkImmediateThread = coroutine.create(function()
            local immediateResult = nil
            pcall(function()
                local reqObj = Networking.FruitStock.Request
                if typeof(reqObj) == "table" then
                    if typeof(reqObj.Invoke) == "function" then
                        immediateResult = reqObj:Invoke()
                    elseif typeof(reqObj.InvokeServer) == "function" then
                        immediateResult = reqObj:InvokeServer()
                    elseif typeof(reqObj.Fire) == "function" then
                        immediateResult = reqObj:Fire()
                    end
                elseif typeof(reqObj) == "function" then
                    immediateResult = reqObj()
                end
            end)
            if immediateResult and typeof(immediateResult) == "table" then
                parseIncomingSnapshot(immediateResult)
            end
        end)
        coroutine.resume(checkImmediateThread)
    end
end)
coroutine.resume(networkingSetupThread)

local function formatValue(value)
    if value == 0 then return "$0.00" end
    local suffixes = {"", "K", "M", "B", "T", "Q"}
    local i = 1
    local absVal = math.abs(value)
    while absVal >= 1000 and i < #suffixes do
        absVal = absVal / 1000
        i = i + 1
    end
    local integerPart = math.floor(absVal)
    local decimalPart = math.floor((absVal - integerPart) * 100)
    local formatted = string.format("%d.%02d", integerPart, decimalPart)
    return "$" .. formatted .. suffixes[i]
end

local function formatExactNumber(value)
    local str = tostring(math.floor(math.abs(value)))
    local formatted = ""
    local count = 0
    for i = #str, 1, -1 do
        formatted = str:sub(i, i) .. formatted
        count = count + 1
        if count % 3 == 0 and i ~= 1 then
            formatted = "," .. formatted
        end
    end
    return formatted
end

local function injectPriceOverlay(itemFrame, truePriceText)
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    local isEnabled = Configs and Configs.EspInventoryToggleState == true
    
    local targetPriceLabel = itemFrame:FindFirstChild("InventoryPriceOverlay")
    if not targetPriceLabel then
        targetPriceLabel = Instance.new("TextLabel")
        targetPriceLabel.Name = "InventoryPriceOverlay"
        targetPriceLabel.Size = UDim2.new(0.8, 0, 0, 22)
        targetPriceLabel.Position = UDim2.new(0.06, 0, 0, 4)
        targetPriceLabel.BackgroundTransparency = 1
        targetPriceLabel.TextColor3 = Color3.fromRGB(124, 252, 0)
        targetPriceLabel.TextSize = 14
        targetPriceLabel.Font = Enum.Font.FredokaOne
        targetPriceLabel.TextXAlignment = Enum.TextXAlignment.Left
        targetPriceLabel.TextStrokeTransparency = 0
        targetPriceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        targetPriceLabel.ZIndex = 99999
        targetPriceLabel.Parent = itemFrame
    end
    
    targetPriceLabel.Visible = isEnabled
    if targetPriceLabel.Text ~= truePriceText then
        targetPriceLabel.Text = truePriceText
    end
end

local function updateHotbarTotalDisplay(totalPrice)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local backpackGui = playerGui and playerGui:FindFirstChild("BackpackGui")
    local backpackFrame = backpackGui and backpackGui:FindFirstChild("Backpack")
    local hotbar = backpackFrame and backpackFrame:FindFirstChild("Hotbar")
    if not hotbar then return end
    
    local totalLabel = hotbar:FindFirstChild("HotbarTotalValueLabel")
    if not totalLabel then
        totalLabel = Instance.new("TextLabel")
        totalLabel.Name = "HotbarTotalValueLabel"
        totalLabel.Size = UDim2.new(1, 0, 0, 25)
        totalLabel.Position = UDim2.new(0, 0, 0, -30)
        totalLabel.BackgroundTransparency = 1
        totalLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        totalLabel.TextSize = 16
        totalLabel.Font = Enum.Font.FredokaOne
        totalLabel.TextXAlignment = Enum.TextXAlignment.Center
        totalLabel.TextStrokeTransparency = 0
        totalLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        totalLabel.ZIndex = 999999
        totalLabel.Parent = hotbar
    end
    
    local alertLabel = hotbar:FindFirstChild("HotbarMultiAlertLabel")
    if not alertLabel then
        alertLabel = Instance.new("TextLabel")
        alertLabel.Name = "HotbarMultiAlertLabel"
        alertLabel.Size = UDim2.new(1, 0, 0, 22)
        alertLabel.Position = UDim2.new(0, 0, 0, -52)
        alertLabel.BackgroundTransparency = 1
        alertLabel.TextSize = 15
        alertLabel.Font = Enum.Font.FredokaOne
        alertLabel.TextXAlignment = Enum.TextXAlignment.Center
        alertLabel.TextStrokeTransparency = 0
        alertLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        alertLabel.ZIndex = 999999
        alertLabel.Parent = hotbar
    end
    
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    local isEnabled = Configs and Configs.EspInventoryToggleState == true
    
    totalLabel.Visible = isEnabled
    local displayString = "Total Fruits Value: " .. formatExactNumber(totalPrice)
    if totalLabel.Text ~= displayString then totalLabel.Text = displayString end
    
    if currentHighMultiText ~= "" and isEnabled then
        alertLabel.Visible = true
        if alertLabel.Text ~= currentHighMultiText then alertLabel.Text = currentHighMultiText end
    else
        alertLabel.Visible = (currentHighMultiText ~= "") and isEnabled
    end
end

local colorCycleThread
colorCycleThread = coroutine.create(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then
        while true do
            for hue = 0, 1, 0.01 do
                pcall(function()
                    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
                    local isEnabled = Configs and Configs.EspInventoryToggleState == true
                    
                    local backpackGui = playerGui:FindFirstChild("BackpackGui")
                    local backpackFrame = backpackGui and backpackGui:FindFirstChild("Backpack")
                    local hotbar = backpackFrame and backpackFrame:FindFirstChild("Hotbar")
                    local alertLabel = hotbar and hotbar:FindFirstChild("HotbarMultiAlertLabel")
                    if alertLabel then
                        if currentHighMultiText ~= "" and isEnabled then
                            alertLabel.Visible = true
                            if alertLabel.Text ~= currentHighMultiText then alertLabel.Text = currentHighMultiText end
                            alertLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        else
                            alertLabel.Visible = false
                        end
                    end
                end)
                task.wait(0.03)
            end
        end
    end
end)
coroutine.resume(colorCycleThread)

local function applyPriceSweeper()
    local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
    local isEnabled = Configs and Configs.EspInventoryToggleState == true
    
    local clientGui = LocalPlayer:FindFirstChild("PlayerGui")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if not clientGui then return end

    if not isEnabled then
        local guis = clientGui:GetChildren()
        for g = 1, #guis do
            local screenGui = guis[g]
            if screenGui:IsA("ScreenGui") then
                local descendants = screenGui:GetDescendants()
                for d = 1, #descendants do
                    local descendant = descendants[d]
                    if descendant:IsA("TextLabel") and descendant.Name == "InventoryPriceOverlay" then
                        descendant.Visible = false
                    end
                end
            end
        end
        
        local backpackGui = clientGui:FindFirstChild("BackpackGui")
        local backpackFrame = backpackGui and backpackGui:FindFirstChild("Backpack")
        local hotbar = backpackFrame and backpackFrame:FindFirstChild("Hotbar")
        if hotbar then
            local totalLabel = hotbar:FindFirstChild("HotbarTotalValueLabel")
            if totalLabel then totalLabel.Visible = false end
            local alertLabel = hotbar:FindFirstChild("HotbarMultiAlertLabel")
            if alertLabel then alertLabel.Visible = false end
        end
    else
        local runningInventoryTotalValue = 0
        local accountedFruitIds = {}
        local backpackFruits = {}
        
        if backpack then
            local children = backpack:GetChildren()
            for i = 1, #children do
                local item = children[i]
                if item:GetAttribute("Fruit") then
                    local uid = item:GetAttribute("Id")
                    if uid then
                        local uidStr = tostring(uid)
                        backpackFruits[uidStr] = item
                        local weight = item:GetAttribute("Weight")
                        if weight then
                            backpackFruits["w_" .. string.format("%.2f", tonumber(weight) or 0)] = item
                        end
                    end
                end
            end
        end

        if character then
            local children = character:GetChildren()
            for i = 1, #children do
                local item = children[i]
                if item:GetAttribute("Fruit") then
                    local uid = item:GetAttribute("Id")
                    if uid then
                        local uidStr = tostring(uid)
                        backpackFruits[uidStr] = item
                        local weight = item:GetAttribute("Weight")
                        if weight then
                            backpackFruits["w_" .. string.format("%.2f", tonumber(weight) or 0)] = item
                        end
                    end
                end
            end
        end
        local guis = clientGui:GetChildren()
        for g = 1, #guis do
            local screenGui = guis[g]
            if screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui.Name ~= "FruitTotalWorthTrackerGui" then
                local descendants = screenGui:GetDescendants()
                for d = 1, #descendants do
                    local descendant = descendants[d]
                    if descendant:IsA("TextLabel") and descendant.Text:find("kg") then
                        local slotFrame = descendant.Parent
                        if slotFrame and slotFrame:IsA("GuiObject") then
                            local frameId = slotFrame:GetAttribute("Id") or slotFrame.Name
                            local matchedTool = backpackFruits[tostring(frameId)]
                            
                            if not matchedTool then
                                local visualWeightNum = tonumber(descendant.Text:match("([%d%.]+)"))
                                if visualWeightNum then
                                    matchedTool = backpackFruits["w_" .. string.format("%.2f", visualWeightNum)]
                                end
                            end
                            if matchedTool then
                                local fruitId = matchedTool:GetAttribute("Id")
                                local fruitIdStr = tostring(fruitId)
                                
                                local finalCorrectedValue = 0
                                local repStorage = game:GetService("ReplicatedStorage")
                                local sharedModules = repStorage:FindFirstChild("SharedModules")
                                local netModule = sharedModules and sharedModules:FindFirstChild("Networking")
                                
                                if netModule then
                                    local Networking = require(netModule)
                                    local networkSuccess, serverBid = pcall(function()
                                        if typeof(Networking.NPCS.GetFruitBid.Invoke) == "function" then
                                            return Networking.NPCS.GetFruitBid:Invoke(fruitId)
                                        else
                                            return Networking.NPCS.GetFruitBid.Fire(Networking.NPCS.GetFruitBid, fruitId)
                                        end
                                    end)
                                    
                                    if networkSuccess and serverBid and serverBid.CurrentSellValue then
                                        finalCorrectedValue = serverBid.CurrentSellValue
                                    else
                                        pcall(function()
                                            local clientDataModule = sharedModules:FindFirstChild("ClientData")
                                            if clientDataModule then
                                                local rawModule = {clientDataModule}
                                                local clientData = require(rawModule[1])
                                                local invData = clientData and clientData:GetInventory()
                                                if invData and invData.Fruits then
                                                    for _, itemData in pairs(invData.Fruits) do
                                                        if tostring(itemData.Id) == fruitIdStr and itemData.CachedSellValue then
                                                            finalCorrectedValue = itemData.CachedSellValue
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                        end)
                                    end
                                end
                                
                                if finalCorrectedValue > 0 then
                                    injectPriceOverlay(slotFrame, formatValue(finalCorrectedValue))
                                    if fruitId and not accountedFruitIds[fruitIdStr] then
                                        accountedFruitIds[fruitIdStr] = true
                                        runningInventoryTotalValue = runningInventoryTotalValue + finalCorrectedValue
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        updateHotbarTotalDisplay(runningInventoryTotalValue)
    end
end

local sweeperLoopThread
sweeperLoopThread = coroutine.create(function()
    while true do
        pcall(applyPriceSweeper)
        task.wait(1.5)
    end
end)
coroutine.resume(sweeperLoopThread)

task.spawn(function()
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.AutoDropItemsEnabled == true then
            pcall(function()
                local Character = LocalPlayer.Character
                local Backpack = LocalPlayer:FindFirstChild("Backpack")
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                
                local networkingModule = game:GetService("ReplicatedStorage"):FindFirstChild("Networking", true)
                local success, Network = pcall(require, networkingModule)
                
                local sharedModules = game:GetService("ReplicatedStorage"):FindFirstChild("SharedModules", true)
                local proxyUtilMod = sharedModules and sharedModules:FindFirstChild("FruitProxyUtil")
                local successUtil, FruitProxyUtil = pcall(require, proxyUtilMod)
                
                if Character and Backpack and PlayerGui and success and type(Network) == "table" and Network.DroppedItem and Network.DroppedItem.RequestDrop then
                    local dropRemote = Network.DroppedItem.RequestDrop
                    local fireMethod = type(dropRemote.FireServer) == "function" and "FireServer" or "Fire"
                    
                    if Character:FindFirstChildOfClass("Tool") then
                        while Character:FindFirstChildOfClass("Tool") do
                            task.wait(0.05)
                        end
                    end
                    
                    local droppedSomething = false
                    
                    if Configs.DropFruitsFilter and type(Configs.DropFruitsFilter) == "table" and #Configs.DropFruitsFilter > 0 then
                        for _, cleanItemName in ipairs(Configs.DropFruitsFilter) do
                            if Character:FindFirstChildOfClass("Tool") then break end
                            
                            local targetId = nil
                            local isProxy = false
                            local targetObject = nil
                            
                            for _, obj in ipairs(Backpack:GetChildren()) do
                                local attrFruitName = obj:GetAttribute("Fruit")
                                local literalName = obj.Name
                                local itemId = obj:GetAttribute("Id")
                                local isFavorite = obj:GetAttribute("IsFavorite")
                                
                                local isPotted = obj:GetAttribute("PottedPlant") or obj:GetAttribute("IsPotted") or obj:GetAttribute("Potted")
                                if isPotted == true then continue end
                                
                                local isTargetName = false
                                if (attrFruitName and tostring(attrFruitName):lower() == tostring(cleanItemName):lower()) or 
                                   string.find(literalName:lower(), tostring(cleanItemName):lower(), 1, true) then
                                    isTargetName = true
                                end
                                
                                if isTargetName and itemId and not isFavorite then
                                    targetId = tostring(itemId)
                                    targetObject = obj
                                    isProxy = obj:IsA("Configuration") or (obj:GetAttribute("FruitProxy") == true)
                                    break
                                end
                            end
                            
                            if targetObject and targetId then
                                local liveToolInstance = nil
                                
                                if isProxy and successUtil and type(FruitProxyUtil) == "table" then
                                    pcall(function() FruitProxyUtil.RequestPromote(targetId) end)
                                    
                                    local timeout = 0
                                    while timeout < 25 do
                                        task.wait(0.1)
                                        timeout = timeout + 1
                                        
                                        local freshBackpack = LocalPlayer:FindFirstChild("Backpack")
                                        if freshBackpack then
                                            for _, bpObj in ipairs(freshBackpack:GetChildren()) do
                                                if bpObj:IsA("Tool") and tostring(bpObj:GetAttribute("Id")) == targetId then
                                                    liveToolInstance = bpObj
                                                    break
                                                end
                                            end
                                        end
                                        if liveToolInstance then break end
                                    end
                                else
                                    liveToolInstance = targetObject
                                end
                                
                                if liveToolInstance and liveToolInstance:IsA("Tool") then
                                    if liveToolInstance.Parent == Backpack then
                                        liveToolInstance.Parent = Character
                                        task.wait(0.15)
                                    end
                                    
                                    if liveToolInstance.Parent == Character then
                                        while liveToolInstance.Parent == Character do
                                            local dropExecuted, _ = pcall(function() 
                                                dropRemote[fireMethod](dropRemote, "HarvestedFruits", targetId) 
                                            end)
                                            task.wait(0.5)
                                            
                                            if not dropExecuted or liveToolInstance.Parent == Character then
                                                task.wait(2.0)
                                            else
                                                droppedSomething = true
                                                break
                                            end
                                        end
                                        task.wait(0.05)
                                    end
                                end
                            end
                        end
                    end

                    if Configs.DropPetsFilter and type(Configs.DropPetsFilter) == "table" and #Configs.DropPetsFilter > 0 then
                        for _, cleanItemName in ipairs(Configs.DropPetsFilter) do
                            
                            for _, tool in ipairs(Backpack:GetChildren()) do
                                if tool:IsA("Tool") and tool:GetAttribute("PetId") then
                                    local pName = tool:GetAttribute("Pet") or tool.Name
                                    local pId = tool:GetAttribute("PetId")
                                    if pId and tostring(pName):lower() == tostring(cleanItemName):lower() then
                                        if tool.Parent == Backpack then
                                            tool.Parent = Character
                                            task.wait(0.05)
                                        end
                                        
                                        while tool.Parent == Character do
                                            local dropExecuted = pcall(function() dropRemote[fireMethod](dropRemote, "Pets", tostring(pId)) end)
                                            task.wait(0.5)
                                            if not dropExecuted or tool.Parent == Character then
                                                task.wait(2.0)
                                            else
                                                droppedSomething = true
                                                break
                                            end
                                        end
                                        task.wait(0.05)
                                        break
                                    end
                                end
                            end

                            if not droppedSomething and Character then
                                for _, tool in ipairs(Character:GetChildren()) do
                                    if tool:IsA("Tool") and tool:GetAttribute("PetId") then
                                        local pName = tool:GetAttribute("Pet") or tool.Name
                                        local pId = tool:GetAttribute("PetId")
                                        if pId and tostring(pName):lower() == tostring(cleanItemName):lower() then
                                            
                                            while tool.Parent == Character do
                                                local dropExecuted = pcall(function() dropRemote[fireMethod](dropRemote, "Pets", tostring(pId)) end)
                                                task.wait(0.5)
                                                if not dropExecuted or tool.Parent == Character then
                                                    task.wait(2.0)
                                                else
                                                    droppedSomething = true
                                                    break
                                                end
                                            end
                                            task.wait(0.05)
                                            break
                                        end
                                    end
                                end
                            end

                        end
                    end
                    
                    if droppedSomething then
                        task.wait(0.2)
                    end
                end
            end)
            
            local sliderSpeed = tonumber(Configs.DropTweenSpeed) or 1
            task.wait(math.max(sliderSpeed, 0.1))
        else
            task.wait(1.0)
        end
    end
end)

task.spawn(function()
    local currentLockedTarget = nil
    
    while true do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        if Configs and Configs.CollectDroppedItemsEnabled == true then
            pcall(function()
                local Character = LocalPlayer.Character
                local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                
                if not RootPart or not Humanoid or Humanoid.Health <= 0 then return end
                
                local clientFolder = workspace:FindFirstChild("DroppedItems")
                if not clientFolder then return end
                
                local standingVerticalOffset = Humanoid.HipHeight + (RootPart.Size.Y / 2)
                
                local stillValid = false
                if currentLockedTarget and currentLockedTarget.Parent == clientFolder then
                    stillValid = true
                else
                    currentLockedTarget = nil
                end
                
                if not stillValid then
                    local activeDrops = clientFolder:GetChildren()
                    local closestDistance = math.huge
                    
                    for idx = 1, #activeDrops do
                        local container = activeDrops[idx]
                        local visualPart = container:IsA("BasePart") and container or container:FindFirstChildOfClass("BasePart", true)
                        local dropPosition = visualPart and visualPart.Position or container:GetPivot().Position
                        
                        local distanceToPlayer = (dropPosition - RootPart.Position).Magnitude
                        if distanceToPlayer < closestDistance then
                            closestDistance = distanceToPlayer
                            currentLockedTarget = container
                        end
                    end
                end
                
                if currentLockedTarget then
                    local visualPart = currentLockedTarget:IsA("BasePart") and currentLockedTarget or currentLockedTarget:FindFirstChildOfClass("BasePart", true)
                    local targetPosition = visualPart and visualPart.Position or currentLockedTarget:GetPivot().Position
                    
                    local safeTargetCoordinates = Vector3.new(targetPosition.X, targetPosition.Y + standingVerticalOffset, targetPosition.Z)
                    local distance = (safeTargetCoordinates - RootPart.Position).Magnitude
                    local speed = tonumber(Configs.DropTweenSpeed) or 16
                    
                    if distance > 3 then
                        if speed > 50 then
                            local maxChunkSize = 25
                            local currentPos = RootPart.Position
                            local totalVector = safeTargetCoordinates - currentPos
                            local totalDistance = totalVector.Magnitude
                            local direction = totalVector.Unit
                            local steps = math.floor(totalDistance / maxChunkSize)
                            
                            for step = 1, steps do
                                if not currentLockedTarget or not currentLockedTarget.Parent or Configs.CollectDroppedItemsEnabled ~= true then break end
                                RootPart.CFrame = CFrame.new(currentPos + (direction * (step * maxChunkSize)))
                                task.wait(0.01)
                            end
                            if currentLockedTarget and currentLockedTarget.Parent and Configs.CollectDroppedItemsEnabled == true then
                                RootPart.CFrame = CFrame.new(safeTargetCoordinates)
                            end
                            task.wait(0.05)
                        else
                            if speed <= 5 then speed = 16 end
                            local startCFrame = RootPart.CFrame
                            local targetCFrame = CFrame.new(safeTargetCoordinates)
                            local duration = distance / speed
                            local elapsed = 0
                            
                            local antiGravityConn
                            antiGravityConn = game:GetService("RunService").PostSimulation:Connect(function()
                                if RootPart then 
                                    RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
                                end
                            end)
                            
                            while elapsed < duration and Configs.CollectDroppedItemsEnabled == true and Humanoid.Health > 0 do
                                if not currentLockedTarget or not currentLockedTarget.Parent then break end
                                elapsed = elapsed + task.wait()
                                local alpha = math.clamp(elapsed / duration, 0, 1)
                                RootPart.CFrame = startCFrame:Lerp(targetCFrame, alpha)
                            end
                            
                            if antiGravityConn then antiGravityConn:Disconnect() end
                        end
                    end
                    local foundPrompt = nil
                    local anchor = currentLockedTarget:FindFirstChild("PromptAnchor")
                    if anchor then
                        foundPrompt = anchor:FindFirstChildOfClass("ProximityPrompt")
                    end
                    
                    if not foundPrompt then
                        foundPrompt = currentLockedTarget:FindFirstChildOfClass("ProximityPrompt", true)
                    end
                    
                    if foundPrompt and foundPrompt.Parent then
                        foundPrompt.RequiresLineOfSight = false
                        foundPrompt.ClickablePrompt = true
                        
                        local oldHold = foundPrompt.HoldDuration
                        foundPrompt.HoldDuration = 0
                        
                        foundPrompt.Enabled = false
                        task.wait()
                        foundPrompt.Enabled = true
                        
                        local maximumRetryTimeout = 0
                        while currentLockedTarget and currentLockedTarget.Parent and foundPrompt and foundPrompt.Parent and maximumRetryTimeout < 15 do
                            if Configs.CollectDroppedItemsEnabled ~= true or Humanoid.Health <= 0 then break end
                            
                            local nativeFirePrompt = (shared or _G).fireproximityprompt or _G.fireproximityprompt or (shared or _G).fire_proximity_prompt
                            
                            if nativeFirePrompt then
                                pcall(function() nativeFirePrompt(foundPrompt, 1) end)
                            else
                                foundPrompt:InputHoldBegin()
                                task.wait(0.01)
                                foundPrompt:InputHoldEnd()
                            end
                            
                            maximumRetryTimeout = maximumRetryTimeout + 1
                            task.wait(0.02)
                        end
                        
                        pcall(function() foundPrompt.HoldDuration = oldHold end)
                    end
                    
                    currentLockedTarget = nil
                    task.wait(0.05) 
                end
            end)
            task.wait(0.05)
        else
            currentLockedTarget = nil
            task.wait(1.0)
        end
    end
end)


local function hideFolderContents(folder, forceState)
    if not folder then return end
    local children = folder:GetChildren()
    for i = 1, #children do
        local model = children[i]
        local descendants = model:GetDescendants()
        for j = 1, #descendants do
            local item = descendants[j]
            if item:IsA("BasePart") then
                local targetTransparency = forceState and 1 or 0
                if item.Transparency ~= targetTransparency then
                    item.Transparency = targetTransparency
                    item.CanCollide = not forceState
                end
            elseif item:IsA("Decal") or item:IsA("Texture") then
                local targetTransparency = forceState and 1 or 0
                if item.Transparency ~= targetTransparency then
                    item.Transparency = targetTransparency
                end
            elseif item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Smoke") or item:IsA("Sparkles") or item:IsA("Fire") or item:IsA("Beam") then
                local targetEnabled = not forceState
                if item.Enabled ~= targetEnabled then
                    item.Enabled = targetEnabled
                end
            end
        end
    end
end

local function cleanAsset(obj)
    if obj:IsA("BasePart") and not obj:IsA("Terrain") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") or obj:IsA("Beam") then
        obj.Enabled = false
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        pcall(function() obj:Destroy() end)
    elseif obj:IsA("MeshPart") then
        obj.RenderFidelity = Enum.RenderFidelity.Performance
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    elseif obj:IsA("SpecialMesh") then
        obj.TextureId = ""
    end
end

task.spawn(function()
    local env = getfenv()
    local Players = typeof(env.cloneref) == "function" and env.cloneref(game:GetService("Players")) or game:GetService("Players")
    local Lighting = typeof(env.cloneref) == "function" and env.cloneref(game:GetService("Lighting")) or game:GetService("Lighting")
    local Workspace = workspace
    local LocalPlayer = Players.LocalPlayer

    local lastGraphicsState = false
    local lastPlantsState = false
    local lastSprinklersState = false
    local hiddenPlotsTracker = {}
    local permanentlyDeletedPlots = {}

    local myUserId = LocalPlayer and LocalPlayer.UserId
    local myName = LocalPlayer and LocalPlayer.Name

    while task.wait(1.5) do
        local Configs = _G.DecodeAPI and _G.DecodeAPI.Configs
        local isBoostActive = Configs and Configs.FpsBoostToggleState == true
        local currentOptions = Configs and Configs.FpsOptionSelection
        
        local optionsMap = {}
        if type(currentOptions) == "table" then
            for i = 1, #currentOptions do
                optionsMap[currentOptions[i]] = true
            end
        end

        local gardens = Workspace:FindFirstChild("Gardens")

        if isBoostActive then
            if gardens then
                local plots = gardens:GetChildren()
                
                local shouldHideMyPlot = optionsMap["Remove My Plot"]
                local shouldHideOtherPlots = optionsMap["Remove Other Plots"]
                local shouldHidePlants = optionsMap["Hide All Plants"]
                local shouldHideSprinklers = optionsMap["Hide All Sprinklers"]

                for p = 1, #plots do
                    local plot = plots[p]
                    if plot:IsA("Instance") and not permanentlyDeletedPlots[plot] then
                        local ownerId = plot:GetAttribute("OwnerUserId")
                        local ownerName = plot:GetAttribute("Owner")
                        local isMyPlot = (ownerId == myUserId) or (ownerName == myName)

                        if isMyPlot then
                            if shouldHideMyPlot then
                                hiddenPlotsTracker[plot] = true
                                hideFolderContents(plot, true)
                            elseif hiddenPlotsTracker[plot] then
                                hiddenPlotsTracker[plot] = nil
                                hideFolderContents(plot, false)
                            end
                        else
                            if shouldHideOtherPlots then
                                permanentlyDeletedPlots[plot] = true
                                pcall(function() plot:Destroy() end)
                                continue
                            elseif hiddenPlotsTracker[plot] then
                                hiddenPlotsTracker[plot] = nil
                                hideFolderContents(plot, false)
                            end
                        end

                        if shouldHidePlants then
                            hideFolderContents(plot:FindFirstChild("Plants"), true)
                        elseif lastPlantsState then
                            hideFolderContents(plot:FindFirstChild("Plants"), false)
                        end
                        
                        if shouldHideSprinklers then
                            hideFolderContents(plot:FindFirstChild("Sprinklers"), true)
                        elseif lastSprinklersState then
                            hideFolderContents(plot:FindFirstChild("Sprinklers"), false)
                        end
                    end
                end
                
                lastPlantsState = shouldHidePlants
                lastSprinklersState = shouldHideSprinklers
            end

            if optionsMap["Lowest Graphics"] then
                if not lastGraphicsState then
                    lastGraphicsState = true
                    
                    local lightingChildren = Lighting:GetChildren()
                    for i = 1, #lightingChildren do
                        pcall(function() lightingChildren[i]:Destroy() end)
                    end
                    
                    local pScripts = LocalPlayer:FindFirstChild("PlayerScripts")
                    local ctrl = pScripts and pScripts:FindFirstChild("Controllers")
                    local lCtrl = ctrl and ctrl:FindFirstChild("LightingController")
                    if lCtrl and lCtrl:IsA("ModuleScript") then
                        pcall(function()
                            local mod = require(lCtrl)
                            if type(mod) == "table" and not _G.OilyNeutralized then
                                local flat = {
                                    ["Ambient"] = Color3.fromRGB(150, 150, 150),
                                    ["Brightness"] = 1,
                                    ["ColorShift_Bottom"] = Color3.fromRGB(0, 0, 0),
                                    ["ColorShift_Top"] = Color3.fromRGB(0, 0, 0),
                                    ["OutdoorAmbient"] = Color3.fromRGB(150, 150, 150),
                                    ["ClockTime"] = 12,
                                    ["EnvironmentDiffuseScale"] = 0
                                }
                                mod.GetDefault = function() return flat end
                                mod.GetCurrentTarget = function() return flat end
                                mod.TransitionTo = function() end
                                mod.SetImmediate = function() end
                                _G.OilyNeutralized = true
                            end
                        end)
                    end
                    
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    pcall(function() Lighting.GlobalShadows = false end)
                    pcall(function() Lighting.FogEnd = 9e9 end)
                    pcall(function() Lighting.Ambient = Color3.fromRGB(150, 150, 150) end)
                    pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150) end)
                    pcall(function() Lighting.Brightness = 1 end)
                    pcall(function() Lighting.EnvironmentDiffuseScale = 0 end)
                    
                    local terrain = Workspace.Terrain
                    pcall(function() terrain.WaterWaveSize = 0 end)
                    pcall(function() terrain.WaterWaveSpeed = 0 end)
                    pcall(function() terrain.WaterReflectance = 0 end)
                    pcall(function() terrain.WaterTransparency = 0 end)
                    pcall(function() terrain.Decoration = false end)
                    
                    local descendants = Workspace:GetDescendants()
                    for i = 1, #descendants do
                        local item = descendants[i]
                        if item:IsA("Explosion") or item:IsA("ForceField") or item:IsA("Highlight") or item:IsA("SelectionBox") or item:IsA("SelectionObject") or item:IsA("Clouds") then
                            pcall(function() item:Destroy() end)
                        elseif not (gardens and item:IsDescendantOf(gardens)) then
                            cleanAsset(item)
                        end
                    end

                    if not _G.DescendantAddedConnection then
                        _G.DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(item)
                            if not _G.DecodeAPI or not _G.DecodeAPI.Configs or not _G.DecodeAPI.Configs.FpsBoostToggleState then return end
                            if item:IsA("Explosion") or item:IsA("ForceField") or item:IsA("Highlight") or item:IsA("SelectionBox") or item:IsA("SelectionObject") or item:IsA("Clouds") then
                                pcall(function() item:Destroy() end)
                            elseif not (gardens and item:IsDescendantOf(gardens)) then
                                cleanAsset(item)
                            end
                        end)
                    end
                end
            else
                lastGraphicsState = false
            end
        else
            if gardens then
                local plots = gardens:GetChildren()
                for i = 1, #plots do
                    local plot = plots[i]
                    if plot:IsA("Instance") then
                        if hiddenPlotsTracker[plot] then
                            hiddenPlotsTracker[plot] = nil
                            hideFolderContents(plot, false)
                        end
                        if lastPlantsState then
                            hideFolderContents(plot:FindFirstChild("Plants"), false)
                        end
                        if lastSprinklersState then
                            hideFolderContents(plot:FindFirstChild("Sprinklers"), false)
                        end
                    end
                end
            end
            lastPlantsState = false
            lastSprinklersState = false
            lastGraphicsState = false
        end
    end
end)

local function startGlobalShovelAutomation()
    task.spawn(function()
        while true do
            local configs = _G.DecodeAPI and _G.DecodeAPI.Configs
            
            if not configs or not configs.AutoShovelToggleState then
                task.wait(1)
                continue
            end

            local selectedPlants = configs.ShovelPlantsFilter or {}
            local selectedFruits = configs.ShovelFruitsFilter or {}

            if #selectedPlants == 0 and #selectedFruits == 0 then
                task.wait(0.5)
                continue
            end

            local targetPlot = nil
            for _, plot in ipairs(v_u_17:GetChildren()) do
                if (plot:GetAttribute("Owner") == v_u_11.Name) or (plot:GetAttribute("OwnerUserId") == v_u_11.UserId) then
                    targetPlot = plot
                    break
                end
            end

            if not targetPlot then
                task.wait(2)
                continue
            end

            local sharedModules = v5:FindFirstChild("SharedModules")
            local foundNetworkInstance = sharedModules and sharedModules:FindFirstChild("Networking")
            
            if not foundNetworkInstance then
                task.wait(1)
                continue
            end

            local requireFunc = getfenv().require
            local networkingModule = requireFunc(foundNetworkInstance)
            
            if not networkingModule or not networkingModule.Shovel or not networkingModule.Shovel.UseShovel then
                task.wait(1)
                continue
            end

            local useShovelRemote = networkingModule.Shovel.UseShovel
            local plantsFolder = targetPlot:FindFirstChild("Plants")
            
            if plantsFolder then
                for _, plant in ipairs(plantsFolder:GetChildren()) do
                    if not configs.AutoShovelToggleState then break end

                    local seedName = plant:GetAttribute("SeedName")
                    local plantId = plant:GetAttribute("PlantId")
                    
                    if not plantId then continue end

                    if seedName and #selectedPlants > 0 and table.find(selectedPlants, seedName) then
                        local thresholdValue = configs.ShovelPlantsWeightThreshold or 0
                        local heightConditionPassed = true

                        if thresholdValue > 0 then
                            local rawHeight = getRemoteHeight(plant)
                            if rawHeight then
                                local roundedHeight = math.round(rawHeight)
                                local thresholdMode = configs.ShovelPlantsThresholdMode or ""
                                if thresholdMode == "Above" then
                                    heightConditionPassed = (roundedHeight > thresholdValue)
                                elseif thresholdMode == "Below" then
                                    heightConditionPassed = (roundedHeight < thresholdValue)
                                else
                                    heightConditionPassed = false
                                end
                            else
                                heightConditionPassed = false
                            end
                        end

                        if heightConditionPassed then
                            local character = v_u_11.Character
                            local backpack = v_u_11:FindFirstChild("Backpack")
                            local shovelTool = character and character:FindFirstChildWhichIsA("Tool")
                            
                            if character and (not shovelTool or not shovelTool:GetAttribute("Shovel")) then
                                local backpackShovel = backpack and backpack:FindFirstChild("Shovel")
                                if backpackShovel then
                                    backpackShovel.Parent = character
                                    shovelTool = backpackShovel
                                    task.wait(0.05)
                                end
                            end

                            if shovelTool and shovelTool:GetAttribute("Shovel") then
                                local shovelAttribute = shovelTool:GetAttribute("Shovel")
                                useShovelRemote:Fire(plantId, "", shovelAttribute, shovelTool)
                            end
                        end
                    end

                    local fruitsFolder = plant:FindFirstChild("Fruits")
                    if fruitsFolder and #selectedFruits > 0 then
                        for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                            if not configs.AutoShovelToggleState then break end

                            local corePartName = fruit:GetAttribute("CorePartName")
                            local fruitId = fruit:GetAttribute("FruitId")

                            if corePartName and fruitId and table.find(selectedFruits, corePartName) then
                                local thresholdValue = configs.ShovelFruitsWeightThreshold or 0
                                local weightConditionPassed = true

                                if thresholdValue > 0 then
                                    local calculatedWeight = getUnharvestedFruitKg(fruit)
                                    local thresholdMode = configs.ShovelFruitsThresholdMode or ""
                                    
                                    if thresholdMode == "Above" then
                                        weightConditionPassed = (calculatedWeight > thresholdValue)
                                    elseif thresholdMode == "Below" then
                                        weightConditionPassed = (calculatedWeight < thresholdValue)
                                    else
                                        weightConditionPassed = false
                                    end
                                end

                                if weightConditionPassed then
                                    local character = v_u_11.Character
                                    local backpack = v_u_11:FindFirstChild("Backpack")
                                    local shovelTool = character and character:FindFirstChildWhichIsA("Tool")
                                    
                                    if character and (not shovelTool or not shovelTool:GetAttribute("Shovel")) then
                                        local backpackShovel = backpack and backpack:FindFirstChild("Shovel")
                                        if backpackShovel then
                                            backpackShovel.Parent = character
                                            shovelTool = backpackShovel
                                            task.wait(0.05)
                                        end
                                    end

                                    if shovelTool and shovelTool:GetAttribute("Shovel") then
                                        local shovelAttribute = shovelTool:GetAttribute("Shovel")
                                        useShovelRemote:Fire(plantId, fruitId, shovelAttribute, shovelTool)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local delayInterval = configs.ShovelInterval or 0
            if delayInterval == 0 then
                task.wait()
            else
                task.wait(delayInterval)
            end
        end
    end)
end

startGlobalShovelAutomation()

_G.DecodeAPI.StartAntiAfk = function()
    if _G.DecodeAPI.AntiAfkLoopActive then return end
    _G.DecodeAPI.AntiAfkLoopActive = true
    
    task.spawn(function()
        local idleConnection
        idleConnection = LocalPlayer.Idled:Connect(function()
            local configs = _G.DecodeAPI.Configs
            if configs and configs.AntiAfkToggleState then
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(0.2)
                    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end)
            end
        end)

        while _G.DecodeAPI.AntiAfkLoopActive do
            task.wait(30)
            local configs = _G.DecodeAPI.Configs
            if configs and configs.AntiAfkToggleState then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(100, 100))
                end)
            end
        end
        
        if idleConnection then 
            idleConnection:Disconnect() 
        end
    end)
end

_G.DecodeAPI.StartAntiAfk()

_G.DecodeAPI.StartKickAutoRejoin = function()
    if _G.DecodeAPI.AutoRejoinConnection then
        return
    end

    local Rejoining = false

    _G.DecodeAPI.AutoRejoinConnection = GuiService.ErrorMessageChanged:Connect(function(errorMessage)
        local configs = _G.DecodeAPI.Configs

        if Rejoining then 
            return 
        end
        if not configs or not configs.RejoinToggleState then 
            return 
        end
        if errorMessage == "" then 
            return 
        end

        Rejoining = true

        local placeId = game.PlaceId
        local jobId = game.JobId

        local env = getfenv()
        local queueTeleport = env.queue_on_teleport or (env.syn and env.syn.queue_on_teleport) or (env.fluxus and env.fluxus.queue_on_teleport)

        if queueTeleport then
            pcall(function()
                queueTeleport(string.format([[
                    task.wait(2)
                    local ts = game:GetService("TeleportService")
                    local lp = game:GetService("Players").LocalPlayer

                    pcall(function()
                        ts:TeleportToPlaceInstance(%d, "%s", lp)
                    end)
                ]], placeId, jobId))
            end)
        end

        task.spawn(function()
            while true do
                pcall(function()
                    TeleportService:Teleport(placeId, LocalPlayer)
                end)
                task.wait(4)
            end
        end)
    end)
end

_G.DecodeAPI.StartKickAutoRejoin()

print("Decode: Function Loaded.")