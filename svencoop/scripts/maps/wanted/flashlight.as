CScheduledFunction@ g_pFLThinkFunc 	= null;
dictionary 				g_PlayerFL;
const Vector 				FL_COLOR( 128, 128, 128 );
const int g_iRadius 			= 40;
const int iDecay 			= 1;
const int iLife				= 2;
const int iBrightness 			= 64;

class PlayerFLData
{
	Vector flColor;
}

flashlight g_Flashlight;

class flashlight
{
	CClientCommand flg( "nvg", "Toggles flashlight on/off", ClientCommandCallback( this.ToggleFL ) );

	void Precache()
	{
		g_SoundSystem.PrecacheSound( "wanted/items/flashlight1.wav" );
		g_Game.PrecacheGeneric( "sound/wanted/items/flashlight1.wav" );
	}

	void MapInit()
	{
		Precache();

		g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, ClientPutInServerHook( this.ClientPutInServer ) );
		g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, ClientDisconnectHook( this.ClientDisconnect ) );
		g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, PlayerKilledHook( this.PlayerKilled ) );
		g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, PlayerSpawnHook( this.PlayerSpawn ) );

		if( g_pFLThinkFunc !is null )
			g_Scheduler.RemoveTimer( g_pFLThinkFunc );

		@g_pFLThinkFunc = g_Scheduler.SetInterval( @this, "flThink", 0.1f );
	}

	void ToggleFL( const CCommand@ args )
	{
		CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

		//if( pPlayer.IsAlive() )
		{
			if( args.ArgC() == 1 )
			{
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

				if( g_PlayerFL.exists( szSteamId ) )
				{
					if( pPlayer.IsAlive() )
						removeFL( pPlayer );
					else
						removeFL( pPlayer, false );
				}
				else
				{
					if( pPlayer.IsAlive() && !pPlayer.HasSuit() )
						return;

					PlayerFLData data;
					data.flColor = Vector( 0, 255, 0 );
					g_PlayerFL[szSteamId] = data;

					if( pPlayer.IsAlive() )
						g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "wanted/items/flashlight1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
				}
			}
		}
	}

	void flMsg( CBasePlayer@ pPlayer, const string szSteamId )
	{
		PlayerFLData@ data = cast<PlayerFLData@>( g_PlayerFL[szSteamId] );

		Vector vecSrc = pPlayer.EyePosition();

		NetworkMessage flon( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
			flon.WriteByte( TE_DLIGHT );
			flon.WriteCoord( vecSrc.x );
			flon.WriteCoord( vecSrc.y );
			flon.WriteCoord( vecSrc.z );
			flon.WriteByte( g_iRadius );
			flon.WriteByte( int(FL_COLOR.x) );
			flon.WriteByte( int(FL_COLOR.y) );
			flon.WriteByte( int(FL_COLOR.z) );
			flon.WriteByte( iLife );
			flon.WriteByte( iDecay );
		flon.End();
	}

	void removeFL( CBasePlayer@ pPlayer, bool bSound = true )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( bSound )
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "wanted/items/flashlight1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );

		if( g_PlayerFL.exists( szSteamId ) )
			g_PlayerFL.delete( szSteamId );
	}

	HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerFL.exists( szSteamId ) )
			removeFL( pPlayer, false );

		return HOOK_CONTINUE;
	}

	HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerFL.exists( szSteamId ) )
			removeFL( pPlayer, false );

		return HOOK_CONTINUE;
	}

	HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerFL.exists( szSteamId ) )
			removeFL( pPlayer, false );

		return HOOK_CONTINUE;
	}

	HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerFL.exists( szSteamId ) )
			removeFL( pPlayer, false );

		return HOOK_CONTINUE;
	}

	void flThink()
	{
		for( int i = 1; i <= g_Engine.maxClients; ++i )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

			if( pPlayer !is null && pPlayer.IsConnected() )
			{
				string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

				if ( g_PlayerFL.exists( szSteamId ) )
					flMsg( pPlayer, szSteamId );
			}
		}
	}
}