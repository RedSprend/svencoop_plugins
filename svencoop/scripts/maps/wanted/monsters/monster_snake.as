// TO-DO:
// - On GibMonster() use snakegibs.mdl

namespace HLWanted_Snake
{
const int SNAKE_FLINCH_DELAY = 2;
const int SNAKE_HEALTH = 15;
const int SNAKE_BITE_DMG = 25;

const int SNAKE_AE_ATTACK_RIGHT = 0x01;

const int TASKSTATUS_RUNNING = 1;

const array<string> pAttackSounds = 
{
	"wanted/snake/snake_bite1.wav",
	"wanted/snake/snake_bite2.wav"
};

const array<string> pIdleSounds = 
{
	"wanted/snake/snake_idle1.wav",
	"wanted/snake/snake_idle2.wav"
};

const array<string> pPainSounds = 
{
	"wanted/snake/snake_pain1.wav",
	"wanted/snake/snake_pain2.wav"
};

class monster_snake : CBaseCustomMonster
{
	float m_flNextFlinch;

	void Spawn()
	{
		Precache();

		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, "models/wanted/snake.mdl" );

		//g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );
		g_EntityFuncs.SetSize( self.pev, Vector(-12, -12, 0), Vector(12, 12, 24) );

		self.pev.solid			= SOLID_SLIDEBOX;
		self.pev.movetype		= MOVETYPE_STEP;
		self.m_bloodColor		= BLOOD_COLOR_RED;
		self.pev.health			= SNAKE_HEALTH;
		self.pev.max_health		= SNAKE_HEALTH;
		self.m_flFieldOfView		= 0.2;// indicates the width of this monster's forward view cone ( as a dotproduct result )
		self.m_MonsterState		= MONSTERSTATE_NONE;
		self.m_afCapability		= bits_CAP_DOORS_GROUP;
		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Snake" );

		self.MonsterInit();

		self.pev.view_ofs		= Vector( 0, 0, 20 ); // position of the eyes relative to monster's origin.
	}

	void Precache()
	{
		uint i;

		if( string( self.pev.model ).IsEmpty() )

		{
			g_Game.PrecacheModel( "models/wanted/snake.mdl" );
			g_Game.PrecacheModel( "models/wanted/snakegibs.mdl" );
			g_Game.PrecacheModel( "models/wanted/snaket.mdl" );
		}

		for( i = 0; i < pAttackSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAttackSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAttackSounds[i] );
		}

