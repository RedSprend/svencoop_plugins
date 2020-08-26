namespace HEVORANGE
{
const int ACTIVITY_NOT_AVAILABLE 	= -1;

const int HEVORANGE_AE_DRAW		= 2;
const int HEVORANGE_AE_SHOOT		= 3;
const int HEVORANGE_AE_HOLSTER		= 4;

enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEADS,
	BODYGROUP_WEAPONS
}

enum HeadSubModel
{
	HEAD_GORDON = 0,
	HEAD_EINSTEIN,
	HEAD_HELMET
}

enum WeaponSubModel
{
	GUN_PISTOLHOLSTERED = 0,
	GUN_PISTOLDRAWN,
	GUN_357,
	GUN_MP5,
	GUN_SHOTGUN,
	GUN_NONE,
	GUN_PLASMA // Grenade? Plasma gun?
}

class monster_hev_orangehelmet : ScriptBaseMonsterEntity
{
	private bool	m_fGunDrawn;
	private float	m_painTime;
	private int	m_head;
	private int	m_iBrassShell;
	private int	m_cClipSize;
	private float	m_flNextFearScream;
	
	monster_hev_orangehelmet()
	{
		@this.m_Schedules = @monster_hev_orangehelmet_schedules;
	}
	
	int ObjectCaps()
	{
		return BaseClass.ObjectCaps();
	}
	
	void RunTask( Task@ pTask )
	{
		switch ( pTask.iTask )
		{
		case TASK_RANGE_ATTACK1:
			//if (self.m_hEnemy().IsValid() && (self.m_hEnemy().GetEntity().IsPlayer()))
				self.pev.framerate = 1.5f;

			//Friendly fire stuff.
			if( !self.NoFriendlyFire() )
			{
				self.ChangeSchedule( self.GetScheduleOfType ( SCHED_FIND_ATTACK_POINT ) );
				return;
			}

			BaseClass.RunTask( pTask );
			break;
		case TASK_RELOAD:
			{
				self.MakeIdealYaw( self.m_vecEnemyLKP );
				self.ChangeYaw( int(self.pev.yaw_speed) );

				if( self.m_fSequenceFinished )
				{
					self.m_cAmmoLoaded = m_cClipSize;
					self.ClearConditions(bits_COND_NO_AMMO_LOADED);
					//m_Activity = ACT_RESET;

					self.TaskComplete();
				}
				break;
			}
		default:
			BaseClass.RunTask( pTask );
			break;
		}
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

	void SetYawSpeed()
	{
		int ys = 0;

		ys = 360; //270 seems to be an ideal speed, which matches most animations

		self.pev.yaw_speed = ys;
	}

	bool CheckRangeAttack1( float flDot, float flDist )
	{
		if ( flDist <= 2048 && flDot >= 0.5 && self.NoFriendlyFire())
		{
			CBaseEntity@ pEnemy = self.m_hEnemy.GetEntity();
			TraceResult tr;
			Vector shootOrigin = self.pev.origin + Vector( 0, 0, 55 );
			Vector shootTarget = (pEnemy.BodyTarget( shootOrigin ) - pEnemy.Center()) + self.m_vecEnemyLKP;
			g_Utility.TraceLine( shootOrigin, shootTarget, dont_ignore_monsters, self.edict(), tr );
			
			if ( tr.flFraction == 1.0 || tr.pHit is pEnemy.edict() )
				return true;
		}

		return false;
	}
	
	void FirePistol()
	{
		Math.MakeVectors( self.pev.angles );
		Vector vecShootOrigin = self.pev.origin + Vector( 0, 0, 55 );
		Vector vecShootDir = self.ShootAtEnemy( vecShootOrigin );
		Vector angDir = Math.VecToAngles( vecShootDir );

		self.FireBullets(1, vecShootOrigin, vecShootDir, VECTOR_CONE_2DEGREES, 1024, BULLET_MONSTER_9MM );
		Vector vecShellVelocity = g_Engine.v_right * Math.RandomFloat(40,90) + g_Engine.v_up * Math.RandomFloat(75,200) + g_Engine.v_forward * Math.RandomFloat(-40, 40);
		g_EntityFuncs.EjectBrass( vecShootOrigin - vecShootDir * -17, vecShellVelocity, self.pev.angles.y, m_iBrassShell, TE_BOUNCE_SHELL); 

		int pitchShift = Math.RandomLong( 0, 20 );
		if ( pitchShift > 10 )// Only shift about half the time
			pitchShift = 0;
		else
			pitchShift -= 5;

		self.SetBlending( 0, angDir.x );
		self.pev.effects = EF_MUZZLEFLASH;
		GetSoundEntInstance().InsertSound ( bits_SOUND_COMBAT, self.pev.origin, NORMAL_GUN_VOLUME, 0.3, self );
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "weapons/pl_gun3.wav", 1, ATTN_NORM, 0, PITCH_NORM + pitchShift );

		if( self.pev.movetype != MOVETYPE_FLY && self.m_MonsterState != MONSTERSTATE_PRONE )
		{
			self.m_flAutomaticAttackTime = g_Engine.time + Math.RandomFloat(0.2, 0.5);
		}

		// UNDONE: Reload?
		--self.m_cAmmoLoaded;// take away a bullet!
	}

