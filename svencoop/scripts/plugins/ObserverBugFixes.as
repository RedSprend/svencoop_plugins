/*
* Purpose:
* Fix for:
* 1) When a trigger_camera has ended, observers solid flag is set to SOLID_SLIDEBOX
* Observers are then able to block projectiles like Spore Launcher or Grapple tongue (abusive against other players)
* 2) Observers are able to trigger NPCs with SF_MONSTER_WAIT_TILL_SEEN flag set.
*/

CScheduledFunction@ g_pThink = null;

void ClearTimer()
{
	if( g_pThink !is null )
		g_Scheduler.RemoveTimer( g_pThink );
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );

	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

void MapInit()
{
	if( !g_SurvivalMode.MapSupportEnabled() )
		return;

	ClearTimer();
	@g_pThink = g_Scheduler.SetInterval( "CheckPlayers", 1.0f );
}

void CheckPlayers()
{
	CBasePlayer@ pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	   
		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;

		if( pPlayer.IsAlive() )
		{
			// Fix for monsters with SF_MONSTER_WAIT_TILL_SEEN flag
			if( pPlayer.pev.flags & FL_NOTARGET != 0 )
				pPlayer.pev.flags &= ~FL_NOTARGET;
		}
		else
		{
			// Fix for monsters with SF_MONSTER_WAIT_TILL_SEEN flag
			if( pPlayer.pev.flags & FL_NOTARGET == 0 )
				pPlayer.pev.flags |= FL_NOTARGET;

			// Observer solid bug fix
			if( pPlayer.pev.solid == SOLID_SLIDEBOX )
				pPlayer.pev.solid = SOLID_NOT;
		}
	}
}

HookReturnCode MapChange()
{
	ClearTimer();
	return HOOK_CONTINUE;
}