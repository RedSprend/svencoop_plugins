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

	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );

	@g_Disable = CCVar( "disable", 1, "block 3rd person view", ConCommandFlag::AdminOnly );
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
	if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
		return HOOK_CONTINUE;

	if( g_Disable.GetBool() )
		pPlayer.SetViewMode(ViewMode_FirstPerson); // Block 3rd person view

	return HOOK_CONTINUE;
}