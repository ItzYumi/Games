local Decode = {}

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local env = getfenv()
local getcustomasset = env.getcustomasset or function() return "" end
local isfile = env.isfile or function() return false end
local isfolder = env.isfolder or function() return false end
local makefolder = env.makefolder or function() end
local readfile = env.readfile or function() return "" end
local writefile = env.writefile or function() end
local folderPath = "Decode by ItzYumi"
local assetFolder = "Decode by ItzYumi/Assets"
local assetPath = assetFolder .. "/icon.png"
local filePath = folderPath .. "/Save System/Grow a Garden 2/config.json"

local Configurations = { 
    SpeedEnabled = false,
    Speed = 0,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
    StopCollectIfFull = false,
    CollectDelay = 0,
    DisableCollectPrompt = false,
    HarvestFruitFilter = {},
    HarvestMutationFilter = {},
    ThresholdMode = "",
    WeightThreshold = 0,
    HarvestFruits = false,
    HarvestAllFruits = false,
    AllowSellIfFull = false,
    SellDelay = 0,
    SellFruitFilter = {},
    SellMutationFilter = {},
    SellThresholdMode = "",
    SellWeightThreshold = 0,
    SellFruits = false,
    SellAllFruits = false,
    PetTweenSpeed = 16,
    SelectedPetsFilter = {},
    SelectedPetSizeFilter = {},
    AutoBuyPets = false,
    CollectTweenSpeed = 16,
    AutoCollectEventSeeds = false,
    MailTargetUser = "",
    MailSendQuantity = 0,
    MailSendInterval = 0,
    MailPetsFilter = {},
    MailFruitsFilter = {},
    MailSeedsFilter = {},
    MailSprinklersFilter = {},
    MailWateringCansFilter = {},
    MailCratesFilter = {},
    MailSeedPacksFilter = {},
    MailEggsFilter = {},
    MailToolsFilter = {},
    SendMailEnabled = false,
    ClaimMailEnabled = false,
    AuctionBelowTimer = 0,
    AuctionBelowSheckles = 0,
    AuctionBuyQuantity = 0,
    AutoBuyAuctionItems = false,
    AuctionEggsFilter = {},
    AuctionSprinklersFilter = {},
    AuctionWateringCansFilter = {},
    AuctionSeedPacksFilter = {},
    AuctionSeedsFilter = {},
    AuctionCratesFilter = {},
    ShopSeedsFilter = {},
    BuySeeds = false,
    BuyAllSeeds = false,
    ShopGearsFilter = {},
    BuyGears = false,
    BuyAllGears = false,
    ShopPropsFilter = {},
    BuyProps = false,
    BuyAllProps = false,
    PlantInterval = 0,
    PlantSeedsFilter = {},
    PlantPositionMode = "",
    AutoPlantEnabled = false,
    PotPlantsFilter = {},
    PotModeSelection = "",
    PotSavedCFrame = nil,
    AutoPotToggleState = false,
    TrowelInterval = 0,
    TrowelPlantsFilter = {},
    TrowelSavedCFrame = nil,
    AutoTrowelToggleState = false,
    DropTweenSpeed = 16,
    DropFruitsFilter = {},
    DropPetsFilter = {},
    AutoDropItemsEnabled = false,
    CollectDroppedItemsEnabled = false,
    EspAboveWeightValue = 0,
    EspAboveHeightValue = 0,
    EspFruitsFilter = {},
    EspPlantsFilter = {},
    EspSprinklersFilter = {},
    EspPlotModeSelection = "",
    EspInventoryToggleState = false,
    EspObjectsToggleState = false,
    FpsOptionSelection = {},
    FpsBoostToggleState = false,
    ShovelInterval = 0,
    ShovelFruitsFilter = {},
    ShovelFruitsThresholdMode = "",
    ShovelFruitsWeightThreshold = 0,
    ShovelPlantsFilter = {},
    ShovelPlantsThresholdMode = "",
    ShovelPlantsWeightThreshold = 0,
    AutoShovelToggleState = false,
    AntiAfkToggleState = true,
    RejoinToggleState = true,
    
    MainHue = {10, 18, 30},
    SidebarHue = {15, 27, 44},
    AccentHue = {14, 165, 233},
    ElementHue = {22, 38, 62},
    TextMainHue = {255, 255, 255},
    TextMutedHue = {140, 160, 185}
}

local UI = {
    Tabs = {},
    FirstTab = nil,
    PageList = {"Home", "Main", "Assist", "Shop", "Misc", "Settings"},
    CreatedPages = {},
    PlayerTracker = { OriginalSpeed = 16 }
}

Decode.Theme = {
    MainBackground = Color3.fromRGB(unpack(Configurations.MainHue)),
    SidebarBackground = Color3.fromRGB(unpack(Configurations.SidebarHue)),
    AccentColor = Color3.fromRGB(unpack(Configurations.AccentHue)),
    ElementBackground = Color3.fromRGB(unpack(Configurations.ElementHue)),
    TextMain = Color3.fromRGB(unpack(Configurations.TextMainHue)),
    TextMuted = Color3.fromRGB(unpack(Configurations.TextMutedHue))
}

local function saveConfig()
    local success, str = pcall(function()
        return HttpService:JSONEncode(Configurations)
    end)
    if success and str then
        local split = string.split(filePath, "/")
        local currentPath = ""
        for i = 1, #split - 1 do
            currentPath = currentPath == "" and split[i] or currentPath .. "/" .. split[i]
            if not isfolder(currentPath) then
                makefolder(currentPath)
            end
        end
        writefile(filePath, str)
    end
end

local function loadConfig()
    if isfile(filePath) then
        local success, content = pcall(function()
            return readfile(filePath)
        end)
        if success and content then
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if decodeSuccess and type(data) == "table" then
                for k, v in pairs(data) do
                    if Configurations[k] ~= nil then
                        Configurations[k] = v
                    end
                end
            end
        end
    end
end

loadConfig()
_G.DecodeAPI = { Configs = Configurations }

if not isfolder(folderPath) then makefolder(folderPath) end
if not isfolder(assetFolder) then makefolder(assetFolder) end

if not isfile(assetPath) then
    pcall(function()
        local g = game
        local content = g["HttpGet"](g, "https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/de_code_logo.png")
        if content then
            writefile(assetPath, content)
        end
    end)
end

function Decode:GetAssetCategory(categoryName)
    local items = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local assets = repStorage:FindFirstChild("Assets")
    local folder = assets and assets:FindFirstChild(categoryName)
    
    if folder then
        for _, child in pairs(folder:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") or child:IsA("Tool") or child:IsA("ModuleScript") then 
                table.insert(items, child.Name) 
            end
        end
    end
    table.sort(items)
    return items
end

function Decode:GetGameSeeds()
    local items = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local assets = repStorage:FindFirstChild("Assets")
    local folder = assets and assets:FindFirstChild("Seeds")
    
    if folder then
        for _, child in pairs(folder:GetChildren()) do
            table.insert(items, child.Name)
        end
    end
    table.sort(items)
    return items
end

function Decode:GetGameMutations()
    local mutations = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local shared = repStorage:FindFirstChild("SharedModules")
    local module = shared and shared:FindFirstChild("MutationData")
    
    if module then
        for _, child in pairs(module:GetChildren()) do
            if child:IsA("ModuleScript") then
                table.insert(mutations, child.Name)
            end
        end
    end
    
    table.sort(mutations)
    return mutations
end

function Decode:GetPetTypesAndSizes()
    local combinedList = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local sharedData = repStorage:FindFirstChild("SharedData")
    
    pcall(function()
        local sizeMod = sharedData and sharedData:FindFirstChild("PetSizes")
        if sizeMod and sizeMod:IsA("ModuleScript") then
            local data = require(sizeMod)
            if type(data) == "table" and data.Scales then
                for sizeName, _ in pairs(data.Scales) do
                    table.insert(combinedList, tostring(sizeName))
                end
            end
        end
    end)
    
    pcall(function()
        local typeMod = sharedData and sharedData:FindFirstChild("PetTypes")
        if typeMod and typeMod:IsA("ModuleScript") then
            local data = require(typeMod)
            if type(data) == "table" and data.Registry then
                for typeName, _ in pairs(data.Registry) do
                    table.insert(combinedList, tostring(typeName))
                end
            end
        end
    end)

    table.sort(combinedList)
    return combinedList
end

function Decode:GetShopStockCategory(shopKey)
    local items = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local stockValues = repStorage:FindFirstChild("StockValues")
    local shopFolder = stockValues and stockValues:FindFirstChild(shopKey)
    local itemsFolder = shopFolder and shopFolder:FindFirstChild("Items")
    
    if itemsFolder then
        for _, child in pairs(itemsFolder:GetChildren()) do
            table.insert(items, child.Name)
        end
    end
    table.sort(items)
    return items
end

function Decode:GetWeatherAndPhases()
    local combinedList = {}
    local repStorage = game:GetService("ReplicatedStorage")
    local players = game:GetService("Players")
    
    pcall(function()
        local sharedModules = repStorage:FindFirstChild("SharedModules")
        local weatherMod = sharedModules and sharedModules:FindFirstChild("WeatherData")
        if weatherMod and weatherMod:IsA("ModuleScript") then
            local data = require(weatherMod)
            if type(data) == "table" and data.Data then
                for _, weatherConfig in ipairs(data.Data) do
                    if type(weatherConfig) == "table" and weatherConfig.Name then
                        table.insert(combinedList, tostring(weatherConfig.Name))
                    end
                end
            end
        end
    end)
    
    pcall(function()
        local sharedModules = repStorage:FindFirstChild("SharedModules")
        local timeCycleMod = sharedModules and sharedModules:FindFirstChild("TimeCycleData")
        if timeCycleMod and timeCycleMod:IsA("ModuleScript") then
            local data = require(timeCycleMod)
            if type(data) == "table" and data.Data then
                for phaseName, _ in pairs(data.Data) do
                    table.insert(combinedList, tostring(phaseName))
                end
            end
        end
    end)

    pcall(function()
        local localPlayer = players.LocalPlayer
        local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
        local controllers = playerScripts and playerScripts:FindFirstChild("Controllers")
        local timeCycleCtrl = controllers and controllers:FindFirstChild("TimeCycleController")
        local phasesFolder = timeCycleCtrl and timeCycleCtrl:FindFirstChild("Phases")
        
        if phasesFolder then
            for _, child in ipairs(phasesFolder:GetChildren()) do
                if child:IsA("ModuleScript") then
                    if not table.find(combinedList, child.Name) then
                        table.insert(combinedList, child.Name)
                    end
                end
            end
        end
    end)

    table.sort(combinedList)
    return combinedList
end

UI.ScreenGui = Instance.new("ScreenGui")
UI.ScreenGui.Name = "Decode_UI"
UI.ScreenGui.ResetOnSpawn = false
UI.ScreenGui.Parent = CoreGui

UI.FrameMain = Instance.new("Frame")
UI.FrameMain.Name = "MainContainer"
UI.FrameMain.Size = UDim2.new(0, 520, 0, 340)
UI.FrameMain.Position = UDim2.new(0.5, -260, 0.5, -170)
UI.FrameMain.BackgroundColor3 = Decode.Theme.MainBackground
UI.FrameMain.BackgroundTransparency = 0.15
UI.FrameMain.BorderSizePixel = 0
UI.FrameMain.Active = true
UI.FrameMain.Draggable = true
UI.FrameMain.Parent = UI.ScreenGui

UI.CornerMain = Instance.new("UICorner")
UI.CornerMain.CornerRadius = UDim.new(0, 10)
UI.CornerMain.Parent = UI.FrameMain

UI.TopHeader = Instance.new("Frame")
UI.TopHeader.Name = "TopHeader"
UI.TopHeader.Size = UDim2.new(1, 0, 0, 35)
UI.TopHeader.BackgroundTransparency = 1
UI.TopHeader.Parent = UI.FrameMain

UI.TitleLabel = Instance.new("TextLabel")
UI.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
UI.TitleLabel.Position = UDim2.new(0, 14, 0, 0)
UI.TitleLabel.BackgroundTransparency = 1
UI.TitleLabel.Text = "DECODE | v1.1.0.0"
UI.TitleLabel.TextColor3 = Decode.Theme.TextMuted
UI.TitleLabel.TextSize = 16
UI.TitleLabel.Font = Enum.Font.SourceSansBold
UI.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
UI.TitleLabel.Parent = UI.TopHeader

UI.CloseButton = Instance.new("TextButton")
UI.CloseButton.Size = UDim2.new(0, 35, 0, 35)
UI.CloseButton.Position = UDim2.new(1, -40, 0, 0)
UI.CloseButton.BackgroundTransparency = 1
UI.CloseButton.Text = "X"
UI.CloseButton.TextColor3 = Decode.Theme.TextMuted
UI.CloseButton.TextSize = 14
UI.CloseButton.Font = Enum.Font.SourceSansBold
UI.CloseButton.Parent = UI.TopHeader

UI.MinimizeButton = Instance.new("TextButton")
UI.MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
UI.MinimizeButton.Position = UDim2.new(1, -75, 0, 0)
UI.MinimizeButton.BackgroundTransparency = 1
UI.MinimizeButton.Text = "-"
UI.MinimizeButton.TextColor3 = Decode.Theme.TextMuted
UI.MinimizeButton.TextSize = 18
UI.MinimizeButton.Font = Enum.Font.SourceSansBold
UI.MinimizeButton.Parent = UI.TopHeader

UI.MinimizeLogo = Instance.new("ImageButton")
UI.MinimizeLogo.Name = "MinimizeLogo"
UI.MinimizeLogo.Size = UDim2.new(0, 40, 0, 40)
UI.MinimizeLogo.Position = UDim2.new(0.05, 0, 0.05, 0)
UI.MinimizeLogo.BackgroundColor3 = Decode.Theme.SidebarBackground
UI.MinimizeLogo.BackgroundTransparency = 0.2
UI.MinimizeLogo.Image = isfile(assetPath) and getcustomasset(assetPath) or ""
UI.MinimizeLogo.Visible = false
UI.MinimizeLogo.Active = true
UI.MinimizeLogo.Draggable = true
UI.MinimizeLogo.Parent = UI.ScreenGui

UI.LogoCorner = Instance.new("UICorner")
UI.LogoCorner.CornerRadius = UDim.new(1, 0)
UI.LogoCorner.Parent = UI.MinimizeLogo

UI.LogoStroke = Instance.new("UIStroke")
UI.LogoStroke.Color = Decode.Theme.MainBackground
UI.LogoStroke.Thickness = 2
UI.LogoStroke.Parent = UI.MinimizeLogo

UI.MinimizeButton.MouseButton1Click:Connect(function()
    UI.FrameMain.Visible = false
    UI.MinimizeLogo.Visible = true
end)

UI.MinimizeLogo.MouseButton1Click:Connect(function()
    UI.MinimizeLogo.Visible = false
    UI.FrameMain.Visible = true
end)

UI.Sidebar = Instance.new("Frame")
UI.Sidebar.Name = "Sidebar"
UI.Sidebar.Size = UDim2.new(0, 160, 1, -35)
UI.Sidebar.Position = UDim2.new(0, 0, 0, 35)
UI.Sidebar.BackgroundColor3 = Decode.Theme.SidebarBackground
UI.Sidebar.BackgroundTransparency = 0.2
UI.Sidebar.BorderSizePixel = 0
UI.Sidebar.Parent = UI.FrameMain

UI.CornerSidebar = Instance.new("UICorner")
UI.CornerSidebar.CornerRadius = UDim.new(0, 10)
UI.CornerSidebar.Parent = UI.Sidebar

UI.NavScroll = Instance.new("ScrollingFrame")
UI.NavScroll.Size = UDim2.new(1, -12, 1, -20)
UI.NavScroll.Position = UDim2.new(0, 12, 0, 10)
UI.NavScroll.BackgroundTransparency = 1
UI.NavScroll.BorderSizePixel = 0
UI.NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
UI.NavScroll.ScrollBarThickness = 0
UI.NavScroll.Parent = UI.Sidebar

UI.NavLayout = Instance.new("UIListLayout")
UI.NavLayout.Parent = UI.NavScroll
UI.NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
UI.NavLayout.Padding = UDim.new(0, 4)

UI.NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    UI.NavScroll.CanvasSize = UDim2.new(0, 0, 0, UI.NavLayout.AbsoluteContentSize.Y)
end)