	void CheckAmmo()
	{
		if ( self.m_cAmmoLoaded <= 0 )
			self.SetConditions( bits_COND_NO_AMMO_LOADED );
	}

	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		switch( pEvent.event )
		{
		case HEVORANGE_AE_SHOOT:
			FirePistol();
			break;
		case HEVORANGE_AE_DRAW:
			// barney's bodygroup switches here so he can pull gun from holster
			self.SetBodygroup( BODYGROUP_WEAPONS, GUN_PISTOLDRAWN );
			m_fGunDrawn = true;
			break;
		case HEVORANGE_AE_HOLSTER:
			// change bodygroup to replace gun in holster
			self.SetBodygroup( BODYGROUP_WEAPONS, GUN_PISTOLHOLSTERED );
			m_fGunDrawn = false;
			break;

		default:
			BaseClass.HandleAnimEvent( pEvent );
		}
	}

	void Precache()
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
		{
			g_Game.PrecacheModel( "models/hlclassic/pov/hev_scientist.mdl" );
			g_Game.PrecacheGeneric( "models/hlclassic/pov/hev_scientist01.mdl" );
			g_Game.PrecacheGeneric( "models/hlclassic/pov/hev_scientist02.mdl" );
			g_Game.PrecacheGeneric( "models/hlclassic/pov/hev_scientist03.mdl" );
			g_Game.PrecacheGeneric( "models/hlclassic/pov/hev_scientistt.mdl" );
		}
		else
			g_Game.PrecacheModel( self.pev.model );

		//g_SoundSystem.PrecacheSound("barney/ba_attack1.wav");
		g_SoundSystem.PrecacheSound("barney/ba_attack2.wav");
		g_SoundSystem.PrecacheSound("scientist/sci_pain1.wav");
		g_SoundSystem.PrecacheSound("scientist/sci_pain2.wav");
		g_SoundSystem.PrecacheSound("scientist/sci_pain3.wav");
		g_SoundSystem.PrecacheSound("scientist/sci_pain4.wav");
		g_SoundSystem.PrecacheSound("scientist/sci_pain5.wav");

		m_iBrassShell = g_Game.PrecacheModel("models/shell.mdl");
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/hlclassic/pov/hev_scientist.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );

		g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );

		pev.solid				= SOLID_SLIDEBOX;
		pev.movetype				= MOVETYPE_STEP;
		self.m_bloodColor			= BLOOD_COLOR_RED;

		if( self.pev.health == 0.0f )
			self.pev.health  = 100.0f;

		self.pev.view_ofs			= Vector( 0, 0, 50 );// position of the eyes relative to monster's origin.
		self.m_flFieldOfView			= VIEW_FIELD_WIDE; // NOTE: we need a wide field of view so npc will notice player and say hello
		self.m_MonsterState			= MONSTERSTATE_NONE;
		self.pev.body				= 0; // gun in holster
		m_fGunDrawn				= false;
		self.m_afCapability			= bits_CAP_HEAR | bits_CAP_TURN_HEAD | bits_CAP_DOORS_GROUP | bits_CAP_USE_TANK;
		self.m_fCanFearCreatures 		= true; // Can attempt to run away from things like zombies
		m_flNextFearScream			= g_Engine.time;
		//self.m_afMoveShootCap()		= bits_MOVESHOOT_RANGE_ATTACK1;

		m_cClipSize				= 17; //17 Shots
		self.m_cAmmoLoaded			= m_cClipSize;

		if( string( self.m_FormattedName ).IsEmpty() )
		{
			self.m_FormattedName = "HEV Orange";
		}

		self.MonsterInit();

		self.SetBodygroup( BODYGROUP_HEADS, HEAD_HELMET );
	}
	
	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
	{
		if( pevAttacker is null )
			return 0;

		CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pevAttacker );

		if( self.CheckAttacker( pAttacker ) )
			return 0;

		return BaseClass.TakeDamage(  pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}

	void FearScream()
	{
		if( m_flNextFearScream < g_Engine.time )
		{
			self.PlaySentence( "SC_SCREAM", Math.RandomFloat(3, 6), VOL_NORM, ATTN_NORM );
			m_flNextFearScream = g_Engine.time + 10;
		}
	}
	
	void PainSound()
	{
		if( g_Engine.time < m_painTime )
			return;

		m_painTime = g_Engine.time + Math.RandomFloat(0.5, 0.75);
		switch (Math.RandomLong(0,4))
		{
		case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "scientist/sci_pain1.wav", 1, ATTN_NORM, 0, PITCH_NORM); break;
		case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "scientist/sci_pain2.wav", 1, ATTN_NORM, 0, PITCH_NORM); break;
		case 2: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "scientist/sci_pain3.wav", 1, ATTN_NORM, 0, PITCH_NORM); break;
		case 3: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "scientist/sci_pain4.wav", 1, ATTN_NORM, 0, PITCH_NORM); break;
		case 4: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "scientist/sci_pain5.wav", 1, ATTN_NORM, 0, PITCH_NORM); break;
		}
	}
	
	void DeathSound()
	{
		PainSound();
	}

	void TraceAttack( entvars_t@ pevAttacker, float flDamage, Vector vecDir, TraceResult& in ptr, int bitsDamageType)
	{
		switch( ptr.iHitgroup)
		{
		case HITGROUP_CHEST:
		case HITGROUP_STOMACH:
			if (( bitsDamageType & ( DMG_BULLET | DMG_SLASH | DMG_BLAST) ) != 0)
			{
				if(flDamage >= 2)
					flDamage -= 2;

				flDamage *= 0.5;
			}
			break;
		case 10:
			if (( bitsDamageType & (DMG_SNIPER | DMG_BULLET | DMG_SLASH | DMG_CLUB) ) != 0)
			{
				flDamage -= 20;
				if (flDamage <= 0)
				{
					g_Utility.Ricochet( ptr.vecEndPos, 1.0 );
					flDamage = 0.01;
				}
			}
			// always a head shot
			ptr.iHitgroup = HITGROUP_HEAD;
			break;
		}

		BaseClass.TraceAttack( pevAttacker, flDamage, vecDir, ptr, bitsDamageType );
	}

	Schedule@ GetScheduleOfType( int Type )
	{		
		Schedule@ psched;

		switch( Type )
		{
		case SCHED_ARM_WEAPON:
			if( self.m_hEnemy.IsValid() )
				return slEnemyDraw;// face enemy, then draw.
			break;

		case SCHED_RELOAD:
			return slReloadQuick; //Immediately reload.

		case SCHED_HEVORANGERELOAD:
			return slReload;

		case SCHED_IDLE_STAND:
			// call base class default so that scientist will talk
			// when standing during idle
			@psched = BaseClass.GetScheduleOfType( Type );

			if( psched is Schedules::slIdleStand )
				return slIdleStand;// just look straight ahead.
			else
				return psched;	
		}

		return BaseClass.GetScheduleOfType( Type );
	}

	void SetActivity( Activity NewActivity )
	{
		int iSequence = ACTIVITY_NOT_AVAILABLE;

		switch( NewActivity )
		{
			case ACT_RANGE_ATTACK1:
			switch( self.GetBodygroup( BODYGROUP_WEAPONS ) )
			{
				case GUN_PISTOLHOLSTERED:
				case GUN_PISTOLDRAWN:
					iSequence = self.LookupSequence( "shootgun" );
					break;
				default: break;
			}
			break;

			default:
			iSequence = self.LookupActivity( NewActivity );
			break;
		}

		self.m_Activity = NewActivity; // Go ahead and set this so it doesn't keep trying when the anim is not present

		// Set to the desired anim, or default anim if the desired is not present
		if( iSequence > ACTIVITY_NOT_AVAILABLE )
		{
			if ( self.pev.sequence != iSequence || !self.m_fSequenceLoops )
			{
				self.pev.frame = 0;
			}

			self.pev.sequence = iSequence;	// Set to the reset anim (if it's there)
			self.ResetSequenceInfo( );
			SetYawSpeed();
		}
		else
		{
			// Not available try to get default anim
			self.pev.sequence = 0;	// Set to the reset anim (if it's there)
		}
	}

	Schedule@ GetSchedule()
	{
		if ( self.HasConditions( bits_COND_HEAR_SOUND ) )
		{
			CSound@ pSound = self.PBestSound();

			if( pSound !is null && (pSound.m_iType & bits_SOUND_DANGER) != 0 )
			{
				FearScream(); //AGHH!!!!
				return self.GetScheduleOfType( SCHED_TAKE_COVER_FROM_BEST_SOUND );
			}
		}

		if( self.HasConditions( bits_COND_ENEMY_DEAD ) )
			self.PlaySentence( "BA_KILL", 4, VOL_NORM, ATTN_NORM );

		switch( self.m_MonsterState )
		{
		case MONSTERSTATE_COMBAT:
			{
				// dead enemy
				if( self.HasConditions( bits_COND_ENEMY_DEAD ) )				
					return BaseClass.GetSchedule();// call base class, all code to handle dead enemies is centralized there.

				// always act surprized with a new enemy
				if( self.HasConditions( bits_COND_NEW_ENEMY ) && self.HasConditions( bits_COND_LIGHT_DAMAGE) )
					return self.GetScheduleOfType( SCHED_SMALL_FLINCH );

				// wait for one schedule to draw gun
				if( !m_fGunDrawn )
					return self.GetScheduleOfType( SCHED_ARM_WEAPON );

				if( self.HasConditions( bits_COND_HEAVY_DAMAGE ) )
					return self.GetScheduleOfType( SCHED_TAKE_COVER_FROM_ENEMY );

				if( self.HasConditions ( bits_COND_NO_AMMO_LOADED ) )
					return self.GetScheduleOfType ( SCHED_HEVORANGERELOAD );
			}
			break;

		case MONSTERSTATE_IDLE:
				if ( self.m_cAmmoLoaded != m_cClipSize )
					return self.GetScheduleOfType( SCHED_HEVORANGERELOAD );

		case MONSTERSTATE_ALERT:	
			{
				if ( self.HasConditions(bits_COND_LIGHT_DAMAGE | bits_COND_HEAVY_DAMAGE) )
					return self.GetScheduleOfType( SCHED_SMALL_FLINCH ); // flinch if hurt
			}
			break;
		}

		return BaseClass.GetSchedule();
	}
}

