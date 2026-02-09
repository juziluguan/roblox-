--// Rayfield UI Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "NovaZHub | Ez Auto Farm Bonde 🤑",
    LoadingTitle = "NovaZHub",
    LoadingSubtitle = "Auto Farm Bonde",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NovaZHub", -- Nome da pasta local
        FileName = "AutoFarmBonde"
    },
    Discord = {
        Enabled = true,
        Invite = "zgthub", -- seu convite
        RememberJoins = true
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)

--// Toggle para ativar/desativar auto farm
MainTab:CreateToggle({
    Name = "Auto Farm Bonde",
    CurrentValue = false,
    Flag = "AutoFarmBonde",
    Callback = function(Value)
        getgenv().autoFarmBond = Value
        getgenv().CollectBond = Value
    end,
})

--// VARIÁVEIS E SERVIÇOS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EndDecision = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EndDecision")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local started = false
local tweenSpeed = 1000
local currentIndex = 1
local collectDelay = 0.01
local lastCollectTime = 0

local gunCFrame = CFrame.new(350.5, 50.89, -9100.78)
local rangeMaxGun = 200

local bondPoints = {
    CFrame.new(-475.66, 200.77, 21969.36),
    CFrame.new(-319.90, 200.77, 14036.94),
    CFrame.new(-15.96, 200.77, 6099.45),
    CFrame.new(-615.17, 200.77, -1836.15),
    CFrame.new(249.76, 200.77, -9067.68),
    CFrame.new(-138.72, 200.77, -17713.91),
    CFrame.new(249.76, 200.77, -9067.68),
    CFrame.new(228.52, 200.77, 5163.45),
    CFrame.new(-860.02, 200.77, -27428.81),
    CFrame.new(10.24, 200.77, -33604.30),
    CFrame.new(-322.95, 200.77, -41545.23),
    CFrame.new(-384.79, 40, -48746.83),
    CFrame.new(-379.98, 3, -49471.26),
    CFrame.new(-380.45, -23, -49332.89),
}

--// FUNÇÕES
local function teleportTo(cf)
    root.Anchored = true
    root.CFrame = cf
    task.wait(3)
    root.Anchored = false
end

local function tweenTo(cf)
    local distance = (root.Position - cf.Position).Magnitude
    local duration = distance / tweenSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, { CFrame = cf })
    local success, err = pcall(function()
        tween:Play()
        task.wait(duration)
    end)
    if not success then warn("Tween error:", err) end
end

local function getLockedGun()
    local runtime = Workspace:FindFirstChild("RuntimeItems")
    if not runtime then return nil end
    for _, v in ipairs(runtime:GetChildren()) do
        if v:IsA("Model") and v.Name == "MaximGun" then
            local dist = (v:GetPivot().Position - gunCFrame.Position).Magnitude
            if dist <= rangeMaxGun then
                return v
            end
        end
    end
    return nil
end

local function sitInGun()
    local gun = getLockedGun()
    local seat = gun and gun:FindFirstChild("VehicleSeat")
    if seat and seat:IsA("VehicleSeat") then
        if seat.Disabled then seat.Disabled = false end
        teleportTo(seat.CFrame)
        return true
    end
    return false
end

local function jumpOff()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function freezeMidAir()
    local freezePos = root.Position + Vector3.new(0, 5, 0)
    root.Anchored = true
    root.CFrame = CFrame.new(freezePos)
    task.wait(1)
    root.Anchored = false
end

local function tryTweenToBond()
    local runtime = Workspace:FindFirstChild("RuntimeItems")
    if runtime then
        for _, v in ipairs(runtime:GetChildren()) do
            if v:IsA("Model") and v.Name == "Bond" then
                local bondPos = v:GetPivot().Position
                local distance = (root.Position - bondPos).Magnitude
                if distance <= 100000 then
                    tweenTo(CFrame.new(bondPos + Vector3.new(0, 4, 0)))
                    return true
                end
            end
        end
    end
    return false
end

local function setupGun()
    teleportTo(gunCFrame)
    if sitInGun() then
        task.wait(0.6)
        jumpOff()
        freezeMidAir()
        task.wait(0.5)
        sitInGun()
        task.wait(0.1)
    end
end

local function finishFarm()
    getgenv().autoFarmBond = false
    getgenv().CollectBond = false
    started = false
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function searchBondPoints()
    if currentIndex > #bondPoints then
        finishFarm()
        return
    end
    local cf = bondPoints[currentIndex]
    if tryTweenToBond() then return end
    teleportTo(cf)
    currentIndex += 1
end

--// COLETAR BOND
RunService.Heartbeat:Connect(function()
    if getgenv().CollectBond and tick() - lastCollectTime >= collectDelay then
        lastCollectTime = tick()
        for _, bond in ipairs(Workspace:GetDescendants()) do
            if bond:IsA("Model") and bond.Name == "Bond" then
                local args = { bond }
                pcall(function()
                    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemotePromise")
                        :WaitForChild("Remotes"):WaitForChild("C_ActivateObject"):FireServer(unpack(args))
                end)
            end
        end
    end
end)

--// EXECUÇÃO PRINCIPAL
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().autoFarmBond and not started then
            setupGun()
            started = true
        elseif getgenv().autoFarmBond and started then
            searchBondPoints()
        end
    end
end)

--// LOOP DE FIM (EndDecision)
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().autoFarmBond then
            pcall(function()
                EndDecision:FireServer(false)
            end)
        end
    end
end)
