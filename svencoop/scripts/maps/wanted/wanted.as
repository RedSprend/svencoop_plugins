/*
* This script implements HLSP survival mode
*/

// TO-DO:
// - (NOT POSSIBLE ATM!) Flashlight identical to the original mod
// - Giving custom ammo through maps/<mapname>_.cfg aren't working

#include "point_checkpoint"
#include "../HLSPClassicMode"

#include "weapons/baseweapon"

#include "weapons/weapon_knife"
#include "weapons/weapon_pick"
#include "weapons/weapon_pistol"
#include "weapons/weapon_colts"
#include "weapons/weapon_shotgun"
#include "weapons/weapon_winchester"
#include "weapons/weapon_bow"
#include "weapons/weapon_dynamite"
#include "weapons/weapon_gattlinggun"
#include "weapons/weapon_cannon"
#include "weapons/weapon_buffalo"
#include "weapons/weapon_beartrap"
#include "weapons/weapon_scorpion"

#include "monsters/basemonster"

#include "monsters/monster_annie"
#include "monsters/monster_bear"
#include "monsters/monster_bigminer"
#include "monsters/monster_chicken"
#include "monsters/monster_cowboy"
#include "monsters/monster_crispen"
#include "monsters/monster_dyndave"
#include "monsters/monster_eagle" // Precache
#include "monsters/monster_horse"
#include "monsters/monster_hoss"
#include "monsters/monster_kaiewi" // Precache
#include "monsters/monster_masala"
#include "monsters/monster_mexbandit"
#include "monsters/monster_nagatow"
#include "monsters/monster_puma"
#include "monsters/monster_smallminer"
#include "monsters/monster_snake"
#include "monsters/monster_tied_colonel"
#include "monsters/monster_townmex"
#include "monsters/monster_townwes"

#include "items/item_elixer"
#include "items/item_herbs"

#include "flashlight"
#include "entity_manipulation"

array<ItemMapping@> g_ItemMappings = {
	ItemMapping( "weapon_crossbow", HLWanted_Bow::GetBowName() ),
	ItemMapping( "weapon_9mmhandgun", HLWanted_Pistol::GetPistolName() ),
	ItemMapping( "weapon_9mmAR", HLWanted_Pistol::GetPistolName() ),
	ItemMapping( "weapon_m16", HLWanted_Pistol::GetPistolName() ),
	ItemMapping( "weapon_shotgun", HLWanted_Shotgun::GetShotgunName() ),
	ItemMapping( "weapon_handgrenade", HLWanted_Dynamite::GetDynamiteName() ),
	ItemMapping( "weapon_pickaxe", HLWanted_PickAxe::GetPickName() ),
	ItemMapping( "weapon_saw", HLWanted_Gattlinggun::GetGattlinggunName() ),
	ItemMapping( "ammo_9mmclip", HLWanted_Pistol::GetPistolAmmoName() ),
	ItemMapping( "ammo_crossbow", HLWanted_Bow::GetBowAmmoName() ),
	ItemMapping( "ammo_rpgclip", HLWanted_Cannon::GetCannonAmmoName() )
};

array<string> g_PlayerModels =
{
	"wnt_annie",
	"wnt_bandit_mex",
	"wnt_bear",
	"wnt_colonel",
	"wnt_cowboy",
	"wnt_crispen",
	"wnt_dyndave",
	"wnt_hoss",
	"wnt_kaiewi",
	"wnt_masala",
	"wnt_miner",
	"wnt_nagatow",
	"wnt_ramone",
	"wnt_rogan",
	"wnt_townmex",
	"wnt_twnwest"
};

array<string> g_PrecacheSounds =
{
	"wanted/items/smallmedkit1.wav",
	"wanted/items/suitchargeok1.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/w_gattlinggun_belt.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/w_gattlinggun_beltT.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_medkit.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/w_medkitt.mdl" );
	g_Game.PrecacheModel( "models/wanted/feathers.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/feathersT.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_battery.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/w_batteryT.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_shotbox.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/w_shotboxt.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_suit.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/w_suitt.mdl" );

	for( uint uiIndex = 0; uiIndex < g_PrecacheSounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_PrecacheSounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_PrecacheSounds[uiIndex] ); // client has to download
	}

	// Server will crash if precaching everything at once.
	// Workaround: Separate each precache() for each map the NPC is used in

	if( g_Engine.mapname == "want3" ||
		g_Engine.mapname == "want4" ||
		g_Engine.mapname == "want5" ||
		g_Engine.mapname == "want7" ||
		g_Engine.mapname == "want13" ||
		g_Engine.mapname == "want14" ||
		g_Engine.mapname == "want15" ||
		g_Engine.mapname == "want20" ||
		g_Engine.mapname == "want21" ||
		g_Engine.mapname == "want25b" )
	{
		HLWanted_Eagle::Precache();
	}

	// Player models
	for( uint uiIndex = 0; uiIndex < g_PlayerModels.length(); ++uiIndex )
	{
		g_Game.PrecacheModel( "models/player/" + g_PlayerModels[uiIndex] + "/" + g_PlayerModels[uiIndex] + ".mdl" );
		g_Game.PrecacheGeneric( "models/player/" + g_PlayerModels[uiIndex] + "/" + g_PlayerModels[uiIndex] + ".bmp" );
	}
}

HUDTextParams h_Parameters; // Temporarily!!

void MapInit()
{
	Precache();

	RegisterPointCheckPointEntity();

	HLWanted_Knife::Register();
	HLWanted_PickAxe::Register();
	HLWanted_Pistol::Register();
	HLWanted_Colts::Register();
	HLWanted_Shotgun::Register();
	HLWanted_Winchester::Register();
	HLWanted_Bow::Register();
	HLWanted_Dynamite::Register();
	HLWanted_Gattlinggun::Register();
	HLWanted_Cannon::Register();
	HLWanted_Buffalo::Register();
	HLWanted_Beartrap::Register();
	HLWanted_Scorpion::Register();

	CTalkMonster talkmonster();
	@g_TalkMonster = @talkmonster;

	HLWanted_Annie::Register();
	HLWanted_Bear::Register();
	HLWanted_BigMiner::Register();
	HLWanted_Cowboy::Register();
	HLWanted_Crispen::Register();
	HLWanted_DynDave::Register();
	HLWanted_Chicken::Register();
	HLWanted_Horse::Register();
	HLWanted_Hoss::Register();
	HLWanted_Kaiewi::Register();
	HLWanted_Puma::Register();
	HLWanted_SmallMiner::Register();
	HLWanted_Snake::Register();
	HLWanted_Masala::Register();
	HLWanted_MexBandit::Register();
	HLWanted_Nagatow::Register();
	HLWanted_ColonelTied::Register();
	HLWanted_TownMex::Register();
	HLWanted_TownWes::Register();

	HLWanted_Elixer::Register();
	HLWanted_Herbs::Register();

	g_Flashlight.MapInit();

	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	ClassicModeMapInit();

	// Initialize classic mode (item mapping only)
	g_ClassicMode.SetItemMappings( @g_ItemMappings );
	g_ClassicMode.ForceItemRemap( true );

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
}

void InitObserver()
{
	g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1 ); 
	g_EngineFuncs.CVarSetFloat( "mp_observer_cyclic", 0 );
}

void OverrideMapCFG()
{
	g_EngineFuncs.CVarSetFloat( "mp_banana", 0 );
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