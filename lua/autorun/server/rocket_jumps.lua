-- Convars
local enabled = CreateConVar( "rocketjumps_enabled", 1, { FCVAR_ARCHIVE }, "Enables rocket jumping (1/0).", 0 ):GetBool()
cvars.AddChangeCallback( "rocketjumps_enabled", function( _, _, val )
    enabled = tobool( val )
end )

local scaleDamage = CreateConVar( "rocketjumps_dmgmult", 0.4, { FCVAR_ARCHIVE }, "The damage multiplier for self damaging explosions.", 0 ):GetFloat()
cvars.AddChangeCallback( "rocketjumps_dmgmult", function( _, _, val )
    scaleDamage = tonumber( val )
end )

local forceMult = CreateConVar( "rocketjumps_forcemult", 1, { FCVAR_ARCHIVE }, "The force multiplier for self damaging explosions.", 0 ):GetFloat()
cvars.AddChangeCallback( "rocketjumps_forcemult", function( _, _, val )
    forceMult = tonumber( val )
end )

local allExplosions = CreateConVar( "rocketjumps_allexplosions", 0, { FCVAR_ARCHIVE }, "Should the force multiplier be applied to all explosions instead of only self inflicted ones?.", 0 ):GetBool()
cvars.AddChangeCallback( "rocketjumps_allexplosions", function( _, _, val )
    allExplosions = tobool( val )
end )

local disableTinnitus = CreateConVar( "rocketjumps_disable_earringing", 1, { FCVAR_ARCHIVE }, "Should the ear ringing tinnitus effect be disabled?.", 0 ):GetBool()
cvars.AddChangeCallback( "rocketjumps_disable_earringing", function( _, _, val )
    disableTinnitus = tobool( val )
end )

local function reduceRocketDamage( ent, dmginfo )
    if not enabled then return end
    if not dmginfo:IsExplosionDamage() then return end
    if not ent:IsPlayer() then return end

    local attacker = dmginfo:GetAttacker()

    if not allExplosions and attacker ~= ent then return end

    local dmgForce = dmginfo:GetDamageForce()
    local newForce = dmgForce * forceMult
    dmginfo:SetDamageForce( newForce )

    if ent:KeyDown( IN_DUCK ) then
        ent:SetVelocity( newForce / 35 )
    else
        ent:SetVelocity( newForce / 70 )
    end

    local newScaleDamage = hook.Run( "EasyRocketJumps_ScaleDamage", ent, dmginfo )
    if newScaleDamage then
        scaleDamage = newScaleDamage
    end

    dmginfo:ScaleDamage( scaleDamage )
end

hook.Add( "EntityTakeDamage", "rocketjumpsEntityTakeDamage", reduceRocketDamage )

-- Remove tinnitus

hook.Add( "OnDamagedByExplosion", "DisableSound", function()
    if not disableTinnitus then return end
    return true
end )
