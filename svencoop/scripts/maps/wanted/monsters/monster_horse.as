// TO-DO:
// - Minus points (pev.frags) in TakeDamage()
// - Don't take damage from entities (scorpion and beartrap e.g.) with player as their owner

namespace HLWanted_Horse
{
const int HORSE_HEALTH = 110;
const int HORSE_KICK_DMG = 15;
const float HORSE_NEXT_ATTACK_DELAY = 1.3;

const array<string> pIdleSounds =
{
	"wanted/horse/horse1.wav",
	"wanted/horse/horse3.wav",
	"wanted/horse/horse6.wav",
	"wanted/horse/horse7.wav",
	"wanted/horse/horse8.wav",
	"wanted/horse/horse9.wav"
};

const array<string> pAttackSounds =
{
	"wanted/horse/horse2.wav",
	"wanted/horse/horse4.wav",
	"wanted/horse/horse5.wav"
};

class monster_horse : CBaseCustomMonster
{
	private float m_flNextAttackTime;
	private float m_flNextPainTime;

	int ISoundMask( void )
	{
		return bits_SOUND_WORLD;
	}

	int Classify( void )
	{
		return self.GetClassification( CLASS_NONE );
	}

	int IRelationship( CBaseEntity@ pTarget )
	{
		if( pTarget.pev.classname == "monster_bear" ||
			pTarget.pev.classname == "monster_snake" ||
			pTarget.pev.classname == "monster_puma" )
		{
			return R_FR;
		}

		return self.IRelationship( pTarget );
	}

	void SetYawSpeed( void )
	{
		int ys;

		ys = 120;

		pev.yaw_speed = ys;
	}

	bool CheckMeleeAttack1( float flDot, float flDist )
	{
		if( flDist <= 80 && flDot >= 0.7 && /*self.m_hEnemy.GetEntity() !is null &&*/ self.pev.FlagBitSet( FL_ONGROUND ) )
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

	void Spawn()
	{
		Precache( );

		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, "models/wanted/horse.mdl" );

		g_EntityFuncs.SetSize( self.pev, Vector( -42, -16, 0 ), Vector( 16, 16, 60 ) );

		self.pev.solid		= SOLID_SLIDEBOX;
		self.pev.movetype	= MOVETYPE_STEP;
		self.m_bloodColor	= BLOOD_COLOR_RED;
		self.pev.effects	= 0;
		self.pev.health		= HORSE_HEALTH;
		self.m_flFieldOfView	= 0.5;// indicates the width of this monster's forward view cone ( as a dotproduct result )
		self.m_MonsterState	= MONSTERSTATE_NONE;

		m_flNextAttackTime 	= g_Engine.time;
		m_flNextPainTime 	= g_Engine.time;

		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Horse" );

		self.MonsterInit();
		self.SetActivity( ACT_IDLE );

		self.pev.view_ofs	= Vector ( 0, 0, 1 );// position of the eyes relative to monster's origin.
		self.pev.takedamage	= DAMAGE_YES;

		self.pev.nextthink 	= g_Engine.time + 0.1;
	}

	void Precache()
	{
		g_Game.PrecacheModel("models/wanted/horse.mdl");
		g_Game.PrecacheModel("models/wanted/horsegibs.mdl");
		g_Game.PrecacheModel("models/wanted/horseT.mdl");

		uint i;

		for( i = 0; i < pIdleSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pIdleSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pIdleSounds[i] );
		}

		for( i = 0; i < pAttackSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAttackSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAttackSounds[i] );
		}

