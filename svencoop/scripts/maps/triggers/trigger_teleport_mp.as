// Suggestion(s):
// - Allow monsters?
//	+ With the option to "ignore clients"

class trigger_teleport_mp : ScriptBaseEntity
{
	private float m_flDelay = 0.0f;
	private string p_master = "";

	dictionary lastTouches;

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "minhullsize" )
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		}
		else if( szKey == "maxhullsize" )
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else if( szKey == "delay" )
		{
			m_flDelay = atof( szValue );
			return true;
		}
		else if( szKey == "master" )
		{
			p_master = szValue;
			return true;
		}

		return BaseClass.KeyValue( szKey, szValue );
	}

	void Spawn()
	{
		self.pev.movetype 	= MOVETYPE_NONE;
		self.pev.solid 		= SOLID_NOT;
		self.pev.framerate 	= 1.0f;

		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );

		self.pev.nextthink 	= g_Engine.time + 0.1f;
	}

	void Think()
	{
		if( p_master == "" || g_EntityFuncs.IsMasterTriggered(p_master, null) )
		{
			CBasePlayer@ pPlayer;
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
			{
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;

				bool a = true;
				a = a && pPlayer.pev.origin.x + pPlayer.pev.maxs.x >= self.pev.origin.x + self.pev.mins.x;
				a = a && pPlayer.pev.origin.y + pPlayer.pev.maxs.y >= self.pev.origin.y + self.pev.mins.y;
				a = a && pPlayer.pev.origin.z + pPlayer.pev.maxs.z >= self.pev.origin.z + self.pev.mins.z;
				a = a && pPlayer.pev.origin.x + pPlayer.pev.mins.x <= self.pev.origin.x + self.pev.maxs.x;
				a = a && pPlayer.pev.origin.y + pPlayer.pev.mins.y <= self.pev.origin.y + self.pev.maxs.y;
				a = a && pPlayer.pev.origin.z + pPlayer.pev.mins.z <= self.pev.origin.z + self.pev.maxs.z;

				if( a )
				{
					TeleportTouch( pPlayer );
				}
			}
		}

		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void TeleportTouch( CBaseEntity@ pOther )
	{
		if( !pOther.IsPlayer() || !pOther.IsAlive() )
			return;

		float lastTouch = -1;
		if( lastTouches.exists( pOther.entindex() ) )
			lastTouches.get( pOther.entindex(), lastTouch );
		lastTouches[pOther.entindex()] = g_Engine.time;

		float diff = g_Engine.time - lastTouch;
		if( diff > m_flDelay )
		{
			Teleport( pOther );
		}
	}

	void Teleport( CBaseEntity@ pOther )
	{
		CBaseEntity@ pTarget = g_EntityFuncs.FindEntityByTargetname( null, pev.target );
		if( pTarget !is null )
		{
			Vector offset = pOther.IsPlayer() ? Vector(0,0,36) : Vector(0,0,0);
			Vector targetPos = pTarget.pev.origin + offset;
			Vector testPos = pTarget.pev.origin + Vector(0,0,36);

			g_EntityFuncs.SetOrigin( pOther, pTarget.pev.origin + offset );

			CBaseEntity@ pEnt = null;
			do {
				@pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, "trigger_teleport_mp" );
				if( pEnt !is null )
				{
					if( pEnt.Intersects( pOther ) )
					{
						// if pEnt will land inside another teleport trigger, then prevent it 
						// from teleporting without re-entering the brush
						trigger_teleport_mp@ pTele = cast<trigger_teleport_mp@>(CastToScriptClass(pEnt));
						pTele.lastTouches[pOther.entindex()] = g_Engine.time;
					}
				}
			} while ( pEnt !is null );

			g_EngineFuncs.MakeVectors( pTarget.pev.angles );

			pOther.pev.velocity = Vector(0,0,0);
			pOther.pev.angles = pTarget.pev.angles;
			pOther.pev.v_angle = pTarget.pev.angles;
			pOther.pev.fixangle = FAM_FORCEVIEWANGLES;
		}
	}
}

void RegisterTriggerTeleportMp()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_teleport_mp", "trigger_teleport_mp" );
}