void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );

	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
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

bool GetLivingPlayers()
{
	bool bLivingPlayers = false;

	for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iIndex );

		if( pPlayer is null || pPlayer.Classify() != CLASS_PLAYER )
			continue;

		if( pPlayer.IsAlive() || pPlayer.GetObserver().HasCorpse() )
		{
			bLivingPlayers = true;
			break;
		}
	}

	return bLivingPlayers;
}

void CheckForLivingPlayers()
{
	@m_pCheckForLivingPlayersFunc = null;

	//Check again, players might have been revived by a monster
	if( !GetLivingPlayers() )
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

	if( !GetLivingPlayers() )
	{
		if( m_pCheckForLivingPlayersFunc is null )
			@m_pCheckForLivingPlayersFunc = g_Scheduler.SetTimeout( "CheckForLivingPlayers", 10.0f );
	}

	return HOOK_CONTINUE;
}