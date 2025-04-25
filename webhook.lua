local webhook = "https://discord.com/api/webhooks/1363752832913772544/B7bSWXh3uVzkiQ2ysIRDTEUsbcULN82nJ3dWFMIBBH-mpmdgelBVsgnDE6HSATpsTjfD"
local rifts = workspace.Rendered:WaitForChild("Rifts")
local HttpService = game:GetService("HttpService")

local function sendWebhook(meters, displayName, multiplier, timerStr)
    if webhook == "" then return end
    local payload = {
        content = "@everyone",
        embeds = {{
            title       = "A Rift has spawned:",
            description = "A rift has spawned at: " .. meters,
            color       = 3426654,
            fields = {
                { name = "Name",       value = displayName,           inline = true },
                { name = "Multiplier", value = tostring(multiplier), inline = true },
                { name = "Timer",      value = timerStr,             inline = true },
                { name = "Meters",     value = tostring(meters),     inline = true },
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    request({
        Url     = webhook,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = HttpService:JSONEncode(payload)
    })
end

local function processRift(v)
    task.wait(5)
    local gui = v:FindFirstChild("Display") and v.Display:FindFirstChild("SurfaceGui")
    if not gui then return end

    local timerText = (gui:FindFirstChild("Timer") or {Text="0"}).Text
    local secs = 0
    if timerText:find(":") then
        local m, s = timerText:match("(%d+):(%d+)")
        secs = (tonumber(m) or 0)*60 + (tonumber(s) or 0)
    else
        secs = (tonumber(timerText:match("%d+")) or 0)*60
    end
    local expiry = os.time() + secs
    local timerValue = ("<t:%d:R>"):format(expiry)

    -- 解析 multiplier
    local luck = gui:FindFirstChild("Icon") and gui.Icon:FindFirstChild("Luck")
    local multNum = tonumber((luck and luck.Text:match("%d+")) or "0") or 0

    local rawName = v.Name
    local displayName = rawName
    if rawName == "event-1" then
        displayName = "bunny-egg"
    elseif rawName == "event-2" then
        displayName = "pastel-egg"
    elseif rawName == "event-3" then
        displayName = "throwback-egg"
    end

    if rawName == "royal-chest" then
        multNum = 9999999999
    end

    local shouldSend = false
    local okVals = {5, 10, 25}
    local function isOK(n)
        for _, v in ipairs(okVals) do
            if n == v then return true end
        end
        return false
    end

    if (rawName == "event-1" 
        or rawName == "event-2" 
        or rawName == "event-3" 
        or rawName == "aura-egg")
    and isOK(multNum) then
        shouldSend = true

    elseif rawName == "nightmare-egg" and multNum == 25 then
        shouldSend = true

    elseif rawName == "royal-chest" then
        shouldSend = true
    end

    local meters = math.floor(v:GetPivot().Position.Y)
    if rawName ~= "gift-rift" and shouldSend then
        sendWebhook(meters, displayName, multNum, timerValue)
    end
end

for _, v in ipairs(rifts:GetChildren()) do
    task.spawn(processRift, v)
end

rifts.ChildAdded:Connect(function(v)
    task.spawn(processRift, v)
end)
