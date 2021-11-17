/*
* 1. Prevent Observers are able to trigger NPCs with SF_MONSTER_WAIT_TILL_SEEN flag set.
* 2. Prevent Observers from making swim sounds.
*/

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );

	g_Hooks.RegisterHook( Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver );
	g_Hooks.RegisterHook( Hooks::Player::PlayerLeftObserver, @PlayerLeftObserver );
}

HookReturnCode PlayerEnteredObserver( CBasePlayer@ pPlayer )
{
	pPlayer.pev.movetype = MOVETYPE_NOCLIP; // Prevent Observers from making swim sounds.
	pPlayer.pev.flags |= FL_NOTARGET; // Fix for monsters with SF_MONSTER_WAIT_TILL_SEEN flag

	return HOOK_CONTINUE;
}

HookReturnCode PlayerLeftObserver( CBasePlayer@ pPlayer )
{
	pPlayer.pev.flags &= ~FL_NOTARGET; // Fix for monsters with SF_MONSTER_WAIT_TILL_SEEN flag

	return HOOK_CONTINUE;
}