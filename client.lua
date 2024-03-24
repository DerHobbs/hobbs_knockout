-- Configuration variables
local KNOCKOUT_HEALTH_THRESHOLD = 60
local RAGDOLL_DURATION = 12000 -- 12 seconds in milliseconds
local KNOCKOUT_RECOVERY_TIME = 12 -- Recovery time in seconds after being knocked out
local HEALTH_REGEN_PER_TICK = 5 -- Health points regenerated per tick
local TICK_INTERVAL_KNOCKED_OUT = 1000 -- Milliseconds, shortened for finer timing
local TICK_INTERVAL_ACTIVE = 500 -- Milliseconds
local PlayingHeartbeat = false

Citizen.CreateThread(function()
    local knockedOut = false
    local wait = KNOCKOUT_RECOVERY_TIME

    while true do
        local player = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)
        
        -- Checks if the player is knocked out but not dead
        if Citizen.InvokeNative(0x4E209B2C1EAD5159, player) and not isPlayerDead then
            if GetEntityHealth(player) < KNOCKOUT_HEALTH_THRESHOLD and not knockedOut then
                knockedOut = true
                StartSoundLoop("Heartbeat", "RDRO_Sniper_Tension_Sounds")
                TriggerEvent('vorp:Tip', "You're knocked out!", 5000)
                Citizen.InvokeNative(0xAE99FB955581844A, player, RAGDOLL_DURATION, RAGDOLL_DURATION, 0, false, false, false)
                Citizen.InvokeNative(0x4102732DF6B4005F, "DeathFailMP01")
                SetPlayerInvincible(PlayerId(), true)
            end
        end

        -- Handling the knockout state
        if knockedOut then
            Citizen.Wait(TICK_INTERVAL_KNOCKED_OUT)
            if not isPlayerDead then
                if wait > 0 then
                    wait = wait - 1
                    SetEntityHealth(player, GetEntityHealth(player) + HEALTH_REGEN_PER_TICK) -- Regenerates health
                else
                    knockedOut = false
                    wait = KNOCKOUT_RECOVERY_TIME
                    StopSoundLoop()
                    SetPlayerInvincible(PlayerId(), false)
                    Citizen.InvokeNative(0xB4FD7446BAB2F394, "DeathFailMP01") -- Stop the screen effect
                    ResetPedRagdollTimer(player)
                end
            else
                -- If the player dies during being knocked out
                knockedOut = false
                StopSoundLoop()
                SetPlayerInvincible(PlayerId(), false)
            end
        else
            Citizen.Wait(TICK_INTERVAL_ACTIVE)
        end
    end
end)

function StartSoundLoop(audioName, audioRef)
    -- Starts playing the heartbeat sound loop
    if not PlayingHeartbeat then
        PlayingHeartbeat = true
        Citizen.CreateThread(function()
            while PlayingHeartbeat do
                PlaySoundFrontend(audioName, audioRef, true)
                Citizen.Wait(1500) -- Waits between sound loops
            end
        end)
    end
end

function StopSoundLoop()
    -- Stops the heartbeat sound loop
    if PlayingHeartbeat then
        PlayingHeartbeat = false
    end
end
