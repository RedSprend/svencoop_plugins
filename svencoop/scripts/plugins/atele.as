// Description: Randomly teleport in aliens on a random player.

// TODO: (I will most likely not finish this plugin as I got bored of it)
// - prevent spawning the monster on (or too close) the player.
// - Trace a szLine from vecEnd downwards (vecEnd.z) to not let the alien spawn in mid air.

bool bInitialized = false;

uint iMinTime = 40; // in seconds
uint iMaxTime = 300; // in seconds

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );

	ATele::ClearTimer();

	if( g_PlayerFuncs.GetNumPlayers() >= 1 ) // if the plugin got reloaded
		ATele::StartTimer();
}

void MapInit()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "EnvPortal::env_portal", "env_portal" );
	g_Game.PrecacheOther( "env_portal" );

	for( uint i = 0; i < ATele::g_szMonsters.length(); i++ )
	{
		g_Game.PrecacheMonster( ATele::g_szMonsters[i], false );
		g_Game.PrecacheMonster( ATele::g_szMonsters[i], true );
	}

	g_Game.PrecacheMonster( "monster_leech", false );

	ATele::ClearTimer();
	bInitialized = false;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( bInitialized )
		return HOOK_CONTINUE;

	bInitialized = true;
	ATele::StartTimer();

	return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
	ATele::ClearTimer();
	return HOOK_CONTINUE;
}

namespace ATele
{
uint iMinTime = 40; // in seconds
uint iMaxTime = 300; // in seconds

CScheduledFunction@ g_pThink = null;

bool StartTimer()
{
	if( g_pThink is null )
	{
		if( !ExcludedMapList() )
		{
			@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", Math.RandomLong(iMinTime, iMaxTime) );
			return true;
		}
	}

	return false;
}

void ClearTimer()
{
	if( g_pThink !is null )
	{
		g_Scheduler.RemoveTimer( g_pThink );
		@g_pThink = null;
	}
}

array<string> g_szMonsters = 
{
	//"monster_alien_controller",
	//"monster_alien_grunt",
	"monster_alien_slave",
	"monster_headcrab",
	"monster_houndeye",
	"monster_snark",
	"monster_sqknest",
	"monster_zombie",
	"monster_zombie_barney",
	"monster_zombie_soldier"
};

CClientCommand g_sm( "at", "- toggle alien spawner", @cmdATele ); // .at in console to toggle the alien spawner

void cmdATele( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

	if( pPlayer is null || !pPlayer.IsConnected() )
		return;

	if( g_PlayerFuncs.AdminLevel(pPlayer) == ADMIN_NO )
	{
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "You have no access to this command.\n" );
		return;
	}

	if( ExcludedMapList() )
	{
		g_EngineFuncs.ClientPrintf( pPlayer, print_console, "[Alien Spawner] This map is black listed.\n" );
		return;
	}

	if( StartTimer() )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, "[Alien Spawner] Enabled alien spawner.\n" );

		float flTime = 1;
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, "[Alien Spawner] Next spawn in "+flTime+" second"+(string(flTime) > 1 ? "s" : "")+".\n" );

		if( g_pThink !is null )
		{
			g_Scheduler.RemoveTimer( g_pThink );
			@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", flTime );
		}
	}
	else
	{
		ClearTimer();

		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, "[Alien Spawner] Disabled alien spawner.\n" );
	}
}

