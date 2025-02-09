-- Load modules safely
pcall(require, "luarocks.loader")
local http = require("socket.http")
local json = require("dkjson")

local webhook_url = "https://discord.com/api/webhooks/1324656544570408980/b0LyD6EyZzpj395zUG9hE3GlaGCFdCbZBMk6Q9Vo-_d02Oq6lfj9dWOq1LjSf2yN5p1S"
local message_id = nil -- Untuk menyimpan ID pesan Discord agar bisa diedit

function get_player_count()
    local response, status = http.request("https://growtopiagame.com/detail")
    if status == 200 and response then
        local data = json.decode(response)
        if data and data.online_user then
            return tonumber(data.online_user)
        end
    end
    return nil
end

function send_initial_message(count)
    local body = json.encode({ content = "**🌎 Growtopia Player Count:** `" .. count .. "` Online" })
    local response_body = {}
    
    local _, status, headers = http.request {
        url = webhook_url,
        method = "POST",
        headers = { ["Content-Type"] = "application/json", ["Content-Length"] = tostring(#body) },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response_body)
    }

    if status == 200 or status == 201 then
        local response_str = table.concat(response_body)
        local response_data = json.decode(response_str)
        if response_data and response_data.id then
            message_id = response_data.id
        end
    end
end

function edit_message(count)
    if not message_id then
        send_initial_message(count)
        return
    end

    local body = json.encode({ content = "**🌎 Growtopia Player Count:** `" .. count .. "` Online" })

    http.request {
        url = webhook_url .. "/messages/" .. message_id,
        method = "PATCH",
        headers = { ["Content-Type"] = "application/json", ["Content-Length"] = tostring(#body) },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table({})
    }
end

while true do
    local count = get_player_count()
    if count then edit_message(count) end
    os.execute("sleep 30") -- Update setiap 30 detik
end
