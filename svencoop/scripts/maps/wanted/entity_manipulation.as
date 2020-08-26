/*
* 	Map Script for "Wanted" campaign
*/

void ManipulateEntities( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	string m_sMap = g_Engine.mapname;

	// Increment Bear's health per player
	int iHealth;

	CBaseEntity@ pEntity = null;
	while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "monster_*")) !is null )
	{
		if( pEntity.pev.deadflag != DEAD_NO )
			continue;
		if( pEntity.pev.classname != "monster_bear" )
			continue;

		if( int(pEntity.pev.health) > 500 )
			pEntity.pev.health = 500;

		iHealth = CalcNewHealth( int( pEntity.pev.health ), 1000 );
	}
}

int CalcNewHealth( int iBaseHealth, int iPerPlayerInc )
{
	int iNumPlayers = 0;
	if( g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsActive() )
	{
		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			iNumPlayers++;
		}
	}
	else
	{
		iNumPlayers = g_PlayerFuncs.GetNumPlayers();
	}

	int iPlayerMul = Math.clamp( 0, 8, iNumPlayers );
	int iSkill = int( g_EngineFuncs.CVarGetFloat( "skill" ) );
	iSkill = Math.clamp( 1, 3, iSkill );

	int iRelBaseHealth = iBaseHealth + ( iBaseHealth / 3 ) * ( iSkill - 2 );
	int iRelPerPlayerInc = iPerPlayerInc + ( iPerPlayerInc / 3 ) * ( iSkill - 2 );
	return iRelBaseHealth + iRelPerPlayerInc * iPlayerMul;
}