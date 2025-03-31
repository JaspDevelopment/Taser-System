local taserUsage = {}

local function cleanupOldEntries()
    local currentTime = os.time()
    for id, data in pairs(taserUsage) do
        local newUsages = {}
        for _, timestamp in ipairs(data) do
            if currentTime - timestamp < 600 then
                table.insert(newUsages, timestamp)
            end
        end
        if #newUsages == 0 then
            taserUsage[id] = nil
        else
            taserUsage[id] = newUsages
        end
    end
end

local function getDiscordId(source)
    for k,v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            return string.sub(v, 9)
        end
    end
    return nil
end

local function sendWebhook(webhook)
    if not Config.WebhookURL or Config.WebhookURL == "" then
        return
    end
    
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers)
        if err then
            print("^1[TASER X2] Failed to send webhook: " .. tostring(err))
        else
            print("^2[TASER X2] Webhook sent successfully!")
        end
    end, 'POST', json.encode(webhook), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('taser-x2:logIncident')
AddEventHandler('taser-x2:logIncident', function(data)
    local source = source
    local currentTime = os.time()
    local discordId = getDiscordId(source)
    
    if not taserUsage[source] then
        taserUsage[source] = {}
    end
    table.insert(taserUsage[source], currentTime)
    cleanupOldEntries()
    
    if #taserUsage[source] == 4 or #taserUsage[source] == 10 then
        local warningEmbed = {
            username = Config.WebhookName,
            embeds = {{
                title = #taserUsage[source] == 10 and "⚠️ CRITICAL TASER USAGE WARNING ⚠️" or "⚠️ EXCESSIVE TASER USAGE WARNING ⚠️",
                description = #taserUsage[source] == 10 
                    and "Officer has deployed their TASER **10 TIMES** in 10 minutes!\nThis requires immediate supervisor review."
                    or "Officer has deployed their TASER **4 TIMES** in 10 minutes.",
                color = 15158332,
                fields = {
                    {
                        name = "Officer",
                        value = (discordId and ("<@" .. discordId .. ">") or GetPlayerName(source)),
                        inline = true
                    },
                    {
                        name = "Discord ID",
                        value = discordId or "Not Linked",
                        inline = true
                    }
                }
            }}
        }
        sendWebhook(warningEmbed)
    end

    local embed = {
        username = Config.WebhookName,
        embeds = {{
            title = "TASER Deployment",
            color = Config.WebhookColor,
            fields = {
                {
                    name = "Officer",
                    value = (discordId and ("<@" .. discordId .. ">") or GetPlayerName(source)),
                    inline = true
                },
                {
                    name = "Discord ID",
                    value = discordId or "Not Linked",
                    inline = true
                },
                {
                    name = "Time",
                    value = os.date("%Y-%m-%d %H:%M:%S"),
                    inline = true
                }
            },
            footer = {
                text = "TASER Logging System"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    if data.postal then
        table.insert(embed.embeds[1].fields, {
            name = "Postal",
            value = "`" .. data.postal .. "`",
            inline = true
        })
    end

    sendWebhook(embed)
end)

RegisterCommand('taserwebhook', function(source, args, rawCommand)
    sendWebhook({
        username = Config.WebhookName,
        content = "**TASER X2 Webhook Test**\n✅ If you see this message, the webhook is working correctly!"
    })
end, false)

RegisterCommand('chargetaser', function(source, args, rawCommand)
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 150, 255},
        args = {'TASER', '^4Battery charging initiated. Please wait...'}
    })
    Wait(3000)
    TriggerClientEvent('taser-x2:chargeBattery', source)
end, false)

RegisterCommand('ct', function(source, args, rawCommand)
    ExecuteCommand('chargetaser')
end, false)

TriggerEvent('chat:addSuggestion', '/chargetaser', 'Recharge your TASER X2 battery to 100% (Alias: /ct)')
TriggerEvent('chat:addSuggestion', '/ct', 'Recharge your TASER X2 battery to 100%')