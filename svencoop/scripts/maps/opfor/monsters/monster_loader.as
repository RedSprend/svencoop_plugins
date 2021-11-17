// No need to use this script.
// monster_loader already exist in the base of the game.

class COFLoader : ScriptBaseMonsterEntity
{
	int Classify() { return CLASS_NONE; }

	int ISoundMask() { return bits_SOUND_NONE; }

	void Precache()
	{
		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( "models/loader.mdl" );
		else
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound( "ambience/loader_step1.wav" );
		g_SoundSystem.PrecacheSound( "ambience/loader_hydra1.wav" );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/loader.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );

		if( self.pev.model == "models/player.mdl"
			|| self.pev.model == "models/holo.mdl" )
		{
			g_EntityFuncs.SetSize( self.pev, VEC_HULL_MIN, VEC_HULL_MAX );
		}
		else
		{
			g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );
		}

		self.pev.solid = SOLID_SLIDEBOX;
		self.pev.movetype = MOVETYPE_STEP;
		self.m_bloodColor = DONT_BLEED;
		self.pev.health = 8;
		self.m_MonsterState = MONSTERSTATE_NONE;
		self.m_flFieldOfView = 0.5f;
		self.pev.takedamage = DAMAGE_NO;
		
		self.MonsterInit();
	}

	void SetYawSpeed()
	{
		self.pev.yaw_speed = 90;
	}

	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		//Don't take damage
		return 1;
	}

	void TraceAttack( entvars_t@ pevAttacker, float flDamage, Vector vecDir, TraceResult ptr, int bitsDamageType )
	{
		g_Utility.Ricochet( ptr.vecEndPos, Math.RandomFloat( 1.0, 2.0 ) );
	}

	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		BaseClass.HandleAnimEvent( pEvent );
	}

	void StartTask( Task@ pTask )
	{
		float newYawAngle;

		switch( pTask.iTask )
		{
		case TASK_TURN_LEFT:
				newYawAngle = Math.AngleMod( self.pev.angles.y ) + pTask.flData;
				break;

		case TASK_TURN_RIGHT:
			newYawAngle = Math.AngleMod( self.pev.angles.y ) - pTask.flData;
			break;

		default:
			BaseClass.StartTask( pTask );
			return;
		}

		self.pev.ideal_yaw = Math.AngleMod( newYawAngle );

		SetTurnActivity();
	}

	void SetTurnActivity()
	{
		float difference = self.FlYawDiff();

		if( difference <= -45 && self.LookupActivity( ACT_TURN_RIGHT ) != -1 )
		{
			self.m_IdealActivity = ACT_TURN_RIGHT;
		}
		else if( difference > 45.0 && self.LookupActivity( ACT_TURN_LEFT ) != -1 )
		{
			self.m_IdealActivity = ACT_TURN_LEFT;
		}
	}
}

void RegisterLoader()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "COFLoader", "monster_loader" );
}