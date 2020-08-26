/*
* This script implements HLSP survival mode
*/

// TO-DO:
// - Flashlight

#include "../point_checkpoint"
#include "../HLSPClassicMode"

#include "entity_manipulation"

#include "monsters/monster_hev_bluehelmet"
#include "monsters/monster_hev_orangehelmet"
#include "monsters/monster_hev_orangehelmet_xtbu"
#include "monsters/monster_hev_scientist"

#include "weapons/weapon_hornetgundual"
#include "weapons/weapon_stukabat"
#include "weapons/weapon_xenhands"

#include "nvg"

array<string> pIdleSounds = {
	"aslave/slv_word1.wav",
	"aslave/slv_word2.wav",
	"aslave/slv_word3.wav",
	"aslave/slv_word4.wav",
	"aslave/slv_word5.wav",
	"aslave/slv_word6.wav",
	"aslave/slv_word7.wav",
	"aslave/slv_word8.wav"
};

array<string> pPainSounds = {
	"aslave/slv_pain1.wav",
	"aslave/slv_pain2.wav"
};

array<string> pDeathSounds = {
	"aslave/slv_die1.wav",
	"aslave/slv_die2.wav"
};

CScheduledFunction@ g_pIdleSound = null;

void ClearTimer()
{
	if( g_pIdleSound !is null )
	{
		g_Scheduler.RemoveTimer( g_pIdleSound );
		@g_pIdleSound = null;
	}
}

void Precache()
{
	g_Game.PrecacheModel( "models/player/dm_slave/dm_slave.mdl" );

	g_Game.PrecacheModel( "models/hlclassic/pov/v_squeak.mdl" );

	for( uint uiIndex = 0; uiIndex < pIdleSounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( pIdleSounds[ uiIndex ] );
		g_Game.PrecacheGeneric( "sound/" + pIdleSounds[ uiIndex ] );
	}

	for( uint uiIndex = 0; uiIndex < pPainSounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( pPainSounds[ uiIndex ] );
		g_Game.PrecacheGeneric( "sound/" + pPainSounds[ uiIndex ] );
	}

	for( uint uiIndex = 0; uiIndex < pDeathSounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( pDeathSounds[ uiIndex ] );
		g_Game.PrecacheGeneric( "sound/" + pDeathSounds[ uiIndex ] );
	}

	for( uint uiIndex = 0; uiIndex < g_PrecacheSounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_PrecacheSounds[ uiIndex ] );
		g_Game.PrecacheGeneric( "sound/" + g_PrecacheSounds[ uiIndex ] );
	}
}

HUDTextParams h_Parameters; // Temporarily!!

void MapInit()
{
	Precache();

	RegisterPointCheckPointEntity();

	HEVBLUE::Register();
	HEVORANGE::Register();
	HEVORANGE_XTBU::Register();
	HEVSCIENTIST::Register();

	XENDHGun::Register();
	XENSTUKABAT::Register();
	XENHANDS::Register();

	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
	g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook( Hooks::PickupObject::CanCollect, @CanCollect );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );

	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	ClassicModeMapInit();

	g_Nightvision.MapInit();

	// Temporarily!!
	h_Parameters.x = 0.0; // X
	h_Parameters.y = 0.82; // Y

	h_Parameters.a1 = 0; // Opaque HUD?

	h_Parameters.r2 = 250; // White color for flashing
	h_Parameters.g2 = 250;
	h_Parameters.b2 = 250;
	h_Parameters.a2 = 1; // White flash should be opaque ?

	h_Parameters.fadeinTime = 0.0;
	h_Parameters.fadeoutTime = 0.0;
	h_Parameters.holdTime = 60.0;
	h_Parameters.fxTime = 0.0;

	// HACKHACK - Prevent HUD message from being overlapped by using mapper's game_text channels (Channels 5-8)
	h_Parameters.channel = 8;

	g_Scheduler.SetInterval( "NotifyPlayers", 2.0, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void MapActivate()
{
	InitObserver();
	OverrideMapCFG();
	ManipulateEntities();

	ClearTimer();
	@g_pIdleSound = g_Scheduler.SetInterval( "PlayerIdleSound", 3.0f );
}

void InitObserver()
{
	g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1 ); 
	g_EngineFuncs.CVarSetFloat( "mp_observer_cyclic", 0 );
}

