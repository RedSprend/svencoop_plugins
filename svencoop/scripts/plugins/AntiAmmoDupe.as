// Prevent players from dropping weapons/ammo (aka ammo duplication) on maps that support Survival Mode until Survival Mode is activated.

CScheduledFunction@ m_pCheckSurvivalStatus = null;
bool bInitialized = false;

void ClearTimer()
{
	if( m_pCheckSurvivalStatus !is null )
	{
		g_Scheduler.RemoveTimer( m_pCheckSurvivalStatus );
		@m_pCheckSurvivalStatus = null;
	}
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );

	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

void MapActivate()
{
	bInitialized = false;
}

HookReturnCode MapChange()
{
	ClearTimer();
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( !g_SurvivalMode.MapSupportEnabled() || g_SurvivalMode.IsActive() || bInitialized )
		return HOOK_CONTINUE;

	bInitialized = true;

	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );

	if( m_pCheckSurvivalStatus is null )
		@m_pCheckSurvivalStatus = g_Scheduler.SetInterval( "CheckSurvivalUntilActive", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );

	return HOOK_CONTINUE;
}

void CheckSurvivalUntilActive()
{
	if( !g_SurvivalMode.IsActive() )
		return;

	ClearTimer();

	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 1 );
}