void ATeleThink()
{
	int iPlayerIndex = GetRandomPlayer();

	if( iPlayerIndex == -1 )
	{
		if( g_pThink !is null )
		{
			g_Scheduler.RemoveTimer( g_pThink );
			@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", 2.0f );
		}
		return;
	}

	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );

	string szMonster = g_szMonsters[Math.RandomLong(0,g_szMonsters.length() - 1)];

	if( szMonster == "monster_alien_slave" )
	{
		bool bFound = false;
		for( uint i = 0; i < MAX_ITEM_TYPES; i++ )
		{
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.m_rgpPlayerItems(i) );

			while( pWeapon !is null )
			{
				if( pWeapon.m_iId >= WEAPON_GLOCK && pWeapon.m_iId <= WEAPON_DISPLACER )
				{
					if( pWeapon.m_iId == WEAPON_MEDKIT ||
						pWeapon.m_iId == WEAPON_PIPEWRENCH ||
						pWeapon.m_iId == WEAPON_GRAPPLE ||
						pWeapon.m_iId == WEAPON_HANDGRENADE ||
						pWeapon.m_iId == WEAPON_TRIPMINE ||
						pWeapon.m_iId == WEAPON_SATCHEL )
						break;

					if( (pWeapon.m_iClip == 0 && // gun clip is empty
						pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType) <= 0) ) // player do not have enough ammo for the gun
						break;

					bFound = true;
					break;
				}

				@pWeapon = cast<CBasePlayerWeapon@>( pWeapon.m_hNextItem.GetEntity() );
			}

			if( bFound )
				break;
		}

		if( !bFound ) // do not spawn alien slave if the player do not have any weapon to fight against it with.
		{
			if( g_pThink !is null )
			{
				g_Scheduler.RemoveTimer( g_pThink );
				@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", 0.1f ); //  Try again (TODO: pass the classname to prevent selecting alien slave over and over again)
			}
			return;
		}
	}

	if( pPlayer.pev.waterlevel > WATERLEVEL_DRY )
	{
		if( pPlayer.pev.waterlevel >= WATERLEVEL_WAIST ) // Spawn a leech instead if the player is under water
			szMonster = "monster_leech";
	}

	// TODO: keep some distance away from the player to prevent spawning the monster on (or too close) the player.
	Vector vecSrc = pPlayer.pev.origin;

	if( (pPlayer.pev.flags & FL_DUCKING) != 0 )
	{ // Player is ducking
		if( szMonster != "monster_headcrab" &&
			szMonster != "monster_snark" &&
			szMonster != "monster_sqknest" &&
			szMonster != "monster_leech" )
			vecSrc.z += 18;
	}

	Vector vecEnd = vecSrc + Vector(Math.RandomLong(-512,512), Math.RandomLong(-512,512), 0);
	float flDir = Math.RandomLong(-360,360);

	vecEnd = vecEnd + g_Engine.v_right * flDir;

	TraceResult tr;
	g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
	if( tr.flFraction >= 1.0 )
	{
		CheckFreeSpace( szMonster, vecEnd, pPlayer);
	}
	else
	{
		if( g_pThink !is null )
		{
			g_Scheduler.RemoveTimer( g_pThink );
			@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", 0.1f );
		}
	}
}

void CheckFreeSpace( const string& in szClassname, Vector& in vecOrigin, CBaseEntity@ pPlayer )
{
	TraceResult tr;
	HULL_NUMBER hullCheck = human_hull;

	// Large monsters
	if( szClassname == "monster_alien_voltigore" ||
		szClassname == "monster_babygarg" ||
		szClassname == "monster_bigmomma" ||
		szClassname == "monster_gargantua" )
		hullCheck = large_hull;
	// Small monsters
	else if( szClassname == "monster_babycrab" ||
		szClassname == "monster_headcrab" ||
		szClassname == "monster_snark" ||
		szClassname == "monster_sqknest" ||
		szClassname == "monster_stukabat" ||
		szClassname == "monster_leech" )
		hullCheck = head_hull;

	g_Utility.TraceHull( vecOrigin, vecOrigin, dont_ignore_monsters, hullCheck, pPlayer.edict(), tr );

	if( tr.fAllSolid == 1 || tr.fStartSolid == 1 || tr.fInOpen == 0 )
	{
		// Obstructed! Try again
		if( g_pThink !is null )
		{
			g_Scheduler.RemoveTimer( g_pThink );
			@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", 0.1f );
		}
		return;
	}
	else
	{
		// All clear! Spawn here

		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, null, true );
		if( pEntity !is null )
		{
			CBaseEntity@ cbePortal = g_EntityFuncs.CreateEntity( "env_portal", null,  false );
			EnvPortal::env_portal@ pPortal = cast<EnvPortal::env_portal@>(CastToScriptClass(cbePortal));
			g_EntityFuncs.SetOrigin( pPortal.self, vecOrigin );
			pPortal.szMonster = szClassname;
			pPortal.hPlayer = EHandle(pPlayer);
			pPortal.Spawn();

			float flTime = Math.RandomLong(iMinTime, iMaxTime) + 1;

			if( g_pThink !is null )
			{
				g_Scheduler.RemoveTimer( g_pThink );
				@g_pThink = g_Scheduler.SetTimeout( "ATeleThink", flTime );
			}

			for( int i = 1; i <= g_Engine.maxClients; i++ )
			{ // notify all admins
				CBasePlayer@ pAdmin = g_PlayerFuncs.FindPlayerByIndex( i );
				if( pAdmin is null || !pAdmin.IsConnected() || g_PlayerFuncs.AdminLevel(pAdmin) == ADMIN_NO )
					continue;

				g_PlayerFuncs.ClientPrint( pAdmin, HUD_PRINTNOTIFY, "(ADMINS) Spawned "+szClassname+" on "+pPlayer.pev.netname+" (next spawn in "+flTime+" second"+(string(flTime) > 1 ? "s" : "")+")\n" );
			}
		}

		return;
	}
}

