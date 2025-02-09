local http = require("socket.http")
local json = require("dkjson")

local webhook_url = "https://discord.com/api/webhooks/1324656544570408980/b0LyD6EyZzpj395zUG9hE3GlaGCFdCbZBMk6Q9Vo-_d02Oq6lfj9dWOq1LjSf2yN5p1S"
local message_id = nil -- Untuk menyimpan ID pesan Discord agar bisa di-edit, bukan membuat baru

-- Fungsi untuk mendapatkan jumlah pemain online di Growtopia
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

-- Fungsi untuk mengirim pesan pertama kali ke Discord (jika belum ada message_id)
function send_initial_message(count)
    local body = json.encode({
        content = "**🌎 Growtopia Player Count:** `" .. count .. "` Online"
    })

    local response, status, headers = http.request {
        url = webhook_url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table({})
    }

    if status == 200 or status == 201 then
        local location = headers["location"] or headers["Location"]
        if location then
            message_id = location:match("/messages/(%d+)")
        end
    end
end

-- Fungsi untuk mengedit pesan yang sudah ada
function edit_message(count)
    if not message_id then
        send_initial_message(count)
        return
    end

    local body = json.encode({
        content = "**🌎 Growtopia Player Count:** `" .. count .. "` Online"
    })

    http.request {
        url = webhook_url .. "/messages/" .. message_id,
        method = "PATCH",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table({})
    }
end

-- Loop utama
while true do
    local count = get_player_count()
    if count then
        edit_message(count)
    end
    os.execute("sleep 30") -- Delay 30 detik sebelum update berikutnya
end
