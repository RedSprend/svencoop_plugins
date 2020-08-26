CScheduledFunction@ g_pNVThinkFunc 	= null;
dictionary 				g_PlayerNV;
const Vector 				NV_COLOR( 180, 0, 0 );
const int g_iRadius 			= 40;
const int iDecay 			= 1;
const int iLife				= 2;
const int iBrightness 			= 16;

class PlayerNVData
{
	Vector nvColor;
}

nightvision g_Nightvision;

class nightvision
{
	CClientCommand nvg( "nvg", "Toggles night vision on/off", ClientCommandCallback( this.ToggleNV ) );

	void Precache()
	{
		g_SoundSystem.PrecacheSound( "aslave/slv_word8.wav" );
	}

	void MapInit()
	{
		Precache();

		g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, ClientPutInServerHook( this.ClientPutInServer ) );
		g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, ClientDisconnectHook( this.ClientDisconnect ) );
		g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, PlayerKilledHook( this.PlayerKilled ) );
		g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, PlayerSpawnHook( this.PlayerSpawn ) );

		if( g_pNVThinkFunc !is null )
			g_Scheduler.RemoveTimer( g_pNVThinkFunc );

		@g_pNVThinkFunc = g_Scheduler.SetInterval( @this, "nvThink", 0.1f );
	}

	void ToggleNV( const CCommand@ args )
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

		//if( pPlayer.IsAlive() )
		{
			if( args.ArgC() == 1 )
			{
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

				if( g_PlayerNV.exists( szSteamId ) )
				{
					if( pPlayer.IsAlive() )
						removeNV( pPlayer );
					else
						removeNV( pPlayer, false );
				}
				else
				{
					if( pPlayer.IsAlive() && !pPlayer.HasSuit() )
						return;

					PlayerNVData data;
					data.nvColor = Vector( 0, 255, 0 );
					g_PlayerNV[szSteamId] = data;
					g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, 0.01, 0.5, iBrightness, FFADE_OUT | FFADE_STAYOUT );

					if( pPlayer.IsAlive() )
						g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "aslave/slv_word8.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
				}
			}
		}
	}

	void nvMsg( CBasePlayer@ pPlayer, const string szSteamId )
	{
		PlayerNVData@ data = cast<PlayerNVData@>( g_PlayerNV[szSteamId] );

		Vector vecSrc = pPlayer.EyePosition();

		NetworkMessage nvon( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
			nvon.WriteByte( TE_DLIGHT );
			nvon.WriteCoord( vecSrc.x );
			nvon.WriteCoord( vecSrc.y );
			nvon.WriteCoord( vecSrc.z );
			nvon.WriteByte( g_iRadius );
			nvon.WriteByte( int(NV_COLOR.x) );
			nvon.WriteByte( int(NV_COLOR.y) );
			nvon.WriteByte( int(NV_COLOR.z) );
			nvon.WriteByte( iLife );
			nvon.WriteByte( iDecay );
		nvon.End();
	}

	void removeNV( CBasePlayer@ pPlayer, bool bSound = true )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, 0.01, 0.1, iBrightness, FFADE_IN );

		if( bSound )
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "aslave/slv_word8.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );

		if( g_PlayerNV.exists( szSteamId ) )
			g_PlayerNV.delete( szSteamId );
	}

	HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerNV.exists( szSteamId ) )
			removeNV( pPlayer, false );

		return HOOK_CONTINUE;
	}

	HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerNV.exists( szSteamId ) )
			removeNV( pPlayer, false );

		return HOOK_CONTINUE;
	}

	HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerNV.exists( szSteamId ) )
			removeNV( pPlayer, false );

		return HOOK_CONTINUE;
	}

	HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerNV.exists( szSteamId ) )
			removeNV( pPlayer, false );

		return HOOK_CONTINUE;
	}

	void nvThink()
	{
		for( int i = 1; i <= g_Engine.maxClients; ++i )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

			if( pPlayer !is null && pPlayer.IsConnected() )
			{
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

				if ( g_PlayerNV.exists( szSteamId ) )
					nvMsg( pPlayer, szSteamId );
			}
		}
	}
}