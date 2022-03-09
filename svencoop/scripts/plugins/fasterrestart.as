// The map will restart faster if there are no player friendly monster_scientist, monster_cleansuit_scientist, or monster_human_medic_ally in the map.

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );

	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

CScheduledFunction@ m_pCheckForLivingPlayersFunc = null;
const int SF_MONSTER_PRISONER = 16;

void ClearTimer()
{
	if( m_pCheckForLivingPlayersFunc !is null )
	{
		g_Scheduler.RemoveTimer( m_pCheckForLivingPlayersFunc );
		@m_pCheckForLivingPlayersFunc = null;
	}
}

void MapInit()
{
	ClearTimer();
}

HookReturnCode MapChange()
{
	ClearTimer();
	return HOOK_CONTINUE;
}

int GetLivingPlayersCount()
{
	int iLivingPlayers = 0;

	for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iIndex );

		if( pPlayer !is null && pPlayer.IsAlive() )
			++iLivingPlayers;
	}

	return iLivingPlayers;
}

void CheckForLivingPlayers()
{
	@m_pCheckForLivingPlayersFunc = null;

	//Check again, players might have been revived by a monster
	int iLivingPlayers = GetLivingPlayersCount();

	if( iLivingPlayers == 0 && !CheckEndConditions() )
	{
		g_EngineFuncs.ChangeLevel( g_Engine.mapname );
	}
	else
	{
		ClearTimer();
	}
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	if( !g_SurvivalMode.IsActive() )
		return HOOK_CONTINUE;

	if( !CheckEndConditions() )
	{
		if( m_pCheckForLivingPlayersFunc is null && GetLivingPlayersCount() == 0 )
			@m_pCheckForLivingPlayersFunc = g_Scheduler.SetTimeout( "CheckForLivingPlayers", 10.0f );
	}

	return HOOK_CONTINUE;
}

bool CheckEndConditions()
{
	CBaseEntity@ pEntity = null;
	bool bFound = false;
	while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "monster_*")) !is null )
	{
		if( pEntity.pev.deadflag != DEAD_NO || !pEntity.IsPlayerAlly() || pEntity.pev.SpawnFlagBitSet( SF_MONSTER_PRISONER ) )
			continue;
		if( pEntity.GetClassname() != "monster_scientist" && pEntity.GetClassname() != "monster_cleansuit_scientist" && pEntity.GetClassname() != "monster_human_medic_ally" )
			continue;

		bFound = true;
		break;
	}

	if( bFound )
		return true;

	return false;
}