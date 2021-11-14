/*
* 1. Prevent Observers are able to trigger NPCs with SF_MONSTER_WAIT_TILL_SEEN flag set.
* 2. Prevent Observers from making swim sounds.
*/

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );

	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
	if( pPlayer is null || !pPlayer.IsConnected() )
		return HOOK_CONTINUE;

	if( !pPlayer.IsAlive() )
	{
		pPlayer.pev.movetype = MOVETYPE_NOCLIP; // Prevent Observers from making swim sounds.

		if( pPlayer.pev.flags & FL_NOTARGET == 0 )
			pPlayer.pev.flags |= FL_NOTARGET; // Fix for monsters with SF_MONSTER_WAIT_TILL_SEEN flag
	}
	else
	{
		if( pPlayer.pev.flags & FL_NOTARGET != 0 )
			pPlayer.pev.flags &= ~FL_NOTARGET;
	}

	return HOOK_CONTINUE;
}