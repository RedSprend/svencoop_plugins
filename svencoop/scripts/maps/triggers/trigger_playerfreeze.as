// TO-DO:
// - I hate Think() loops, but all (re)spawn (& Revive()) functions aren't exposed >:(

trigger_playerfreeze g_TriggerPlayerFreeze;

class trigger_playerfreeze : ScriptBaseEntity
{
	CScheduledFunction@ g_pThink = null;
	string m_sMaster;
	bool g_bFreezePlayers = false;

	void MapInit()
	{
		g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, ClientPutInServerHook( this.ClientPutInServer ) );
	}

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if ( szKey == "master" )
		{
			m_sMaster = szValue;
			return true;
		}
		return BaseClass.KeyValue( szKey, szValue );
	}

	void Think()
	{
		CBasePlayer@ pPlayer;

		if( !g_bFreezePlayers )
		{
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
			{
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;

				pPlayer.SetMaxSpeed( int(g_EngineFuncs.CVarGetPointer( "sv_maxspeed" ).value) );
				//pPlayer.SetMaxSpeedOverride( -1.0f );
			}
			return;
		}

		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			if ( pPlayer.IsAlive() )
			{
				//pPlayer.SetMaxSpeedOverride( 0.0f );
				pPlayer.SetMaxSpeed( 0.0f );
			}
			else
			{
				//pPlayer.SetMaxSpeedOverride( -1.0f );
				pPlayer.SetMaxSpeed( int(g_EngineFuncs.CVarGetPointer( "sv_maxspeed" ).value) );
			}
		}

		g_Scheduler.SetTimeout( @this, "Think", 0.1 );
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( null, m_sMaster );
		if ( pEntity !is null )
		{
			if( !g_EntityFuncs.IsMasterTriggered( m_sMaster, pActivator ) )
				return;
		}

		switch( useType )
		{
			case USE_OFF:
			{
				g_bFreezePlayers = false;
				Think();
			}
			break;
			case USE_ON:
			{
				g_bFreezePlayers = true;
				Think();
			}
			break;
			case USE_TOGGLE: self.Use( null, null, g_bFreezePlayers ? USE_OFF : USE_ON, 0 ); break;
		}
	}

	HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
	{
		if ( g_bFreezePlayers )
		{
			if( pPlayer.IsAlive() )
			{
				//pPlayer.SetMaxSpeedOverride( 0.0f );
				pPlayer.SetMaxSpeed( 0.0f );
			}
			else
			{
				//pPlayer.SetMaxSpeedOverride( -1.0f );
				pPlayer.SetMaxSpeed( int(g_EngineFuncs.CVarGetPointer( "sv_maxspeed" ).value) );
			}
		}

		return HOOK_CONTINUE;
	}
}

void RegisterTriggerPlayerFreeze()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_playerfreeze", "trigger_playerfreeze" );
}