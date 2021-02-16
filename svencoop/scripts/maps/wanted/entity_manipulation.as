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

		iHealth = CalcNewHealth( int( pEntity.pev.health ), 500 );
	}
}

// Apply full health for every even player count and half on odd player count
int CalcNewHealth( int iBaseHealth, int iPerPlayerInc, bool bEvenOddNum = false )
{
	bool bSurvival = false;

	if( g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsActive() )
		bSurvival = true;

	int iNumPlayers = 0;
	int iCalcNewHealth = 0;

	CBasePlayer@ pPlayer = null;
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;

		if( bSurvival )
		{
			if( !pPlayer.IsAlive() )
				continue;
		}

		iNumPlayers++;

		if( iNumPlayers == 1 )
			continue;

		if( bEvenOddNum )
		{
			if( iNumPlayers % 2 == 0 )
			{ // even number
				iCalcNewHealth += iPerPlayerInc;
			}
			else
			{ // odd number
				iCalcNewHealth += iPerPlayerInc / 2;
			}
		}
		else
			iCalcNewHealth += iPerPlayerInc;
	}

	return iBaseHealth + iCalcNewHealth;
}