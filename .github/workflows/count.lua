local webhookUrl = "https://discord.com/api/webhooks/1324656544570408980/b0LyD6EyZzpj395zUG9hE3GlaGCFdCbZBMk6Q9Vo-_d02Oq6lfj9dWOq1LjSf2yN5p1S"
local lastPlayerCount = 0
local messageId = nil

function sendWebhook(message)
    os.execute("curl -X POST -H 'Content-Type: application/json' -d '{\"content\": \"" .. message .. "\"}' " .. webhookUrl)
end

function editWebhook(message)
    if not messageId then return end
    os.execute("curl -X PATCH -H 'Content-Type: application/json' -d '{\"content\": \"" .. message .. "\"}' " .. webhookUrl .. "/messages/" .. messageId)
end

sendWebhook("✅ **Live Player Count Started!**")

while true do
    local handle = io.popen("curl -s https://growtopiagame.com/detail")
    local response = handle:read("*a")
    handle:close()

    local playerCount = tonumber(response:match('"online_user":"(%d+)"'))

    if playerCount then
        local difference = playerCount - lastPlayerCount
        local sign = (difference >= 0) and "+" or "-"
        local msg = "👥 **Current Players:** " .. playerCount .. " (**" .. sign .. math.abs(difference) .. "**)"

        if messageId then
            editWebhook(msg)
        else
            sendWebhook(msg)
        end

        lastPlayerCount = playerCount
    else
        editWebhook("⚠️ **Error fetching player count.**")
    end

    os.execute("sleep 30") -- Delay 30 detik
end