bool ExcludedMapList()
{
	string szExcludedMapList = "scripts/plugins/store/ATele-Maplist.txt";
	File@ pFile = g_FileSystem.OpenFile( szExcludedMapList, OpenFile::READ );

	if( pFile is null || !pFile.IsOpen() )
	{
		g_EngineFuncs.ServerPrint("WARNING! Failed to open "+szExcludedMapList+"\n");
		return false;
	}

	string strMap = g_Engine.mapname;
	strMap.ToLowercase();

	string szLine;

	while( !pFile.EOFReached() )
	{
		pFile.ReadLine( szLine );
		szLine.Trim();

		if( szLine.Length() < 1 || szLine[0] == '/' && szLine[1] == '/' || szLine[0] == '#' || szLine[0] == ';' )
			continue;

		szLine.ToLowercase();

		if( strMap == szLine )
		{
			pFile.Close();
			return true;
		}

		if( szLine.EndsWith("*", String::CaseInsensitive) )
		{
			szLine = szLine.SubString(0, szLine.Length()-1);

			if( strMap.Find(szLine) != Math.SIZE_MAX )
			{
				pFile.Close();
				return true;
			}
		}
	}

	pFile.Close();

	return false;
}

int GetRandomPlayer() 
{
	int[] iPlayer(g_Engine.maxClients + 1);
	int iPlayerCount = 0;
	for( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
		if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || (pPlayer.pev.flags & FL_FROZEN) != 0 )
			continue;

		iPlayer[iPlayerCount] = i;
		iPlayerCount++;
	}
	return (iPlayerCount == 0) ? -1 : iPlayer[Math.RandomLong(0,iPlayerCount-1)];
}
}

namespace EnvPortal
{
class env_portal : ScriptBaseAnimating
{
	private EHandle m_hSpriteStart, m_hSpriteTele;
	private CSprite@ m_pSpriteStart
	{
		get const { return cast<CSprite@>( m_hSpriteStart.GetEntity() ); }
		set { m_hSpriteStart = EHandle( @value ); }
	};
	private CSprite@ m_pSpriteTele
	{
		get const { return cast<CSprite@>( m_hSpriteTele.GetEntity() ); }
		set { m_hSpriteTele = EHandle( @value ); }
	};

	EHandle hPlayer;
	string szMonster;
	private float flScale = 1.0;

	void Precache()
	{
		g_Game.PrecacheModel( "sprites/b-tele1.spr" );
		g_Game.PrecacheModel( "sprites/enter1.spr" );

		g_SoundSystem.PrecacheSound( "ambience/alien_cycletone.wav" );
		g_SoundSystem.PrecacheSound( "ambience/port_suckout1.wav" );
		g_SoundSystem.PrecacheSound( "debris/beamstart7.wav" );
	}

