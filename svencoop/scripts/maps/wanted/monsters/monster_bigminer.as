/*
* 	(!) Neither CTalkMonster or CSquadMonster are exposed. Useless until SC dev implements it. Dammit!
*/

namespace HLWanted_BigMiner
{
const int ACTIVITY_NOT_AVAILABLE 	= -1;

//=========================================================
// monster-specific DEFINE's
//=========================================================
const int MINER_LIMP_HEALTH 		= 20;
const float MINER_SENTENCE_VOLUME 	= 0.35;

const int MINER_PICKAXE			= ( 1 << 0 );
const int MINER_HANDGRENADE 		= ( 1 << 1 );

const int HEAD_GROUP 			= 1;
const int HEAD_1 			= 0;
const int HEAD_2 			= 1;
const int HEAD_3 			= 2;
const int HEAD_4			= 3;
const int GUN_GROUP			= 2;
const int GUN_PICKAXE 			= 0;
const int GUN_NONE 			= 1;

//=========================================================
// Monster's Anim Events Go Here
//=========================================================
const int MINER_AE_KICK			= ( 3 );
const int MINER_AE_GREN_TOSS		= ( 7 );
const int MINER_AE_GREN_DROP		= ( 9 );
const int MINER_AE_CAUGHT_ENEMY 	= ( 10 ); // grunt established sight with an enemy (player only) that had previously eluded the squad.
const int MINER_AE_DROP_GUN 		= ( 11 ); // grunt (probably dead) is dropping his mp5.

const int MINER_HEALTH			= 100;

const int MINER_MELEE_DIST 		= 70;
const int MINER_DAMAGE_KICK 		= 34;

const int TASKSTATUS_RUNNING 		= 1; // Running task & movement
const int TASKSTATUS_COMPLETE 		= 4; // Completed, get next task

//=========================================================
// monster-specific schedule types
//=========================================================
enum SCHED_MINER
{
	SCHED_MINER_ESTABLISH_LINE_OF_FIRE = LAST_COMMON_SCHEDULE + 1,// move to a location to set up an attack against the enemy. (usually when a friendly is in the way).
	SCHED_MINER_SWEEP,
	SCHED_MINER_FOUND_ENEMY,
	SCHED_MINER_WAIT_FACE_ENEMY,
	SCHED_MINER_TAKECOVER_FAILED,// special schedule type that forces analysis of conditions and picks the best possible schedule to recover from this type of failure.
	SCHED_MINER_ELOF_FAIL,
};

//=========================================================
// monster-specific tasks
//=========================================================
enum TASK_MINER
{
	TASK_MINER_FACE_TOSS_DIR = LAST_COMMON_TASK + 1,
	TASK_MINER_SPEAK_SENTENCE,
	TASK_PLAY_THROWGRENADE_SEQUENCE,
};

enum MINER_SENTENCE_TYPES
{
	MI_NONE = -1,
	MI_GREN = 0,
	MI_ALERT,
	MI_MONSTER,
	MI_COVER,
	MI_THROW,
	MI_CHARGE,
	MI_TAUNT,
};

const array<string> pAttackHitSounds = 
{
	"zombie/claw_strike1.wav",
	"zombie/claw_strike2.wav",
	"zombie/claw_strike3.wav"
};

const array<string> pIdleSounds = 
{
	"wanted/miner/newbeams.wav",
	"wanted/miner/sweetlovin.wav",
	"wanted/miner/newshovel.wav"
};

const array<string> pAlertSounds = 
{
	"wanted/miner/getpistol.wav",
	"wanted/miner/itsthesherriff.wav",
	"wanted/miner/iseehim.wav",
	"wanted/miner/shitlawman.wav",
	"wanted/miner/getsherriff.wav",
	"wanted/miner/blowheadoff.wav",
	"wanted/miner/hesoverhere.wav"
};

const array<string> pMonsterAlertSounds = 
{
	"wanted/miner/iseeoneofem.wav",
	"wanted/miner/visitors.wav",
	"wanted/miner/getawaygold.wav",
	"wanted/miner/stealgold.wav"
};

const array<string> pCheckSounds = 
{
	"wanted/miner/whereruzeke.wav",
	"wanted/miner/seeanysign.wav",
	"wanted/miner/heycharlie.wav",
	"wanted/miner/damnedifican.wav",
	"wanted/miner/shootanything.wav",
	"wanted/miner/seemoving.wav",
	"wanted/miner/shadows.wav",
	"wanted/miner/heyjake.wav"
};

const array<string> pClearSounds = 
{
	"wanted/miner/noonehere.wav",
	"wanted/miner/cantseeanyone.wav",
	"wanted/miner/mustbehiding.wav",
	"wanted/miner/nosignofem.wav",
	"wanted/miner/canyouseeem.wav",
	"wanted/miner/cantseenoone.wav",
	"wanted/miner/aintnoone.wav",
	"wanted/miner/rats.wav",
	"wanted/miner/allquiet.wav",
	"wanted/miner/cantseenothin.wav",
	"wanted/miner/heardsomething.wav",
	"wanted/miner/notevenarat.wav",
	"wanted/miner/invisible.wav"
};

const array<string> pQuestionSounds = 
{
	"wanted/miner/eyeopen.wav",
	"wanted/miner/damnfools.wav",
	"wanted/miner/keeplookout.wav",
	"wanted/miner/shutup.wav",
	"wanted/miner/stayhere.wav",
	"wanted/miner/seeflush.wav",
	"wanted/miner/headdown.wav",
	"wanted/miner/keepemaway.wav",
	"wanted/miner/passround.wav",
	"wanted/miner/makesure.wav",
	"wanted/miner/allok.wav",
	"wanted/miner/roundsomewhere.wav"
};

const array<string> pAnswerSounds = 
{
	"wanted/miner/yep.wav",
	"wanted/miner/ok.wav",
	"wanted/miner/okok.wav",
	"wanted/miner/whomadeyou.wav",
	"wanted/miner/yepsure.wav",
	"wanted/miner/errok.wav",
	"wanted/miner/whatdidyousay.wav"
};

const array<string> pThrowGrenadeSounds = 
{
	"wanted/miner/fireinhole.wav",
	"wanted/miner/takethis.wav",
	"wanted/miner/chewonthis.wav",
	"wanted/miner/likethisone.wav"
};

const array<string> pTakeCoverSounds = 
{
	"wanted/miner/duck.wav",
	"wanted/miner/pinemdown.wav",
	"wanted/miner/gimmehelp.wav",
	"wanted/miner/runferit.wav",
	"wanted/miner/lookoutt.wav",
	"wanted/miner/flushhimout.wav",
	"wanted/miner/goddamnit.wav",
	"wanted/miner/somebodycover.wav"
};

const array<string> pTauntSounds = 
{
	"wanted/miner/runout.wav",
	"wanted/miner/yermomma.wav",
	"wanted/miner/whupass.wav",
	"wanted/miner/homeinabox.wav",
	"wanted/miner/awavefile.wav",
	"wanted/miner/tinstar.wav",
};

const array<string> pPainSounds = 
{
	"wanted/miner/pain1.wav",
	"wanted/miner/pain2.wav",
	"wanted/miner/pain3.wav"
};

const array<string> pDeathSounds = 
{
	"wanted/miner/death1.wav",
	"wanted/miner/death2.wav",
	"wanted/miner/death6.wav"
};

class monster_bigminer : CBaseCustomMonster//ScriptBaseMonsterEntity
{
	float m_flNextGrenadeCheck;
	float m_flNextPainTime;
	float m_flLastEnemySightTime;

