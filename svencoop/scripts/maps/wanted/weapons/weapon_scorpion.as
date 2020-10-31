namespace HLWanted_Scorpion
{
const int SCORPION_DEFAULT_GIVE = 5;
const int SCORPION_MAX_CARRY 	= 20;
const int SCORPION_WEIGHT 	= 5;

enum w_scorpion_e
{
	WSCORPION_IDLE1 = 0,
	WSCORPION_FIDGET,
	WSCORPION_JUMP,
	WSCORPION_RUN,
};

uint WEAPON_SCORPION = 17;

class monster_scorpion : CBaseCustomMonster
{
	private float m_flDie;
	private Vector m_vecTarget;
	private float m_flNextHunt;
	private Vector m_posPrev;
	private EHandle m_hOwner;
	private int m_iMyClass;

	private float m_flNextBounceSoundTime = 0;

	private float SCORPION_DETONATE_DELAY = 15.0f;
	private int SCORPION_BITE = 5;

	int Classify( void )
	{
		if( m_iMyClass != 0 )
			return m_iMyClass; // protect against recursion

		if( self.m_hEnemy.IsValid() )
		{
			m_iMyClass = CLASS_INSECT; // no one cares about it
			switch( self.m_hEnemy.GetEntity().Classify() )
			{
				case CLASS_PLAYER:
				case CLASS_HUMAN_PASSIVE:
				case CLASS_HUMAN_MILITARY:
					m_iMyClass = 0;
					return CLASS_ALIEN_MILITARY; // barney's get mad, grunts get mad at it
			}
			m_iMyClass = 0;
		}

		return CLASS_ALIEN_BIOWEAPON;
	}

	void Spawn( void )
	{
		Precache();

		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;

		g_EntityFuncs.SetModel( self, "models/wanted/w_scorpion.mdl") ;
		g_EntityFuncs.SetSize( self.pev, Vector( -4, -4, 0 ), Vector( 4, 4, 8 ) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		SetTouch( TouchFunction( SuperBounceTouch ) );
		SetThink( ThinkFunction( HuntThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
		m_flNextHunt = g_Engine.time + 1E6;

		self.pev.flags 			|= FL_MONSTER;
		self.pev.takedamage 		= DAMAGE_AIM;
		self.pev.health 		= 2.0f;
		self.pev.gravity 		= 1.0f;
		self.pev.friction 		= 0.5f;
		self.m_bloodColor		= BLOOD_COLOR_RED;

		self.pev.dmg 			= 8.0f;

		m_flDie 			= g_Engine.time + SCORPION_DETONATE_DELAY;

		self.m_flFieldOfView 		= 0; // 180 degrees

		//if( self.pev.owner is null )
		{
			m_hOwner = g_EntityFuncs.Instance( self.pev.owner );
		}

		m_flNextBounceSoundTime 	= g_Engine.time;// reset each time a scorpion is spawned.

		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Scorpion" );

		self.pev.sequence = WSCORPION_RUN;
		self.ResetSequenceInfo( );
	}

	void Precache( void )
	{
		g_Game.PrecacheModel( "models/wanted/w_scorpion.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_scorpiont.mdl" );
		g_SoundSystem.PrecacheSound( "common/bodysplat.wav" );
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_die1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_die1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_hunt1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_hunt1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_hunt2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_hunt2.wav" );
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_hunt3.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_hunt3.wav" );
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_deploy1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_deploy1.wav" );
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		pev.deadflag = DEAD_DYING;
		self.FCheckAITrigger();

		pev.health = 0;

		pev.solid = SOLID_NOT;
		pev.takedamage = DAMAGE_NO;
		pev.velocity = g_vecZero;

		pev.sequence = self.LookupSequence( "die" );

		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_die1.wav", 1, ATTN_NORM, 0, 100 + Math.RandomLong(0,0x3F));

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

			pev.sequence = self.LookupSequence( "dead" );
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

	void GibMonster( void )
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "common/bodysplat.wav", 0.75, ATTN_NORM, 0, 200 );		
	}

	void HuntThink( void )
	{
		if( !self.IsInWorld() )
		{
			SetTouch( null );
			SetThink( ThinkFunction( DestroyThink ) );
			return;
		}
	
		self.StudioFrameAdvance( );
		pev.nextthink = g_Engine.time + 0.1;

		// explode when ready
		if( g_Engine.time >= m_flDie )
		{
			pev.health = -1;
			Killed( self.pev, 0 );
			return;
		}

		// float
		if( pev.waterlevel != 0 )
		{
			if( pev.movetype == MOVETYPE_BOUNCE )
			{
				pev.movetype = MOVETYPE_FLY;
			}
			pev.velocity = pev.velocity * 0.9;
			pev.velocity.z += 8.0;
		}
		else if( pev.movetype == MOVETYPE_FLY )
		{
			pev.movetype = MOVETYPE_BOUNCE;
		}

		// return if not time to hunt
		if( m_flNextHunt > g_Engine.time )
			return;

		m_flNextHunt = g_Engine.time + 2.0;
	
		Vector vecDir;
		Vector vecDirToEnemy;
		TraceResult tr;

		Vector vecFlat = pev.velocity;
		vecFlat.z = 0;
		vecFlat = vecFlat.Normalize();

		Math.MakeVectors( pev.angles );

		self.m_hEnemy = FindClosestEnemy();

		// squeek if it's about time blow up
		if( (m_flDie - g_Engine.time <= 0.5) && (m_flDie - g_Engine.time >= 0.3) )
		{
			GetSoundEntInstance().InsertSound( bits_SOUND_COMBAT, pev.origin, 256, 0.25, self );
		}

		// higher pitch as squeeker gets closer to detonation time
		float flpitch = 155.0 - 60.0 * ((m_flDie - g_Engine.time) / SCORPION_DETONATE_DELAY);
		if (flpitch < 80)
			flpitch = 80;

		if( self.m_hEnemy.IsValid() )
		{
			if( self.FVisible( self.m_hEnemy, true ) )
			{
				vecDir = self.m_hEnemy.GetEntity().EyePosition() - pev.origin;
				m_vecTarget = vecDir.Normalize( );
			}

			float flVel = pev.velocity.Length();
			float flAdj = 50.0 / (flVel + 10.0);

			if (flAdj > 1.2)
				flAdj = 1.2;

			pev.velocity = pev.velocity * flAdj + m_vecTarget * 300;
			pev.velocity.z = 0;
		}

		if( (pev.flags & FL_ONGROUND) != 0 )
		{
			pev.avelocity = Vector( 0, 0, 0 );
		}
		else
		{
			if( pev.avelocity == Vector( 0, 0, 0) )
			{
				pev.avelocity.x = Math.RandomFloat( -100, 100 );
				pev.avelocity.z = Math.RandomFloat( -100, 100 );
			}
		}

		if( (pev.origin - m_posPrev).Length() < 1.0 )
		{
			pev.velocity.x = Math.RandomFloat( -100, 100 );
			pev.velocity.y = Math.RandomFloat( -100, 100 );
		}
		m_posPrev = pev.origin;

		pev.angles = Math.VecToAngles( pev.velocity );
		pev.angles.z = 0;
		pev.angles.x = 0;

		if( pev.movetype != MOVETYPE_FLY ) // Fix for the scorpion to be able to step up on slopes, stairs e.g.
			g_EngineFuncs.WalkMove( self.edict(), self.pev.angles.y, 0.5, int(WALKMOVE_NORMAL) );
	}

	void SuperBounceTouch( CBaseEntity@ pOther )
	{
		float flpitch;

		// it's not another scorpiongrenade
		if( pOther.pev.modelindex == pev.modelindex // it's not another scorpiongrenade
			|| pev.owner !is null && pOther.edict() is pev.owner // don't hit the guy that launched this grenade
			|| pOther.IsPlayer() && (m_hOwner.IsValid() && m_hOwner.GetEntity().entindex() != pOther.entindex()) ) // don't hit owner's teammates
			return;

		// at least until we've bounced once
		@pev.owner = null;

		pev.angles.x = 0;
		pev.angles.z = 0;

		// higher pitch as squeeker gets closer to detonation time
		flpitch = 155.0 - 60.0 * ((m_flDie - g_Engine.time) / SCORPION_DETONATE_DELAY);

		if( pOther.pev.takedamage > DAMAGE_NO && self.m_flNextAttack < g_Engine.time )
		{
			if( m_hOwner.IsValid() )
				pOther.TakeDamage( self.pev, m_hOwner.GetEntity().pev, SCORPION_BITE, DMG_POISON );
			else
				pOther.TakeDamage( self.pev, self.pev, SCORPION_BITE, DMG_POISON );

			// make bite sound
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "wanted/scorpion/scorp_deploy1.wav", 1.0, ATTN_NORM, 0, int(flpitch));
			self.m_flNextAttack = g_Engine.time + 0.5;
		}

		m_flNextHunt = g_Engine.time;

		// in multiplayer, we limit how often scorpions can make their bounce sounds to prevent overflows.
		if ( g_Engine.time < m_flNextBounceSoundTime )
		{
			// too soon!
			return;
		}

		if( !self.pev.FlagBitSet( FL_ONGROUND ) )
		{
			// play bounce sound
			float flRndSound = Math.RandomFloat ( 0 , 1 );

			if ( flRndSound <= 0.33 )
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt1.wav", 1, ATTN_NORM, 0, int(flpitch));		
			else if (flRndSound <= 0.66)
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt2.wav", 1, ATTN_NORM, 0, int(flpitch));
			else
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt3.wav", 1, ATTN_NORM, 0, int(flpitch));
			GetSoundEntInstance().InsertSound( bits_SOUND_COMBAT, pev.origin, 256, 0.25f, self );
		}
		else
		{
			// skittering sound
			GetSoundEntInstance().InsertSound( bits_SOUND_COMBAT, pev.origin, 100, 0.1f, self );
		}

		m_flNextBounceSoundTime = g_Engine.time + 0.5;// half second.
	}

	CBaseEntity@ FindClosestEnemy()
	{
		CBaseEntity@ ent = null;
		float iNearest = 4096;

		do
		{
			@ent = g_EntityFuncs.FindEntityInSphere( ent, self.pev.origin, iNearest, "*", "classname" );

			if( ent is null || ent.pev.classname == "squadmaker" || !ent.IsAlive() ||
				ent.pev.classname == "monster_horse" ||
				ent.pev.classname == "monster_chicken" ||
				ent.pev.classname == "monster_tied_colonel" )
				continue;

			if( ent.entindex() == self.entindex() || ent.pev.modelindex == pev.modelindex )
				continue;

			if( m_hOwner.IsValid() && ( ent.entindex() == m_hOwner.GetEntity().entindex() || ent.IsPlayer() || ent.IsPlayerAlly() ) )
				continue;

			int rel = self.IRelationship(ent);
			if ( rel == R_AL || rel == R_NO )
				continue;

			float iDist = ( ent.pev.origin - self.pev.origin ).Length();
			if ( iDist < iNearest )
			{
				iNearest = iDist;
				@self.pev.enemy = ent.edict();
			}
		}
		while ( ent !is null );

		return g_EntityFuncs.Instance( self.pev.enemy );
	}

	/*CBaseEntity@ BestVisibleEnemy()
	{
		CBaseEntity@ pReturn = null;

		while( ( @pReturn = g_EntityFuncs.FindEntityInSphere( pReturn, self.pev.origin, m_fRange, "monster_*", "classname" ) ) !is null )
		{
			if( self.IRelationship( pReturn ) > ( R_NO ) && pReturn.IsAlive() )
				return pReturn;
		}
		return pReturn;
	}*/

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

enum scorpion_e
{
	SCORPION_IDLE1 = 0,
	SCORPION_FIDGET,
	SCORPION_IDLE2,
	SCORPION_HOLSTER,
	SCORPION_DRAW,
	SCORPION_THROW
};

class weapon_scorpion : CBaseCustomWeapon
{
	private int m_fJustThrown;

	void Spawn()
	{
		Precache( );
		//self.m_iId = WEAPON_SCORPION;
		g_EntityFuncs.SetModel(self, "models/wanted/w_scorpnest.mdl");

		self.m_iDefaultAmmo = SCORPION_DEFAULT_GIVE;

		self.FallInit();

		self.pev.sequence = 1;
		self.pev.animtime = g_Engine.time;
		self.pev.framerate = 1.0;
	}

	void Precache( void )
	{
		g_Game.PrecacheModel("models/wanted/w_scorpnest.mdl");
		g_Game.PrecacheModel("models/wanted/w_scorpnestt.mdl");
		g_Game.PrecacheModel("models/wanted/v_scorpion.mdl");
		g_Game.PrecacheModel("models/wanted/p_scorpion.mdl");
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_hunt2.wav");
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_hunt2.wav" );
		g_SoundSystem.PrecacheSound( "wanted/scorpion/scorp_hunt3.wav");
		g_Game.PrecacheGeneric( "sound/" + "wanted/scorpion/scorp_hunt3.wav" );

		g_SoundSystem.PrecacheSound( "items/gunpickup2.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud3.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud6.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_scorpion.txt" );

		g_Game.PrecacheOther( "monster_scorpion" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 = SCORPION_MAX_CARRY;
		info.iAmmo1Drop	= 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 4;
		info.iPosition = 11;
		info.iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
		info.iId = g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iWeight = SCORPION_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;

		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( g_ItemRegistry.GetIdForName( self.pev.classname ) );
		message.End();

		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			m_fDropped = false;
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_scorpion.mdl" ), self.GetP_Model( "models/wanted/p_scorpion.mdl" ), SCORPION_DRAW, "squeak" );
			// play hunt sound
			float flRndSound = Math.RandomFloat( 0, 1 );

			if ( flRndSound <= 0.5 )
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt2.wav", 1, ATTN_NORM, 0, 100 );
			else 
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt3.wav", 1, ATTN_NORM, 0, 100 );

			m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
			return bResult;
		}
	}

	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) != 0;
	}

	void DestroyThink( void )
	{
		SetThink( null );
		self.DestroyItem();
	}

	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false;// cancel any reload in progress.

		m_pPlayer.m_flNextAttack = g_Engine.time + 0.5;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 && !m_fDropped )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName( self.pev.classname ) );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		else
		{
			self.SendWeaponAnim( SCORPION_HOLSTER );
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "common/null.wav", 1.0, ATTN_NORM );
		}

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			Math.MakeVectors( m_pPlayer.pev.v_angle );
			TraceResult tr;
			Vector trace_origin;

			// HACK HACK:  Ugly hacks to handle change in origin based on new physics code for players
			// Move origin up if crouched and start trace a bit outside of body ( 20 units instead of 16 )
			trace_origin = m_pPlayer.pev.origin;
			if ( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				trace_origin = trace_origin - ( VEC_HULL_MIN - VEC_DUCK_HULL_MIN );
			}

			// find place to toss monster
			g_Utility.TraceLine( trace_origin + g_Engine.v_forward * 20, trace_origin + g_Engine.v_forward * 64, dont_ignore_monsters, null, tr );

			if( tr.fAllSolid == 0 && tr.fStartSolid == 0 && tr.flFraction > 0.25 )
			{
				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

				CBaseEntity@ pScorpion = g_EntityFuncs.Create( "monster_scorpion", tr.vecEndPos, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
				pScorpion.pev.velocity = g_Engine.v_forward * 200 + m_pPlayer.pev.velocity;

				// play hunt sound
				float flRndSound = Math.RandomFloat( 0, 1 );

				if ( flRndSound <= 0.5 )
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt2.wav", 1, ATTN_NORM, 0, 105);
				else 
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "wanted/scorpion/scorp_hunt3.wav", 1, ATTN_NORM, 0, 105);

				m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;

				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

				m_fJustThrown = 1;

				self.m_flNextPrimaryAttack = g_Engine.time + 0.3f;
				self.m_flTimeWeaponIdle = g_Engine.time + 1.0f;
			}
		}
	}

	void SecondaryAttack( void )
	{
	}

	void WeaponIdle( void )
	{
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_fJustThrown != 0 )
		{
			m_fJustThrown = 0;

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				self.RetireWeapon();
				return;
			}

			self.SendWeaponAnim( SCORPION_DRAW );
			self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			return;
		}

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if (flRand <= 0.75)
		{
			iAnim = SCORPION_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + 30.0 / 16 * (2);
		}
		else if (flRand <= 0.875)
		{
			iAnim = SCORPION_FIDGET;
			self.m_flTimeWeaponIdle = g_Engine.time + 70.0 / 16.0;
		}
		else
		{
			iAnim = SCORPION_IDLE2;
			self.m_flTimeWeaponIdle = g_Engine.time + 80.0 / 16.0;
		}
		self.SendWeaponAnim( iAnim );
	}

	void Materialize()
	{
		BaseClass.Materialize();
		//SetTouch( TouchFunction( CustomTouch ) );
	}

	bool CanHaveDuplicates()
	{
		return true;
	}

/*	void CustomTouch( CBaseEntity@ pOther ) 
	{
		if( !pOther.IsPlayer() )
			return;
		
		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

		if( pPlayer.HasNamedPlayerItem( GetScorpionName() ) !is null )
		{
	  		if( pPlayer.GiveAmmo( SCORPION_DEFAULT_GIVE, GetScorpionName(), SCORPION_MAX_CARRY ) != -1 ) 
			{
				self.CheckRespawn();

				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
				g_EntityFuncs.Remove( self );
	  		}

	  		return;
		}
		else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
	  		self.AttachToPlayer( pPlayer );
	  		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
		}
	}*/
}

string GetScorpionName()
{
	return "weapon_scorpion";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Scorpion::monster_scorpion", "monster_scorpion" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Scorpion::weapon_scorpion", GetScorpionName() );
	g_ItemRegistry.RegisterWeapon( GetScorpionName(), "wanted", GetScorpionName(), "", GetScorpionName() );
}

} //namespace HLWanted_Scorpion END