	void Spawn()
	{
		if( string(szMonster).IsEmpty() )
			return;

		if( szMonster == "monster_babycrab" ||
			szMonster == "monster_headcrab" ||
			szMonster == "monster_snark" ||
			szMonster == "monster_sqknest" ||
			szMonster == "monster_stukabat" ||
			szMonster == "monster_leech" )
		{
			flScale = 0.6; // scale down the sprites for small monsters
		}
		else
		{
			g_EntityFuncs.SetOrigin( self, self.pev.origin + Vector(0,0,16) );
		}

		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "ambience/port_suckout1.wav", 1.0f, ATTN_NORM );

		SetThink( ThinkFunction( this.StartThink ) );
		self.pev.nextthink = g_Engine.time + 1.0f;
	}

	void StartThink()
	{
		if( m_pSpriteStart !is null )
			g_EntityFuncs.Remove( m_pSpriteStart );

		@m_pSpriteStart = g_EntityFuncs.CreateSprite( "sprites/b-tele1.spr", self.pev.origin, true, 10 );
		m_pSpriteStart.TurnOn();
		m_pSpriteStart.pev.rendermode = kRenderTransAdd;
		m_pSpriteStart.pev.renderamt = 255;
		m_pSpriteStart.pev.scale = flScale;

		SetThink( ThinkFunction( this.TeleEffectsThink ) );
		self.pev.nextthink = g_Engine.time + 2.25f;
	}

	void TeleEffectsThink()
	{
		if( m_pSpriteStart !is null )
		{
			g_EntityFuncs.Remove( m_pSpriteStart );
			@m_pSpriteStart = null;
		}

		CreateTeleEffect();

		SetThink( ThinkFunction( this.StartKillSpriteThink ) );
		self.pev.nextthink = g_Engine.time + 3.0f;
	}

	void StartKillSpriteThink()
	{
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "ambience/port_suckout1.wav", 1.0f, ATTN_NORM );

		SetThink( ThinkFunction( this.KillSpriteThink ) );
		self.pev.nextthink = g_Engine.time + 3.0f;
	}

	void KillSpriteThink()
	{
		if( m_pSpriteTele !is null )
		{
			g_EntityFuncs.Remove( m_pSpriteTele );
			@m_pSpriteTele = null;
		}

		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "ambience/alien_cycletone.wav", 0, 0, SND_STOP, 100);
	}

	void CreateTeleEffect()
	{
		if( m_pSpriteTele !is null )
			g_EntityFuncs.Remove( m_pSpriteTele );

		@m_pSpriteTele = g_EntityFuncs.CreateSprite( "sprites/enter1.spr", self.pev.origin, true, 10 );
		m_pSpriteTele.TurnOn();
		m_pSpriteTele.pev.rendermode = kRenderTransAdd;
		m_pSpriteTele.pev.renderamt = 200;
		m_pSpriteTele.pev.scale = flScale;

		// light
		NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			msg.WriteByte( TE_DLIGHT );
			msg.WriteCoord( self.pev.origin.x );
			msg.WriteCoord( self.pev.origin.y );
			msg.WriteCoord( self.pev.origin.z );
			if( flScale <= 0.6 )
				msg.WriteByte( 10 ); // radius
			else
				msg.WriteByte( 16 ); // radius
			msg.WriteByte( 77 ); // red
			msg.WriteByte( 210 ); // green
			msg.WriteByte( 130 ); // blue
			msg.WriteByte( 60 ); // life
			msg.WriteByte( 0 ); // decay rate
		msg.End();

		// sound
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, "debris/beamstart7.wav", 1.0f, ATTN_NORM );
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "ambience/alien_cycletone.wav", 0.8f, ATTN_NORM, 0, 100 );

		// beam
		// TODO

		// monster
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szMonster, null, true );
		if( pEntity !is null )
		{
			g_EntityFuncs.SetOrigin( pEntity, self.pev.origin );

			if( pEntity.pev.health > 1 )
			{
				pEntity.pev.health /= 2; // spawn the monster with half of the original health
				pEntity.pev.max_health = pEntity.pev.health;
			}

			if( hPlayer.IsValid() )
			{
				Vector vecAngles = Math.VecToAngles( hPlayer.GetEntity().pev.origin - pEntity.pev.origin );
				pEntity.pev.angles.y = vecAngles.y;
			}
		}
	}
}
}