array<ScriptSchedule@>@ monster_hev_orangehelmet_schedules;

ScriptSchedule slIdleStand(
	bits_COND_NEW_ENEMY	|
	bits_COND_LIGHT_DAMAGE	|
	bits_COND_HEAVY_DAMAGE	|
	bits_COND_HEAR_SOUND	|
	bits_COND_SMELL,

	bits_SOUND_COMBAT	|// sound flags - change these, and you'll break the talking code.	
	bits_SOUND_DANGER	|
	bits_SOUND_MEAT		|// scents
	bits_SOUND_CARCASS	|
	bits_SOUND_GARBAGE,
	"IdleStand" );

ScriptSchedule slReload(
	bits_COND_HEAVY_DAMAGE	|
	bits_COND_HEAR_SOUND,
	bits_SOUND_DANGER,
	"Reload");

ScriptSchedule slReloadQuick(
	bits_COND_HEAVY_DAMAGE	|
	bits_COND_HEAR_SOUND,
	bits_SOUND_DANGER,
	"Reload Quick");

ScriptSchedule slEnemyDraw( 0, 0, "Enemy Draw" );

void InitSchedules()
{
	slEnemyDraw.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slEnemyDraw.AddTask( ScriptTask(TASK_FACE_ENEMY) );
	slEnemyDraw.AddTask( ScriptTask(TASK_PLAY_SEQUENCE_FACE_ENEMY, float(ACT_ARM)) );

	slIdleStand.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slIdleStand.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
	slIdleStand.AddTask( ScriptTask(TASK_WAIT, 2) );
	//slIdleStand.AddTask( ScriptTask(TASK_TLK_HEADRESET) );

	slReload.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slReload.AddTask( ScriptTask(TASK_SET_FAIL_SCHEDULE, float(SCHED_RELOAD)) );
	slReload.AddTask( ScriptTask(TASK_FIND_COVER_FROM_ENEMY) );
	slReload.AddTask( ScriptTask(TASK_RUN_PATH) );
	slReload.AddTask( ScriptTask(TASK_REMEMBER, float(bits_MEMORY_INCOVER)) );
	slReload.AddTask( ScriptTask(TASK_WAIT_FOR_MOVEMENT_ENEMY_OCCLUDED) );
	slReload.AddTask( ScriptTask(TASK_RELOAD) );
	slReload.AddTask( ScriptTask(TASK_FACE_ENEMY) );

	slReloadQuick.AddTask( ScriptTask(TASK_STOP_MOVING) );
	slReloadQuick.AddTask( ScriptTask(TASK_RELOAD) );
	slReloadQuick.AddTask( ScriptTask(TASK_FACE_ENEMY) );

	array<ScriptSchedule@> scheds = {slEnemyDraw, slIdleStand, slReload, slReloadQuick};

	@monster_hev_orangehelmet_schedules = @scheds;
}

enum monsterScheds
{
	SCHED_HEVORANGERELOAD = LAST_COMMON_SCHEDULE + 1,
}

void Register()
{
	InitSchedules();
	g_CustomEntityFuncs.RegisterCustomEntity( "HEVORANGE::monster_hev_orangehelmet", "monster_hev_orangehelmet" );
}

} // end of namespace