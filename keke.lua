-- 创建GUI界面
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")

ScreenGui.Name = "PrivateServerGUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.8, 0, 0.5, 0)
Frame.Size = UDim2.new(0.15, 0, 0.2, 0)

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.1, 0, 0.6, 0)
TextButton.Size = UDim2.new(0.8, 0, 0.3, 0)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "点击生成私服(剪贴板复制的不要管)"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 14.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
TextLabel.Size = UDim2.new(0.8, 0, 0.4, 0)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "橙c美式私服"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

-- MD5和HMAC相关函数（与你的代码相同）
local MD5_CONSTANTS = {
    0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,0xf57c0faf,0x4787c62a,
    0xa8304613,0xfd469501,0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,
    0x6b901122,0xfd987193,0xa679438e,0x49b40821,0xf61e2562,0xc040b340,
    0x265e5a51,0xe9b6c7aa,0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,
    0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,0xa9e3e905,0xfcefa3f8,
    0x676f02d9,0x8d2a4c8a,0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,
    0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,0x289b7ec6,0xeaa127fa,
    0xd4ef3085,0x04881d05,0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
    0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,0x655b59c3,0x8f0ccc92,
    0xffeff47d,0x85845dd1,0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,
    0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391
}

local function md5_hash(message)
    local A, B, C, D = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
    local padded = message .. "\x80"
    while #padded % 64 ~= 56 do
        padded = padded .. "\0"
    end
    local bit_len = #message * 8
    for i = 0, 7 do
        padded = padded .. string.char(bit32.band(bit32.rshift(bit_len, i * 8), 0xFF))
    end
    for block_start = 1, #padded, 64 do
        local chunk = padded:sub(block_start, block_start + 63)
        local X = {}
        for j = 0, 15 do
            local b1, b2, b3, b4 = chunk:byte(j*4+1, j*4+4)
            X[j] = bit32.bor(b1, bit32.lshift(b2, 8), bit32.lshift(b3, 16), bit32.lshift(b4, 24))
        end
        local AA, BB, CC, DD = A, B, C, D
        local shift_amounts = {7,12,17,22, 5,9,14,20, 4,11,16,23, 6,10,15,21}
        for i = 0, 63 do
            local F, g, s_index
            if i < 16 then
                F = bit32.bor(bit32.band(B, C), bit32.band(bit32.bnot(B), D))
                g = i
                s_index = i % 4
            elseif i < 32 then
                F = bit32.bor(bit32.band(D, B), bit32.band(C, bit32.bnot(D)))
                g = (5 * i + 1) % 16
                s_index = 4 + (i % 4)
            elseif i < 48 then
                F = bit32.bxor(B, bit32.bxor(C, D))
                g = (3 * i + 5) % 16
                s_index = 8 + (i % 4)
            else
                F = bit32.bxor(C, bit32.bor(B, bit32.bnot(D)))
                g = (7 * i) % 16
                s_index = 12 + (i % 4)
            end
            local temp = bit32.band(A + F + X[g] + MD5_CONSTANTS[i+1], 0xFFFFFFFF)
            local s = shift_amounts[s_index + 1]
            local rotated = bit32.bor(bit32.lshift(temp, s), bit32.rshift(temp, 32 - s))
            local newB = bit32.band(B + rotated, 0xFFFFFFFF)
            A, B, C, D = D, newB, B, C
        end
        A = bit32.band(A + AA, 0xFFFFFFFF)
        B = bit32.band(B + BB, 0xFFFFFFFF)
        C = bit32.band(C + CC, 0xFFFFFFFF)
        D = bit32.band(D + DD, 0xFFFFFFFF)
    end
    local digest = ""
    for _, val in ipairs({A, B, C, D}) do
        for i = 0, 3 do
            digest = digest .. string.char(bit32.band(bit32.rshift(val, i * 8), 0xFF))
        end
    end
    return digest
end

local function hmac(key, message, hash_func)
    if #key > 64 then
        key = hash_func(key)
    end
    local o_key_pad = ""
    local i_key_pad = ""
    for i = 1, 64 do
        local byte = i <= #key and string.byte(key, i) or 0
        o_key_pad = o_key_pad .. string.char(bit32.bxor(byte, 0x5c))
        i_key_pad = i_key_pad .. string.char(bit32.bxor(byte, 0x36))
    end
    return hash_func(o_key_pad .. hash_func(i_key_pad .. message))
end

local function base64_encode(data)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local bit_string = (data:gsub(".", function(char)
        local byte = char:byte()
        local bits = ""
        for i = 7, 0, -1 do
            bits = bits .. (math.floor(byte / 2^i) % 2 == 1 and "1" or "0")
        end
        return bits
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(bits)
        if #bits < 6 then return "" end
        local c = 0
        for i = 1, 6 do
            if bits:sub(i, i) == "1" then c = c + 2^(6 - i) end
        end
        return b64chars:sub(c + 1, c + 1)
    end)
    local padding = ({ "", "==", "=" })[#data % 3 + 1]
    return bit_string .. padding
end

local function generate_access_code(place_id)
    local uuid_bytes = {}
    for i = 1, 16 do
        uuid_bytes[i] = math.random(0, 255)
    end
    uuid_bytes[7] = bit32.bor(bit32.band(uuid_bytes[7], 0x0F), 0x40)
    uuid_bytes[9] = bit32.bor(bit32.band(uuid_bytes[9], 0x3F), 0x80)
    local uuid_str = string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", table.unpack(uuid_bytes))
    
    local place_id_bytes = {}
    local pid = place_id
    for i = 1, 8 do
        place_id_bytes[i] = string.char(pid % 256)
        pid = math.floor(pid / 256)
    end
    local place_id_str = table.concat(place_id_bytes)

    local payload = table.concat((function()
        local t = {}
        for i = 1, #uuid_bytes do t[i] = string.char(uuid_bytes[i]) end
        return t
    end)()) .. place_id_str

    local secret_key = "e4Yn8ckbCJtw2sv7qmbg"
    local signature = hmac(secret_key, payload, md5_hash)

    local combined = signature .. payload
    local encoded = base64_encode(combined)
    encoded = encoded:gsub("%+", "-"):gsub("/", "_")
    local padding_count = 0
    encoded = encoded:gsub("=", function()
        padding_count = padding_count + 1
        return ""
    end)
    encoded = encoded .. tostring(padding_count)

    return encoded, uuid_str
end

-- 按钮点击事件
TextButton.MouseButton1Click:Connect(function()
    TextLabel.Text = "正在生成私服..."
    
    local success, result = pcall(function()
        local access_code, uuid_string = generate_access_code(game.PlaceId)
        setclipboard(access_code .. "\n" .. tostring(game.PlaceId))
        game:GetService("RobloxReplicatedStorage").ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", access_code)
        return access_code
    end)
    
    if success then
        TextLabel.Text = "密钥已生成并复制到剪贴板!\n已发送私服邀请"
        wait(2)
        TextLabel.Text = "点击进入私服"
    else
        TextLabel.Text = "错误: " .. result
        wait(3)
        TextLabel.Text = "点击进入私服"
    end
end)