UI.ContentContainer = Instance.new("Frame")
UI.ContentContainer.Name = "ContentContainer"
UI.ContentContainer.Size = UDim2.new(1, -185, 1, -50)
UI.ContentContainer.Position = UDim2.new(0, 175, 0, 40)
UI.ContentContainer.BackgroundTransparency = 1
UI.ContentContainer.Parent = UI.FrameMain

UI.PageHeaderLabel = Instance.new("TextLabel")
UI.PageHeaderLabel.Name = "PageHeaderLabel"
UI.PageHeaderLabel.Size = UDim2.new(1, 0, 0, 30)
UI.PageHeaderLabel.Position = UDim2.new(0, 0, 0, -5)
UI.PageHeaderLabel.BackgroundTransparency = 1
UI.PageHeaderLabel.Text = "Home"
UI.PageHeaderLabel.TextColor3 = Decode.Theme.TextMain
UI.PageHeaderLabel.TextSize = 22
UI.PageHeaderLabel.Font = Enum.Font.SourceSansBold
UI.PageHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
UI.PageHeaderLabel.Parent = UI.ContentContainer

UI.NotifyContainer = Instance.new("Frame")
UI.NotifyContainer.Name = "NotificationContainer"
UI.NotifyContainer.Size = UDim2.new(0, 280, 0, 400)
UI.NotifyContainer.Position = UDim2.new(1, -290, 0, 20)
UI.NotifyContainer.BackgroundTransparency = 1
UI.NotifyContainer.ZIndex = 9999
UI.NotifyContainer.Parent = UI.ScreenGui

local activeCards = {}
local maxCards = 3

function Decode:Notify(titleText, bodyText, isAlert)
    for idx = #activeCards, 1, -1 do
        local oldCard = activeCards[idx]
        if idx >= maxCards then
            table.remove(activeCards, idx)
            local dropTween = TweenService:Create(oldCard, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1.5, 0, 0, oldCard.Position.Y.Offset),
                BackgroundTransparency = 1
            })
            dropTween:Play()
            dropTween.Completed:Connect(function() oldCard:Destroy() end)
        else
            activeCards[idx + 1] = oldCard
            local targetY = idx * 68
            TweenService:Create(oldCard, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, targetY)
            }):Play()
        end
    end

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 56)
    Card.Position = UDim2.new(1.4, 0, 0, 0)
    Card.BackgroundColor3 = Decode.Theme.SidebarBackground
    Card.BackgroundTransparency = 0.1
    Card.BorderSizePixel = 0
    Card.ZIndex = 10000
    Card.Parent = UI.NotifyContainer

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 6)
    CardCorner.Parent = Card

    local GlowBar = Instance.new("Frame")
    GlowBar.Size = UDim2.new(0, 4, 1, 0)
    GlowBar.Position = UDim2.new(0, 0, 0, 0)
    GlowBar.BackgroundColor3 = isAlert and Color3.fromRGB(239, 68, 68) or Decode.Theme.AccentColor
    GlowBar.BorderSizePixel = 0
    GlowBar.ZIndex = 10001
    GlowBar.Parent = Card

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(0, 4)
    GlowCorner.Parent = GlowBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 14, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = tostring(titleText):upper()
    TitleLabel.TextColor3 = isAlert and Color3.fromRGB(252, 165, 165) or Decode.Theme.TextMain
    TitleLabel.TextSize = 11
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 10002
    TitleLabel.Parent = Card

    local BodyLabel = Instance.new("TextLabel")
    BodyLabel.Size = UDim2.new(1, -20, 0, 24)
    BodyLabel.Position = UDim2.new(0, 14, 0, 24)
    BodyLabel.BackgroundTransparency = 1
    BodyLabel.Text = bodyText
    BodyLabel.TextColor3 = Decode.Theme.TextMuted
    BodyLabel.TextSize = 13
    BodyLabel.Font = Enum.Font.SourceSans
    BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    BodyLabel.TextWrapped = true
    BodyLabel.ZIndex = 10002
    BodyLabel.Parent = Card

    table.insert(activeCards, 1, Card)

    TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(2.0, function()
        if Card and Card.Parent then
            local cardIndex = table.find(activeCards, Card)
            if cardIndex then table.remove(activeCards, cardIndex) end
            
            local exitTween = TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1.4, 0, 0, Card.Position.Y.Offset),
                BackgroundTransparency = 1
            })
            exitTween:Play()
            exitTween.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

_G.PostMailboxTerminalAlert = function(title, body, isErr)
    Decode:Notify(title, body, isErr)
end

function Decode:CreateTab(tabName)
    local Temp = {}
    Temp.Page = Instance.new("ScrollingFrame")
    Temp.Page.Name = tabName .. "_Page"
    Temp.Page.Size = UDim2.new(1, 0, 1, -30)
    Temp.Page.Position = UDim2.new(0, 0, 0, 30)
    Temp.Page.BackgroundTransparency = 1
    Temp.Page.BorderSizePixel = 0
    Temp.Page.Visible = false
    Temp.Page.ScrollBarThickness = 0
    Temp.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Temp.Page.Parent = UI.ContentContainer

    Temp.Layout = Instance.new("UIListLayout")
    Temp.Layout.Parent = Temp.Page
    Temp.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Temp.Layout.Padding = UDim.new(0, 6)
    
    Temp.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Temp.Page.CanvasSize = UDim2.new(0, 0, 0, Temp.Layout.AbsoluteContentSize.Y + 10)
    end)

    Temp.Button = Instance.new("TextButton")
    Temp.Button.Name = tabName .. "_Btn"
    Temp.Button.Size = UDim2.new(1, 0, 0, 34)
    Temp.Button.BackgroundColor3 = Decode.Theme.ElementBackground
    Temp.Button.BackgroundTransparency = 1
    Temp.Button.Text = "  " .. tabName
    Temp.Button.TextColor3 = Decode.Theme.TextMuted
    Temp.Button.TextSize = 14
    Temp.Button.Font = Enum.Font.SourceSansBold
    Temp.Button.TextXAlignment = Enum.TextXAlignment.Left
    Temp.Button.Parent = UI.NavScroll

    Temp.Corner = Instance.new("UICorner")
    Temp.Corner.CornerRadius = UDim.new(0, 6)
    Temp.Corner.Parent = Temp.Button

    UI.Tabs[tabName] = Temp

    Temp.Button.MouseButton1Click:Connect(function()
        for _, tab in pairs(UI.Tabs) do
            tab.Page.Visible = false
            tab.Button.BackgroundTransparency = 1
            tab.Button.TextColor3 = Decode.Theme.TextMuted
        end
        Temp.Page.Visible = true
        Temp.Button.BackgroundTransparency = 0.8
        Temp.Button.TextColor3 = Decode.Theme.TextMain
        UI.PageHeaderLabel.Text = tabName
    end)

    if not UI.FirstTab then
        UI.FirstTab = Temp
    end

    return Temp.Page
end

