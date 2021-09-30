bool bConcussAll = false;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );

	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

CClientCommand g_concuss( "concussall", "- concuss all", @cmdConcuss );

void MapStart()
{
	bConcussAll = false;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( bConcussAll )
	{
		g_PlayerFuncs.ConcussionEffect( pPlayer, 50, 0.8, 5 );
	}

	return HOOK_CONTINUE;
}

void cmdConcuss( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

	if ( pPlayer is null || !pPlayer.IsConnected() )
		return;

	if ( g_PlayerFuncs.AdminLevel(pPlayer) == ADMIN_NO )
		return;

	if( !bConcussAll )
		bConcussAll = true;
	else
		bConcussAll = false;

	@pPlayer = null;
	for ( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if ( pPlayer is null || !pPlayer.IsConnected() )
			return;

		if ( bConcussAll )
			g_PlayerFuncs.ConcussionEffect( pPlayer, 50, 0.8, 5 );
		else
			g_PlayerFuncs.ConcussionEffect( pPlayer, 0, 1, 3 );
	}
}