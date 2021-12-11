/* default_plugins.txt:
	"plugin"
	{
		"name" "Block3rdPersonView"
		"script" "block3rdperson"
		"concommandns" "3rd"
	}
*/

CCVar@ g_Disable;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );
	
	@g_Disable = CCVar( "disable", 0, "block 3rd person view", ConCommandFlag::AdminOnly );
}

void MapActivate()
{
	g_Scheduler.SetInterval( "Block3rdPersonLoop", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void Block3rdPersonLoop()
{
	CBasePlayer@ pPlayer = null;
	for( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;

		if( g_Disable.GetBool() )
			pPlayer.SetViewMode(ViewMode_FirstPerson); // Block 3rd person view
	}
}