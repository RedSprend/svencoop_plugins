bool bConcussAll = false;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );

	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
}

CClientCommand g_concuss( "concussall", "- concuss all", @cmdConcuss );

void MapStart()
{
	bConcussAll = false;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	if( pPlayer is null )
		return HOOK_CONTINUE;

	g_Scheduler.SetTimeout( "DelayedPlayerSpawn", 0.5f, EHandle(pPlayer) );

	return HOOK_CONTINUE;
}

void DelayedPlayerSpawn( EHandle hPlayer )
{
	if( !hPlayer.IsValid() )
		return;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());

	if( pPlayer is null )
		return;

	if( bConcussAll )
	{
		g_PlayerFuncs.ConcussionEffect( pPlayer, 50, 0.8, 5 );
	}
}

void cmdConcuss( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

	if( pPlayer is null || !pPlayer.IsConnected() )
		return;

	if( g_PlayerFuncs.AdminLevel(pPlayer) == ADMIN_NO )
		return;

	if( !bConcussAll )
		bConcussAll = true;
	else
		bConcussAll = false;

	@pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null || !pPlayer.IsConnected() )
			return;

		if( bConcussAll )
			g_PlayerFuncs.ConcussionEffect( pPlayer, 50, 0.8, 5 );
		else
			g_PlayerFuncs.ConcussionEffect( pPlayer, 0, 1, 3 );
	}
}