		for( i = 0; i < pIdleSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pIdleSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pIdleSounds[i] );
		}

		for( i = 0; i < pPainSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pPainSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pPainSounds[i] );
		}

		g_SoundSystem.PrecacheSound( "common/bodysplat.wav" );
	}

	int IRelationship( CBaseEntity@ pTarget )
	{
		if( pTarget.pev.classname == "monster_chicken" )
		{
			return R_DL;
		}

		return self.IRelationship( pTarget );
	}

	//=========================================================
	// SetYawSpeed - allows each sequence to have a different
	// turn rate associated with it.
	//=========================================================
	void SetYawSpeed()
	{
		int ys = 120;
		self.pev.yaw_speed = ys;
	}

	int Classify()
	{
		return CLASS_ALIEN_MONSTER;
	}

	bool CheckMeleeAttack1( float flDot, float flDist )
	{
		if( flDist <= 70 && flDot >= 0.7 && self.m_hEnemy.GetEntity() !is null && self.pev.FlagBitSet( FL_ONGROUND ) )
		{
			return true;
		}
		return false;
	}

	bool CheckMeleeAttack2( float flDot, float flDist )
	{
		return false;
	}

	bool CheckRangeAttack1( float flDot, float flDist )
	{
		return false;
	}

	bool CheckRangeAttack2( float flDot, float flDist )
	{
		return false;
	}

	//=========================================================
	// HandleAnimEvent - catches the monster-specific messages
	// that occur when tagged animation frames are played.
	//=========================================================
	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		switch( pEvent.event )
		{
			case SNAKE_AE_ATTACK_RIGHT:
			{
				// do stuff for this event.
				CBaseEntity@ pHurt = CheckTraceHullAttack( self, 70, SNAKE_BITE_DMG, DMG_SLASH );
				if( pHurt !is null )
				{
					if( (pHurt.pev.flags & (FL_MONSTER|FL_CLIENT)) == 1 )
					{
						pHurt.pev.punchangle.z = -18;
						pHurt.pev.punchangle.x = 5;
					}
				}
				// Play a random attack sound
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackSounds[Math.RandomLong(0,(pAttackSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
			}
			break;

			default:
				BaseClass.HandleAnimEvent( pEvent );
				break;
		}
	}

	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		if( pevAttacker is null )
			return 0;

		CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pevAttacker );

		if( self.CheckAttacker( pAttacker ) )
			return 0;

		if( self.IsAlive() )
		{
			PainSound();

			if( pevAttacker.classname == "player" )
			{
				float points = Math.min(flDamage, pev.health)*0.05f;
				pevAttacker.frags += points;
			}
		}

		return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}

	/*void Killed( entvars_t@ pevAttacker, int iGib )
	{
		BaseClass.Killed( pevAttacker, GIB_ALWAYS );
	}*/

	/*void GibMonster()
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "common/bodysplat.wav", 1.0f, ATTN_NORM );

		//CGib@ pGib = null;
		int cGibs = 4;
		int GIB_COUNT = 3;
		for( int cSplat = 0; cSplat < cGibs; cSplat++ )
		{
			//@pGib = g_EntityFuncs.CreateGib( pev.origin, g_vecZero );
			CBaseEntity@ pGib = g_EntityFuncs.CreateEntity( "gib", null, false );
			CGib@ iGib = cast<CGib@>(pGib);
			g_EntityFuncs.DispatchSpawn( pGib.edict() );

			g_EntityFuncs.SetModel( pGib, "models/wanted/snakegibs.mdl" );
			pGib.pev.body = Math.RandomLong(0, GIB_COUNT-1);

			// spawn the gib somewhere in the monster's bounding volume
			pGib.pev.origin.x = pev.absmin.x + pev.size.x * (Math.RandomFloat( 0, 1 ) );
			pGib.pev.origin.y = pev.absmin.y + pev.size.y * (Math.RandomFloat( 0, 1 ) );
			pGib.pev.origin.z = pev.absmin.z + pev.size.z * (Math.RandomFloat( 0, 1 ) ) + 1;

			// mix in some noise
			pGib.pev.velocity.x += Math.RandomFloat( -0.25, 0.25 );
			pGib.pev.velocity.y += Math.RandomFloat( -0.25, 0.25 );
			pGib.pev.velocity.z += Math.RandomFloat( -0.25, 0.25 );

			pGib.pev.velocity = pGib.pev.velocity * Math.RandomFloat( 300, 400 );

			pGib.pev.avelocity.x = Math.RandomFloat( 100, 200 );
			pGib.pev.avelocity.y = Math.RandomFloat( 100, 300 );

			// copy owner's blood color
			iGib.m_bloodColor = self.BloodColor();

			if( pev.health > -50)
			{
				pGib.pev.velocity = pGib.pev.velocity * 0.7;
			}
			else if( pev.health > -200)
			{
				pGib.pev.velocity = pGib.pev.velocity * 2;
			}
			else
			{
				pGib.pev.velocity = pGib.pev.velocity * 4;
			}

			pGib.pev.solid = SOLID_BBOX;
			g_EntityFuncs.SetSize( pGib.pev, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );

			iGib.LimitVelocity();

			iGib.SetThink( ThinkFunction( iGib.Think ) );
			pGib.pev.nextthink = g_Engine.time + 15.0f;
		}
	}*/

	void PainSound()
	{
		int pitch = 95 + Math.RandomLong(0,9);

		if( Math.RandomLong(0,5) < 2 )
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pPainSounds[Math.RandomLong(0,(pPainSounds.length() - 1))], 1.0, ATTN_NORM, 0, pitch );
	}

	void IdleSound()
	{
		// Play a random idle sound
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0,(pIdleSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void RunAI( void )
	{
		if ( ( self.m_MonsterState == MONSTERSTATE_IDLE || self.m_MonsterState == MONSTERSTATE_ALERT ) && Math.RandomLong(0,99) == 0 && (pev.spawnflags & SF_MONSTER_GAG) == 0 )
			IdleSound();

		BaseClass.RunAI();
	}

	//=========================================================
	// AI Schedules Specific to this monster
	//=========================================================
	/*int IgnoreConditions()
	{
		int iIgnore = BaseIgnoreConditions();

		if( (self.m_Activity == ACT_MELEE_ATTACK1) || (self.m_Activity == ACT_MELEE_ATTACK1) )
		{
			if( m_flNextFlinch >= g_Engine.time )
				iIgnore |= (bits_COND_LIGHT_DAMAGE|bits_COND_HEAVY_DAMAGE);
		}

		if( (self.m_Activity == ACT_SMALL_FLINCH) || (self.m_Activity == ACT_BIG_FLINCH) )
		{
			if( m_flNextFlinch < g_Engine.time )
				m_flNextFlinch = g_Engine.time + SNAKE_FLINCH_DELAY;
		}

		return iIgnore;
	}

	int BaseIgnoreConditions()
	{
		int iIgnoreConditions = 0;

		if( !self.FShouldEat() )
		{
			// not hungry? Ignore food smell.
			iIgnoreConditions |= bits_COND_SMELL_FOOD;
		}

		if( self.m_MonsterState == MONSTERSTATE_SCRIPT && self.m_pCine !is null )
			iIgnoreConditions |= self.m_pCine.IgnoreConditions();

		return iIgnoreConditions;
	}*/

	CBaseEntity@ CheckTraceHullAttack( CBaseMonster@ pThis, float flDist, int iDamage, int iDmgType )
	{
		TraceResult tr;

		if( pThis.IsPlayer() )
			Math.MakeVectors( pThis.pev.angles );
		else
			Math.MakeAimVectors( pThis.pev.angles );

		Vector vecStart = self.pev.origin;
		//vecStart.z += self.pev.size.z * 0.5;
		vecStart.z += 64.0f;
		Vector vecEnd = vecStart + (g_Engine.v_forward * flDist ) - (g_Engine.v_up * flDist * 0.3);

		g_Utility.TraceHull( vecStart, vecEnd, dont_ignore_monsters, head_hull, pThis.edict(), tr );

		if( tr.pHit !is null )
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			if( iDamage > 0 )
			{
				pEntity.TakeDamage( pThis.pev, pThis.pev, iDamage, iDmgType );
			}

			return pEntity;
		}

		return null;
	}
}

string GetSnakeName()
{
	return "monster_snake";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Snake::monster_snake", GetSnakeName() );
}

} //namespace HLWanted_Snake END