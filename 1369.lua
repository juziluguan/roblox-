local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

WindUI:Popup({
    Title = gradient("Dead Rails Hub", Color3.fromHex("#6A11CB"), Color3.fromHex("#2575FC")),
    Icon = "sparkles",
    Content = "Welcome to the ultimate Dead Rails experience!",
    Buttons = {
        {
            Title = "Get Started",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "Dead Rails Hub",
    Icon = "skull",
    Author = "Integrated Hub",
    Folder = "DeadRails_Hub",
    Size = UDim2.fromOffset(750, 550),
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            WindUI:Notify({
                Title = "User Profile",
                Content = "Profile clicked!",
                Duration = 3
            })
        end
    },
    SideBarWidth = 220,
    ScrollBarEnabled = true
})

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({
        Title = "Theme Changed",
        Content = "Current theme: " .. WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

local Sections = {
    Farm = Window:Section({ Title = "Farm", Opened = true }),
    Combat = Window:Section({ Title = "Combat", Opened = true }),
    ESP = Window:Section({ Title = "ESP", Opened = true }),
    Teleport = Window:Section({ Title = "Teleport", Opened = true }),
    Automation = Window:Section({ Title = "Automation", Opened = true }),
    Misc = Window:Section({ Title = "Misc", Opened = true }),
    Settings = Window:Section({ Title = "Settings", Opened = true })
}

local FarmTab = Sections.Farm:Tab({ Title = "Bond Farm", Icon = "coins" })

FarmTab:Paragraph({
    Title = "Bond Farming",
    Desc = "Automated bond collection features",
    Image = "target",
    ImageSize = 20,
    Color = "White"
})

FarmTab:Divider()

local autoFarmBonds = false
FarmTab:Toggle({
    Title = "Auto Farm Bonds",
    Desc = "Normal farming mode",
    Value = false,
    Callback = function(state)
        autoFarmBonds = state
        if state then
            getgenv().DeadRails = {
                ["Farm"] = {
                    ["Enabled"] = true,
                    ["Mode"] = "Normal",
                },
            }
            local baseUrl = "https://raw.githubusercontent.com/Shade-vex/Hutao-hub-code-pro-mode/refs/heads/main/"
            loadstring(game:HttpGet(baseUrl .. "AutoBondsINF"))()
        end
        WindUI:Notify({
            Title = "Auto Farm",
            Content = state and "Bond farming started" or "Bond farming stopped",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local ultimateFarm = false
FarmTab:Toggle({
    Title = "Ultimate Auto Farm",
    Desc = "70+ bonds per run (Recommended)",
    Value = false,
    Callback = function(state)
        ultimateFarm = state
        if state then
            local baseUrl = "https://raw.githubusercontent.com/Shade-vex/Hutao-hub-code-pro-mode/refs/heads/main/"
            loadstring(game:HttpGet(baseUrl .. "AutoBonds2.lua.txt"))()
        end
        WindUI:Notify({
            Title = "Ultimate Farm",
            Content = state and "Ultimate farming started" or "Ultimate farming stopped",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local autoFarmWin = false
FarmTab:Toggle({
    Title = "Auto Farm & Win",
    Desc = "AI farm bonds and win (Cowboy class recommended)",
    Value = false,
    Callback = function(state)
        autoFarmWin = state
        if state then
            local baseUrl = "https://raw.githubusercontent.com/Shade-vex/Hutao-hub-code-pro-mode/refs/heads/main/"
            loadstring(game:HttpGet(baseUrl .. "AutoBonds3.lua.txt"))()
        end
        WindUI:Notify({
            Title = "Auto Farm & Win",
            Content = state and "Auto farm & win started" or "Auto farm & win stopped",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local bondCount = 0
local bondCounterGui = nil

FarmTab:Toggle({
    Title = "Bond Counter",
    Desc = "Show collected bonds count",
    Value = false,
    Callback = function(state)
        if state then
            if not game.CoreGui:FindFirstChild("BondCounter") then
                local gui = Instance.new("ScreenGui", game.CoreGui)
                gui.Name = "BondCounter"
                gui.ResetOnSpawn = false

                local frame = Instance.new("Frame", gui)
                frame.Size = UDim2.new(0, 200, 0, 60)
                frame.Position = UDim2.new(0, 20, 0, 100)
                frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
                frame.BorderSizePixel = 0

                local corner = Instance.new("UICorner", frame)
                corner.CornerRadius = UDim.new(0, 8)

                local title = Instance.new("TextLabel", frame)
                title.Size = UDim2.new(1, 0, 0.4, 0)
                title.BackgroundTransparency = 1
                title.Text = "Bonds Collected"
                title.TextColor3 = Color3.new(1, 1, 1)
                title.Font = Enum.Font.GothamBold

                local count = Instance.new("TextLabel", frame)
                count.Name = "Count"
                count.Size = UDim2.new(1, 0, 0.6, 0)
                count.Position = UDim2.new(0, 0, 0.4, 0)
                count.BackgroundTransparency = 1
                count.Text = "0"
                count.TextColor3 = Color3.fromRGB(0, 255, 100)
                count.Font = Enum.Font.GothamBold
                count.TextSize = 24

                bondCounterGui = gui
            end

            workspace.RuntimeItems.ChildAdded:Connect(function(v)
                if v.Name:find("Bond") and v:FindFirstChild("Part") then
                    v.Destroying:Connect(function()
                        bondCount = bondCount + 1
                    end)
                end
            end)

            task.spawn(function()
                while bondCounterGui do
                    local gui = game.CoreGui:FindFirstChild("BondCounter")
                    if gui and gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("Count") then
                        gui.Frame.Count.Text = tostring(bondCount)
                    end
                    task.wait(0.1)
                end
            end)
        else
            if game.CoreGui:FindFirstChild("BondCounter") then
                game.CoreGui.BondCounter:Destroy()
                bondCounterGui = nil
            end
        end
    end
})

local CombatTab = Sections.Combat:Tab({ Title = "Combat", Icon = "sword" })

CombatTab:Paragraph({
    Title = "Combat Features",
    Desc = "Aimbot, Kill Aura, and more",
    Image = "crosshair",
    ImageSize = 20,
    Color = "White"
})

CombatTab:Divider()

local aimbotEnabled = false
local fov = 100
CombatTab:Toggle({
    Title = "Aimbot V2",
    Desc = "Hold M2 to aim (FOV circle)",
    Value = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local Cam = workspace.CurrentCamera
            local Player = game:GetService("Players").LocalPlayer

            local FOVring = Drawing.new("Circle")
            FOVring.Visible = false
            FOVring.Thickness = 2
            FOVring.Color = Color3.fromRGB(255, 255, 255)
            FOVring.Filled = false
            FOVring.Radius = fov
            FOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)

            local isAiming = false
            local validNPCs = {}
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local function isNPC(obj)
                return obj:IsA("Model") 
                    and obj:FindFirstChild("Humanoid")
                    and obj.Humanoid.Health > 0
                    and obj:FindFirstChild("Head")
                    and obj:FindFirstChild("HumanoidRootPart")
                    and not game:GetService("Players"):GetPlayerFromCharacter(obj)
            end

            local function updateNPCs()
                local tempTable = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if isNPC(obj) then
                        tempTable[obj] = true
                    end
                end
                for i = #validNPCs, 1, -1 do
                    if not tempTable[validNPCs[i]] then
                        table.remove(validNPCs, i)
                    end
                end
                for obj in pairs(tempTable) do
                    if not table.find(validNPCs, obj) then
                        table.insert(validNPCs, obj)
                    end
                end
            end

            workspace.DescendantAdded:Connect(function(descendant)
                if isNPC(descendant) then
                    table.insert(validNPCs, descendant)
                end
            end)

            local function predictPos(target)
                local rootPart = target:FindFirstChild("HumanoidRootPart")
                local head = target:FindFirstChild("Head")
                if not rootPart or not head then
                    return head and head.Position or rootPart and rootPart.Position
                end
                local velocity = rootPart.Velocity
                local predictionTime = 0.02
                local basePosition = rootPart.Position + velocity * predictionTime
                local headOffset = head.Position - rootPart.Position
                return basePosition + headOffset
            end

            local function getTarget()
                local nearest = nil
                local minDistance = math.huge
                local viewportCenter = Cam.ViewportSize / 2
                raycastParams.FilterDescendantsInstances = {Player.Character}
                for _, npc in ipairs(validNPCs) do
                    local predictedPos = predictPos(npc)
                    local screenPos, visible = Cam:WorldToViewportPoint(predictedPos)
                    if visible and screenPos.Z > 0 then
                        local ray = workspace:Raycast(
                            Cam.CFrame.Position,
                            (predictedPos - Cam.CFrame.Position).Unit * 1000,
                            raycastParams
                        )
                        if ray and ray.Instance:IsDescendantOf(npc) then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                            if distance < minDistance and distance < fov then
                                minDistance = distance
                                nearest = npc
                            end
                        end
                    end
                end
                return nearest
            end

            local function aim(targetPosition)
                local currentCF = Cam.CFrame
                local targetDirection = (targetPosition - currentCF.Position).Unit
                local smoothFactor = 0.581
                local newLookVector = currentCF.LookVector:Lerp(targetDirection, smoothFactor)
                Cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
            end

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
                    isAiming = true
                    FOVring.Visible = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    isAiming = false
                    FOVring.Visible = false
                end
            end)

            RunService.Heartbeat:Connect(function()
                updateNPCs()
                if isAiming then
                    local target = getTarget()
                    if target then
                        local predictedPosition = predictPos(target)
                        aim(predictedPosition)
                    end
                end
            end)
        end
    end
})

CombatTab:Slider({
    Title = "Aimbot FOV",
    Desc = "Field of view for aimbot",
    Value = { Min = 50, Max = 250, Default = 100 },
    Callback = function(value)
        fov = value
    end
})

local gunKillAura = false
CombatTab:Toggle({
    Title = "Gun Kill Aura",
    Desc = "Auto shoot nearby enemies",
    Value = false,
    Callback = function(state)
        gunKillAura = state
        if state then
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local workspace = game.Workspace

            local ShootRemote = ReplicatedStorage.Remotes.Weapon.Shoot
            local ReloadRemote = ReplicatedStorage.Remotes.Weapon.Reload
            local Camera = workspace.CurrentCamera
            local LocalPlayer = Players.LocalPlayer

            local AutoReloadEnabled = true
            local GunAuraAllMobs = true
            local SEARCH_RADIUS = 1000
            local HEADSHOT_DELAY = 0.1

            local Weapons = {
                ["Revolver"] = true,
                ["Rifle"] = true,
                ["Sawed-Off Shotgun"] = true,
                ["Bolt Action Rifle"] = true,
                ["Navy Revolver"] = true,
                ["Mauser"] = true,
                ["Shotgun"] = true
            }

            local function getEquippedSupportedWeapon()
                local char = LocalPlayer.Character
                if not char then return nil end
                for name, _ in pairs(Weapons) do
                    local tool = char:FindFirstChild(name)
                    if tool then return tool end
                end
                return nil
            end

            local function isNPC(obj)
                if not obj:IsA("Model") then return false end
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return false end
                return obj:FindFirstChild("Head") and obj:FindFirstChild("HumanoidRootPart")
                    and not Players:GetPlayerFromCharacter(obj)
            end

            task.spawn(function()
                while gunKillAura do
                    local tool = getEquippedSupportedWeapon()
                    if tool then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if isNPC(obj) then
                                local head = obj:FindFirstChild("Head")
                                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                                if dist <= SEARCH_RADIUS then
                                    local pelletTable = {}
                                    if tool.Name:lower():find("shotgun") then
                                        for i = 1, 6 do pelletTable[tostring(i)] = obj.Humanoid end
                                    else
                                        pelletTable["1"] = obj.Humanoid
                                    end
                                    local shootArgs = {
                                        workspace:GetServerTimeNow(),
                                        tool,
                                        CFrame.new(head.Position + Vector3.new(0, 1.5, 0), head.Position),
                                        pelletTable
                                    }
                                    pcall(function() ShootRemote:FireServer(unpack(shootArgs)) end)
                                    if AutoReloadEnabled then
                                        pcall(function() ReloadRemote:FireServer(workspace:GetServerTimeNow(), tool) end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(HEADSHOT_DELAY)
                end
            end)
        end
    end
})

local hitboxEnabled = false
CombatTab:Toggle({
    Title = "Hitbox Expander",
    Desc = "Expand enemy hitboxes",
    Value = false,
    Callback = function(state)
        hitboxEnabled = state
        local hitboxSize = Vector3.new(15, 15, 15)
        local hitboxTransparency = 0.85
        local hitboxColor = Color3.fromRGB(255, 0, 0)
        local originalProperties = {}

        local targetNPCs = {
            ["Vampire"] = true, ["Werewolf"] = true, ["Wolf"] = true,
            ["Runner"] = true, ["Walker"] = true, ["Banner"] = true,
            ["Nikola Tesla"] = true, ["Lab Zombie"] = true, ["Captain Prescott"] = true,
            ["Zombie Soldier"] = true, ["Banker"] = true,
            ["Outlaw"] = true, ["RifleOutlaw"] = true, ["ShotgunOutlaw"] = true,
            ["RevolverOutlaw"] = true, ["TurretOutlaw"] = true,
            ["Scientist Zombies"] = true, ["Scientist"] = true, ["Soldier"] = true,
            ["ZombieMiner"] = true, ["SkeletonMiner"] = true,
        }

        local function isTargetNPC(character)
            return character:IsA("Model") and character:FindFirstChild("Humanoid") and targetNPCs[character.Name]
        end

        local function expandHitbox(npc)
            for _, partName in ipairs({"HumanoidRootPart", "Head"}) do
                local hitboxPart = npc:FindFirstChild(partName)
                local humanoid = npc:FindFirstChild("Humanoid")
                if hitboxPart and humanoid and humanoid.Health > 0 then
                    if not originalProperties[npc] then originalProperties[npc] = {} end
                    if not originalProperties[npc][partName] then
                        originalProperties[npc][partName] = {
                            Size = hitboxPart.Size,
                            Transparency = (partName == "HumanoidRootPart") and 1 or 0,
                            Shape = hitboxPart.Shape,
                            CanCollide = hitboxPart.CanCollide
                        }
                    end
                    hitboxPart.Size = hitboxSize
                    hitboxPart.Transparency = hitboxTransparency
                    hitboxPart.Color = hitboxColor
                    hitboxPart.Material = Enum.Material.ForceField
                    hitboxPart.CanCollide = false
                    hitboxPart.Shape = (partName == "HumanoidRootPart") and Enum.PartType.Block or Enum.PartType.Ball
                end
            end
        end

        local function resetHitbox(npc)
            for _, partName in ipairs({"HumanoidRootPart", "Head"}) do
                local hitboxPart = npc:FindFirstChild(partName)
                if hitboxPart and originalProperties[npc] and originalProperties[npc][partName] then
                    hitboxPart.Size = originalProperties[npc][partName].Size
                    hitboxPart.Transparency = originalProperties[npc][partName].Transparency
                    hitboxPart.Shape = originalProperties[npc][partName].Shape
                    hitboxPart.Color = Color3.fromRGB(255, 255, 255)
                    hitboxPart.Material = Enum.Material.Plastic
                    hitboxPart.CanCollide = originalProperties[npc][partName].CanCollide
                end
            end
            originalProperties[npc] = nil
        end

        if state then
            task.spawn(function()
                while hitboxEnabled do
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if isTargetNPC(npc) then
                            expandHitbox(npc)
                        end
                    end
                    task.wait(0.3)
                end
                for _, npc in ipairs(workspace:GetDescendants()) do
                    if isTargetNPC(npc) then resetHitbox(npc) end
                end
            end)
        else
            for _, npc in ipairs(workspace:GetDescendants()) do
                if isTargetNPC(npc) then resetHitbox(npc) end
            end
        end
    end
})

local meleeAura = false
CombatTab:Toggle({
    Title = "Melee Aura",
    Desc = "Auto attack with melee weapons",
    Value = false,
    Callback = function(state)
        meleeAura = state
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Shade-vex/Dead-Rails-V3/refs/heads/main/Melle-Aura.lua.txt"))()
        end
    end
})

local autoReload = false
CombatTab:Toggle({
    Title = "Auto Reload",
    Desc = "Auto reload weapons",
    Value = false,
    Callback = function(state)
        autoReload = state
        if state then
            task.spawn(function()
                while autoReload do
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:FindFirstChild("ClientWeaponState") and v.ClientWeaponState:FindFirstChild("CurrentAmmo") then
                            game.ReplicatedStorage.Remotes.Weapon.Reload:FireServer(game.Workspace:GetServerTimeNow(), v)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

local ESPTab = Sections.ESP:Tab({ Title = "ESP", Icon = "eye" })

ESPTab:Paragraph({
    Title = "ESP Features",
    Desc = "Visual enhancements",
    Image = "scan",
    ImageSize = 20,
    Color = "White"
})

ESPTab:Divider()

local itemESP = false
ESPTab:Toggle({
    Title = "Item ESP",
    Desc = "Highlight items and enemies",
    Value = false,
    Callback = function(state)
        itemESP = state
        if state then
            task.spawn(function()
                while itemESP do
                    for _, v in pairs(workspace:FindFirstChild("RuntimeItems"):GetChildren()) do
                        if v.ClassName == "Model" and not v:FindFirstChild("Esp_Highlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "Esp_Highlight"
                            highlight.FillColor = Color3.fromRGB(255, 255, 255)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Adornee = v
                            highlight.Parent = v
                        end
                    end
                    task.wait(1)
                end
                for _, v in pairs(workspace:FindFirstChild("RuntimeItems"):GetChildren()) do
                    if v:FindFirstChild("Esp_Highlight") then
                        v.Esp_Highlight:Destroy()
                    end
                end
            end)
        else
            for _, v in pairs(workspace:FindFirstChild("RuntimeItems"):GetChildren()) do
                if v:FindFirstChild("Esp_Highlight") then
                    v.Esp_Highlight:Destroy()
                end
            end
        end
    end
})

local goldenEggESP = false
ESPTab:Toggle({
    Title = "GoldenEgg ESP",
    Desc = "Highlight Golden Eggs",
    Value = false,
    Callback = function(state)
        goldenEggESP = state
        if state then
            task.spawn(function()
                while goldenEggESP do
                    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
                    if runtimeItems then
                        for _, item in ipairs(runtimeItems:GetChildren()) do
                            if item:IsA("Model") and item.Name == "GoldenEgg" and not item:FindFirstChildOfClass("Highlight") then
                                local highlight = Instance.new("Highlight")
                                highlight.FillColor = Color3.new(1, 1, 0)
                                highlight.OutlineColor = Color3.new(0, 0, 0)
                                highlight.Parent = item
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            local runtimeItems = workspace:FindFirstChild("RuntimeItems")
            if runtimeItems then
                for _, item in ipairs(runtimeItems:GetChildren()) do
                    if item:IsA("Model") and item.Name == "GoldenEgg" then
                        local highlight = item:FindFirstChildOfClass("Highlight")
                        if highlight then highlight:Destroy() end
                    end
                end
            end
        end
    end
})

local bondESP = false
ESPTab:Toggle({
    Title = "Bond ESP",
    Desc = "Highlight Bonds",
    Value = false,
    Callback = function(state)
        bondESP = state
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/DeadRails"))()
        end
    end
})

local mobESP = false
ESPTab:Toggle({
    Title = "Mob ESP",
    Desc = "Highlight enemies",
    Value = false,
    Callback = function(state)
        mobESP = state
        if state then
            task.spawn(function()
                while mobESP do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") 
                           and not game.Players:GetPlayerFromCharacter(v) and v.Humanoid.Health > 0 then
                            if not v:FindFirstChild("MobESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "MobESP"
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.Adornee = v
                                highlight.Parent = v
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("MobESP") then
                    v.MobESP:Destroy()
                end
            end
        end
    end
})

local TpTab = Sections.Teleport:Tab({ Title = "Teleport", Icon = "map-pin" })

TpTab:Paragraph({
    Title = "Teleport Locations",
    Desc = "Quick travel to key locations",
    Image = "navigation",
    ImageSize = 20,
    Color = "White"
})

TpTab:Divider()

local teleportLocations = {
    ["Fort"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tpfort.github.io/refs/heads/main/Tpfort.lua"))() end,
    ["Lab/Tesla"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/tptotesla.github.io/refs/heads/main/Tptotesla.lua"))() end,
    ["Castle"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))() end,
    ["Sterling"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/sterlingnotifcation.github.io/refs/heads/main/Sterling.lua"))() end,
    ["Train"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/train.github.io/refs/heads/main/train.lua"))() end,
    ["Barn/Farm"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/tpfarm.github.io/refs/heads/main/tptofarm.lua"))() end,
    ["Bank"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/Tptobank.github.io/refs/heads/main/Banktp.lua"))() end,
    ["End"] = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/newpacifisct/refs/heads/main/newpacifisct.lua"))() end,
}

for name, func in pairs(teleportLocations) do
    TpTab:Button({
        Title = "Teleport to " .. name,
        Icon = "locate",
        Callback = function()
            pcall(func)
            WindUI:Notify({
                Title = "Teleport",
                Content = "Teleporting to " .. name,
                Duration = 2
            })
        end
    })
end

TpTab:Divider()

local baseLocations = {
    ["Spawn"] = CFrame.new(56.64, 3.25, 29936.35),
    ["10 KM"] = CFrame.new(-160.58, 3.00, 19913.25),
    ["20 KM"] = CFrame.new(-556.93, 2.99, 9956.80),
    ["30 KM"] = CFrame.new(-569.78, 3.00, 47.60),
    ["40 KM"] = CFrame.new(-184.49, 3.15, -9899.92),
    ["50 KM"] = CFrame.new(55.23, 3.20, -19842.38),
    ["60 KM"] = CFrame.new(-199.62, 3.15, -29733.95),
    ["70 KM"] = CFrame.new(-577.78, 3.50, -39654.21),
}

local selectedBase = "Spawn"
TpTab:Dropdown({
    Title = "Select Base",
    Values = {"Spawn", "10 KM", "20 KM", "30 KM", "40 KM", "50 KM", "60 KM", "70 KM"},
    Value = "Spawn",
    Callback = function(option)
        selectedBase = option
    end
})

TpTab:Button({
    Title = "Teleport to Base",
    Icon = "locate-fixed",
    Callback = function()
        local Player = game.Players.LocalPlayer
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = baseLocations[selectedBase]
            WindUI:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. selectedBase,
                Duration = 2
            })
        end
    end
})

local AutoTab = Sections.Automation:Tab({ Title = "Automation", Icon = "bot" })

AutoTab:Paragraph({
    Title = "Automation Features",
    Desc = "Auto-collect and auto-use items",
    Image = "settings-2",
    ImageSize = 20,
    Color = "White"
})

AutoTab:Divider()

local autoHeal = false
local healThreshold = 30
AutoTab:Toggle({
    Title = "Auto Heal",
    Desc = "Auto use Snake Oil or Bandage",
    Value = false,
    Callback = function(state)
        autoHeal = state
        if state then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            task.spawn(function()
                while autoHeal do
                    local Character = LocalPlayer.Character
                    if Character then
                        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                        if Humanoid and Humanoid.Health < (Humanoid.MaxHealth * (healThreshold / 100)) then
                            local Backpack = LocalPlayer.Backpack
                            local SnakeOil, Bandage = nil, nil

                            for _, item in ipairs(Backpack:GetChildren()) do
                                if item:IsA("Tool") then
                                    if item.Name:find("Snake Oil") then SnakeOil = item
                                    elseif item.Name:find("Bandage") then Bandage = item end
                                end
                            end

                            if SnakeOil then
                                SnakeOil.Parent = Character
                                task.wait(0.1)
                                pcall(function() SnakeOil.Use:FireServer() end)
                            elseif Bandage then
                                Bandage.Parent = Character
                                task.wait(0.2)
                                pcall(function() Bandage.Use:FireServer() end)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoTab:Slider({
    Title = "Heal Threshold (%)",
    Desc = "Health percentage to trigger heal",
    Value = { Min = 10, Max = 90, Default = 30 },
    Callback = function(value)
        healThreshold = value
    end
})

local autoMoney = false
AutoTab:Toggle({
    Title = "Auto Collect Money Bag",
    Desc = "Auto collect nearby money bags",
    Value = false,
    Callback = function(state)
        autoMoney = state
        if state then
            task.spawn(function()
                while autoMoney do
                    for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
                        if v.Name == "Moneybag" and v:FindFirstChild("MoneyBag") then
                            local prompt = v.MoneyBag:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                prompt.HoldDuration = 0
                                if (v.MoneyBag.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= prompt.MaxActivationDistance then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local autoPickup = false
AutoTab:Toggle({
    Title = "Auto Pickup Items",
    Desc = "Auto pickup Snake Oil, Bandage, Ammo",
    Value = false,
    Callback = function(state)
        autoPickup = state
        if state then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            task.spawn(function()
                while autoPickup do
                    for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
                        if v.Name == "Snake Oil" or v.Name == "Bandage" then
                            for _, part in pairs(v:GetChildren()) do
                                if part:IsA("BasePart") and 30 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude then
                                    ReplicatedStorage.Remotes.Tool.PickUpTool:FireServer(v)
                                end
                            end
                        elseif v.Name:find("Ammo") or v.Name:find("Shells") then
                            for _, part in pairs(v:GetChildren()) do
                                if part:IsA("BasePart") and 30 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude then
                                    ReplicatedStorage.Shared.Network.RemotePromise.Remotes.C_ActivateObject:FireServer(v)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

local autoFuel = false
AutoTab:Toggle({
    Title = "Auto Fuel Train",
    Desc = "Auto fuel the train",
    Value = false,
    Callback = function(state)
        autoFuel = state
        if state then
            task.spawn(function()
                while autoFuel do
                    for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
                        if v.ClassName == "Model" and v:FindFirstChild("ObjectInfo") and v.PrimaryPart then
                            for _, info in pairs(v.ObjectInfo:GetChildren()) do
                                if info.Name == "TextLabel" and info.Text == "Fuel" then
                                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude < 5 then
                                        game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.RequestStartDrag:FireServer(v)
                                        task.wait(0.3)
                                        for _, train in pairs(workspace:GetChildren()) do
                                            if train:IsA("Model") and train:FindFirstChild("RequiredComponents") and train.RequiredComponents:FindFirstChild("FuelZone") then
                                                v:SetPrimaryPartCFrame(train.RequiredComponents.FuelZone.CFrame)
                                            end
                                        end
                                        task.wait(0.3)
                                        game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.RequestStopDrag:FireServer()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local MiscTab = Sections.Misc:Tab({ Title = "Misc", Icon = "sliders" })

MiscTab:Paragraph({
    Title = "Miscellaneous Features",
    Desc = "Various utility features",
    Image = "wrench",
    ImageSize = 20,
    Color = "White"
})

MiscTab:Divider()

local noclip = false
MiscTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(state)
        noclip = state
        task.spawn(function()
            while noclip do
                if game.Players.LocalPlayer.Character then
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
                task.wait()
            end
            if game.Players.LocalPlayer.Character then
                for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end)
    end
})

local fullbright = false
local originalLighting = {}
MiscTab:Toggle({
    Title = "FullBright",
    Desc = "Maximum brightness",
    Value = false,
    Callback = function(state)
        fullbright = state
        local Lighting = game.Lighting
        if state then
            originalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                OutdoorAmbient = Lighting.OutdoorAmbient
            }
            task.spawn(function()
                while fullbright do
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                    task.wait()
                end
                for i, v in pairs(originalLighting) do
                    Lighting[i] = v
                end
            end)
        end
    end
})

local noFog = false
MiscTab:Toggle({
    Title = "No Fog",
    Desc = "Remove fog effects",
    Value = false,
    Callback = function(state)
        noFog = state
        if state then
            task.spawn(function()
                while noFog do
                    game.Lighting.FogStart = 100000
                    game.Lighting.FogEnd = 200000
                    for _, v in pairs(game.Lighting:GetChildren()) do
                        if v.ClassName == "Atmosphere" then
                            v.Density = 0
                            v.Haze = 0
                        end
                    end
                    task.wait()
                end
                game.Lighting.FogStart = 0
                game.Lighting.FogEnd = 1000
            end)
        end
    end
})

local walkSpeedEnabled = false
MiscTab:Toggle({
    Title = "WalkSpeed Boost",
    Desc = "Increased movement speed",
    Value = false,
    Callback = function(state)
        walkSpeedEnabled = state
        if state then
            task.spawn(function()
                while walkSpeedEnabled do
                    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 18.5
                    end
                    task.wait(0.5)
                end
                if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
                end
            end)
        end
    end
})

MiscTab:Button({
    Title = "Get Horse Class",
    Icon = "horse",
    Callback = function()
        local args = { [1] = "Horse" }
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitFirstChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_BuyClass"):FireServer(unpack(args))
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_EquipClass"):FireServer(unpack(args))
        WindUI:Notify({
            Title = "Horse Class",
            Content = "Horse class obtained and equipped!",
            Duration = 3
        })
    end
})

local noCooldown = false
MiscTab:Toggle({
    Title = "No Cooldown",
    Desc = "Instant interaction prompts",
    Value = false,
    Callback = function(state)
        noCooldown = state
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.ClassName == "ProximityPrompt" then
                    v.HoldDuration = 0
                end
            end
            workspace.DescendantAdded:Connect(function(v)
                if noCooldown and v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end)
        end
    end
})

MiscTab:Button({
    Title = "Load Infinite Yield",
    Icon = "terminal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
        WindUI:Notify({
            Title = "Infinite Yield",
            Content = "Infinite Yield loaded!",
            Duration = 3
        })
    end
})

local SettingsTab = Sections.Settings:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Paragraph({
    Title = "UI Settings",
    Desc = "Customize your experience",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

SettingsTab:Divider()

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

SettingsTab:Dropdown({
    Title = "Select Theme",
    Values = themes,
    Value = "Dark",
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "Theme Applied",
            Content = theme,
            Icon = "palette",
            Duration = 2
        })
    end
})

SettingsTab:Slider({
    Title = "Window Transparency",
    Value = { Min = 0, Max = 1, Default = 0.2 },
    Step = 0.1,
    Callback = function(value)
        WindUI.TransparencyValue = tonumber(value)
    end
})

SettingsTab:Toggle({
    Title = "Dark Mode",
    Desc = "Use dark color scheme",
    Value = true,
    Callback = function(state)
        WindUI:SetTheme(state and "Dark" or "Light")
    end
})

SettingsTab:Divider()

local configName = "default"
SettingsTab:Input({
    Title = "Config Name",
    Value = configName,
    Callback = function(value)
        configName = value
    end
})

local ConfigManager = Window.ConfigManager
if ConfigManager then
    ConfigManager:Init(Window)

    SettingsTab:Button({
        Title = "Save Config",
        Icon = "save",
        Variant = "Primary",
        Callback = function()
            local configFile = ConfigManager:CreateConfig(configName)
            configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            if configFile:Save() then
                WindUI:Notify({
                    Title = "Config Saved",
                    Content = "Saved as: " .. configName,
                    Icon = "check",
                    Duration = 3
                })
            end
        end
    })

    SettingsTab:Button({
        Title = "Load Config",
        Icon = "folder",
        Callback = function()
            local configFile = ConfigManager:CreateConfig(configName)
            local loadedData = configFile:Load()
            if loadedData then
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "Loaded: " .. configName,
                    Icon = "refresh-cw",
                    Duration = 3
                })
            end
        end
    })
end

local footerSection = Window:Section({ Title = "Dead Rails Hub v1.0" })
SettingsTab:Paragraph({
    Title = "Made with love",
    Desc = "Integrated from multiple sources",
    Image = "heart",
    ImageSize = 20,
    Color = "Grey",
    Buttons = {
        {
            Title = "Copy Discord",
            Icon = "copy",
            Variant = "Tertiary",
            Callback = function()
                setclipboard("discord.gg/deadrails")
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord link copied to clipboard",
                    Duration = 2
                })
            end
        }
    }
})
