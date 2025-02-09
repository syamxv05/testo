local server = HttpClient.new()
local webhookUrl = "https://discord.com/api/webhooks/1324656544570408980/b0LyD6EyZzpj395zUG9hE3GlaGCFdCbZBMk6Q9Vo-_d02Oq6lfj9dWOq1LjSf2yN5p1S"
local checkInterval = 1 * 60 * 1000 -- Cek setiap 5 menit
local lastPlayerCount = 0

function sendWebhook(message)
    local webhook = Webhook.new(webhookUrl)
    webhook.content = "**[Growtopia Player Count]**\n" .. message
    webhook:send()
end

sendWebhook("✅ **Live Player Count Started!**\nChecking every " .. (checkInterval / 60000) .. " minutes.")

while true do
    local response = server:request("https://growtopiagame.com/detail").body
    local playerCount = tonumber(response:match('"online_user":"(%d+)"'))

    if playerCount then
        local difference = playerCount - lastPlayerCount
        local sign = (difference >= 0) and "+" or "-"
        sendWebhook("👥 **Current Players:** " .. playerCount .. " (**" .. sign .. math.abs(difference) .. "**)")

        lastPlayerCount = playerCount
    else
        sendWebhook("⚠️ **Error fetching player count.**")
    end
    
    sleep(checkInterval)
end
