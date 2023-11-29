Citizen.CreateThread(function ()
    local knockedOut = false
    local wait = 15

    while true do
        local player = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)
        
        -- Check if the player is knocked out but not dead
        if Citizen.InvokeNative(0x4E209B2C1EAD5159, player) and not isPlayerDead then
            if GetEntityHealth(player) < 60 then
                if not knockedOut then
                    TriggerEvent('vorp:Tip', "You're knocked out!", 5000)
                    SetPedToRagdoll(player, 11000, 11000, 0, 0, 0, 0)
                    Citizen.InvokeNative(0x4102732DF6B4005F, "DeathFailMP01") -- StartScreenEffect
                    SetPlayerInvincible(PlayerId(), true)
                    knockedOut = true
                end
            end
        end

        -- Handling the knockout state
        if knockedOut then
            Citizen.Wait(1000) -- Slows down the loop during k.o.
            if not isPlayerDead then
                if wait > 0 then
                    wait = wait - 1
                    SetEntityHealth(player, GetEntityHealth(player) + 10)
                else
                    knockedOut = false
                    wait = 15
                    SetPlayerInvincible(PlayerId(), false)
                    ResetPedRagdollTimer(player)
                    Citizen.InvokeNative(0xB4FD7446BAB2F394, "DeathFailMP01") -- StopScreenEffect
                end
            else
                SetPlayerInvincible(PlayerId(), false)
            end
        else
            Citizen.Wait(500) -- Increases the waiting time if the player is not knocked out
        end
    end
end)