void OverrideMapCFG()
{
	g_EngineFuncs.CVarSetFloat( "mp_weapon_respawndelay", -1 );
	g_EngineFuncs.CVarSetFloat( "mp_ammo_respawndelay", -1 );
	g_EngineFuncs.CVarSetFloat( "mp_item_respawndelay", -1 );
	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_weaponstay", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_suitpower", 0 );
	g_EngineFuncs.CVarSetFloat( "npc_dropweapons", 0 );
}

void EnableObserver(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if ( !g_SurvivalMode.IsActive() )
		InitObserver();

	if( pActivator is null || !pActivator.IsPlayer() )
		return;

	CBasePlayer@ player = cast<CBasePlayer@>( pActivator );

	player.GetObserver().StartObserver(player.pev.origin, Vector(), false);
}

void ActivateSurvival(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_SurvivalMode.Activate();
}

void DisableSurvival(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_SurvivalMode.Disable();
}

void PlayerIdleSound()
{
	CBasePlayer@ pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
			continue;
		if( ( pPlayer.pev.button & IN_ATTACK ) != 0 || ( pPlayer.pev.button & IN_ATTACK2 ) != 0 )
			continue;

		if( Math.RandomLong(0,99) <= 20 )
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0, pIdleSounds.length()-1)], 1.0, ATTN_NORM, 0, Math.RandomLong(85,110) );
	}
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
	if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
		return HOOK_CONTINUE;

	if( pPlayer.BloodColor() != BLOOD_COLOR_GREEN )
		pPlayer.m_bloodColor = BLOOD_COLOR_GREEN;

	return HOOK_CONTINUE;
}

HookReturnCode PlayerTakeDamage( DamageInfo@ info )
{
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pVictim.pev));
	entvars_t@ pevInflictor = info.pInflictor !is null ? info.pInflictor.pev : null;
	entvars_t@ pevAttacker = info.pAttacker !is null ? info.pAttacker.pev : null;

	if( info.pInflictor !is null and pPlayer !is null and pPlayer.IRelationship(info.pInflictor) <= R_NO || info.pAttacker is null )
		return HOOK_CONTINUE; // don't take damage from other players nor ally monsters

	if( Math.RandomLong(0,1) == 0 )
	{
		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_VOICE, pPainSounds[Math.RandomLong(0, pPainSounds.length()-1)], 1.0, ATTN_NORM, 0, Math.RandomLong(85,110) );
	}

	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	if( !((pPlayer.pev.health < -40 && iGib != GIB_NEVER) || iGib == GIB_ALWAYS) )
		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_VOICE, pDeathSounds[Math.RandomLong(0, pDeathSounds.length()-1)], 1.0, ATTN_NORM, 0, Math.RandomLong(85,110) );

	return HOOK_CONTINUE;
}

HookReturnCode CanCollect( CBaseEntity@ pPickup, CBaseEntity@ pOther, bool& out bResult )
{
	if( pPickup is null || pOther is null )
		return HOOK_CONTINUE;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

	if( pPlayer is null || !pPlayer.IsAlive() )
		return HOOK_CONTINUE;

	if( pPlayer !is null )
		return HOOK_HANDLED;

	return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
	ClearTimer();
	return HOOK_CONTINUE;
}

void NotifyPlayers()
{
	CBasePlayer@ pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer !is null && pPlayer.IsConnected() )
		{
			h_Parameters.r1 = 128;
			h_Parameters.g1 = 128;
			h_Parameters.b1 = 128;
			h_Parameters.effect = 0; // No effect

			string strMsg = "(!) ATTENTION:\nDue to lack of exposed classes, functions and data types for custom NPCs,\nthis project on hold until the Sven Co-op team expose more features.\n\nEnjoy the current state of it!";

			g_PlayerFuncs.HudMessage( pPlayer, h_Parameters, strMsg );
		}
	}
}