	Vector	m_vecTossVelocity;

	bool	m_fThrowGrenade;
	bool	m_fFirstEncounter;// only put on the handsign show in the squad's first encounter.

	int 	m_voicePitch;

	int	m_iSentence;

	array<string> pMinerSentences =
	{
		"MI_GREN", // grenade scared grunt
		"MI_ALERT", // sees player
		"MI_MONSTER", // sees monster
		"MI_COVER", // running to cover
		"MI_THROW", // about to throw grenade
		"MI_CHARGE",  // running out to get the enemy
		"MI_TAUNT", // say rude things
	};

	monster_bigminer( void )
	{
		@this.m_Schedules = @monster_bigminer_schedules;
	}

	void Spawn( void )
	{
		Precache();

		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, "models/wanted/bigminer.mdl" );

		g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );

		pev.solid			= SOLID_SLIDEBOX;
		pev.movetype			= MOVETYPE_STEP;
		self.m_bloodColor		= BLOOD_COLOR_RED;
		pev.effects			= 0;

		if( self.pev.health == 0.0f )
		{
			self.pev.health 	= MINER_HEALTH;
		}

		self.pev.view_ofs		= Vector( 0, 0, 50 );// position of the eyes relative to monster's origin.
		self.m_flFieldOfView		= 0.2;
		self.m_MonsterState		= MONSTERSTATE_NONE;
		m_flNextGrenadeCheck 		= g_Engine.time + 1;
		m_flNextPainTime		= g_Engine.time;
		m_iSentence 			= MI_NONE;

		self.m_afCapability 		= bits_CAP_SQUAD | bits_CAP_TURN_HEAD | bits_CAP_DOORS_GROUP;

		m_fFirstEncounter 		= true;// this is true when the grunt spawns, because he hasn't encountered an enemy yet.

		self.m_HackedGunPos = Vector ( 0, 0, 55 );

		if( string( self.m_FormattedName ).IsEmpty() )
		{
			self.m_FormattedName = "Miner";
		}

		g_TalkMonster.g_talkWaitTime = 0;

		self.MonsterInit();