		g_SoundSystem.PrecacheSound( "wanted/horse/pain.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/horse/pain.wav" );
	}

	void Think( void )
	{
		float flInterval = self.StudioFrameAdvance();
		pev.nextthink = g_Engine.time + 0.1;
		self.DispatchAnimEvents( flInterval );

		switch( self.m_Activity )
		{
		case ACT_MELEE_ATTACK1:
			if( self.m_fSequenceFinished )
			{
				self.SetActivity( ACT_IDLE );
			}
			break;

		case ACT_IDLE:
			if( self.m_fSequenceFinished )
			{
				self.SetActivity( ACT_IDLE );

				if( self.IsAlive() )
				{
					if( Math.RandomLong(0,1) == 1 )
						IdleSound();
				}
			}
			break;
		}

		BaseClass.Think();
	}

	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		int g_npckill = int( g_EngineFuncs.CVarGetFloat( "mp_npckill" ) );
		if( pevAttacker.ClassNameIs("player") && (g_npckill == 0 || g_npckill == 2) )
			return 0;

		if( self.IsAlive() )
		{
			PainSound();
			Attack();

			if( pevAttacker.classname == "player" )
			{
				float points = Math.min(flDamage, pev.health)*0.05f;
				pevAttacker.frags -= points;
			}
		}

		return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}

	void Attack( void )
	{
		if( m_flNextAttackTime > g_Engine.time )
			return;

		if( self.m_Activity == ACT_IDLE )
		{
			self.SetActivity( ACT_MELEE_ATTACK1 );

			CBaseEntity@ pHurt = CheckTraceHullAttack( self, 80, HORSE_KICK_DMG, DMG_SLASH );
			if( pHurt !is null )
			{
				if( (pHurt.pev.flags & (FL_MONSTER|FL_CLIENT)) == 1 )
				{
					pHurt.pev.punchangle.z = -18;
					pHurt.pev.punchangle.x = 5;
					pHurt.pev.velocity = pHurt.pev.velocity - g_Engine.v_right * 100;
				}
			}

			//if( Math.RandomLong(0,1) == 1 )
				AttackSound();
		}

		m_flNextAttackTime = g_Engine.time + HORSE_NEXT_ATTACK_DELAY;
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		GetSoundEntInstance().InsertSound( bits_SOUND_WORLD, pev.origin, 128, 1, self );

		pev.deadflag = DEAD_DYING;
		self.FCheckAITrigger();

		pev.health = 0;

		pev.solid = SOLID_NOT;
		pev.takedamage = DAMAGE_NO;
		pev.velocity = g_vecZero;

		self.SetActivity( ACT_DIESIMPLE );

		self.SetBoneController( 0, 0 );
		self.StudioFrameAdvance( 0.1 );

		SetTouch( null );
		SetThink( ThinkFunction( DyingThink ) );
		pev.nextthink = g_Engine.time + 0.1;
	}

	void DyingThink()
	{
		pev.nextthink = g_Engine.time + 0.1;

		float flInterval = self.StudioFrameAdvance( 0.1 );
		self.DispatchAnimEvents( flInterval );

		if( self.m_fSequenceFinished )
		{
			// death anim finished.
			self.StopAnimation();

			pev.deadflag = DEAD_DEAD;

			if( self.pev.spawnflags & SF_MONSTER_FADECORPSE == 0 )
			{
				SetThink( ThinkFunction( FadeOut ) );
				pev.nextthink = g_Engine.time + 15.0f; // fade out corpse after 15 sec
			}
			else // has "Don't Fade Corpse" bitset
			{
				SetThink( null );
				return;
			}
		}
	}

	void IdleSound()
	{
		// Play a random idle sound
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0,(pIdleSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void AttackSound()
	{
		// Play a random attack sound
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAttackSounds[Math.RandomLong(0,(pAttackSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void PainSound()
	{
		if( m_flNextPainTime > g_Engine.time )
			return;

		int pitch = 95 + Math.RandomLong(0,9);

		if( Math.RandomLong(0,5) < 2 )
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/horse/pain.wav", 1.0, ATTN_NORM, 0, pitch );

		m_flNextPainTime = g_Engine.time + 0.5;
	}

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

	void DestroyThink( void )
	{
		self.SUB_Remove();
	}

	void FadeOut()
	{
		pev.nextthink = g_Engine.time + 0.1;

		if( pev.rendermode == kRenderNormal )
		{
			pev.renderamt = 255;
			pev.rendermode = kRenderTransTexture;
		}

		if( pev.renderamt > 7 )
		{
			pev.renderamt -= 7;
		}
		else
		{
			pev.renderamt = 0;
			pev.nextthink = g_Engine.time + 0.1f;
			SetThink( ThinkFunction( DestroyThink ) );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Horse::monster_horse", "monster_horse" );
}

} //namespace HLWanted_Horse END