function Decode:CreateDropdown(parentPage, dropdownText)
    local Temp = {}
    Temp.Container = Instance.new("Frame")
    Temp.Container.Name = dropdownText .. "_DropdownContainer"
    Temp.Container.Size = UDim2.new(1, 0, 0, 36)
    Temp.Container.BackgroundColor3 = Decode.Theme.ElementBackground
    Temp.Container.BackgroundTransparency = 0.4
    Temp.Container.ClipsDescendants = true
    Temp.Container.Parent = parentPage

    Temp.Corner = Instance.new("UICorner")
    Temp.Corner.CornerRadius = UDim.new(0, 6)
    Temp.Corner.Parent = Temp.Container

    Temp.Header = Instance.new("TextButton")
    Temp.Header.Name = "Header"
    Temp.Header.Size = UDim2.new(1, 0, 0, 36)
    Temp.Header.BackgroundTransparency = 1
    Temp.Header.Text = "  " .. dropdownText
    Temp.Header.TextColor3 = Decode.Theme.TextMain
    Temp.Header.TextSize = 14
    Temp.Header.Font = Enum.Font.SourceSansSemibold
    Temp.Header.TextXAlignment = Enum.TextXAlignment.Left
    Temp.Header.Parent = Temp.Container

    Temp.Arrow = Instance.new("TextLabel")
    Temp.Arrow.Name = "Arrow"
    Temp.Arrow.Size = UDim2.new(0, 36, 0, 36)
    Temp.Arrow.Position = UDim2.new(1, -36, 0, 0)
    Temp.Arrow.BackgroundTransparency = 1
    Temp.Arrow.Text = ">"
    Temp.Arrow.TextColor3 = Decode.Theme.TextMuted
    Temp.Arrow.TextSize = 13
    Temp.Arrow.Font = Enum.Font.SourceSansBold
    Temp.Arrow.Parent = Temp.Header

    Temp.ItemsFrame = Instance.new("Frame")
    Temp.ItemsFrame.Name = "Items"
    Temp.ItemsFrame.Size = UDim2.new(1, -12, 1, -40)
    Temp.ItemsFrame.Position = UDim2.new(0, 6, 0, 40)
    Temp.ItemsFrame.BackgroundTransparency = 1
    Temp.ItemsFrame.Parent = Temp.Container

    Temp.Layout = Instance.new("UIListLayout")
    Temp.Layout.Parent = Temp.ItemsFrame
    Temp.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Temp.Layout.Padding = UDim.new(0, 5)

    Temp.Open = false
    Temp.Header.MouseButton1Click:Connect(function()
        Temp.Open = not Temp.Open
        local targetHeight = Temp.Open and (Temp.Layout.AbsoluteContentSize.Y + 45) or 36
        local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(Temp.Container, info, {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        TweenService:Create(Temp.Arrow, info, {Rotation = Temp.Open and 90 or 0}):Play()
        
        task.wait(0.2)
        if Temp.Open and parentPage:IsA("ScrollingFrame") then
            parentPage.CanvasSize = UDim2.new(0, 0, 0, parentPage.UIListLayout.AbsoluteContentSize.Y + 10)
        end
    end)

    return Temp.ItemsFrame
end

function Decode:AddSlider(parentPage, sliderText, defaultValue, callback, subtext)
    local Temp = {}
    Temp.Frame = Instance.new("Frame")
    Temp.Frame.Size = UDim2.new(1, 0, 0, 36)
    Temp.Frame.BackgroundColor3 = Decode.Theme.ElementBackground
    Temp.Frame.BackgroundTransparency = 0.6
    Temp.Frame.Parent = parentPage

    Temp.Corner = Instance.new("UICorner")
    Temp.Corner.CornerRadius = UDim.new(0, 6)
    Temp.Corner.Parent = Temp.Frame

    Temp.Label = Instance.new("TextLabel")
    Temp.Label.Size = UDim2.new(0, 180, subtext and 0.5 or 1, 0)
    Temp.Label.Position = UDim2.new(0, 10, 0, subtext and 2 or 0)
    Temp.Label.BackgroundTransparency = 1
    Temp.Label.Text = sliderText
    Temp.Label.TextColor3 = Decode.Theme.TextMain
    Temp.Label.TextSize = 13
    Temp.Label.Font = Enum.Font.SourceSansBold
    Temp.Label.TextXAlignment = Enum.TextXAlignment.Left
    Temp.Label.Parent = Temp.Frame

    if subtext then
        Temp.SubLabel = Instance.new("TextLabel")
        Temp.SubLabel.Size = UDim2.new(0, 220, 0.5, 0)
        Temp.SubLabel.Position = UDim2.new(0, 10, 0.5, -2)
        Temp.SubLabel.BackgroundTransparency = 1
        Temp.SubLabel.Text = subtext
        Temp.SubLabel.TextColor3 = Decode.Theme.TextMuted
        Temp.SubLabel.TextSize = 11
        Temp.SubLabel.Font = Enum.Font.SourceSans
        Temp.SubLabel.TextXAlignment = Enum.TextXAlignment.Left
        Temp.SubLabel.Parent = Temp.Frame
    end

    Temp.ValueBox = Instance.new("TextBox")
    Temp.ValueBox.Size = UDim2.new(0, 55, 0, 24)
    Temp.ValueBox.Position = UDim2.new(1, -65, 0.5, -12)
    Temp.ValueBox.BackgroundColor3 = Decode.Theme.MainBackground
    Temp.ValueBox.Text = tostring(defaultValue)
    Temp.ValueBox.TextColor3 = Decode.Theme.TextMain
    Temp.ValueBox.TextSize = 12
    Temp.ValueBox.Font = Enum.Font.SourceSansBold
    Temp.ValueBox.Parent = Temp.Frame

    Temp.CornerBox = Instance.new("UICorner")
    Temp.CornerBox.CornerRadius = UDim.new(0, 4)
    Temp.CornerBox.Parent = Temp.ValueBox

    Temp.ValueBox.FocusLost:Connect(function()
        local num = tonumber(Temp.ValueBox.Text)
        if num and callback then
            callback(num)
        elseif callback then
            callback(defaultValue)
        end
    end)
    return Temp
end

function Decode:AddToggle(parentPage, toggleText, callback)
    local Temp = {}
    Temp.Frame = Instance.new("Frame")
    Temp.Frame.Name = toggleText .. "_ToggleFrame"
    Temp.Frame.Size = UDim2.new(1, 0, 0, 36)
    Temp.Frame.BackgroundColor3 = Decode.Theme.ElementBackground
    Temp.Frame.BackgroundTransparency = 0.6
    Temp.Frame.Parent = parentPage

    Temp.Corner = Instance.new("UICorner")
    Temp.Corner.CornerRadius = UDim.new(0, 6)
    Temp.Corner.Parent = Temp.Frame

    Temp.Label = Instance.new("TextLabel")
    Temp.Label.Size = UDim2.new(1, -60, 1, 0)
    Temp.Label.Position = UDim2.new(0, 10, 0, 0)
    Temp.Label.BackgroundTransparency = 1
    Temp.Label.Text = toggleText
    Temp.Label.TextColor3 = Decode.Theme.TextMain
    Temp.Label.TextSize = 13
    Temp.Label.Font = Enum.Font.SourceSans
    Temp.Label.TextXAlignment = Enum.TextXAlignment.Left
    Temp.Label.Parent = Temp.Frame

    Temp.SwitchBg = Instance.new("Frame")
    Temp.SwitchBg.Name = "ToggleSwitchBg"
    Temp.SwitchBg.Size = UDim2.new(0, 32, 0, 16)
    Temp.SwitchBg.Position = UDim2.new(1, -45, 0.5, -8)
    Temp.SwitchBg.BackgroundColor3 = Decode.Theme.MainBackground
    Temp.SwitchBg.Parent = Temp.Frame

    Temp.SwitchCorner = Instance.new("UICorner")
    Temp.SwitchCorner.CornerRadius = UDim.new(1, 0)
    Temp.SwitchCorner.Parent = Temp.SwitchBg

    Temp.SliderNode = Instance.new("Frame")
    Temp.SliderNode.Name = "ToggleSliderNode"
    Temp.SliderNode.Size = UDim2.new(0, 12, 0, 12)
    Temp.SliderNode.Position = UDim2.new(0, 2, 0.5, -6)
    Temp.SliderNode.BackgroundColor3 = Decode.Theme.TextMuted
    Temp.SliderNode.Parent = Temp.SwitchBg

    Temp.NodeCorner = Instance.new("UICorner")
    Temp.NodeCorner.CornerRadius = UDim.new(1, 0)
    Temp.NodeCorner.Parent = Temp.SliderNode

    Temp.ClickBtn = Instance.new("TextButton")
    Temp.ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    Temp.ClickBtn.BackgroundTransparency = 1
    Temp.ClickBtn.Text = ""
    Temp.ClickBtn.Parent = Temp.Frame

    Temp.IsToggled = false

    function Temp:UpdateVisualState()
        if Temp.IsToggled then
            Temp.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
            Temp.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
        else
            Temp.SwitchBg.BackgroundColor3 = Decode.Theme.MainBackground
            Temp.SliderNode.BackgroundColor3 = Decode.Theme.TextMuted
        end
    end

    Temp.ClickBtn.MouseButton1Click:Connect(function()
        Temp.IsToggled = not Temp.IsToggled
        local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if Temp.IsToggled then
            game:GetService("TweenService"):Create(Temp.SwitchBg, info, {BackgroundColor3 = Decode.Theme.AccentColor}):Play()
            game:GetService("TweenService"):Create(Temp.SliderNode, info, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMain}):Play()
        else
            game:GetService("TweenService"):Create(Temp.SwitchBg, info, {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            game:GetService("TweenService"):Create(Temp.SliderNode, info, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
        if callback then callback(Temp.IsToggled) end
    end)

    return Temp
end

function Decode:AddLabel(parentPage, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Decode.Theme.TextMuted
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.Parent = parentPage
end

function Decode:AddSelector(parentPage, text, options, onSelect)
    local Temp = {}
    Temp.Frame = Instance.new("Frame")
    Temp.Frame.Size = UDim2.new(1, 0, 0, 36)
    Temp.Frame.BackgroundColor3 = Decode.Theme.ElementBackground
    Temp.Frame.BackgroundTransparency = 0.6
    Temp.Frame.Parent = parentPage

    Temp.Corner = Instance.new("UICorner")
    Temp.Corner.CornerRadius = UDim.new(0, 6)
    Temp.Corner.Parent = Temp.Frame

    Temp.Label = Instance.new("TextLabel")
    Temp.Label.Size = UDim2.new(0, 150, 1, 0)
    Temp.Label.Position = UDim2.new(0, 10, 0, 0)
    Temp.Label.BackgroundTransparency = 1
    Temp.Label.Text = text
    Temp.Label.TextColor3 = Decode.Theme.TextMain
    Temp.Label.TextSize = 13
    Temp.Label.Font = Enum.Font.SourceSansBold
    Temp.Label.TextXAlignment = Enum.TextXAlignment.Left
    Temp.Label.Parent = Temp.Frame

    Temp.SelectBtn = Instance.new("TextButton")
    Temp.SelectBtn.Size = UDim2.new(0, 120, 0, 26)
    Temp.SelectBtn.Position = UDim2.new(1, -130, 0.5, -13)
    Temp.SelectBtn.BackgroundColor3 = Decode.Theme.MainBackground
    Temp.SelectBtn.Text = "Select Options"
    Temp.SelectBtn.TextColor3 = Decode.Theme.TextMuted
    Temp.SelectBtn.TextSize = 12
    Temp.SelectBtn.Font = Enum.Font.SourceSans
    Temp.SelectBtn.Parent = Temp.Frame

    Temp.SelectCorner = Instance.new("UICorner")
    Temp.SelectCorner.CornerRadius = UDim.new(0, 6)
    Temp.SelectCorner.Parent = Temp.SelectBtn

    Temp.Popup = Instance.new("Frame")
    Temp.Popup.Size = UDim2.new(0, 160, 0, 240)
    Temp.Popup.Position = UDim2.new(1, -175, 0, 45)
    Temp.Popup.BackgroundColor3 = Decode.Theme.SidebarBackground
    Temp.Popup.BorderSizePixel = 0
    Temp.Popup.Visible = false
    Temp.Popup.ZIndex = 50
    Temp.Popup.Parent = UI.FrameMain

    Temp.PopupCorner = Instance.new("UICorner")
    Temp.PopupCorner.CornerRadius = UDim.new(0, 8)
    Temp.PopupCorner.Parent = Temp.Popup

    Temp.PopupStroke = Instance.new("UIStroke")
    Temp.PopupStroke.Color = Decode.Theme.MainBackground
    Temp.PopupStroke.Thickness = 1
    Temp.PopupStroke.Parent = Temp.Popup

    Temp.SearchBox = Instance.new("TextBox")
    Temp.SearchBox.Size = UDim2.new(1, -20, 0, 24)
    Temp.SearchBox.Position = UDim2.new(0, 10, 0, 10)
    Temp.SearchBox.BackgroundColor3 = Decode.Theme.MainBackground
    Temp.SearchBox.Text = ""
    Temp.SearchBox.PlaceholderText = "Search"
    Temp.SearchBox.PlaceholderColor3 = Decode.Theme.TextMuted
    Temp.SearchBox.TextColor3 = Decode.Theme.TextMain
    Temp.SearchBox.TextSize = 12
    Temp.SearchBox.Font = Enum.Font.SourceSans
    Temp.SearchBox.ZIndex = 51
    Temp.SearchBox.Parent = Temp.Popup

    Temp.SearchCorner = Instance.new("UICorner")
    Temp.SearchCorner.CornerRadius = UDim.new(0, 4)
    Temp.SearchCorner.Parent = Temp.SearchBox

    Temp.Scroll = Instance.new("ScrollingFrame")
    Temp.Scroll.Size = UDim2.new(1, -10, 1, -50)
    Temp.Scroll.Position = UDim2.new(0, 5, 0, 45)
    Temp.Scroll.BackgroundTransparency = 1
    Temp.Scroll.BorderSizePixel = 0
    Temp.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Temp.Scroll.ScrollBarThickness = 2
    Temp.Scroll.ScrollBarImageColor3 = Decode.Theme.AccentColor
    Temp.Scroll.ZIndex = 51
    Temp.Scroll.Parent = Temp.Popup

    Temp.Layout = Instance.new("UIListLayout")
    Temp.Layout.Padding = UDim.new(0, 4)
    Temp.Layout.Parent = Temp.Scroll

    Temp.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Temp.Scroll.CanvasSize = UDim2.new(0, 0, 0, Temp.Layout.AbsoluteContentSize.Y)
    end)

    function Temp:UpdateSelectionText(val)
        Temp.SelectBtn.TextWrapped = true
        if type(val) == "table" then
            if #val > 0 then
                local sortedTable = {}
                for _, item in ipairs(val) do table.insert(sortedTable, item) end
                table.sort(sortedTable)

                local textStr = ""
                for i, option in ipairs(sortedTable) do
                    textStr = textStr .. (i == 1 and "" or ", ") .. option
                end
                Temp.SelectBtn.Text = textStr
                Temp.SelectBtn.TextColor3 = Decode.Theme.TextMain
                Temp.SelectBtn.TextSize = #textStr > 22 and 10 or 12
            else
                Temp.SelectBtn.Text = "Select Options"
                Temp.SelectBtn.TextColor3 = Decode.Theme.TextMuted
                Temp.SelectBtn.TextSize = 12
            end
        else
            if val and val ~= "" then
                Temp.SelectBtn.Text = tostring(val)
                Temp.SelectBtn.TextColor3 = Decode.Theme.TextMain
                Temp.SelectBtn.TextSize = string.len(tostring(val)) > 22 and 10 or 12
            else
                Temp.SelectBtn.Text = "Select Options"
                Temp.SelectBtn.TextColor3 = Decode.Theme.TextMuted
                Temp.SelectBtn.TextSize = 12
            end
        end
        
        for _, btn in pairs(Temp.Scroll:GetChildren()) do
            if btn:IsA("TextButton") then
                local btnText = string.gsub(btn.Text, "^%s+", "")
                if Temp.SelectBtn.Text == btnText or string.find(Temp.SelectBtn.Text, btnText .. ",") or string.find(Temp.SelectBtn.Text, ", " .. btnText) then
                    btn.BackgroundTransparency = 0.4
                else
                    btn.BackgroundTransparency = 1
                end
            end
        end
    end

    function Temp:Populate(list)
        for _, obj in pairs(Temp.Scroll:GetChildren()) do
            if obj:IsA("TextButton") then obj:Destroy() end
        end
        for _, optName in ipairs(list) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, -5, 0, 28)
            OptBtn.BackgroundColor3 = Decode.Theme.AccentColor
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = "  " .. optName
            OptBtn.TextColor3 = Decode.Theme.TextMain
            OptBtn.TextSize = 13
            OptBtn.Font = Enum.Font.SourceSans
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
            OptBtn.ZIndex = 52
            OptBtn.Parent = Temp.Scroll

            local OptCorner = Instance.new("UICorner")
            OptCorner.CornerRadius = UDim.new(0, 4)
            OptCorner.Parent = OptBtn

            local currentText = Temp.SelectBtn.Text
            if currentText == optName or string.find(currentText, optName .. ",") or string.find(currentText, ", " .. optName) then
                OptBtn.BackgroundTransparency = 0.4
            end

            OptBtn.MouseButton1Click:Connect(function()
                if onSelect then
                    onSelect(optName, Temp)
                else
                    if Temp.SelectBtn.Text == optName then
                        Temp:UpdateSelectionText("")
                    else
                        Temp:UpdateSelectionText(optName)
                    end
                end
            end)
        end
    end

    if options then Temp:Populate(options) end

    Temp.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(Temp.SearchBox.Text)
        for _, btn in pairs(Temp.Scroll:GetChildren()) do
            if btn:IsA("TextButton") then
                if query == "" or string.find(string.lower(btn.Text), query) then
                    btn.Visible = true
                else
                    btn.Visible = false
                end
            end
        end
    end)

    local UserInputService = game:GetService("UserInputService")
    
    Temp.SelectBtn.MouseButton1Click:Connect(function()
        Temp.Popup.Visible = not Temp.Popup.Visible
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Temp.Popup.Visible then
                local pos = input.Position
                local popupPos = Temp.Popup.AbsolutePosition
                local popupSize = Temp.Popup.AbsoluteSize
                local btnPos = Temp.SelectBtn.AbsolutePosition
                local btnSize = Temp.SelectBtn.AbsoluteSize

                local inPopup = pos.X >= popupPos.X and pos.X <= (popupPos.X + popupSize.X) and pos.Y >= popupPos.Y and pos.Y <= (popupPos.Y + popupSize.Y)
                local inBtn = pos.X >= btnPos.X and pos.X <= (btnPos.X + btnSize.X) and pos.Y >= btnPos.Y and pos.Y <= (btnPos.Y + btnSize.Y)

                if not inPopup and not inBtn then
                    Temp.Popup.Visible = false
                end
            end
        end
    end)
    
    return Temp
end

for _, name in ipairs(UI.PageList) do
    UI.CreatedPages[name] = Decode:CreateTab(name)
end

UI.DiscordDrop = Decode:CreateDropdown(UI.CreatedPages["Home"], "Discord")

UI.DiscordRow = Instance.new("Frame")
UI.DiscordRow.Name = "DiscordInviteRow"
UI.DiscordRow.Size = UDim2.new(1, 0, 0, 36)
UI.DiscordRow.BackgroundColor3 = Decode.Theme.ElementBackground
UI.DiscordRow.BackgroundTransparency = 0.6
UI.DiscordRow.Parent = UI.DiscordDrop

UI.DiscordRowCorner = Instance.new("UICorner")
UI.DiscordRowCorner.CornerRadius = UDim.new(0, 6)
UI.DiscordRowCorner.Parent = UI.DiscordRow

UI.DiscordLabel = Instance.new("TextLabel")
UI.DiscordLabel.Size = UDim2.new(0, 150, 1, 0)
UI.DiscordLabel.Position = UDim2.new(0, 10, 0, 0)
UI.DiscordLabel.BackgroundTransparency = 1
UI.DiscordLabel.Text = "Discord Invite"
UI.DiscordLabel.TextColor3 = Decode.Theme.TextMain
UI.DiscordLabel.TextSize = 13
UI.DiscordLabel.Font = Enum.Font.SourceSans
UI.DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left
UI.DiscordLabel.Parent = UI.DiscordRow

UI.CopyButton = Instance.new("TextButton")
UI.CopyButton.Name = "CopyBtn"
UI.CopyButton.Size = UDim2.new(0, 55, 0, 24)
UI.CopyButton.Position = UDim2.new(1, -65, 0.5, -12)
UI.CopyButton.BackgroundColor3 = Decode.Theme.MainBackground
UI.CopyButton.Text = "COPY"
UI.CopyButton.TextColor3 = Decode.Theme.TextMain
UI.CopyButton.TextSize = 12
UI.CopyButton.Font = Enum.Font.SourceSansBold
UI.CopyButton.Parent = UI.DiscordRow

UI.CopyCorner = Instance.new("UICorner")
UI.CopyCorner.CornerRadius = UDim.new(0, 4)
UI.CopyCorner.Parent = UI.CopyButton

UI.CopyButton.MouseButton1Click:Connect(function()
    local invite = "https://discord.gg/Q6SqhpEKGZ"
    local clipboard = env["setclipboard"] or env["toclipboard"]
    if clipboard then
        pcall(clipboard, invite)
    elseif env["request"] then
        pcall(env["request"], {
            Url = "http://localhost:24892/copy",
            Method = "POST",
            Body = invite
        })
    end
end)

UI.LocalPlayerDrop = Decode:CreateDropdown(UI.CreatedPages["Home"], "LocalPlayer")
UI.HarvestDrop = Decode:CreateDropdown(UI.CreatedPages["Main"], "Harvest")

function UI:UpdateCharacterSpeed()
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            if Configurations.SpeedEnabled then
                Humanoid.WalkSpeed = Configurations.Speed
            else
                Humanoid.WalkSpeed = UI.PlayerTracker.OriginalSpeed
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(Char)
    local Hum = Char:WaitForChild("Humanoid", 5)
    if Hum then
        UI.PlayerTracker.OriginalSpeed = Hum.WalkSpeed
        if Configurations.SpeedEnabled then
            Hum.WalkSpeed = Configurations.Speed
        end
    end
end)

RunService.Stepped:Connect(function()
    if Configurations.NoClipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Configurations.InfiniteJumpEnabled and LocalPlayer.Character then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

UI.SpeedSlider = Decode:AddSlider(UI.LocalPlayerDrop, "Set Speed", Configurations.Speed, function(value)
    Configurations.Speed = value
    saveConfig()
    UI:UpdateCharacterSpeed()
end)

UI.WalkspeedToggle = Decode:AddToggle(UI.LocalPlayerDrop, "Enable Walkspeed", function(state)
    Configurations.SpeedEnabled = state
    saveConfig()
    if not state then
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = UI.PlayerTracker.OriginalSpeed
            end
        end
    else
        UI:UpdateCharacterSpeed()
    end
end)

UI.NoClipToggle = Decode:AddToggle(UI.LocalPlayerDrop, "No Clip", function(state)
    Configurations.NoClipEnabled = state
    saveConfig()
    if not state and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end)

UI.InfJumpToggle = Decode:AddToggle(UI.LocalPlayerDrop, "Infinite Jump", function(state)
    Configurations.InfiniteJumpEnabled = state
    saveConfig()
    if not state and LocalPlayer.Character then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

Decode:AddLabel(UI.HarvestDrop, "- [ Configs ] -")

UI.StopCollectToggle = Decode:AddToggle(UI.HarvestDrop, "Stop Harvest If Backpack Is Full Max", function(state)
    Configurations.StopCollectIfFull = state
    saveConfig()
end)

UI.DelayCollectSlider = Decode:AddSlider(UI.HarvestDrop, "Delay To Harvest", Configurations.CollectDelay or 0, function(value)
    Configurations.CollectDelay = value
    saveConfig()
end)

UI.DisablePromptToggle = Decode:AddToggle(UI.HarvestDrop, "Disable Harvest Prompt", function(state)
    Configurations.DisableCollectPrompt = state
    saveConfig()
end)

Decode:AddLabel(UI.HarvestDrop, "- [ Options ] -")

UI.FruitSelector = Decode:AddSelector(UI.HarvestDrop, "Select Fruits", Decode:GetAssetCategory("Plants"), function(chosen, selectorObj)
    Configurations.HarvestFruitFilter = Configurations.HarvestFruitFilter or {}
    local idx = table.find(Configurations.HarvestFruitFilter, chosen)
    if idx then table.remove(Configurations.HarvestFruitFilter, idx) else table.insert(Configurations.HarvestFruitFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.HarvestFruitFilter)
end)

UI.MutationSelector = Decode:AddSelector(UI.HarvestDrop, "Select Mutations", Decode:GetGameMutations(), function(chosen, selectorObj)
    Configurations.HarvestMutationFilter = Configurations.HarvestMutationFilter or {}
    local idx = table.find(Configurations.HarvestMutationFilter, chosen)
    if idx then table.remove(Configurations.HarvestMutationFilter, idx) else table.insert(Configurations.HarvestMutationFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.HarvestMutationFilter)
end)

UI.ThresholdSelector = Decode:AddSelector(UI.HarvestDrop, "Select Threshold Mode", {"Above", "Below"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.ThresholdMode = ""
    else
        Configurations.ThresholdMode = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ThresholdMode)
end)

UI.WeightSlider = Decode:AddSlider(UI.HarvestDrop, "Weight Threshold", Configurations.WeightThreshold or 0, function(value)
    Configurations.WeightThreshold = value
    saveConfig()
end, "if you don't want use this, just input '0'")

Decode:AddLabel(UI.HarvestDrop, "- [ Functions ] -")

UI.HarvestFruitsToggle = {}
UI.HarvestAllFruitsToggle = {}

UI.HarvestFruitsToggle = Decode:AddToggle(UI.HarvestDrop, "Harvest Fruits", function(state)
    Configurations.HarvestFruits = state
    saveConfig()
    if state and Configurations.HarvestAllFruits then
        Configurations.HarvestAllFruits = false
        saveConfig()
        if UI.HarvestAllFruitsToggle and type(UI.HarvestAllFruitsToggle) == "table" and UI.HarvestAllFruitsToggle.SwitchBg then
            UI.HarvestAllFruitsToggle.IsToggled = false
            TweenService:Create(UI.HarvestAllFruitsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.HarvestAllFruitsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.HarvestAllFruitsToggle = Decode:AddToggle(UI.HarvestDrop, "Harvest All Fruits", function(state)
    Configurations.HarvestAllFruits = state
    saveConfig()
    if state and Configurations.HarvestFruits then
        Configurations.HarvestFruits = false
        saveConfig()
        if UI.HarvestFruitsToggle and type(UI.HarvestFruitsToggle) == "table" and UI.HarvestFruitsToggle.SwitchBg then
            UI.HarvestFruitsToggle.IsToggled = false
            TweenService:Create(UI.HarvestFruitsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.HarvestFruitsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.SellDrop = Decode:CreateDropdown(UI.CreatedPages["Main"], "Sell")

Decode:AddLabel(UI.SellDrop, "- [ Configs ] -")

UI.AllowSellIfFullToggle = Decode:AddToggle(UI.SellDrop, "Allow Sell If Backpack Is Full Max", function(state)
    Configurations.AllowSellIfFull = state
    saveConfig()
end)

UI.DelaySellSlider = Decode:AddSlider(UI.SellDrop, "Delay To Sell", Configurations.SellDelay or 0, function(value)
    Configurations.SellDelay = value
    saveConfig()
end)

Decode:AddLabel(UI.SellDrop, "- [ Options ] -")

UI.SellFruitSelector = Decode:AddSelector(UI.SellDrop, "Select Fruits", Decode:GetAssetCategory("Plants"), function(chosen, selectorObj)
    Configurations.SellFruitFilter = Configurations.SellFruitFilter or {}
    local idx = table.find(Configurations.SellFruitFilter, chosen)
    if idx then 
        table.remove(Configurations.SellFruitFilter, idx) 
    else 
        table.insert(Configurations.SellFruitFilter, chosen) 
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.SellFruitFilter)
end)

UI.SellMutationSelector = Decode:AddSelector(UI.SellDrop, "Select Mutations", Decode:GetGameMutations(), function(chosen, selectorObj)
    Configurations.SellMutationFilter = Configurations.SellMutationFilter or {}
    local idx = table.find(Configurations.SellMutationFilter, chosen)
    if idx then 
        table.remove(Configurations.SellMutationFilter, idx) 
    else 
        table.insert(Configurations.SellMutationFilter, chosen) 
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.SellMutationFilter)
end)

UI.SellThresholdSelector = Decode:AddSelector(UI.SellDrop, "Select Threshold Mode", {"Above", "Below"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.SellThresholdMode = ""
    else
        Configurations.SellThresholdMode = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.SellThresholdMode)
end)

UI.SellWeightSlider = Decode:AddSlider(UI.SellDrop, "Weight Threshold", Configurations.SellWeightThreshold or 0, function(value)
    Configurations.SellWeightThreshold = value
    saveConfig()
end, "if you don't want use this, just input '0'")

Decode:AddLabel(UI.SellDrop, "- [ Functions ] -")

UI.SellFruitsToggle = {}
UI.SellAllFruitsToggle = {}

UI.SellFruitsToggle = Decode:AddToggle(UI.SellDrop, "Sell Fruits", function(state)
    Configurations.SellFruits = state
    saveConfig()
    if state and Configurations.SellAllFruits then
        Configurations.SellAllFruits = false
        saveConfig()
        if UI.SellAllFruitsToggle and type(UI.SellAllFruitsToggle) == "table" and UI.SellAllFruitsToggle.SwitchBg then
            UI.SellAllFruitsToggle.IsToggled = false
            TweenService:Create(UI.SellAllFruitsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.SellAllFruitsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.SellAllFruitsToggle = Decode:AddToggle(UI.SellDrop, "Sell All Fruits", function(state)
    Configurations.SellAllFruits = state
    saveConfig()
    if state and Configurations.SellFruits then
        Configurations.SellFruits = false
        saveConfig()
        if UI.SellFruitsToggle and type(UI.SellFruitsToggle) == "table" and UI.SellFruitsToggle.SwitchBg then
            UI.SellFruitsToggle.IsToggled = false
            TweenService:Create(UI.SellFruitsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.SellFruitsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.PetsDrop = Decode:CreateDropdown(UI.CreatedPages["Main"], "Pets")

Decode:AddLabel(UI.PetsDrop, "- [ Configs ] -")

UI.PetTweenSlider = Decode:AddSlider(UI.PetsDrop, "Tween Speed", Configurations.PetTweenSpeed or 0, function(value)
    Configurations.PetTweenSpeed = value
    saveConfig()
end)

Decode:AddLabel(UI.PetsDrop, "- [ Options ] -")

UI.PetsSelector = Decode:AddSelector(UI.PetsDrop, "Select Pets", {}, function(chosen, selectorObj)
    Configurations.SelectedPetsFilter = Configurations.SelectedPetsFilter or {}
    local idx = table.find(Configurations.SelectedPetsFilter, chosen)
    if idx then 
        table.remove(Configurations.SelectedPetsFilter, idx) 
    else 
        table.insert(Configurations.SelectedPetsFilter, chosen) 
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.SelectedPetsFilter)
end)

UI.PetSizeSelector = Decode:AddSelector(UI.PetsDrop, "Select Size/Type", {}, function(chosen, selectorObj)
    Configurations.SelectedPetSizeFilter = Configurations.SelectedPetSizeFilter or {}
    local idx = table.find(Configurations.SelectedPetSizeFilter, chosen)
    if idx then 
        table.remove(Configurations.SelectedPetSizeFilter, idx) 
    else 
        table.insert(Configurations.SelectedPetSizeFilter, chosen) 
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.SelectedPetSizeFilter)
end)

Decode:AddLabel(UI.PetsDrop, "- [ Functions ] -")

UI.BuyPetsToggle = Decode:AddToggle(UI.PetsDrop, "Buy Pets", function(state)
    Configurations.AutoBuyPets = state
    saveConfig()
end)

UI.CollectDrop = Decode:CreateDropdown(UI.CreatedPages["Main"], "Collect")

Decode:AddLabel(UI.CollectDrop, "- [ Configs ] -")

UI.CollectTweenSlider = Decode:AddSlider(UI.CollectDrop, "Tween Speed", Configurations.CollectTweenSpeed or 0, function(value)
    Configurations.CollectTweenSpeed = value
    saveConfig()
end)

Decode:AddLabel(UI.CollectDrop, "- [ Functions ] -")

UI.CollectSeedsToggle = Decode:AddToggle(UI.CollectDrop, "Collect All Event Seeds", function(state)
    Configurations.AutoCollectEventSeeds = state
    saveConfig()
end)

UI.MailboxDrop = Decode:CreateDropdown(UI.CreatedPages["Assist"], "Mailbox")

Decode:AddLabel(UI.MailboxDrop, "- [ Configs ] -")

local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(1, 0, 0, 36)
TargetFrame.BackgroundColor3 = Decode.Theme.ElementBackground
TargetFrame.BackgroundTransparency = 0.6
TargetFrame.Parent = UI.MailboxDrop

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 6)
TargetCorner.Parent = TargetFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0, 150, 1, 0)
TargetLabel.Position = UDim2.new(0, 10, 0, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Send Target"
TargetLabel.TextColor3 = Decode.Theme.TextMain
TargetLabel.TextSize = 13
TargetLabel.Font = Enum.Font.SourceSansBold
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = TargetFrame

UI.MailTargetBox = Instance.new("TextBox")
UI.MailTargetBox.Size = UDim2.new(0, 120, 0, 26)
UI.MailTargetBox.Position = UDim2.new(1, -130, 0.5, -13)
UI.MailTargetBox.BackgroundColor3 = Decode.Theme.MainBackground
UI.MailTargetBox.Text = Configurations.MailTargetUser or ""
UI.MailTargetBox.PlaceholderText = "username"
UI.MailTargetBox.PlaceholderColor3 = Decode.Theme.TextMuted
UI.MailTargetBox.TextColor3 = Decode.Theme.TextMain
UI.MailTargetBox.TextSize = 12
UI.MailTargetBox.Font = Enum.Font.SourceSans
UI.MailTargetBox.Parent = TargetFrame

local MailBoxCorner = Instance.new("UICorner")
MailBoxCorner.CornerRadius = UDim.new(0, 6)
MailBoxCorner.Parent = UI.MailTargetBox

UI.MailTargetBox.FocusLost:Connect(function()
    Configurations.MailTargetUser = UI.MailTargetBox.Text
    saveConfig()
end)

UI.MailQuantitySlider = Decode:AddSlider(UI.MailboxDrop, "Send Quantity", Configurations.MailSendQuantity or 0, function(value)
    Configurations.MailSendQuantity = value
    saveConfig()
end)

UI.MailIntervalSlider = Decode:AddSlider(UI.MailboxDrop, "Send Interval", Configurations.MailSendInterval or 0, function(value)
    Configurations.MailSendInterval = value
    saveConfig()
end)

Decode:AddLabel(UI.MailboxDrop, "- [ Options ] -")

UI.MailPetsSelector = Decode:AddSelector(UI.MailboxDrop, "Select Pets", {}, function(chosen, selectorObj)
    Configurations.MailPetsFilter = Configurations.MailPetsFilter or {}
    local idx = table.find(Configurations.MailPetsFilter, chosen)
    if idx then table.remove(Configurations.MailPetsFilter, idx) else table.insert(Configurations.MailPetsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailPetsFilter)
end)

UI.MailFruitsSelector = Decode:AddSelector(UI.MailboxDrop, "Select Fruits", {}, function(chosen, selectorObj)
    Configurations.MailFruitsFilter = Configurations.MailFruitsFilter or {}
    local idx = table.find(Configurations.MailFruitsFilter, chosen)
    if idx then table.remove(Configurations.MailFruitsFilter, idx) else table.insert(Configurations.MailFruitsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailFruitsFilter)
end)

UI.MailSeedsSelector = Decode:AddSelector(UI.MailboxDrop, "Select Seeds", {}, function(chosen, selectorObj)
    Configurations.MailSeedsFilter = Configurations.MailSeedsFilter or {}
    local idx = table.find(Configurations.MailSeedsFilter, chosen)
    if idx then table.remove(Configurations.MailSeedsFilter, idx) else table.insert(Configurations.MailSeedsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailSeedsFilter)
end)

UI.MailSprinklersSelector = Decode:AddSelector(UI.MailboxDrop, "Select Sprinklers", {}, function(chosen, selectorObj)
    Configurations.MailSprinklersFilter = Configurations.MailSprinklersFilter or {}
    local idx = table.find(Configurations.MailSprinklersFilter, chosen)
    if idx then table.remove(Configurations.MailSprinklersFilter, idx) else table.insert(Configurations.MailSprinklersFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailSprinklersFilter)
end)

UI.MailWateringCansSelector = Decode:AddSelector(UI.MailboxDrop, "Select Watering Cans", {}, function(chosen, selectorObj)
    Configurations.MailWateringCansFilter = Configurations.MailWateringCansFilter or {}
    local idx = table.find(Configurations.MailWateringCansFilter, chosen)
    if idx then table.remove(Configurations.MailWateringCansFilter, idx) else table.insert(Configurations.MailWateringCansFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailWateringCansFilter)
end)

UI.MailCratesSelector = Decode:AddSelector(UI.MailboxDrop, "Select Crates", {}, function(chosen, selectorObj)
    Configurations.MailCratesFilter = Configurations.MailCratesFilter or {}
    local idx = table.find(Configurations.MailCratesFilter, chosen)
    if idx then table.remove(Configurations.MailCratesFilter, idx) else table.insert(Configurations.MailCratesFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailCratesFilter)
end)

UI.MailSeedPacksSelector = Decode:AddSelector(UI.MailboxDrop, "Select Seed Packs", {}, function(chosen, selectorObj)
    Configurations.MailSeedPacksFilter = Configurations.MailSeedPacksFilter or {}
    local idx = table.find(Configurations.MailSeedPacksFilter, chosen)
    if idx then table.remove(Configurations.MailSeedPacksFilter, idx) else table.insert(Configurations.MailSeedPacksFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailSeedPacksFilter)
end)

UI.MailEggsSelector = Decode:AddSelector(UI.MailboxDrop, "Select Eggs", {}, function(chosen, selectorObj)
    Configurations.MailEggsFilter = Configurations.MailEggsFilter or {}
    local idx = table.find(Configurations.MailEggsFilter, chosen)
    if idx then table.remove(Configurations.MailEggsFilter, idx) else table.insert(Configurations.MailEggsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailEggsFilter)
end)

UI.MailToolsSelector = Decode:AddSelector(UI.MailboxDrop, "Select Tools", {"Basic Pot", "Trowel"}, function(chosen, selectorObj)
    Configurations.MailToolsFilter = Configurations.MailToolsFilter or {}
    local idx = table.find(Configurations.MailToolsFilter, chosen)
    if idx then table.remove(Configurations.MailToolsFilter, idx) else table.insert(Configurations.MailToolsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.MailToolsFilter)
end)

Decode:AddLabel(UI.MailboxDrop, "- [ Functions ] -")

UI.SendMailToggle = Decode:AddToggle(UI.MailboxDrop, "Send Mail", function(state)
    Configurations.SendMailEnabled = state
    saveConfig()
end)

UI.ClaimMailToggle = Decode:AddToggle(UI.MailboxDrop, "Claim Mail", function(state)
    Configurations.ClaimMailEnabled = state
    saveConfig()
end)

UI.PlantingDrop = Decode:CreateDropdown(UI.CreatedPages["Assist"], "Planting")

Decode:AddLabel(UI.PlantingDrop, "- [ Configs ] -")

UI.PlantIntervalSlider = Decode:AddSlider(UI.PlantingDrop, "Plant Interval", Configurations.PlantInterval or 0, function(value)
    Configurations.PlantInterval = value
    saveConfig()
end)

Decode:AddLabel(UI.PlantingDrop, "- [ Options ] -")

UI.PlantSeedsSelector = Decode:AddSelector(UI.PlantingDrop, "Select Seeds", {}, function(chosen, selectorObj)
    Configurations.PlantSeedsFilter = Configurations.PlantSeedsFilter or {}
    local idx = table.find(Configurations.PlantSeedsFilter, chosen)
    if idx then table.remove(Configurations.PlantSeedsFilter, idx) else table.insert(Configurations.PlantSeedsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.PlantSeedsFilter)
end)

UI.PlantPositionSelector = Decode:AddSelector(UI.PlantingDrop, "Select Position", {"Sprinkler Radius", "Random", "Player Front"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.PlantPositionMode = ""
    else
        Configurations.PlantPositionMode = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.PlantPositionMode)
end)

Decode:AddLabel(UI.PlantingDrop, "- [ Function ] -")

UI.AutoPlantToggle = Decode:AddToggle(UI.PlantingDrop, "Plant", function(state)
    Configurations.AutoPlantEnabled = state
    saveConfig()
end)

UI.PottedDrop = Decode:CreateDropdown(UI.CreatedPages["Assist"], "Potted")

Decode:AddLabel(UI.PottedDrop, "- [ Options ] -")

UI.PotPlantsSelector = Decode:AddSelector(UI.PottedDrop, "Select Plants", {}, function(chosen, selectorObj)
    Configurations.PotPlantsFilter = Configurations.PotPlantsFilter or {}
    local idx = table.find(Configurations.PotPlantsFilter, chosen)
    if idx then table.remove(Configurations.PotPlantsFilter, idx) else table.insert(Configurations.PotPlantsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.PotPlantsFilter)
end)

UI.PotModeSelector = Decode:AddSelector(UI.PottedDrop, "Select Mode", {"Place", "Pickup"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.PotModeSelection = ""
    else
        Configurations.PotModeSelection = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.PotModeSelection)
end)

Decode:AddLabel(UI.PottedDrop, "- [ Functions ] -")

UI.SavePotPosBtn = Instance.new("TextButton")
UI.SavePotPosBtn.Size = UDim2.new(1, 0, 0, 36)
UI.SavePotPosBtn.BackgroundColor3 = Decode.Theme.ElementBackground
UI.SavePotPosBtn.BackgroundTransparency = 0.6
UI.SavePotPosBtn.Text = "Save Position"
UI.SavePotPosBtn.TextColor3 = Decode.Theme.TextMain
UI.SavePotPosBtn.TextSize = 13
UI.SavePotPosBtn.Font = Enum.Font.SourceSansBold
UI.SavePotPosBtn.Parent = UI.PottedDrop

local PotCorner = Instance.new("UICorner")
PotCorner.CornerRadius = UDim.new(0, 6)
PotCorner.Parent = UI.SavePotPosBtn

UI.SavePotPosBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            Configurations.PotSavedCFrame = {root.CFrame:GetComponents()}
            saveConfig()
            if _G.PostMailboxTerminalAlert then
                _G.PostMailboxTerminalAlert("Potted", "Saved target coordinates successfully!", false)
            end
        end
    end)
end)

UI.PotActionToggle = Decode:AddToggle(UI.PottedDrop, "Pot Place/Pickup", function(state)
    Configurations.AutoPotToggleState = state
    saveConfig()
end)

UI.TrowelDrop = Decode:CreateDropdown(UI.CreatedPages["Assist"], "Trowel")

Decode:AddLabel(UI.TrowelDrop, "- [ Configs ] -")

UI.TrowelIntervalSlider = Decode:AddSlider(UI.TrowelDrop, "Trowel Interval", Configurations.TrowelInterval or 0, function(value)
    Configurations.TrowelInterval = value
    saveConfig()
end)

Decode:AddLabel(UI.TrowelDrop, "- [ Options ] -")

UI.TrowelPlantsSelector = Decode:AddSelector(UI.TrowelDrop, "Select Plants", {}, function(chosen, selectorObj)
    Configurations.TrowelPlantsFilter = Configurations.TrowelPlantsFilter or {}
    local idx = table.find(Configurations.TrowelPlantsFilter, chosen)
    if idx then table.remove(Configurations.TrowelPlantsFilter, idx) else table.insert(Configurations.TrowelPlantsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.TrowelPlantsFilter)
end)

Decode:AddLabel(UI.TrowelDrop, "- [ Functions ] -")

UI.SaveTrowelPosBtn = Instance.new("TextButton")
UI.SaveTrowelPosBtn.Size = UDim2.new(1, 0, 0, 36)
UI.SaveTrowelPosBtn.BackgroundColor3 = Decode.Theme.ElementBackground
UI.SaveTrowelPosBtn.BackgroundTransparency = 0.6
UI.SaveTrowelPosBtn.Text = "Save Position"
UI.SaveTrowelPosBtn.TextColor3 = Decode.Theme.TextMain
UI.SaveTrowelPosBtn.TextSize = 13
UI.SaveTrowelPosBtn.Font = Enum.Font.SourceSansBold
UI.SaveTrowelPosBtn.Parent = UI.TrowelDrop

local TrowelCorner = Instance.new("UICorner")
TrowelCorner.CornerRadius = UDim.new(0, 6)
TrowelCorner.Parent = UI.SaveTrowelPosBtn

UI.SaveTrowelPosBtn.MouseButton1Click:Connect(function()
    local player = game:GetService("Players").LocalPlayer
    if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end
    local playerPlot = nil
    local gardensFolder = game:GetService("Workspace"):FindFirstChild("Gardens")
    if gardensFolder then
        for _, plot in ipairs(gardensFolder:GetChildren()) do
            local idChild = plot:FindFirstChild("OwnerUserId")
            local nameChild = plot:FindFirstChild("Owner")
            local idVal = idChild and (idChild:IsA("ValueBase") and idChild.Value or idChild)
            local nameVal = nameChild and (nameChild:IsA("ValueBase") and nameChild.Value or nameChild)
            local idAttr = plot:GetAttribute("OwnerUserId")
            local nameAttr = plot:GetAttribute("Owner")
            local matchId = (idVal == player.UserId) or (idAttr == player.UserId)
            local matchName = (nameVal == player.Name) or (nameAttr == player.Name)
            if matchId or matchName or string.find(string.lower(plot.Name), string.lower(player.Name)) then
                playerPlot = plot
                break
            end
        end
        if not playerPlot then
            local hrpPos = player.Character.HumanoidRootPart.Position
            local closestDist = math.huge
            for _, plot in ipairs(gardensFolder:GetChildren()) do
                local pivotPart = plot.PrimaryPart or plot:FindFirstChild("Floor") or plot:FindFirstChildOfClass("BasePart") or plot:FindFirstChildOfClass("MeshPart")
                if pivotPart then
                    local dist = (hrpPos - pivotPart.Position).Magnitude
                    if dist < closestDist and dist < 200 then
                        closestDist = dist
                        playerPlot = plot
                    end
                end
            end
        end
    end
    if playerPlot then
        local plotAnchor = playerPlot.PrimaryPart or playerPlot:FindFirstChild("Floor") or playerPlot:FindFirstChildOfClass("BasePart") or playerPlot:FindFirstChildOfClass("MeshPart")
        if plotAnchor then
            local characterCFrame = player.Character.HumanoidRootPart.CFrame
            local relativeOffset = plotAnchor.CFrame:ToObjectSpace(characterCFrame)
            
            Configurations.SavedTrowelPositions = {relativeOffset:GetComponents()}
            if saveConfig then pcall(saveConfig) end
            
            UI.SaveTrowelPosBtn.Text = "SAVED!"
            task.delay(1, function()
                UI.SaveTrowelPosBtn.Text = "Save Position"
            end)
        end
    end
end)

UI.TrowelActionToggle = Decode:AddToggle(UI.TrowelDrop, "Trowel", function(state)
    Configurations.AutoTrowelToggleState = state
    saveConfig()
end)


UI.ShovelDrop = Decode:CreateDropdown(UI.CreatedPages["Assist"], "Shovel")

Decode:AddLabel(UI.ShovelDrop, "- [ Configs ] -")

UI.ShovelIntervalSlider = Decode:AddSlider(UI.ShovelDrop, "Shovel Interval", Configurations.ShovelInterval or 0, function(value)
    Configurations.ShovelInterval = value
    saveConfig()
end)

Decode:AddLabel(UI.ShovelDrop, "- [ Options ] -")

UI.ShovelFruitsSelector = Decode:AddSelector(UI.ShovelDrop, "Select Fruits", {}, function(chosen, selectorObj)
    Configurations.ShovelFruitsFilter = Configurations.ShovelFruitsFilter or {}
    local idx = table.find(Configurations.ShovelFruitsFilter, chosen)
    if idx then table.remove(Configurations.ShovelFruitsFilter, idx) else table.insert(Configurations.ShovelFruitsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShovelFruitsFilter)
end)

UI.ShovelFruitsThresholdSelector = Decode:AddSelector(UI.ShovelDrop, "Select Fruits Threshold Mode", {"Above", "Below"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.ShovelFruitsThresholdMode = ""
    else
        Configurations.ShovelFruitsThresholdMode = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShovelFruitsThresholdMode)
end)

UI.ShovelFruitsWeightSlider = Decode:AddSlider(UI.ShovelDrop, "Fruits Weight Threshold", Configurations.ShovelFruitsWeightThreshold or 0, function(value)
    Configurations.ShovelFruitsWeightThreshold = value
    saveConfig()
end, "if you don't want use this, just input '0'")

UI.ShovelPlantsSelector = Decode:AddSelector(UI.ShovelDrop, "Select Plants", {}, function(chosen, selectorObj)
    Configurations.ShovelPlantsFilter = Configurations.ShovelPlantsFilter or {}
    local idx = table.find(Configurations.ShovelPlantsFilter, chosen)
    if idx then table.remove(Configurations.ShovelPlantsFilter, idx) else table.insert(Configurations.ShovelPlantsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShovelPlantsFilter)
end)

UI.ShovelPlantsThresholdSelector = Decode:AddSelector(UI.ShovelDrop, "Select Plants Threshold Mode", {"Above", "Below"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.ShovelPlantsThresholdMode = ""
    else
        Configurations.ShovelPlantsThresholdMode = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShovelPlantsThresholdMode)
end)

UI.ShovelPlantsWeightSlider = Decode:AddSlider(UI.ShovelDrop, "Plants Height Threshold", Configurations.ShovelPlantsWeightThreshold or 0, function(value)
    Configurations.ShovelPlantsWeightThreshold = value
    saveConfig()
end, "if you don't want use this, just input '0'")

Decode:AddLabel(UI.ShovelDrop, "- [ Functions ] -")

UI.ShovelActionToggle = Decode:AddToggle(UI.ShovelDrop, "Shovel", function(state)
    Configurations.AutoShovelToggleState = state
    saveConfig()
end)

UI.AuctionDrop = Decode:CreateDropdown(UI.CreatedPages["Shop"], "Auction")

Decode:AddLabel(UI.AuctionDrop, "- [ Configs ] -")

UI.AuctionTimerSlider = Decode:AddSlider(UI.AuctionDrop, "Below Timer", Configurations.AuctionBelowTimer or 0, function(value)
    Configurations.AuctionBelowTimer = value
    saveConfig()
end)

UI.AuctionShecklesSlider = Decode:AddSlider(UI.AuctionDrop, "Below Sheckles", Configurations.AuctionBelowSheckles or 0, function(value)
    Configurations.AuctionBelowSheckles = value
    saveConfig()
end)

UI.AuctionQuantitySlider = Decode:AddSlider(UI.AuctionDrop, "Buy Quantity", Configurations.AuctionBuyQuantity or 0, function(value)
    Configurations.AuctionBuyQuantity = value
    saveConfig()
end)

Decode:AddLabel(UI.AuctionDrop, "- [ Options ] -")

UI.AuctionEggsSelector = Decode:AddSelector(UI.AuctionDrop, "Select Eggs", {}, function(chosen, selectorObj)
    Configurations.AuctionEggsFilter = Configurations.AuctionEggsFilter or {}
    local idx = table.find(Configurations.AuctionEggsFilter, chosen)
    if idx then table.remove(Configurations.AuctionEggsFilter, idx) else table.insert(Configurations.AuctionEggsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.AuctionEggsFilter)
end)

UI.AuctionSprinklersSelector = Decode:AddSelector(UI.AuctionDrop, "Select Sprinklers", {}, function(chosen, selectorObj)
    Configurations.AuctionSprinklersFilter = Configurations.AuctionSprinklersFilter or {}
    local idx = table.find(Configurations.AuctionSprinklersFilter, chosen)
    if idx then table.remove(Configurations.AuctionSprinklersFilter, idx) else table.insert(Configurations.AuctionSprinklersFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.AuctionSprinklersFilter)
end)

UI.AuctionWateringCansSelector = Decode:AddSelector(UI.AuctionDrop, "Select Watering Cans", {}, function(chosen, selectorObj)
    Configurations.AuctionWateringCansFilter = Configurations.AuctionWateringCansFilter or {}
    local idx = table.find(Configurations.AuctionWateringCansFilter, chosen)
    if idx then table.remove(Configurations.AuctionWateringCansFilter, idx) else table.insert(Configurations.AuctionWateringCansFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.AuctionWateringCansFilter)
end)

UI.AuctionSeedPacksSelector = Decode:AddSelector(UI.AuctionDrop, "Select Seed Packs", {}, function(chosen, selectorObj)
    Configurations.AuctionSeedPacksFilter = Configurations.AuctionSeedPacksFilter or {}
    local idx = table.find(Configurations.AuctionSeedPacksFilter, chosen)
    if idx then table.remove(Configurations.AuctionSeedPacksFilter, idx) else table.insert(Configurations.AuctionSeedPacksFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.AuctionSeedPacksFilter)
end)

UI.AuctionSeedsSelector = Decode:AddSelector(UI.AuctionDrop, "Select Seeds", {}, function(chosen, selectorObj)
    Configurations.AuctionSeedsFilter = Configurations.AuctionSeedsFilter or {}
    local idx = table.find(Configurations.AuctionSeedsFilter, chosen)
    if idx then table.remove(Configurations.AuctionSeedsFilter, idx) else table.insert(Configurations.AuctionSeedsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.AuctionSeedsFilter)
end)

UI.AuctionCratesSelector = Decode:AddSelector(UI.AuctionDrop, "Select Crates", {}, function(chosen, selectorObj)
    Configurations.AuctionCratesFilter = Configurations.AuctionCratesFilter or {}
    local idx = table.find(Configurations.AuctionCratesFilter, chosen)
    if idx then table.remove(Configurations.AuctionCratesFilter, idx) else table.insert(Configurations.AuctionCratesFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.AuctionCratesFilter)
end)

Decode:AddLabel(UI.AuctionDrop, "- [ Functions ] -")

UI.BuyAuctionToggle = Decode:AddToggle(UI.AuctionDrop, "Buy Items", function(state)
    Configurations.AutoBuyAuctionItems = state
    saveConfig()
end)

UI.DropDrop = Decode:CreateDropdown(UI.CreatedPages["Assist"], "Drop")

Decode:AddLabel(UI.DropDrop, "- [ Configs ] -")

UI.DropTweenSpeedSlider = Decode:AddSlider(UI.DropDrop, "Tween Speed", Configurations.DropTweenSpeed or 0, function(value)
    Configurations.DropTweenSpeed = value
    saveConfig()
end)

Decode:AddLabel(UI.DropDrop, "- [ Options ] -")

UI.DropFruitsSelector = Decode:AddSelector(UI.DropDrop, "Select Fruits", {}, function(chosen, selectorObj)
    Configurations.DropFruitsFilter = Configurations.DropFruitsFilter or {}
    local idx = table.find(Configurations.DropFruitsFilter, chosen)
    if idx then table.remove(Configurations.DropFruitsFilter, idx) else table.insert(Configurations.DropFruitsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.DropFruitsFilter)
end)

UI.DropPetsSelector = Decode:AddSelector(UI.DropDrop, "Select Pets", {}, function(chosen, selectorObj)
    Configurations.DropPetsFilter = Configurations.DropPetsFilter or {}
    local idx = table.find(Configurations.DropPetsFilter, chosen)
    if idx then table.remove(Configurations.DropPetsFilter, idx) else table.insert(Configurations.DropPetsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.DropPetsFilter)
end)

Decode:AddLabel(UI.DropDrop, "- [ Functions ] -")

UI.DropActionToggle = Decode:AddToggle(UI.DropDrop, "Drop Item", function(state)
    Configurations.AutoDropItemsEnabled = state
    saveConfig()
end)

UI.CollectDroppedToggle = Decode:AddToggle(UI.DropDrop, "Collect Dropped Items", function(state)
    Configurations.CollectDroppedItemsEnabled = state
    saveConfig()
end)

UI.ShopSeedsDrop = Decode:CreateDropdown(UI.CreatedPages["Shop"], "Seeds")
Decode:AddLabel(UI.ShopSeedsDrop, "- [ Options ] -")

UI.ShopSeedsSelector = Decode:AddSelector(UI.ShopSeedsDrop, "Select Seeds", {}, function(chosen, selectorObj)
    Configurations.ShopSeedsFilter = Configurations.ShopSeedsFilter or {}
    local idx = table.find(Configurations.ShopSeedsFilter, chosen)
    if idx then table.remove(Configurations.ShopSeedsFilter, idx) else table.insert(Configurations.ShopSeedsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShopSeedsFilter)
end)

Decode:AddLabel(UI.ShopSeedsDrop, "- [ Functions ] -")

UI.BuySeedsToggle = {}
UI.BuyAllSeedsToggle = {}

UI.BuySeedsToggle = Decode:AddToggle(UI.ShopSeedsDrop, "Buy Seeds", function(state)
    Configurations.BuySeeds = state
    saveConfig()
    if state and Configurations.BuyAllSeeds then
        Configurations.BuyAllSeeds = false
        saveConfig()
        if UI.BuyAllSeedsToggle and UI.BuyAllSeedsToggle.SwitchBg then
            UI.BuyAllSeedsToggle.IsToggled = false
            TweenService:Create(UI.BuyAllSeedsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.BuyAllSeedsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.BuyAllSeedsToggle = Decode:AddToggle(UI.ShopSeedsDrop, "Buy All Seeds", function(state)
    Configurations.BuyAllSeeds = state
    saveConfig()
    if state and Configurations.BuySeeds then
        Configurations.BuySeeds = false
        saveConfig()
        if UI.BuySeedsToggle and UI.BuySeedsToggle.SwitchBg then
            UI.BuySeedsToggle.IsToggled = false
            TweenService:Create(UI.BuySeedsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.BuySeedsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.ShopGearsDrop = Decode:CreateDropdown(UI.CreatedPages["Shop"], "Gears")
Decode:AddLabel(UI.ShopGearsDrop, "- [ Options ] -")

UI.ShopGearsSelector = Decode:AddSelector(UI.ShopGearsDrop, "Select Gears", {}, function(chosen, selectorObj)
    Configurations.ShopGearsFilter = Configurations.ShopGearsFilter or {}
    local idx = table.find(Configurations.ShopGearsFilter, chosen)
    if idx then table.remove(Configurations.ShopGearsFilter, idx) else table.insert(Configurations.ShopGearsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShopGearsFilter)
end)

Decode:AddLabel(UI.ShopGearsDrop, "- [ Functions ] -")

UI.BuyGearsToggle = {}
UI.BuyAllGearsToggle = {}

UI.BuyGearsToggle = Decode:AddToggle(UI.ShopGearsDrop, "Buy Gears", function(state)
    Configurations.BuyGears = state
    saveConfig()
    if state and Configurations.BuyAllGears then
        Configurations.BuyAllGears = false
        saveConfig()
        if UI.BuyAllGearsToggle and UI.BuyAllGearsToggle.SwitchBg then
            UI.BuyAllGearsToggle.IsToggled = false
            TweenService:Create(UI.BuyAllGearsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.BuyAllGearsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.BuyAllGearsToggle = Decode:AddToggle(UI.ShopGearsDrop, "Buy All Gears", function(state)
    Configurations.BuyAllGears = state
    saveConfig()
    if state and Configurations.BuyGears then
        Configurations.BuyGears = false
        saveConfig()
        if UI.BuyGearsToggle and UI.BuyGearsToggle.SwitchBg then
            UI.BuyGearsToggle.IsToggled = false
            TweenService:Create(UI.BuyGearsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.BuyGearsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.ShopPropsDrop = Decode:CreateDropdown(UI.CreatedPages["Shop"], "Props")
Decode:AddLabel(UI.ShopPropsDrop, "- [ Options ] -")

UI.ShopPropsSelector = Decode:AddSelector(UI.ShopPropsDrop, "Select Props", {}, function(chosen, selectorObj)
    Configurations.ShopPropsFilter = Configurations.ShopPropsFilter or {}
    local idx = table.find(Configurations.ShopPropsFilter, chosen)
    if idx then table.remove(Configurations.ShopPropsFilter, idx) else table.insert(Configurations.ShopPropsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.ShopPropsFilter)
end)

Decode:AddLabel(UI.ShopPropsDrop, "- [ Functions ] -")

UI.BuyPropsToggle = {}
UI.BuyAllPropsToggle = {}

UI.BuyPropsToggle = Decode:AddToggle(UI.ShopPropsDrop, "Buy Props", function(state)
    Configurations.BuyProps = state
    saveConfig()
    if state and Configurations.BuyAllProps then
        Configurations.BuyAllProps = false
        saveConfig()
        if UI.BuyAllPropsToggle and UI.BuyAllPropsToggle.SwitchBg then
            UI.BuyAllPropsToggle.IsToggled = false
            TweenService:Create(UI.BuyAllPropsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.BuyAllPropsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.BuyAllPropsToggle = Decode:AddToggle(UI.ShopPropsDrop, "Buy All Props", function(state)
    Configurations.BuyAllProps = state
    saveConfig()
    if state and Configurations.BuyProps then
        Configurations.BuyProps = false
        saveConfig()
        if UI.BuyPropsToggle and UI.BuyPropsToggle.SwitchBg then
            UI.BuyPropsToggle.IsToggled = false
            TweenService:Create(UI.BuyPropsToggle.SwitchBg, TweenInfo.new(0.15), {BackgroundColor3 = Decode.Theme.MainBackground}):Play()
            TweenService:Create(UI.BuyPropsToggle.SliderNode, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Decode.Theme.TextMuted}):Play()
        end
    end
end)

UI.EspDrop = Decode:CreateDropdown(UI.CreatedPages["Misc"], "ESP")

Decode:AddLabel(UI.EspDrop, "- [ Configs ] -")

UI.EspWeightSlider = Decode:AddSlider(UI.EspDrop, "Above Weight", Configurations.EspAboveWeightValue or 0, function(value)
    Configurations.EspAboveWeightValue = value
    saveConfig()
end, "ESP Fruits above the target weight")

UI.EspHeightSlider = Decode:AddSlider(UI.EspDrop, "Above Height", Configurations.EspAboveHeightValue or 0, function(value)
    Configurations.EspAboveHeightValue = value
    saveConfig()
end, "ESP Plants above the target height")

Decode:AddLabel(UI.EspDrop, "- [ Options ] -")

UI.EspFruitsSelector = Decode:AddSelector(UI.EspDrop, "Select Fruits", {}, function(chosen, selectorObj)
    Configurations.EspFruitsFilter = Configurations.EspFruitsFilter or {}
    local idx = table.find(Configurations.EspFruitsFilter, chosen)
    if idx then table.remove(Configurations.EspFruitsFilter, idx) else table.insert(Configurations.EspFruitsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.EspFruitsFilter)
end)

UI.EspPlantsSelector = Decode:AddSelector(UI.EspDrop, "Select Plants", {}, function(chosen, selectorObj)
    Configurations.EspPlantsFilter = Configurations.EspPlantsFilter or {}
    local idx = table.find(Configurations.EspPlantsFilter, chosen)
    if idx then table.remove(Configurations.EspPlantsFilter, idx) else table.insert(Configurations.EspPlantsFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.EspPlantsFilter)
end)

UI.EspSprinklersSelector = Decode:AddSelector(UI.EspDrop, "Select Sprinklers", {}, function(chosen, selectorObj)
    Configurations.EspSprinklersFilter = Configurations.EspSprinklersFilter or {}
    local idx = table.find(Configurations.EspSprinklersFilter, chosen)
    if idx then table.remove(Configurations.EspSprinklersFilter, idx) else table.insert(Configurations.EspSprinklersFilter, chosen) end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.EspSprinklersFilter)
end)

UI.EspPlotSelector = Decode:AddSelector(UI.EspDrop, "Select Plot", {"Own Plot", "All Plots"}, function(chosen, selectorObj)
    if selectorObj.SelectBtn.Text == chosen then
        Configurations.EspPlotModeSelection = ""
    else
        Configurations.EspPlotModeSelection = chosen
    end
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.EspPlotModeSelection)
end)

Decode:AddLabel(UI.EspDrop, "- [ Functions ] -")

UI.EspInventoryToggle = Decode:AddToggle(UI.EspDrop, "ESP Inventory", function(state)
    Configurations.EspInventoryToggleState = state
    saveConfig()
end)

UI.EspObjectsToggle = Decode:AddToggle(UI.EspDrop, "ESP Fruits/Sprinklers", function(state)
    Configurations.EspObjectsToggleState = state
    saveConfig()
end)

UI.FpsDrop = Decode:CreateDropdown(UI.CreatedPages["Misc"], "FPS")

Decode:AddLabel(UI.FpsDrop, "- [ Options ] -")

UI.FpsOptionSelector = Decode:AddSelector(UI.FpsDrop, "Select FPS option", {"Remove Other Plots", "Remove My Plot", "Hide All Plants", "Hide All Sprinklers", "Lowest Graphics"}, function(chosen, selectorObj)
    Configurations.FpsOptionSelection = Configurations.FpsOptionSelection or {}
    if type(Configurations.FpsOptionSelection) ~= "table" then
        Configurations.FpsOptionSelection = {}
    end
    local idx = table.find(Configurations.FpsOptionSelection, chosen)
    if idx then 
        table.remove(Configurations.FpsOptionSelection, idx) 
    else 
        table.insert(Configurations.FpsOptionSelection, chosen) 
    end  
    saveConfig()
    selectorObj:UpdateSelectionText(Configurations.FpsOptionSelection)
end)

Decode:AddLabel(UI.FpsDrop, "- [ Function ] -")

UI.FpsBoostToggle = Decode:AddToggle(UI.FpsDrop, "FPS Boost", function(state)
    Configurations.FpsBoostToggleState = state
    saveConfig()
end)

UI.ServerDrop = Decode:CreateDropdown(UI.CreatedPages["Misc"], "Server")

Decode:AddLabel(UI.ServerDrop, "- [ Functions ] -")

UI.AntiAfkToggle = Decode:AddToggle(UI.ServerDrop, "Anti-AFK", function(state)
    Configurations.AntiAfkToggleState = state
    saveConfig()
end)

UI.RejoinToggle = Decode:AddToggle(UI.ServerDrop, "Auto-Rejoin", function(state)
    Configurations.RejoinToggleState = state
    saveConfig()
end)

UI.ConfigDrop = Decode:CreateDropdown(UI.CreatedPages["Settings"], "Config")

Decode:AddLabel(UI.ConfigDrop, "To be updated.")

task.spawn(function()
    task.wait(0.1)

    if Configurations.HarvestFruitFilter then
        UI.FruitSelector:UpdateSelectionText(Configurations.HarvestFruitFilter)
    end

    if Configurations.HarvestMutationFilter then
        UI.MutationSelector:UpdateSelectionText(Configurations.HarvestMutationFilter)
    end

    if Configurations.ThresholdMode and Configurations.ThresholdMode ~= "" then
        UI.ThresholdSelector:UpdateSelectionText(Configurations.ThresholdMode)
    end

    if Configurations.SpeedEnabled and UI.WalkspeedToggle then
        UI.WalkspeedToggle.IsToggled = true
        UI.WalkspeedToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.WalkspeedToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.WalkspeedToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
        UI:UpdateCharacterSpeed()
    end

    if Configurations.NoClipEnabled and UI.NoClipToggle then
        UI.NoClipToggle.IsToggled = true
        UI.NoClipToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.NoClipToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.NoClipToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.InfiniteJumpEnabled and UI.InfJumpToggle then
        UI.InfJumpToggle.IsToggled = true
        UI.InfJumpToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.InfJumpToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.InfJumpToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.StopCollectIfFull and UI.StopCollectToggle then
        UI.StopCollectToggle.IsToggled = true
        UI.StopCollectToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.StopCollectToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.StopCollectToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.DisableCollectPrompt and UI.DisablePromptToggle then
        UI.DisablePromptToggle.IsToggled = true
        UI.DisablePromptToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.DisablePromptToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.DisablePromptToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.HarvestFruits and UI.HarvestFruitsToggle then
        UI.HarvestFruitsToggle.IsToggled = true
        UI.HarvestFruitsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.HarvestFruitsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.HarvestFruitsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.HarvestAllFruits and UI.HarvestAllFruitsToggle then
        UI.HarvestAllFruitsToggle.IsToggled = true
        UI.HarvestAllFruitsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.HarvestAllFruitsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.HarvestAllFruitsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.SellFruitFilter then
        UI.SellFruitSelector:UpdateSelectionText(Configurations.SellFruitFilter)
    end

    if Configurations.SellMutationFilter then
        UI.SellMutationSelector:UpdateSelectionText(Configurations.SellMutationFilter)
    end

    if Configurations.SellThresholdMode and Configurations.SellThresholdMode ~= "" then
        UI.SellThresholdSelector:UpdateSelectionText(Configurations.SellThresholdMode)
    end

    if Configurations.AllowSellIfFull and UI.AllowSellIfFullToggle then
        UI.AllowSellIfFullToggle.IsToggled = true
        UI.AllowSellIfFullToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.AllowSellIfFullToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.AllowSellIfFullToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.SellFruits and UI.SellFruitsToggle then
        UI.SellFruitsToggle.IsToggled = true
        UI.SellFruitsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.SellFruitsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.SellFruitsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.SellAllFruits and UI.SellAllFruitsToggle then
        UI.SellAllFruitsToggle.IsToggled = true
        UI.SellAllFruitsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.SellAllFruitsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.SellAllFruitsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

        if Configurations.SelectedPetsFilter then
        UI.PetsSelector:UpdateSelectionText(Configurations.SelectedPetsFilter)
    end

    if Configurations.SelectedPetSizeFilter then
        UI.PetSizeSelector:UpdateSelectionText(Configurations.SelectedPetSizeFilter)
    end

    if Configurations.AutoBuyPets and UI.BuyPetsToggle then
        UI.BuyPetsToggle.IsToggled = true
        UI.BuyPetsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyPetsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyPetsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.AutoCollectEventSeeds and UI.CollectSeedsToggle then
        UI.CollectSeedsToggle.IsToggled = true
        UI.CollectSeedsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.CollectSeedsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.CollectSeedsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.MailFruitsFilter then UI.MailFruitsSelector:UpdateSelectionText(Configurations.MailFruitsFilter) end
    if Configurations.MailPetsFilter then UI.MailPetsSelector:UpdateSelectionText(Configurations.MailPetsFilter) end
    if Configurations.MailSeedsFilter then UI.MailSeedsSelector:UpdateSelectionText(Configurations.MailSeedsFilter) end
    if Configurations.MailSprinklersFilter then UI.MailSprinklersSelector:UpdateSelectionText(Configurations.MailSprinklersFilter) end
    if Configurations.MailWateringCansFilter then UI.MailWateringCansSelector:UpdateSelectionText(Configurations.MailWateringCansFilter) end
    if Configurations.MailCratesFilter then UI.MailCratesSelector:UpdateSelectionText(Configurations.MailCratesFilter) end
    if Configurations.MailSeedPacksFilter then UI.MailSeedPacksSelector:UpdateSelectionText(Configurations.MailSeedPacksFilter) end
    if Configurations.MailEggsFilter then UI.MailEggsSelector:UpdateSelectionText(Configurations.MailEggsFilter) end
    if Configurations.MailToolsFilter then UI.MailToolsSelector:UpdateSelectionText(Configurations.MailToolsFilter) end

    if Configurations.SendMailEnabled and UI.SendMailToggle then
        UI.SendMailToggle.IsToggled = true
        UI.SendMailToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.SendMailToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.SendMailToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.ClaimMailEnabled and UI.ClaimMailToggle then
        UI.ClaimMailToggle.IsToggled = true
        UI.ClaimMailToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.ClaimMailToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.ClaimMailToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.AuctionEggsFilter then UI.AuctionEggsSelector:UpdateSelectionText(Configurations.AuctionEggsFilter) end
    if Configurations.AuctionSprinklersFilter then UI.AuctionSprinklersSelector:UpdateSelectionText(Configurations.AuctionSprinklersFilter) end
    if Configurations.AuctionWateringCansFilter then UI.AuctionWateringCansSelector:UpdateSelectionText(Configurations.AuctionWateringCansFilter) end
    if Configurations.AuctionSeedPacksFilter then UI.AuctionSeedPacksSelector:UpdateSelectionText(Configurations.AuctionSeedPacksFilter) end
    if Configurations.AuctionSeedsFilter then UI.AuctionSeedsSelector:UpdateSelectionText(Configurations.AuctionSeedsFilter) end
    if Configurations.AuctionCratesFilter then UI.AuctionCratesSelector:UpdateSelectionText(Configurations.AuctionCratesFilter) end

    if Configurations.AutoBuyAuctionItems and UI.BuyAuctionToggle then
        UI.BuyAuctionToggle.IsToggled = true
        UI.BuyAuctionToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyAuctionToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyAuctionToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.ShopSeedsFilter then UI.ShopSeedsSelector:UpdateSelectionText(Configurations.ShopSeedsFilter) end
    if Configurations.ShopGearsFilter then UI.ShopGearsSelector:UpdateSelectionText(Configurations.ShopGearsFilter) end
    if Configurations.ShopPropsFilter then UI.ShopPropsSelector:UpdateSelectionText(Configurations.ShopPropsFilter) end

    if Configurations.BuySeeds and UI.BuySeedsToggle then
        UI.BuySeedsToggle.IsToggled = true
        UI.BuySeedsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuySeedsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuySeedsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end
    if Configurations.BuyAllSeeds and UI.BuyAllSeedsToggle then
        UI.BuyAllSeedsToggle.IsToggled = true
        UI.BuyAllSeedsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyAllSeedsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyAllSeedsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.BuyGears and UI.BuyGearsToggle then
        UI.BuyGearsToggle.IsToggled = true
        UI.BuyGearsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyGearsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyGearsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end
    if Configurations.BuyAllGears and UI.BuyAllGearsToggle then
        UI.BuyAllGearsToggle.IsToggled = true
        UI.BuyAllGearsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyAllGearsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyAllGearsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.BuyProps and UI.BuyPropsToggle then
        UI.BuyPropsToggle.IsToggled = true
        UI.BuyPropsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyPropsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyPropsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end
    if Configurations.BuyAllProps and UI.BuyAllPropsToggle then
        UI.BuyAllPropsToggle.IsToggled = true
        UI.BuyAllPropsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.BuyAllPropsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.BuyAllPropsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.PlantSeedsFilter then UI.PlantSeedsSelector:UpdateSelectionText(Configurations.PlantSeedsFilter) end
    if Configurations.PlantPositionMode and Configurations.PlantPositionMode ~= "" then UI.PlantPositionSelector:UpdateSelectionText(Configurations.PlantPositionMode) end

    if Configurations.AutoPlantEnabled and UI.AutoPlantToggle then
        UI.AutoPlantToggle.IsToggled = true
        UI.AutoPlantToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.AutoPlantToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.AutoPlantToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.PotPlantsFilter then UI.PotPlantsSelector:UpdateSelectionText(Configurations.PotPlantsFilter) end
    if Configurations.PotModeSelection and Configurations.PotModeSelection ~= "" then UI.PotModeSelector:UpdateSelectionText(Configurations.PotModeSelection) end
    if Configurations.TrowelPlantsFilter then UI.TrowelPlantsSelector:UpdateSelectionText(Configurations.TrowelPlantsFilter) end

    if Configurations.AutoPotToggleState and UI.PotActionToggle then
        UI.PotActionToggle.IsToggled = true
        UI.PotActionToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.PotActionToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.PotActionToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.AutoTrowelToggleState and UI.TrowelActionToggle then
        UI.TrowelActionToggle.IsToggled = true
        UI.TrowelActionToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.TrowelActionToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.TrowelActionToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.DropFruitsFilter then UI.DropFruitsSelector:UpdateSelectionText(Configurations.DropFruitsFilter) end
    if Configurations.DropPetsFilter then UI.DropPetsSelector:UpdateSelectionText(Configurations.DropPetsFilter) end

    if Configurations.AutoDropItemsEnabled and UI.DropActionToggle then
        UI.DropActionToggle.IsToggled = true
        UI.DropActionToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.DropActionToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.DropActionToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end
    if Configurations.CollectDroppedItemsEnabled and UI.CollectDroppedToggle then
        UI.CollectDroppedToggle.IsToggled = true
        UI.CollectDroppedToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.CollectDroppedToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.CollectDroppedToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.EspFruitsFilter then UI.EspFruitsSelector:UpdateSelectionText(Configurations.EspFruitsFilter) end
    if Configurations.EspPlantsFilter then UI.EspPlantsSelector:UpdateSelectionText(Configurations.EspPlantsFilter) end
    if Configurations.EspSprinklersFilter then UI.EspSprinklersSelector:UpdateSelectionText(Configurations.EspSprinklersFilter) end
    if Configurations.EspPlotModeSelection and Configurations.EspPlotModeSelection ~= "" then UI.EspPlotSelector:UpdateSelectionText(Configurations.EspPlotModeSelection) end

    if Configurations.EspInventoryToggleState and UI.EspInventoryToggle then
        UI.EspInventoryToggle.IsToggled = true
        UI.EspInventoryToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.EspInventoryToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.EspInventoryToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.EspObjectsToggleState and UI.EspObjectsToggle then
        UI.EspObjectsToggle.IsToggled = true
        UI.EspObjectsToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.EspObjectsToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.EspObjectsToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if type(Configurations.FpsOptionSelection) == "table" and #Configurations.FpsOptionSelection > 0 then 
        UI.FpsOptionSelector:UpdateSelectionText(Configurations.FpsOptionSelection) 
    else
        UI.FpsOptionSelector:UpdateSelectionText("None Selected")
    end

    if Configurations.FpsBoostToggleState and UI.FpsBoostToggle then
        UI.FpsBoostToggle.IsToggled = true
        UI.FpsBoostToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.FpsBoostToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.FpsBoostToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.ShovelFruitsFilter then UI.ShovelFruitsSelector:UpdateSelectionText(Configurations.ShovelFruitsFilter) end
    if Configurations.ShovelFruitsThresholdMode and Configurations.ShovelFruitsThresholdMode ~= "" then UI.ShovelFruitsThresholdSelector:UpdateSelectionText(Configurations.ShovelFruitsThresholdMode) end
    if Configurations.ShovelPlantsFilter then UI.ShovelPlantsSelector:UpdateSelectionText(Configurations.ShovelPlantsFilter) end
    if Configurations.ShovelPlantsThresholdMode and Configurations.ShovelPlantsThresholdMode ~= "" then UI.ShovelPlantsThresholdSelector:UpdateSelectionText(Configurations.ShovelPlantsThresholdMode) end

    if Configurations.AutoShovelToggleState and UI.ShovelActionToggle then
        UI.ShovelActionToggle.IsToggled = true
        UI.ShovelActionToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.ShovelActionToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.ShovelActionToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.AntiAfkToggleState and UI.AntiAfkToggle then
        UI.AntiAfkToggle.IsToggled = true
        UI.AntiAfkToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.AntiAfkToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.AntiAfkToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end

    if Configurations.RejoinToggleState and UI.RejoinToggle then
        UI.RejoinToggle.IsToggled = true
        UI.RejoinToggle.SwitchBg.BackgroundColor3 = Decode.Theme.AccentColor
        UI.RejoinToggle.SliderNode.Position = UDim2.new(1, -14, 0.5, -6)
        UI.RejoinToggle.SliderNode.BackgroundColor3 = Decode.Theme.TextMain
    end
end)

task.spawn(function()
    local PetList = Decode:GetAssetCategory("Pets")
    local sizeAndTypeList = Decode:GetPetTypesAndSizes()
    local SeedsList = Decode:GetGameSeeds()
    local FruitList = Decode:GetAssetCategory("Plants")
    local MultiList = Decode:GetAssetCategory("Fruits")
    local SprinklersList = Decode:GetAssetCategory("Sprinklers")
    local CansList = Decode:GetAssetCategory("WateringCans")
    local CratesList = Decode:GetAssetCategory("Crates")
    local PacksList = Decode:GetAssetCategory("SeedPacks")
    local EggsList = Decode:GetAssetCategory("Eggs")
    
    if UI.PetsSelector and UI.PetsSelector.Populate then pcall(function() UI.PetsSelector:Populate(PetList) end) end
    if UI.PetSizeSelector and UI.PetSizeSelector.Populate then pcall(function() UI.PetSizeSelector:Populate(sizeAndTypeList) end) end    
    if UI.MailFruitsSelector and UI.MailFruitsSelector.Populate then pcall(function() UI.MailFruitsSelector:Populate(FruitList) end) end
    if UI.MailPetsSelector and UI.MailPetsSelector.Populate then pcall(function() UI.MailPetsSelector:Populate(PetList) end) end
    if UI.MailSeedsSelector and UI.MailSeedsSelector.Populate then pcall(function() UI.MailSeedsSelector:Populate(SeedsList) end) end
    if UI.MailSprinklersSelector and UI.MailSprinklersSelector.Populate then pcall(function() UI.MailSprinklersSelector:Populate(SprinklersList) end) end
    if UI.MailWateringCansSelector and UI.MailWateringCansSelector.Populate then pcall(function() UI.MailWateringCansSelector:Populate(CansList) end) end
    if UI.MailCratesSelector and UI.MailCratesSelector.Populate then pcall(function() UI.MailCratesSelector:Populate(CratesList) end) end
    if UI.MailSeedPacksSelector and UI.MailSeedPacksSelector.Populate then pcall(function() UI.MailSeedPacksSelector:Populate(PacksList) end) end
    if UI.MailEggsSelector and UI.MailEggsSelector.Populate then pcall(function() UI.MailEggsSelector:Populate(EggsList) end) end
    if UI.ShovelFruitsSelector and UI.ShovelFruitsSelector.Populate then pcall(function() UI.ShovelFruitsSelector:Populate(MultiList) end) end
    if UI.ShovelPlantsSelector and UI.ShovelPlantsSelector.Populate then pcall(function() UI.ShovelPlantsSelector:Populate(MultiList) end) end
    if UI.PlantSeedsSelector and UI.PlantSeedsSelector.Populate then pcall(function() UI.PlantSeedsSelector:Populate(SeedsList) end) end
    if UI.PotPlantsSelector and UI.PotPlantsSelector.Populate then pcall(function() UI.PotPlantsSelector:Populate(FruitList) end) end
    if UI.TrowelPlantsSelector and UI.TrowelPlantsSelector.Populate then pcall(function() UI.TrowelPlantsSelector:Populate(FruitList) end) end
    if UI.DropFruitsSelector and UI.DropFruitsSelector.Populate then pcall(function() UI.DropFruitsSelector:Populate(FruitList) end) end
    if UI.DropPetsSelector and UI.DropPetsSelector.Populate then pcall(function() UI.DropPetsSelector:Populate(PetList) end) end
    if UI.EspFruitsSelector and UI.EspFruitsSelector.Populate then pcall(function() UI.EspFruitsSelector:Populate(FruitList) end) end
    if UI.EspPlantsSelector and UI.EspPlantsSelector.Populate then pcall(function() UI.EspPlantsSelector:Populate(FruitList) end) end
    if UI.EspSprinklersSelector and UI.EspSprinklersSelector.Populate then pcall(function() UI.EspSprinklersSelector:Populate(SprinklersList) end) end
    if UI.AuctionEggsSelector and UI.AuctionEggsSelector.Populate then pcall(function() UI.AuctionEggsSelector:Populate(EggsList) end) end
    if UI.AuctionSprinklersSelector and UI.AuctionSprinklersSelector.Populate then pcall(function() UI.AuctionSprinklersSelector:Populate(SprinklersList) end) end
    if UI.AuctionWateringCansSelector and UI.AuctionWateringCansSelector.Populate then pcall(function() UI.AuctionWateringCansSelector:Populate(CansList) end) end
    if UI.AuctionSeedPacksSelector and UI.AuctionSeedPacksSelector.Populate then pcall(function() UI.AuctionSeedPacksSelector:Populate(PacksList) end) end
    if UI.AuctionSeedsSelector and UI.AuctionSeedsSelector.Populate then pcall(function() UI.AuctionSeedsSelector:Populate(SeedsList) end) end
    if UI.AuctionCratesSelector and UI.AuctionCratesSelector.Populate then pcall(function() UI.AuctionCratesSelector:Populate(CratesList) end) end

    local liveShopSeeds = Decode:GetShopStockCategory("SeedShop")
    local liveShopGears = Decode:GetShopStockCategory("GearShop")
    local liveShopProps = Decode:GetShopStockCategory("CrateShop")
    
    if UI.ShopSeedsSelector and UI.ShopSeedsSelector.Populate then pcall(function() UI.ShopSeedsSelector:Populate(liveShopSeeds) end) end
    if UI.ShopGearsSelector and UI.ShopGearsSelector.Populate then pcall(function() UI.ShopGearsSelector:Populate(liveShopGears) end) end
    if UI.ShopPropsSelector and UI.ShopPropsSelector.Populate then pcall(function() UI.ShopPropsSelector:Populate(liveShopProps) end) end
end)

UI.CloseTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
UI.ExitModal = Instance.new("Frame")
UI.ExitModal.Name = "ExitConfirmation"
UI.ExitModal.Size = UDim2.new(0, 320, 0, 200)
UI.ExitModal.Position = UDim2.new(0.5, -160, 0.5, -100)
UI.ExitModal.BackgroundColor3 = Decode.Theme.SidebarBackground
UI.ExitModal.BackgroundTransparency = 0.05
UI.ExitModal.BorderSizePixel = 0
UI.ExitModal.Visible = false
UI.ExitModal.ZIndex = 10
UI.ExitModal.Parent = UI.FrameMain

UI.ModalCorner = Instance.new("UICorner")
UI.ModalCorner.CornerRadius = UDim.new(0, 12)
UI.ModalCorner.Parent = UI.ExitModal

UI.ModalStroke = Instance.new("UIStroke")
UI.ModalStroke.Color = Decode.Theme.AccentColor
UI.ModalStroke.Thickness = 1
UI.ModalStroke.Parent = UI.ExitModal

UI.WarnIcon = Instance.new("TextLabel")
UI.WarnIcon.Size = UDim2.new(1, 0, 0, 40)
UI.WarnIcon.Position = UDim2.new(0, 0, 0, 15)
UI.WarnIcon.BackgroundTransparency = 1
UI.WarnIcon.Text = "⚠️"
UI.WarnIcon.TextSize = 28
UI.WarnIcon.ZIndex = 11
UI.WarnIcon.Parent = UI.ExitModal

UI.ConfirmHeader = Instance.new("TextLabel")
UI.ConfirmHeader.Size = UDim2.new(1, 0, 0, 25)
UI.ConfirmHeader.Position = UDim2.new(0, 0, 0, 60)
UI.ConfirmHeader.BackgroundTransparency = 1
UI.ConfirmHeader.Text = "Exit Confirmation"
UI.ConfirmHeader.TextColor3 = Decode.Theme.TextMain
UI.ConfirmHeader.TextSize = 16
UI.ConfirmHeader.Font = Enum.Font.SourceSansBold
UI.ConfirmHeader.ZIndex = 11
UI.ConfirmHeader.Parent = UI.ExitModal

UI.ConfirmDesc = Instance.new("TextLabel")
UI.ConfirmDesc.Size = UDim2.new(1, -40, 0, 35)
UI.ConfirmDesc.Position = UDim2.new(0, 20, 0, 85)
UI.ConfirmDesc.BackgroundTransparency = 1
UI.ConfirmDesc.Text = "Are you sure you want to close the UI?\nYou won't be able to re-open in this session."
UI.ConfirmDesc.TextColor3 = Decode.Theme.TextMuted
UI.ConfirmDesc.TextSize = 13
UI.ConfirmDesc.Font = Enum.Font.SourceSans
UI.ConfirmDesc.TextWrapped = true
UI.ConfirmDesc.ZIndex = 11
UI.ConfirmDesc.Parent = UI.ExitModal

UI.YesBtn = Instance.new("TextButton")
UI.YesBtn.Name = "YesButton"
UI.YesBtn.Size = UDim2.new(0, 125, 0, 35)
UI.YesBtn.Position = UDim2.new(0, 25, 1, -50)
UI.YesBtn.BackgroundColor3 = Decode.Theme.ElementBackground
UI.YesBtn.Text = "Yes"
UI.YesBtn.TextColor3 = Decode.Theme.TextMain
UI.YesBtn.TextSize = 14
UI.YesBtn.Font = Enum.Font.SourceSansBold
UI.YesBtn.ZIndex = 11
UI.YesBtn.Parent = UI.ExitModal

UI.YesCorner = Instance.new("UICorner")
UI.YesCorner.CornerRadius = UDim.new(0, 6)
UI.YesCorner.Parent = UI.YesBtn

UI.NoBtn = Instance.new("TextButton")
UI.NoBtn.Name = "NoButton"
UI.NoBtn.Size = UDim2.new(0, 125, 0, 35)
UI.NoBtn.Position = UDim2.new(1, -150, 1, -50)
UI.NoBtn.BackgroundColor3 = Decode.Theme.ElementBackground
UI.NoBtn.Text = "No"
UI.NoBtn.TextColor3 = Decode.Theme.TextMain
UI.NoBtn.TextSize = 14
UI.NoBtn.Font = Enum.Font.SourceSansBold
UI.NoBtn.ZIndex = 11
UI.NoBtn.Parent = UI.ExitModal

UI.NoCorner = Instance.new("UICorner")
UI.NoCorner.CornerRadius = UDim.new(0, 6)
UI.NoCorner.Parent = UI.NoBtn

UI.CloseButton.MouseButton1Click:Connect(function()
    UI.ExitModal.Size = UDim2.new(0, 0, 0, 0)
    UI.ExitModal.Position = UDim2.new(0.5, 0, 0.5, 0)
    UI.ExitModal.Visible = true
    local OpenTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(UI.ExitModal, OpenTweenInfo, {
        Size = UDim2.new(0, 320, 0, 200),
        Position = UDim2.new(0.5, -160, 0.5, -100)
    }):Play()
end)

local function closePopup()
    local tween = TweenService:Create(UI.ExitModal, UI.CloseTweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        UI.ExitModal.Visible = false
    end)
end

UI.NoBtn.MouseButton1Click:Connect(closePopup)

UI.YesBtn.MouseButton1Click:Connect(function()
    UI.ScreenGui:Destroy()
end)

function Decode:Init()
    if UI.FirstTab then
        UI.FirstTab.Page.Visible = true
        UI.FirstTab.Button.BackgroundTransparency = 0.8
        UI.FirstTab.Button.TextColor3 = Decode.Theme.TextMain
    end
end

print("Decode: UI Loaded.")
Decode:Init()
return Decode