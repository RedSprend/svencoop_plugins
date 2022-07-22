/*
* Add to main map script:
*
* #include "trigger_playerfreeze"
*
* Under MapInit(), add:
*
* TriggerPlayerFreeze::Register();
*/

namespace TriggerPlayerFreeze
{
enum spawnflags
{
	SF_INVIS = 1 << 0
};

class trigger_playerfreeze : ScriptBaseEntity
{
	private bool m_bUnFrozen;

	void Spawn()
	{
		self.pev.movetype 	= MOVETYPE_NONE;
		self.pev.solid 		= SOLID_NOT;
		self.pev.effects	|= EF_NODRAW;

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		m_bUnFrozen = true;
	}

	void FreezeThink()
	{
		self.pev.nextthink = g_Engine.time + 0.1;

		CBasePlayer@ pPlayer = null;
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			if( pPlayer.IsAlive() )
			{
				if( self.pev.SpawnFlagBitSet( SF_INVIS ) && (pPlayer.pev.effects & EF_NODRAW) == 0 )
					pPlayer.pev.effects |= EF_NODRAW;

				pPlayer.EnableControl( m_bUnFrozen );
			}
			else
			{
				pPlayer.EnableControl( !m_bUnFrozen );
			}
		}
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		m_bUnFrozen = !m_bUnFrozen;

		switch( useType )
		{
			case USE_OFF:
			{
				SetThink( null );
				m_bUnFrozen = true;

				CBasePlayer@ pPlayer = null;
				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
				{
					@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

					if( pPlayer is null || !pPlayer.IsConnected() )
						continue;

					if( pPlayer.IsAlive() )
					{
						if( self.pev.SpawnFlagBitSet( SF_INVIS ) && (pPlayer.pev.effects & EF_NODRAW) != 0 )
							pPlayer.pev.effects &= ~EF_NODRAW;

						pPlayer.EnableControl( m_bUnFrozen );
					}
				}
			}
			break;
			case USE_ON:
			{
				m_bUnFrozen = false;

				SetThink( ThinkFunction(FreezeThink) );
				self.pev.nextthink = g_Engine.time + 0.1;
			}
			break;
			case USE_TOGGLE: self.Use( self, self, m_bUnFrozen ? USE_OFF : USE_ON, 0 ); break;
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "TriggerPlayerFreeze::trigger_playerfreeze", "trigger_playerfreeze" );
}
}