// Description: Randomly teleport in aliens on a random player.
// Based on m_flCooldownTime and REQUIRED_PLAYER_COUNT

// TODO: (I will most likely not finish this plugin as I got bored of it)
// - prevent spawning the monster on (or too close) the player.
// - Trace a line from vecEnd downwards (vecEnd.z) to not let the alien spawn in mid air.
// - Use SetTimeout instead of SetInterval.

const bool debug = false;
const int REQUIRED_PLAYER_COUNT = 1;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

bool bInitialized = false;
CScheduledFunction@ g_pThink = null;
float m_flNextThink, m_flCooldownTime;

bool StartTimer()
{
	if( g_pThink is null )
	{
		ExcludedMapList();
		
		m_flNextThink = g_Engine.time + m_flCooldownTime;

		if( debug )
		{
			float flTime = m_flNextThink - g_Engine.time;
			g_EngineFuncs.ServerPrint("-- DEBUG: Next time: "+flTime+"\n");
		}

		@g_pThink = g_Scheduler.SetInterval( "Think", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
		
		return true;
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
	"monster_sqknest"
};

void MapInit()
{
	for( uint i = 0; i < g_szMonsters.length(); i++ )
	{
		g_Game.PrecacheMonster( g_szMonsters[i], false );
		g_Game.PrecacheMonster( g_szMonsters[i], true );
	}
	
	g_Game.PrecacheMonster( "monster_leech", false );

	ClearTimer();
}

void MapActivate()
{
	bInitialized = false;
	m_flNextThink = g_Engine.time;
	m_flCooldownTime = Math.RandomLong(60,600); // random delay between 1 min. to 10 min.
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( bInitialized )
	{
		if( g_PlayerFuncs.GetNumPlayers() == REQUIRED_PLAYER_COUNT )
			m_flCooldownTime = Math.RandomLong(60,600); // random delay between 1 min. to 10 min.

		return HOOK_CONTINUE;
	}

	bInitialized = true;
	StartTimer();

	return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
	ClearTimer();
	return HOOK_CONTINUE;
}

CClientCommand g_sm( "at", "- toggle alien spawner", @cmdATele );
void cmdATele( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	
	if( pPlayer is null || !pPlayer.IsConnected() )
		return;
		
	if( g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_OWNER )
		return;

	if( StartTimer() )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, "Enabled alien spawner.\n" );

		if( debug )
		{
			m_flNextThink = g_Engine.time + 1;
			float flTime = m_flNextThink - g_Engine.time;
			g_EngineFuncs.ServerPrint("-- DEBUG: Next time: "+flTime+"\n");
		}
	}
	else
	{
		ClearTimer();

		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, "Disabled alien spawner.\n" );
	}
}

void Think()
{
	if( m_flNextThink > g_Engine.time || !debug && g_PlayerFuncs.GetNumPlayers() < REQUIRED_PLAYER_COUNT )
		return;

	int iPlayerIndex = GetRandomPlayer();
	if( iPlayerIndex == -1)
		return;

	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayerIndex );

	string szMonster = g_szMonsters[Math.RandomLong(0,g_szMonsters.length() - 1)];
	
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
		m_flNextThink = g_Engine.time;
		return;
	}
	else
	{
		// All clear! Spawn here

		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, null, true );
		if( pEntity !is null )
		{
			CreateSpawnEffect( szClassname, vecOrigin, EHandle(pPlayer) );

			m_flNextThink = g_Engine.time + m_flCooldownTime;

			if( debug )
			{
				m_flNextThink = g_Engine.time + 1;
				float flTime = m_flNextThink - g_Engine.time;
				g_EngineFuncs.ServerPrint("-- DEBUG: Next time: "+flTime+"\n");
			}

			for( int i = 1; i <= g_Engine.maxClients; i++ )
			{ // notify all admins
				CBasePlayer@ pAdmin = g_PlayerFuncs.FindPlayerByIndex( i );
				if( pAdmin is null || !pAdmin.IsConnected() || g_PlayerFuncs.AdminLevel(pAdmin) == ADMIN_NO )
					continue;

				g_PlayerFuncs.ClientPrint( pAdmin, HUD_PRINTNOTIFY, "(ADMINS) Spawned "+szClassname+" on "+pPlayer.pev.netname+"\n" );
			}
		}

		return;
	}
}