		self.pev.weapons = MINER_PICKAXE | MINER_HANDGRENADE;
		self.SetBodygroup( GUN_GROUP, GUN_PICKAXE );
		self.SetBodygroup( HEAD_GROUP, Math.RandomLong( 0, HEAD_4 ) );
	}

	void Precache( void )
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
		{
			g_Game.PrecacheModel( "models/wanted/bigminer.mdl" );
			g_Game.PrecacheGeneric( "models/" + "wanted/bigminer01.mdl" );
			g_Game.PrecacheGeneric( "models/" + "wanted/bigminer02.mdl" );
			g_Game.PrecacheGeneric( "models/" + "wanted/bigminer03.mdl" );
			g_Game.PrecacheGeneric( "models/" + "wanted/bigminer04.mdl" );
			g_Game.PrecacheModel( "models/wanted/bigminerT.mdl" );
		}
		else
		{
			g_Game.PrecacheModel( self.pev.model );
		}

		uint i;

		for( i = 0; i < pAlertSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAlertSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAlertSounds[i] );
		}

		for( i = 0; i < pMonsterAlertSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pMonsterAlertSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pMonsterAlertSounds[i] );
		}

		for( i = 0; i < pCheckSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pCheckSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pCheckSounds[i] );
		}

		for( i = 0; i < pClearSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pClearSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pClearSounds[i] );
		}

		for( i = 0; i < pQuestionSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pQuestionSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pQuestionSounds[i] );
		}

		for( i = 0; i < pAnswerSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAnswerSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAnswerSounds[i] );
		}

		for( i = 0; i < pThrowGrenadeSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pThrowGrenadeSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pThrowGrenadeSounds[i] );
		}

		for( i = 0; i < pTakeCoverSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pTakeCoverSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pTakeCoverSounds[i] );
		}

		for( i = 0; i < pTauntSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pTauntSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pTauntSounds[i] );
		}

		for( i = 0; i < pPainSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pPainSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pPainSounds[i] );
		}

		for( i = 0; i < pDeathSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pDeathSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pDeathSounds[i] );
		}

		g_SoundSystem.PrecacheSound( "zombie/claw_miss2.wav" ); // because we use the basemonster SWIPE animation event

		if( Math.RandomLong( 0, 1 ) == 1 )
			m_voicePitch = 109 + Math.RandomLong( 0, 7 );
		else
			m_voicePitch = 100;
	}
	
	int ObjectCaps( void )
	{
		if( self.IsPlayerAlly() )
			return FCAP_IMPULSE_USE;
		else
			return BaseClass.ObjectCaps();
	}

	//=========================================================
	// start task
	//=========================================================
	void StartTask( Task@ pTask )
	{
		self.m_iTaskStatus = TASKSTATUS_RUNNING;

		switch( pTask.iTask )
		{
		/*case TASK_MINER_SPEAK_SENTENCE:
			SpeakSentence();
			self.TaskComplete();
			break;*/

		case TASK_WALK_PATH:
		case TASK_RUN_PATH:
			self.Forget( bits_MEMORY_INCOVER );
			BaseClass.StartTask( pTask );
			break;

		case TASK_MINER_FACE_TOSS_DIR:
			break;

		case TASK_FACE_IDEAL:
		case TASK_FACE_ENEMY:
			BaseClass.StartTask( pTask );
			break;

		case TASK_PLAY_THROWGRENADE_SEQUENCE:
			pev.sequence = self.LookupSequence( "throwgrenade" );
			pev.frame = 0;
			self.ResetSequenceInfo();
			break;

		default: 
			BaseClass.StartTask( pTask );
			break;
		}
	}

	//=========================================================
	// RunTask
	//=========================================================
	void RunTask( Task@ pTask )
	{
		switch( pTask.iTask )
		{
		case TASK_PLAY_THROWGRENADE_SEQUENCE:
			if( self.m_fSequenceFinished )
			{
				self.TaskComplete();
			}
			break;
		case TASK_MINER_FACE_TOSS_DIR:
			{
				// project a point along the toss vector and turn to face that point.
				self.MakeIdealYaw( pev.origin + m_vecTossVelocity * 64 );
				self.ChangeYaw( int(self.pev.yaw_speed) );

				if( FacingIdeal() )
				{
					self.m_iTaskStatus = TASKSTATUS_COMPLETE;
				}
				break;
			}
		default:
			BaseClass.RunTask( pTask );
			break;
		}
	}

	//=========================================================
	// PainSound
	//=========================================================
	void PainSound( void )
	{
		if ( g_Engine.time > m_flNextPainTime )
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pPainSounds[Math.RandomLong( 0, ( pPainSounds.length() - 1 ) )], 1.0f, ATTN_NORM );
			m_flNextPainTime = g_Engine.time + 1;
		}
	}

	//=========================================================
	// DeathSound 
	//=========================================================
	void DeathSound( void )
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pDeathSounds[Math.RandomLong( 0, ( pDeathSounds.length() - 1 ) )], 1.0f, ATTN_IDLE );
	}

	int ISoundMask()
	{
		return	bits_SOUND_WORLD	|
			bits_SOUND_COMBAT	|
			bits_SOUND_BULLETHIT	|
			bits_SOUND_CARCASS	|
			bits_SOUND_MEAT		|
			bits_SOUND_GARBAGE	|
			bits_SOUND_DANGER	|
			bits_SOUND_PLAYER;
	}

	int Classify()
	{
		return self.GetClassification( CLASS_HUMAN_MILITARY );
	}

	void SetYawSpeed( void )
	{
		int ys = 0;

		switch( self.m_Activity )
		{
			case ACT_IDLE:
				ys = 150;		
				break;
			case ACT_RUN:
				ys = 150;	
				break;
			case ACT_WALK:
				ys = 180;		
				break;
			case ACT_RANGE_ATTACK1:
				ys = 120;
				break;
			case ACT_RANGE_ATTACK2:
				ys = 120;
				break;
			case ACT_MELEE_ATTACK1:
				ys = 120;
				break;
			case ACT_MELEE_ATTACK2:
				ys = 120;
				break;
			case ACT_TURN_LEFT:
			case ACT_TURN_RIGHT:
				ys = 180;
				break;
			default:
				ys = 90;
				break;
		}

		self.pev.yaw_speed = ys;
	}

	bool CheckMeleeAttack1( float flDot, float flDist )
	{
		if( !self.m_hEnemy.IsValid() )
			return false;

		CBaseMonster@ pEnemy = self.m_hEnemy.GetEntity().MyMonsterPointer();

		if( pEnemy is null )
			return false;

		if ( flDist <= 64 && flDot >= 0.7 && 
			 pEnemy.Classify() != CLASS_ALIEN_BIOWEAPON &&
			 pEnemy.Classify() != CLASS_PLAYER_BIOWEAPON )
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
		if( !( ( self.pev.weapons & MINER_HANDGRENADE ) != 0 ) )
		{
			return false;
		}

		// if the grunt isn't moving, it's ok to check.
		if( self.m_flGroundSpeed != 0 )
		{
			m_fThrowGrenade = false;
			return m_fThrowGrenade;
		}

		// assume things haven't changed too much since last time
		if( g_Engine.time < m_flNextGrenadeCheck )
		{
			return m_fThrowGrenade;
		}

		if( !( ( self.m_hEnemy.GetEntity().pev.flags & FL_ONGROUND ) != 0 ) && self.m_hEnemy.GetEntity().pev.waterlevel == 0 && self.m_vecEnemyLKP.z > self.pev.absmax.z  )
		{
			m_fThrowGrenade = false;
			return m_fThrowGrenade;
		}

		Vector vecTarget;

		//if( ( self.pev.weapons & MINER_HANDGRENADE ) != 0 )
		{
			// find feet
			if ( Math.RandomLong(0, 1) == 1 )
			{
				// magically know where they are
				vecTarget = Vector( self.m_hEnemy.GetEntity().pev.origin.x, self.m_hEnemy.GetEntity().pev.origin.y, self.m_hEnemy.GetEntity().pev.absmin.z );
			}
			else
			{
				// toss it to where you last saw them
				vecTarget = self.m_vecEnemyLKP;
			}
		}
		/*else
		{
			// find target
			vecTarget = self.m_vecEnemyLKP + (self.m_hEnemy.GetEntity().BodyTarget( self.pev.origin ) - self.m_hEnemy.GetEntity().pev.origin);
			// estimate position
			if ( self.HasConditions( bits_COND_SEE_ENEMY ) )
				vecTarget = vecTarget + ( ( vecTarget - self.pev.origin ).Length() / 500 ) * self.m_hEnemy.GetEntity().pev.velocity;
		}*/

		if( ( vecTarget - self.pev.origin ).Length2D() <= 256 )
		{
			// crap, I don't want to blow myself up
			m_flNextGrenadeCheck = g_Engine.time + 1; // one full second.
			m_fThrowGrenade = false;
			return m_fThrowGrenade;
		}

		//if( ( self.pev.weapons & MINER_HANDGRENADE ) != 0 )
		{
			Vector vecToss = VecCheckToss( self.edict(), GetGunPosition(), vecTarget, 0.5 );

			if( vecToss != g_vecZero )
			{
				m_vecTossVelocity = vecToss;

				// throw a hand grenade
				m_fThrowGrenade = true;
				// don't check again for a while.
				m_flNextGrenadeCheck = g_Engine.time; // 1/3 second.
			}
			else
			{
				// don't throw
				m_fThrowGrenade = false;
				// don't check again for a while.
				m_flNextGrenadeCheck = g_Engine.time + 1; // one full second.
			}
		}
		/*else
		{
			Vector vecToss = VecCheckThrow( self.edict(), GetGunPosition(), vecTarget, 500, 0.5 );

			if( vecToss != g_vecZero )
			{
				m_vecTossVelocity = vecToss;

				// throw a hand grenade
				m_fThrowGrenade = true;
				// don't check again for a while.
				m_flNextGrenadeCheck = g_Engine.time + 0.3; // 1/3 second.
			}
			else
			{
				// don't throw
				m_fThrowGrenade = false;
				// don't check again for a while.
				m_flNextGrenadeCheck = g_Engine.time + 1; // one full second.
			}
		}*/

		return m_fThrowGrenade;
	}

	CBaseEntity@ Kick( void )
	{
		TraceResult tr;

		Math.MakeVectors( pev.angles );
		Vector vecStart = pev.origin;
		//vecStart.z += pev.size.z * 0.5;
		//Vector vecEnd = vecStart + (g_Engine.v_forward * MINER_MELEE_DIST);
		vecStart.z += 64.0f;
		Vector vecEnd = vecStart + (g_Engine.v_forward * 80 ) - (g_Engine.v_up * 80 * 0.3);

		g_Utility.TraceHull( vecStart, vecEnd, dont_ignore_monsters, head_hull, self.edict(), tr );

		if ( tr.pHit !is null )
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );
			return pEntity;
		}

		return null;
	}
	
	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		Vector	vecShootDir;
		Vector vecShootOrigin;

		switch( pEvent.event )
		{
			case MINER_AE_GREN_TOSS:
			{
				Math.MakeVectors( pev.angles );
				g_EntityFuncs.ShootTimed( pev, GetGunPosition(), m_vecTossVelocity, 3.5 );

				m_fThrowGrenade = false;
				m_flNextGrenadeCheck = g_Engine.time + 6;// wait six seconds before even looking again to see if a grenade can be thrown.
				// !!!LATER - when in a group, only try to throw grenade if ordered.
			}
			break;

			case MINER_AE_GREN_DROP:
			{
				Math.MakeVectors( pev.angles );
				g_EntityFuncs.ShootTimed( pev, self.pev.origin + g_Engine.v_forward * 17 - g_Engine.v_right * 27 + g_Engine.v_up * 6, g_vecZero, 3 );
			}
			break;

			case MINER_AE_KICK:
			{
				CBaseEntity@ pHurt = Kick();

				if ( pHurt !is null )
				{
					// SOUND HERE!
					Math.MakeVectors( pev.angles );
					pHurt.pev.punchangle.x = 15;
					pHurt.pev.velocity = pHurt.pev.velocity + g_Engine.v_forward * 100 + g_Engine.v_up * 50;
					pHurt.TakeDamage( pev, pev, MINER_DAMAGE_KICK, DMG_CLUB );
				}
			}
			break;

			case MINER_AE_CAUGHT_ENEMY:
			{
				if( FOkToSpeak() )
				{
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAlertSounds[Math.RandomLong(0, pAlertSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
					JustSpoke();
				}
			}

			default:
				BaseClass.HandleAnimEvent( pEvent );
				break;
		}
	}
	
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
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

		self.Forget( bits_MEMORY_INCOVER );

		return BaseClass.TakeDamage(pevInflictor, pevAttacker, flDamage, bitsDamageType);
	}

	/*void SpeakSentence( void )
	{
		if ( m_iSentence == MI_NONE )
		{
			// no sentence cued up.
			return; 
		}

		if( FOkToSpeak() )
		{
			g_SoundSystem.PlaySentenceGroup( self.edict(), pMinerSentences[ m_iSentence ], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
			JustSpoke();
		}
	}*/
	
	bool FOkToSpeak( void )
	{
		// if someone else is talking, don't speak
		if( g_Engine.time <= g_TalkMonster.g_talkWaitTime )
			return false;

		if( (pev.spawnflags & SF_MONSTER_GAG) != 0 )
		{
			if( self.m_MonsterState != MONSTERSTATE_COMBAT )
			{
				// no talking outside of combat if gagged.
				return false;
			}
		}
		return true;
	}

	void JustSpoke( void )
	{
		g_TalkMonster.g_talkWaitTime = g_Engine.time + Math.RandomFloat( 1.5, 2.0 );
		m_iSentence = MI_NONE;
	}

	void IdleSound( void )
	{
		if( FOkToSpeak() && ( g_TalkMonster.g_fMinerQuestion > 0 || Math.RandomLong( 0, 1 ) == 1 ) )
		{
			if( g_TalkMonster.g_fMinerQuestion <= 0 )
			{
				// ask question or make statement
				switch( Math.RandomLong( 0, 2 ) )
				{
					case 0: // check in
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pCheckSounds[Math.RandomLong(0, pCheckSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						g_TalkMonster.g_fMinerQuestion = 1;
						break;
					case 1: // question
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pQuestionSounds[Math.RandomLong(0, pQuestionSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						g_TalkMonster.g_fMinerQuestion = 2;
						break;
					case 2: // statement
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0, pIdleSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						break;
				}
			}
			else
			{
				switch( g_TalkMonster.g_fMinerQuestion )
				{
					case 1: // check in
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pClearSounds[Math.RandomLong(0, pClearSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						break;
					case 2: // question 
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAnswerSounds[Math.RandomLong(0, pAnswerSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						break;
				}
				g_TalkMonster.g_fMinerQuestion = 0;
			}
			JustSpoke();
		}
	}

	void RunAI( void )
	{
		if( ( self.m_MonsterState == MONSTERSTATE_IDLE || self.m_MonsterState == MONSTERSTATE_ALERT ) && Math.RandomLong(0,99) == 0 && (pev.spawnflags & SF_MONSTER_GAG) == 0 )
			IdleSound();

		BaseClass.RunAI();
	}

	//=========================================================
	// GetGunPosition	return the end of the barrel
	//=========================================================
	Vector GetGunPosition()
	{
		return self.pev.origin + Vector( 0, 0, 60 );
	}

	Schedule@ GetScheduleOfType( int Type )
	{
		switch( Type )
		{
			case SCHED_TAKE_COVER_FROM_ENEMY:
			{
				if( Math.RandomLong( 0, 1 ) == 1 )
				{
					return slMinerTakeCover;
				}
				else
				{
					return slMinerGrenadeCover;
				}
			}

			case SCHED_TAKE_COVER_FROM_BEST_SOUND:
			{
				return slMinerTakeCoverFromBestSound;
			}

			case SCHED_MINER_TAKECOVER_FAILED:
			{
				if( self.HasConditions( bits_COND_CAN_RANGE_ATTACK1 ) )
				{
					return GetScheduleOfType( SCHED_RANGE_ATTACK1 );
				}

				return GetScheduleOfType( SCHED_FAIL );
			}

			case SCHED_MINER_ELOF_FAIL:
			{
				// human grunt is unable to move to a position that allows him to attack the enemy.
				return GetScheduleOfType( SCHED_TAKE_COVER_FROM_ENEMY );
			}

			case SCHED_MINER_ESTABLISH_LINE_OF_FIRE:
			{
				return slMinerEstablishLineOfFire;
			}

			case SCHED_RANGE_ATTACK2:
			{
				return slMinerRangeAttack2;
			}

			case SCHED_MINER_WAIT_FACE_ENEMY:
			{
				return slMinerWaitInCover;
			}

			case SCHED_MINER_SWEEP:
			{
				return slMinerSweep;
			}

			case SCHED_MINER_FOUND_ENEMY:
			{
				return slMinerFoundEnemy;
			}

			case SCHED_VICTORY_DANCE:
			{
				return slMinerVictoryDance;
			}

			case SCHED_FAIL:
			{
				return slMinerFail;
			}
		}

		return BaseClass.GetScheduleOfType( Type );
	}
	
	Schedule@ GetSchedule( void )
	{
		// clear old sentence
		m_iSentence = MI_NONE;

		// grunts place HIGH priority on running away from danger sounds.
		if( self.HasConditions( bits_COND_HEAR_SOUND ) )
		{
			CSound@ pSound;
			@pSound = self.PBestSound();

			if( pSound !is null )
			{
				if( pSound.m_iType & bits_SOUND_DANGER != 0 )
				{
					// dangerous sound nearby!
					if ( FOkToSpeak() )
					{
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pTakeCoverSounds[Math.RandomLong(0, pTakeCoverSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						JustSpoke();
					}
					return GetScheduleOfType( SCHED_TAKE_COVER_FROM_BEST_SOUND );
				}
			}
		}
		switch( self.m_MonsterState )
		{
			case MONSTERSTATE_COMBAT:
			{
				// dead enemy
				if ( self.HasConditions( bits_COND_ENEMY_DEAD ) )
				{
					// call base class, all code to handle dead enemies is centralized there.
					return BaseClass.GetSchedule();
				}

				// new enemy
				if( self.HasConditions( bits_COND_NEW_ENEMY ) )
				{
					if( FOkToSpeak() && Math.RandomLong(0, 1) == 1 )
					{
						if ( self.m_hEnemy.IsValid() && self.m_hEnemy.GetEntity().IsPlayer() )
							// player
							g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAlertSounds[Math.RandomLong(0, pAlertSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
						else if ( self.m_hEnemy.IsValid() &&
								( self.m_hEnemy.GetEntity().Classify() != CLASS_PLAYER_ALLY ) && 
								( self.m_hEnemy.GetEntity().Classify() != CLASS_HUMAN_PASSIVE ) && 
								( self.m_hEnemy.GetEntity().Classify() != CLASS_MACHINE ) )
							// monster
							g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pMonsterAlertSounds[Math.RandomLong(0, pMonsterAlertSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );

						JustSpoke();
					}

					return GetScheduleOfType ( SCHED_MINER_ESTABLISH_LINE_OF_FIRE );
				}
				// damaged just a little
				else if( self.HasConditions( bits_COND_LIGHT_DAMAGE ) )
				{
					// if hurt:
					// 90% chance of taking cover
					// 10% chance of flinch.
					int iPercent = Math.RandomLong( 0, 99 );

					if( iPercent <= 90 && self.m_hEnemy.IsValid() )
					{
						if( FOkToSpeak() )
						{
							m_iSentence = MI_COVER;
						}
						return GetScheduleOfType( SCHED_TAKE_COVER_FROM_ENEMY );
					}
					else
					{
						return GetScheduleOfType( SCHED_SMALL_FLINCH );
					}
				}
				// can kick
				else if( self.HasConditions ( bits_COND_CAN_MELEE_ATTACK1 ) )
				{
					return GetScheduleOfType ( SCHED_MELEE_ATTACK1 );
				}
				// can't see enemy
				else if( self.HasConditions( bits_COND_ENEMY_OCCLUDED ) )
				{
					/*if( self.HasConditions( bits_COND_CAN_RANGE_ATTACK2 ) )
					{
						//!!!KELLY - this grunt is about to throw or fire a grenade at the player. Great place for "fire in the hole"  "frag out" etc
						if ( FOkToSpeak() )
						{
							g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pThrowGrenadeSounds[Math.RandomLong(0, pThrowGrenadeSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
							JustSpoke();
						}
						return GetScheduleOfType( SCHED_RANGE_ATTACK2 );
					}
					else*/
					{
						//!!!KELLY - grunt is going to stay put for a couple seconds to see if
						// the enemy wanders back out into the open, or approaches the
						// grunt's covered position. Good place for a taunt, I guess?
						if ( FOkToSpeak() && Math.RandomLong( 0, 1 ) == 1 )
						{
							g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pTauntSounds[Math.RandomLong(0, pTauntSounds.length()-1)], MINER_SENTENCE_VOLUME, ATTN_NORM, 0, m_voicePitch );
							JustSpoke();
						}
						return GetScheduleOfType( SCHED_STANDOFF );
					}
				}
			}
		}

		// no special cases here, call the base class
		return BaseClass.GetSchedule();
	}

	void SetActivity( Activity NewActivity )
	{
		int iSequence = ACTIVITY_NOT_AVAILABLE;

		switch( NewActivity )
		{
			case ACT_RANGE_ATTACK2:
			iSequence = self.LookupSequence( "throwgrenade" );
			break;
			
			case ACT_RUN:
			if ( self.pev.health <= MINER_LIMP_HEALTH )
			{
				// limp!
				iSequence = self.LookupActivity( ACT_RUN_HURT );
			}
			else
			{
				iSequence = self.LookupActivity( NewActivity );
			}
			break;
			
			case ACT_WALK:
			if ( self.pev.health <= MINER_LIMP_HEALTH )
			{
				// limp!
				iSequence = self.LookupActivity( ACT_WALK_HURT );
			}
			else
			{
				iSequence = self.LookupActivity( NewActivity );
			}
			break;
			
			case ACT_IDLE:
			if ( self.m_MonsterState == MONSTERSTATE_COMBAT )
			{
				NewActivity = ACT_IDLE_ANGRY;
			}
			iSequence = self.LookupActivity( NewActivity );
			break;

			default:
			iSequence = self.LookupActivity( NewActivity );
			break;
		}

		self.m_Activity = NewActivity; // Go ahead and set this so it doesn't keep trying when the anim is not present

		// Set to the desired anim, or default anim if the desired is not present
		if ( iSequence > ACTIVITY_NOT_AVAILABLE )
		{
			if ( self.pev.sequence != iSequence || !self.m_fSequenceLoops )
			{
				self.pev.frame = 0;
			}

			self.pev.sequence		= iSequence;	// Set to the reset anim (if it's there)
			self.ResetSequenceInfo( );
			SetYawSpeed();
		}
		else
		{
			// Not available try to get default anim
			self.pev.sequence		= 0;	// Set to the reset anim (if it's there)
		}
	}

	bool FacingIdeal( void )
	{
		float flDelta = Math.AngleMod( pev.angles.y - pev.ideal_yaw );
		return (flDelta < 45 || flDelta > 315);
	}
}

array<ScriptSchedule@>@ monster_bigminer_schedules;

ScriptSchedule slMinerFail(
	bits_COND_CAN_MELEE_ATTACK1	|
	bits_COND_CAN_MELEE_ATTACK2,
	0,
	"MinerFail" );

ScriptSchedule slMinerCombatFail(
	bits_COND_CAN_RANGE_ATTACK1	|
	bits_COND_CAN_RANGE_ATTACK2,
	0,
	"MinerCombatFail" );
	
ScriptSchedule slMinerVictoryDance(
	bits_COND_NEW_ENEMY		|
	bits_COND_LIGHT_DAMAGE		|
	bits_COND_HEAVY_DAMAGE,
	0,
	"MinerVictoryDance" );
	
ScriptSchedule slMinerEstablishLineOfFire(
	bits_COND_NEW_ENEMY		|
	bits_COND_ENEMY_DEAD		|
	bits_COND_CAN_MELEE_ATTACK1	|
	bits_COND_CAN_MELEE_ATTACK2	|
	bits_COND_HEAR_SOUND,
	bits_SOUND_DANGER,
	"MinerEstablishLineOfFire" );
	
ScriptSchedule slMinerFoundEnemy(
	bits_COND_HEAR_SOUND,
	bits_SOUND_DANGER,
	"MinerFoundEnemy" );

ScriptSchedule slMinerWaitInCover(
	bits_COND_NEW_ENEMY		|
	bits_COND_HEAR_SOUND		|
	bits_COND_CAN_RANGE_ATTACK1	|
	bits_COND_CAN_RANGE_ATTACK2	|
	bits_COND_CAN_MELEE_ATTACK1	|
	bits_COND_CAN_MELEE_ATTACK2	|
	0,
	bits_SOUND_DANGER,
	"MinerWaitInCover" );

ScriptSchedule slMinerTakeCover(
	0,
	0,
	"TakeCover" );

ScriptSchedule slMinerGrenadeCover(
	0,
	0,
	"GrenadeCover" );

ScriptSchedule slMinerTossGrenadeCover(
	0,
	0,
	"TossGrenadeCover" );

ScriptSchedule slMinerTakeCoverFromBestSound(
	0,
	0,
	"TakeCoverFromBestSound" );

ScriptSchedule slMinerSweep(
	bits_COND_NEW_ENEMY		|
	bits_COND_LIGHT_DAMAGE		|
	bits_COND_HEAVY_DAMAGE		|
	bits_COND_CAN_RANGE_ATTACK1	|
	bits_COND_CAN_RANGE_ATTACK2	|
	bits_COND_HEAR_SOUND,
	bits_SOUND_WORLD		|
	bits_SOUND_DANGER		|
	bits_SOUND_PLAYER,
	"Sweep" );

ScriptSchedule slMinerRangeAttack2(
	0,
	0,
	"RangeAttack2" );

void InitSchedules()
{
	slMinerFail.AddTask( ScriptTask( TASK_STOP_MOVING, 0 ) );
	slMinerFail.AddTask( ScriptTask( TASK_SET_ACTIVITY, float( ACT_IDLE ) ) );
	slMinerFail.AddTask( ScriptTask( TASK_WAIT, float( 2 ) ) );
	slMinerFail.AddTask( ScriptTask( TASK_WAIT_PVS, float( 0 ) ) );

	slMinerVictoryDance.AddTask( ScriptTask( TASK_STOP_MOVING, float( 0 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_FACE_ENEMY, float ( 0 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_WAIT, float( 1.5 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_GET_PATH_TO_ENEMY_CORPSE, float( 0 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_WALK_PATH, float( 0 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_WAIT_FOR_MOVEMENT, float( 0 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_FACE_ENEMY, float( 0 ) ) );
	slMinerVictoryDance.AddTask( ScriptTask( TASK_PLAY_SEQUENCE, float( ACT_VICTORY_DANCE ) ) );

	slMinerEstablishLineOfFire.AddTask( ScriptTask( TASK_SET_FAIL_SCHEDULE, float( SCHED_MINER_ELOF_FAIL ) ) );
	slMinerEstablishLineOfFire.AddTask( ScriptTask( TASK_GET_PATH_TO_ENEMY, float( 0 ) ) );
	//slMinerEstablishLineOfFire.AddTask( ScriptTask( TASK_MINER_SPEAK_SENTENCE, float( 0 ) ) );
	slMinerEstablishLineOfFire.AddTask( ScriptTask( TASK_RUN_PATH, float( 0 ) ) );
	slMinerEstablishLineOfFire.AddTask( ScriptTask( TASK_WAIT_FOR_MOVEMENT, float( 0 ) ) );

	slMinerFoundEnemy.AddTask( ScriptTask( TASK_STOP_MOVING, 0 ) );
	slMinerFoundEnemy.AddTask( ScriptTask( TASK_FACE_ENEMY, float( 0 ) ) );
	slMinerFoundEnemy.AddTask( ScriptTask( TASK_PLAY_SEQUENCE_FACE_ENEMY, float( ACT_SIGNAL1 ) ) );

	slMinerWaitInCover.AddTask( ScriptTask( TASK_STOP_MOVING, float( 0 ) ) );
	slMinerWaitInCover.AddTask( ScriptTask( TASK_SET_ACTIVITY, float( ACT_IDLE ) ) );
	slMinerWaitInCover.AddTask( ScriptTask( TASK_FACE_ENEMY, float( 1 ) ) );

	slMinerTakeCover.AddTask( ScriptTask( TASK_STOP_MOVING, float( 0 ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_SET_FAIL_SCHEDULE, float( SCHED_MINER_TAKECOVER_FAILED ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_WAIT, float( 0.2 ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_FIND_COVER_FROM_ENEMY, float( 0 ) ) );
	//slMinerTakeCover.AddTask( ScriptTask( TASK_MINER_SPEAK_SENTENCE, float( 0 ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_RUN_PATH, float( 0 ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_WAIT_FOR_MOVEMENT, float( 0 ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_REMEMBER, float( bits_MEMORY_INCOVER ) ) );
	slMinerTakeCover.AddTask( ScriptTask( TASK_SET_SCHEDULE, float( SCHED_MINER_WAIT_FACE_ENEMY ) ) );
	
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_STOP_MOVING, float( 0 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_FIND_COVER_FROM_ENEMY, float( 99 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_FIND_FAR_NODE_COVER_FROM_ENEMY, float( 384 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_PLAY_SEQUENCE, float( ACT_SPECIAL_ATTACK1 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_CLEAR_MOVE_WAIT, float( 0 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_RUN_PATH, float( 0 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_WAIT_FOR_MOVEMENT, float( 0 ) ) );
	slMinerGrenadeCover.AddTask( ScriptTask( TASK_SET_SCHEDULE, float( SCHED_MINER_WAIT_FACE_ENEMY ) ) );
	
	slMinerTossGrenadeCover.AddTask( ScriptTask( TASK_FACE_ENEMY, float( 0 ) ) );
	slMinerTossGrenadeCover.AddTask( ScriptTask( TASK_RANGE_ATTACK2, float( 0 ) ) );
	slMinerTossGrenadeCover.AddTask( ScriptTask( TASK_SET_SCHEDULE, float( SCHED_TAKE_COVER_FROM_ENEMY ) ) );
	
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_SET_FAIL_SCHEDULE, float( SCHED_COWER ) ) );
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_STOP_MOVING, float( 0 ) ) );
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_FIND_COVER_FROM_BEST_SOUND, float( 0 ) ) );
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_RUN_PATH, float( 0 ) ) );
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_WAIT_FOR_MOVEMENT, float( 0 ) ) );
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_REMEMBER, float( bits_MEMORY_INCOVER ) ) );
	slMinerTakeCoverFromBestSound.AddTask( ScriptTask( TASK_TURN_LEFT, float( 179 ) ) );
	
	slMinerSweep.AddTask( ScriptTask( TASK_TURN_LEFT, float( 179 ) ) );
	slMinerSweep.AddTask( ScriptTask( TASK_WAIT, float( 1 ) ) );
	slMinerSweep.AddTask( ScriptTask( TASK_TURN_LEFT, float( 179 ) ) );
	slMinerSweep.AddTask( ScriptTask( TASK_WAIT, float( 1 ) ) );

	slMinerRangeAttack2.AddTask( ScriptTask( TASK_STOP_MOVING, float( 0 ) ) );
	slMinerRangeAttack2.AddTask( ScriptTask( TASK_MINER_FACE_TOSS_DIR, float( 0 ) ) );
	//slMinerRangeAttack2.AddTask( ScriptTask( TASK_PLAY_SEQUENCE, float( ACT_RANGE_ATTACK2 ) ) );
	slMinerRangeAttack2.AddTask( ScriptTask( TASK_PLAY_THROWGRENADE_SEQUENCE, float( 0 ) ) );
	slMinerRangeAttack2.AddTask( ScriptTask( TASK_SET_SCHEDULE, float( SCHED_MINER_WAIT_FACE_ENEMY ) ) );

	array<ScriptSchedule@> scheds =
	{
		slMinerFail,
		slMinerVictoryDance,
		slMinerEstablishLineOfFire,
		slMinerFoundEnemy,
		slMinerWaitInCover,
		slMinerTakeCover,
		slMinerGrenadeCover,
		slMinerTossGrenadeCover,
		slMinerTakeCoverFromBestSound,
		slMinerSweep,
		slMinerRangeAttack2,
	};

	@monster_bigminer_schedules = @scheds;
}

void Register()
{
	InitSchedules();
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_BigMiner::monster_bigminer", "monster_bigminer" );
}

} // end of HLWanted_BigMiner namespace