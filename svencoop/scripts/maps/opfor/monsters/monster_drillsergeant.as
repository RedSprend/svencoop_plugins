/*
* 	(!) CTalkMonster is not exposed. Useless until SC dev implements it. Dammit!
*/

class monster_drillsergeant : ScriptBaseMonsterEntity
{
	private int DRILL_GROUP_BODY 			= 0;
	private int DRILL_GROUP_ACCESSORIES 		= 0;

	private int DRILL_ACCESSORIES_NONE		= 0;
	private int DRILL_ACCESSORIES_WHISTLE		= 1;
	private int DRILL_ACCESSORIES_MEGAPHONE		= 2;
	private int DRILL_ACCESSORIES_BINOCULARS	= 2;

	private float m_painTime;

	int ISoundMask( void ) 
	{
		return	bits_SOUND_WORLD	|
			bits_SOUND_COMBAT	|
			bits_SOUND_CARCASS	|
			bits_SOUND_MEAT		|
			bits_SOUND_GARBAGE	|
			bits_SOUND_DANGER	|
			bits_SOUND_PLAYER;
	}

	int Classify( void )
	{
		return self.GetClassification( CLASS_PLAYER_ALLY );
	}

	void SetYawSpeed( void )
	{
		int ys;

		ys = 0;

		switch ( self.m_Activity )
		{
			case ACT_IDLE:
			case ACT_WALK:	
				ys = 70;
				break;

			case ACT_RUN:
				ys = 90;
				break;

			default:
				ys = 70;
				break;
		}

		self.pev.yaw_speed = ys;
	}

	void Spawn()
	{
		Precache();

		g_EntityFuncs.SetModel(self, "models/drill.mdl");
		g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX);

		self.pev.solid			= SOLID_SLIDEBOX;
		self.pev.movetype		= MOVETYPE_STEP;
		self.m_bloodColor		= BLOOD_COLOR_RED;
		self.pev.health			= 100.0f;
		self.pev.view_ofs		= Vector ( 0, 0, 50 );// position of the eyes relative to monster's origin.
		self.m_flFieldOfView		= VIEW_FIELD_WIDE; // NOTE: we need a wide field of view so npc will notice player and say hello
		self.m_MonsterState		= MONSTERSTATE_NONE;
		self.m_afCapability		= bits_CAP_HEAR | bits_CAP_TURN_HEAD | bits_CAP_DOORS_GROUP;

