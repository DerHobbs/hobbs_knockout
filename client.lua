Citizen.CreateThread(function ()
    local knockedOut = false
    local wait = 15

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()

        if Citizen.InvokeNative(0x4E209B2C1EAD5159 ,player) then
            if GetEntityHealth(player) < 60 and not IsEntityDead(PlayerPedId()) then
                TriggerEvent('vorp:Tip',"You're knocked out!",5000)
                wait = 10
                knockedOut = true
                SetPedToRagdoll(PlayerPedId(), 11000, 11000, 0, 0, 0, 0)
                Citizen.InvokeNative(0x4102732DF6B4005F,"DeathFailMP01")--StartScreenEffect
            end
        end
        while(knockedOut) do
            Citizen.Wait(1000)
            if not IsEntityDead(PlayerPedId()) then
                SetPlayerInvincible(PlayerId(), true)
                if wait > 0 then
                    wait = wait - 1
                    SetEntityHealth(player, GetEntityHealth(player)+10)
                else
                    Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 0, 40)
                    SetPlayerInvincible(PlayerId(), false)
                    knockedOut = false
                    ResetPedRagdollTimer(player)
                    Citizen.InvokeNative(0xB4FD7446BAB2F394,"DeathFailMP01")--StopScreenEffect
                end
            else
                SetPlayerInvincible(PlayerId(), false)
            end
        end
    end
end)