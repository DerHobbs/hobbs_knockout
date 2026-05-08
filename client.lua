local KNOCKOUT_HEALTH_THRESHOLD = 60
local RAGDOLL_DURATION          = 12000
local KNOCKOUT_RECOVERY_TIME    = 12
local HEALTH_REGEN_PER_TICK     = 5
local TICK_INTERVAL_KNOCKED_OUT = 1000
local TICK_INTERVAL_ACTIVE      = 500
local KNOCKOUT_COOLDOWN         = 300000 -- 5 Min
local knockedOut       = false
local heartbeatActive  = false
local knockoutCooldownUntil = 0

local function StartHeartbeat()
    if heartbeatActive then return end
    heartbeatActive = true

    CreateThread(function()
        while heartbeatActive do
            PlaySoundFrontend("Heartbeat", "RDRO_Sniper_Tension_Sounds", true)
            Citizen.Wait(1500)
        end
    end)
end

local function StopHeartbeat()
    heartbeatActive = false
end

local function EndKnockout()
    if not knockedOut then return end
    knockedOut = false
    knockoutCooldownUntil = GetGameTimer() + KNOCKOUT_COOLDOWN

    StopHeartbeat()
    SetPlayerInvincible(PlayerId(), false)
    Citizen.InvokeNative(0xB4FD7446BAB2F394, "DeathFailMP01")
    ResetPedRagdollTimer(PlayerPedId())
end

CreateThread(function()
    local recoveryTimer = KNOCKOUT_RECOVERY_TIME

    while true do
        local player = PlayerPedId()

        if not knockedOut then
            if GetGameTimer() > knockoutCooldownUntil
                and not IsEntityDead(player)
                and Citizen.InvokeNative(0x4E209B2C1EAD5159, player)
                and GetEntityHealth(player) < KNOCKOUT_HEALTH_THRESHOLD
            then
                knockedOut    = true
                recoveryTimer = KNOCKOUT_RECOVERY_TIME

                StartHeartbeat()
                TriggerEvent("vorp:Tip", "Du wurdest bewusstlos!", 5000)
                Citizen.InvokeNative(0xAE99FB955581844A, player, RAGDOLL_DURATION, RAGDOLL_DURATION, 0, false, false, false)
                Citizen.InvokeNative(0x4102732DF6B4005F, "DeathFailMP01")
                SetPlayerInvincible(PlayerId(), true)
            end

            Citizen.Wait(TICK_INTERVAL_ACTIVE)
        else
            Citizen.Wait(TICK_INTERVAL_KNOCKED_OUT)

            player = PlayerPedId()

            if IsEntityDead(player) then
                EndKnockout()
            elseif recoveryTimer > 0 then
                recoveryTimer = recoveryTimer - 1
                local currentHP = GetEntityHealth(player)
                if currentHP < KNOCKOUT_HEALTH_THRESHOLD then
                    local newHP = math.min(currentHP + HEALTH_REGEN_PER_TICK, KNOCKOUT_HEALTH_THRESHOLD)
                    SetEntityHealth(player, newHP)
                end
            else
                EndKnockout()
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() and knockedOut then
        EndKnockout()
    end
end)