void CreateSpawnEffect( const string& in szClassname, Vector& in vecOrigin, EHandle hPlayer )
{
	if( !hPlayer.IsValid() )
		return;

	int iBeamCount = 8;
	Vector vBeamColor = Vector(30, 150, 50);//Vector(217,226,146);
	int iBeamAlpha = 128;
	float flBeamRadius = 256;

	Vector vLightColor = Vector(39,209,137);
	float flLightRadius = 160;

	Vector vStartSpriteColor = Vector(65,209,61);
	float flStartSpriteScale = 1.0f;
	float flStartSpriteFramerate = 12;
	int iStartSpriteAlpha = 255;

	Vector vEndSpriteColor = Vector(159,240,214);
	float flEndSpriteScale = 1.0f;
	float flEndSpriteFramerate = 12;
	int iEndSpriteAlpha = 255;

	// create the clientside effect
	NetworkMessage msg( MSG_PVS, NetworkMessages::TE_CUSTOM, vecOrigin );
		msg.WriteByte( 2 );
		msg.WriteVector( vecOrigin );
		// for the beams
		msg.WriteByte( iBeamCount );
		msg.WriteVector( vBeamColor );
		msg.WriteByte( iBeamAlpha );
		msg.WriteCoord( flBeamRadius );
		// for the dlight
		msg.WriteVector( vLightColor );
		msg.WriteCoord( flLightRadius );
		// for the sprites
		msg.WriteVector( vStartSpriteColor );
		msg.WriteByte( int( flStartSpriteScale*10 ) );
		msg.WriteByte( int( flStartSpriteFramerate ) );
		msg.WriteByte( iStartSpriteAlpha );

		msg.WriteVector( vEndSpriteColor );
		msg.WriteByte( int( flEndSpriteScale*10 ) );
		msg.WriteByte( int( flEndSpriteFramerate ) );
		msg.WriteByte( iEndSpriteAlpha );
	msg.End();
	
	g_Scheduler.SetTimeout( "SpawnMonster", 0.8f, szClassname, vecOrigin, hPlayer );
}

void SpawnMonster( const string& in szClassname, Vector& in vecOrigin, EHandle hPlayer )
{
	if( !hPlayer.IsValid() )
		return;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
	if( pPlayer is null )
		return;

	CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, null, true );
	if( pEntity !is null )
	{
		g_EntityFuncs.SetOrigin( pEntity, vecOrigin );
		Vector vecAngles = Math.VecToAngles( pPlayer.pev.origin - pEntity.pev.origin );
		pEntity.pev.angles.y = vecAngles.y;
	}
}

void ExcludedMapList()
{
	string szExcludedMapList = "scripts/plugins/store/ATele-Maplist.txt";
	File@ pFile = g_FileSystem.OpenFile( szExcludedMapList, OpenFile::READ );

	if( pFile is null || !pFile.IsOpen() )
	{
		g_EngineFuncs.ServerPrint("WARNING! Failed to open "+szExcludedMapList+"\n");
		return;
	}

	string strMap = g_Engine.mapname;
	strMap.ToLowercase();

	string line;

	while( !pFile.EOFReached() )
	{
		pFile.ReadLine( line );

		if( line.Length() < 1 || line[0] == '/' && line[1] == '/' || line[0] == '#' || line[0] == ';' )
			continue;

		line.ToLowercase();

		if( line.EndsWith("*") )
			return;

		if( strMap == line )
			return;
	}

	pFile.Close();
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