		CTalkMonster@ pTalkMonster;
		self.MonsterInit();
		SetUse( UseFunction( BaseClass.FollowerPlayerUse ) );
	}

	void Precache()
	{
		BaseClass.Precache();

		g_Game.PrecacheModel("models/drill.mdl");
		g_SoundSystem.PrecacheSound("drill/shit.wav");	// Fograin92: For all yours pain and death sounds needs.
		g_Game.PrecacheGeneric( "sound/" + "drill/shit.wav" );

		self.TalkInit();
	}

	void TalkInit()
	{
		BaseClass.TalkInit();

		// Drill instructor will try to talk to friends in this order:
		self.m_szFriends[0] = "monster_drillsergeant";
		self.m_szFriends[1] = "monster_recruit";
		self.m_szFriends[2] = "monster_human_grunt_ally";

		if( self.pev.skin == 1 )
		{
			self.m_szGrp[TLK_ANSWER]	=	"DR_DR2_ADD";
			self.m_szGrp[TLK_QUESTION]	=	"DR_DR2_ADD";
			self.m_szGrp[TLK_IDLE]		=	"0";
			self.m_szGrp[TLK_STARE]		=	"0";
			self.m_szGrp[TLK_USE]		=	"DR_DR2_ADD";
			self.m_szGrp[TLK_UNUSE]		=	"DR_DR2_ADD";
			self.m_szGrp[TLK_STOP]		=	"0";
			self.m_szGrp[TLK_NOSHOOT]	=	"0";
			self.m_szGrp[TLK_HELLO]		=	"0";
			self.m_szGrp[TLK_PHELLO]	=	"0";
			self.m_szGrp[TLK_PIDLE]		=	"0";
			self.m_szGrp[TLK_PQUESTION]	=	"0";
			self.m_szGrp[TLK_SMELL]		=	"0";
			self.m_szGrp[TLK_WOUND]		=	"0";
			self.m_szGrp[TLK_MORTAL]	=	"0";
		}
		else
		{
			self.m_szGrp[TLK_ANSWER]	=	"DR_ADD";
			self.m_szGrp[TLK_QUESTION]	=	"DR_ADD";
			self.m_szGrp[TLK_IDLE]		=	"0";
			self.m_szGrp[TLK_STARE]		=	"0";
			self.m_szGrp[TLK_USE]		=	"DR_ADD";
			self.m_szGrp[TLK_UNUSE]		=	"DR_ADD";
			self.m_szGrp[TLK_STOP]		=	"0";
			self.m_szGrp[TLK_NOSHOOT]	=	"0";
			self.m_szGrp[TLK_HELLO]		=	"0";
			self.m_szGrp[TLK_PHELLO]	=	"0";
			self.m_szGrp[TLK_PIDLE]		=	"0";
			self.m_szGrp[TLK_PQUESTION]	=	"0";
			self.m_szGrp[TLK_SMELL]		=	"0";
			self.m_szGrp[TLK_WOUND]		=	"0";
			self.m_szGrp[TLK_MORTAL]	=	"0";
		}

		self.m_voicePitch = 100;
	}

	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		// make sure friends talk about it if player hurts talkmonsters...
		int ret = BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
		return ret;
	}

	void PainSound( void )
	{
		if (g_Engine.time < m_painTime)
			return;

		m_painTime = g_Engine.time + Math.RandomFloat(0.5, 0.75);
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "drill/shit.wav", 1, ATTN_NORM, 0, self.GetVoicePitch() );
	}

	void DeathSound( void )
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "drill/shit.wav", 1, ATTN_NORM, 0, self.GetVoicePitch() );
	}

	void TraceAttack( entvars_t@ pevAttacker, float flDamage, Vector vecDir, TraceResult ptr, int bitsDamageType )
	{
		switch( ptr.iHitgroup)
		{
			case 10:
				// always a head shot
				ptr.iHitgroup = HITGROUP_HEAD;
			break;
		}

		BaseClass.TraceAttack( pevAttacker, flDamage, vecDir, ptr, bitsDamageType );
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		SetBodygroup( DRILL_GROUP_ACCESSORIES, DRILL_ACCESSORIES_NONE ); // Empty hands
		SetUse( null );	
		BaseClass.Killed( pevAttacker, iGib );
	}

	Schedule@ GetScheduleOfType( int Type )
	{
		return BaseClass.GetScheduleOfType( Type );
	}

	Schedule@ GetSchedule( void )
	{
		switch( self.m_MonsterState )
		{
			case MONSTERSTATE_ALERT:	
			case MONSTERSTATE_IDLE:
				if ( self.HasConditions(bits_COND_LIGHT_DAMAGE | bits_COND_HEAVY_DAMAGE ) )
				{
					// flinch if hurt
					return BaseClass.GetScheduleOfType( SCHED_SMALL_FLINCH );
				}

				if ( self.m_hEnemy == 0 && self.IsFollowing() )
				{
					if ( !self.m_hTargetEnt.IsAlive() )
					{
						// UNDONE: Comment about the recently dead player here?
						self.StopFollowing( FALSE );
						break;
					}
					else
					{
						if ( self.HasConditions( bits_COND_CLIENT_PUSH ) )
						{
							return BaseClass.GetScheduleOfType( SCHED_MOVE_AWAY_FOLLOW );
						}
						return BaseClass.GetScheduleOfType( SCHED_TARGET_FACE );
					}
				}

				if ( self.HasConditions( bits_COND_CLIENT_PUSH ) )
				{
					return BaseClass.GetScheduleOfType( SCHED_MOVE_AWAY );
				}
			break;
		}
		return BaseClass.GetSchedule();
	}

	MONSTERSTATE GetIdealState( void )
	{
		return BaseClass.GetIdealState();
	}

	//void DeclineFollowing( void )
	void StopPlayerFollowing( const bool bClearSchedule )
	{
		if( self.pev.skin == 1 )
			self.PlaySentence( "DR_DR2_ADD", 2, VOL_NORM, ATTN_NORM );
		else
			self.PlaySentence( "DR_ADD", 2, VOL_NORM, ATTN_NORM );
	}
}

string GetDrillSergeantName()
{
	return "monster_drillsergeant";
}

void RegisterDrillSergeant()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "monster_drillsergeant", DrillSergeantName() );
}