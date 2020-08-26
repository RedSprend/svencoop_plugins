// TO-DO:
// - Roam freely on the level/map, like a roach
// - Attack scorpions

namespace HLWanted_Chicken
{
const int CHICKEN_IDLE			= 0;
const int CHICKEN_BORED			= 1;
const int CHICKEN_SCARED_BY_ENT		= 2;

const array<string> pIdleSounds =
{
	"wanted/chicken/chick_cluck.wav",
	"wanted/chicken/chick_scream3.wav",
	"wanted/chicken/chick_scream4.wav",
	"wanted/chicken/chick_scream5.wav"
};

const array<string> pFearSounds =
{
	"wanted/chicken/chick_scream1.wav",
	"wanted/chicken/chick_scream2.wav"
};

class monster_chicken : ScriptBaseMonsterEntity
{
	private int SF_MONSTER_FADECORPSE = 512;

	CBaseEntity@ m_pLink = null;

	private int	m_iMode;

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

	void Spawn()
	{
		Precache( );

		g_EntityFuncs.SetModel( self, "models/wanted/chicken.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector(-12, -12, 0), Vector(12, 12, 20) );

		self.pev.solid		= SOLID_SLIDEBOX;
		self.pev.movetype	= MOVETYPE_STEP;
		self.m_bloodColor	= BLOOD_COLOR_RED;
		self.pev.effects	= 0;
		self.pev.health		= 5;
		self.m_flFieldOfView	= 0.5;// indicates the width of this monster's forward view cone ( as a dotproduct result )
		self.m_MonsterState	= MONSTERSTATE_NONE;

		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Chicken" );
		//g_EntityFuncs.DispatchKeyValue( self.edict(), "is_player_ally", "1" ); // not killable by players with this

		self.MonsterInit();
		self.SetActivity( ACT_IDLE );

		self.pev.view_ofs	= Vector ( 0, 0, 1 );// position of the eyes relative to monster's origin.
		self.pev.takedamage	= DAMAGE_YES;
		m_iMode			= CHICKEN_IDLE;

		SetThink( ThinkFunction( MonsterThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void Precache()
	{
		g_Game.PrecacheModel("models/wanted/chicken.mdl");
		g_Game.PrecacheModel("models/wanted/chickengibs.mdl");
		g_Game.PrecacheModel("models/wanted/chickenT.mdl");
		g_Game.PrecacheModel("models/wanted/feathers.mdl");
		g_Game.PrecacheModel("models/wanted/feathersT.mdl");

		uint i;

		for( i = 0; i < pIdleSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pIdleSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pIdleSounds[i] );
		}

		for( i = 0; i < pFearSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pFearSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pFearSounds[i] );
		}
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		pev.deadflag = DEAD_DYING;
		self.FCheckAITrigger();

		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "common/null.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );

		pev.health = 0;

		pev.solid = SOLID_NOT;
		pev.takedamage = DAMAGE_NO;
		pev.velocity = g_vecZero;

		g_EntityFuncs.SetModel( self, "models/wanted/feathers.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector(0, 0, 0), Vector(0, 0, 0) );

		pev.frame = 0;
		pev.sequence = self.LookupSequence( "idle" );
		self.ResetSequenceInfo();

		SetTouch( null );
		SetThink( ThinkFunction( DyingThink ) );
		pev.nextthink = g_Engine.time + 0.1;

		//g_EntityFuncs.Remove( self );
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
			else // "Don't Fade Corpse" is enabled
			{
				SetThink( null );
				return;
			}
		}
	}

	void MonsterThink( void )
	{
		float flInterval = self.StudioFrameAdvance();
		pev.nextthink = g_Engine.time + 0.1;
		self.DispatchAnimEvents( flInterval );

		switch( self.m_Activity )
		{
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
		default:
			BaseClass.Think();
			break;
		}
	}

	/*void Think( void  )
	{
		pev.nextthink = g_Engine.time + 0.1f;

		float flInterval = self.StudioFrameAdvance( ); // animate

		switch( m_iMode )
		{
		case CHICKEN_IDLE:
			{
				// if not moving, sample environment to see if anything scary is around. Do a radius search 'look' at random.
				if( Math.RandomLong(0,3) == 1 )
				{
					self.Look( 150 );
					if( self.HasConditions( bits_COND_SEE_FEAR ) )
					{
						if( Math.RandomLong(0,1) == 1 )
							FearSound();

						// if see something scary
						PickNewDest( CHICKEN_SCARED_BY_ENT );
						self.SetActivity( ACT_RUN );
					}
					else if( Math.RandomLong(0, 149) == 1 )
					{
						if( Math.RandomLong(0,1) == 1 )
							IdleSound();

						// if roach doesn't see anything, there's still a chance that it will move. (boredom)
						PickNewDest( CHICKEN_BORED );
						self.SetActivity( ACT_WALK );
					}
				}
				break;
			}
		}
	
		if( self.m_flGroundSpeed != 0 )
		{
			Move( flInterval );
		}
	}*/

	void PickNewDest( int iCondition )
	{
		g_EngineFuncs.ServerPrint("-- DEBUG: PickNewDest\n");
		Vector	vecNewDir;
		Vector	vecDest;
		float	flDist;

		m_iMode = iCondition;

		do
		{
			// picks a random spot, requiring that it be at least 128 units away
			// else, the roach will pick a spot too close to itself and run in 
			// circles. this is a hack but buys me time to work on the real monsters.
			vecNewDir.x = Math.RandomFloat( -1, 1 );
			vecNewDir.y = Math.RandomFloat( -1, 1 );
			flDist = 256 + ( Math.RandomLong(0,255) );
			vecDest = pev.origin + vecNewDir * flDist;

		} while ( ( vecDest - pev.origin ).Length2D() < 128 );

		self.m_Route( 0 ).vecLocation.x = vecDest.x;
		self.m_Route( 0 ).vecLocation.y = vecDest.y;
		self.m_Route( 0 ).vecLocation.z = pev.origin.z;
		self.m_Route( 0 ).iType = bits_MF_TO_LOCATION;
		self.m_movementGoal = self.RouteClassify( self.m_Route( 0 ).iType );
	}

	void Move( float flInterval ) 
	{
		float		flWaypointDist;
		Vector		vecApex;

		flWaypointDist = ( self.m_Route( self.m_iRouteIndex ).vecLocation - pev.origin ).Length2D();
		self.MakeIdealYaw( self.m_Route( self.m_iRouteIndex ).vecLocation );

		self.ChangeYaw( int(self.pev.yaw_speed) );
		Math.MakeVectors( pev.angles );

		if( Math.RandomLong(0, 7) == 1 )
		{
			if ( g_EngineFuncs.WalkMove( self.edict(), pev.ideal_yaw, 4, WALKMOVE_NORMAL ) == 0 )
			{
				PickNewDest( m_iMode );
			}
		}
	
		g_EngineFuncs.WalkMove( self.edict(), pev.ideal_yaw, self.m_flGroundSpeed * flInterval, WALKMOVE_NORMAL );

		if( flWaypointDist <= self.m_flGroundSpeed * flInterval )
		{
			self.SetActivity( ACT_IDLE );
			m_iMode = CHICKEN_IDLE;
		}

		if( Math.RandomLong(0, 149) == 1 )
		{
			PickNewDest( 0 );
		}
	}

	void IdleSound()
	{
		// Play a random idle sound
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0,(pIdleSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void FearSound()
	{
		// Play a random idle sound
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pFearSounds[Math.RandomLong(0,(pFearSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void Look( int iDistance )
	{
		CBaseEntity@ pSightEnt = null;
		CBaseEntity@ pPreviousEnt;
		int iSighted = 0;

		self.ClearConditions( bits_COND_SEE_HATE | bits_COND_SEE_DISLIKE | bits_COND_SEE_ENEMY | bits_COND_SEE_FEAR );

		@pSightEnt = @g_EntityFuncs.Instance( g_EngineFuncs.FindClientInPVS( self.edict() ) );
		if( pSightEnt is null )
		{
			return;
		}

		@m_pLink = null;
		@pPreviousEnt = self;

		while ((@pSightEnt = g_EntityFuncs.FindEntityInSphere( pSightEnt, pev.origin, iDistance )) !is null)
		{
			if( pSightEnt.IsPlayer() || pSightEnt.pev.FlagBitSet( FL_MONSTER ) && self.IRelationship(pSightEnt) > R_AL )
			{
				if( !pSightEnt.pev.FlagBitSet( FL_NOTARGET ) && pSightEnt.pev.health > 0 )
				{
					//@pPreviousEnt.m_pLink = pSightEnt;
					//@pSightEnt.m_pLink = null;
					@cast<monster_chicken@>(CastToScriptClass(pPreviousEnt)).m_pLink = pSightEnt;
					@cast<monster_chicken@>(CastToScriptClass(pSightEnt)).m_pLink = null;
					@pPreviousEnt = @pSightEnt;

					switch( self.IRelationship( pSightEnt ) )
					{
					case	R_FR:
						iSighted |= bits_COND_SEE_FEAR;
						break;
					case	R_NO:
						break;
					default:
						break;
					}
				}
			}
		}
		self.SetConditions( iSighted );
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
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Chicken::monster_chicken", "monster_chicken" );
}

} //namespace HLWanted_Chicken END