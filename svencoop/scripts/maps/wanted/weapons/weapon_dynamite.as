namespace HLWanted_Dynamite
{
const int DYNAMITE_DAMAGE	= 100;
const int DYNAMITE_DEFAULT_GIVE	= 5;
const int DYNAMITE_WEIGHT	= 5;
const int DYNAMITE_MAX_CARRY	= 15;

enum Animation
{
	ANIM_IDLE = 0,
	ANIM_FIDGET,
	ANIM_PINPULL,
	ANIM_THROW1,	// toss
	ANIM_THROW2,	// medium
	ANIM_THROW3,	// hard
	ANIM_HOLSTER,
	ANIM_DRAW
};

const array<string> pBounceSounds =
{
	"wanted/weapons/grenade_hit1.wav",
	"wanted/weapons/grenade_hit2.wav",
	"wanted/weapons/grenade_hit3.wav"
};

class dynamite : ScriptBaseMonsterEntity
{
	private int g_sModelIndexFireball;
	private int g_sModelIndexWExplosion;
	private int g_sModelIndexSmoke;

	bool m_bRegisteredSound;

	void Spawn()
	{
		Precache();

		pev.movetype = MOVETYPE_BOUNCE;
		pev.solid = SOLID_BBOX;

		g_EntityFuncs.SetModel( self, "models/wanted/w_dynamite.mdl" );
		g_EntityFuncs.SetSize( self.pev, g_vecZero, g_vecZero );

		pev.dmg = 100;
		m_bRegisteredSound = false;
	}

	void Precache()
	{
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/debris1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/debris2.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/debris3.wav" );

		g_sModelIndexFireball = g_Game.PrecacheModel( "sprites/zerogxplode.spr" );
		g_sModelIndexWExplosion = g_Game.PrecacheModel( "sprites/WXplo1.spr" );
		g_sModelIndexSmoke = g_Game.PrecacheModel( "sprites/steam1.spr" );
	}

	void Explode()
	{
		TraceResult tr;

		g_Utility.TraceLine( pev.origin, pev.origin + Vector(0, 0, -32), ignore_monsters, self.edict(), tr);
		Explode( tr, DMG_BLAST );
	}

	void Explode( TraceResult pTrace, int bitsDamageType )
	{
		pev.model = string_t();//invisible
		pev.solid = SOLID_NOT;// intangible

		pev.takedamage = DAMAGE_NO;

		// Pull out of the wall a bit
		if( pTrace.flFraction != 1.0f )
			pev.origin = pTrace.vecEndPos + (pTrace.vecPlaneNormal * (pev.dmg - 24) * 0.6f);

		int iContents = g_EngineFuncs.PointContents( pev.origin );

		NetworkMessage expl( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
			expl.WriteByte( TE_EXPLOSION );		// This makes a dynamic light and the explosion sprites/sound
			expl.WriteCoord( pev.origin.x );	// Send to PAS because of the sound
			expl.WriteCoord( pev.origin.y );
			expl.WriteCoord( pev.origin.z );
			if( iContents != CONTENTS_WATER )
				expl.WriteShort( g_sModelIndexFireball );
			else
				expl.WriteShort( g_sModelIndexWExplosion );
			expl.WriteByte( int((pev.dmg - 50) * 0.60f)  ); // scale * 10
			expl.WriteByte( 15 ); // framerate
			expl.WriteByte( TE_EXPLFLAG_NONE );
		expl.End();

		GetSoundEntInstance().InsertSound( bits_SOUND_COMBAT, pev.origin, NORMAL_EXPLOSION_VOLUME, 3.0f, self ); 

		entvars_t@ pevOwner;
		if( pev.owner !is null )
			@pevOwner = pev.owner.vars;
		else
			@pevOwner = null;

		@pev.owner = null; // can't traceline attack owner if this is set

		g_WeaponFuncs.RadiusDamage( pev.origin, self.pev, pevOwner, pev.dmg, pev.dmg * 2.5f, CLASS_NONE, bitsDamageType );

		if( Math.RandomFloat(0, 1) < 0.5f )
			g_Utility.DecalTrace( pTrace, DECAL_SCORCH1 );
		else
			g_Utility.DecalTrace( pTrace, DECAL_SCORCH2 );

		switch( Math.RandomLong(0, 2) )
		{
			case 0:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hlclassic/weapons/debris1.wav", 0.55f, ATTN_NORM ); break;
			case 1:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hlclassic/weapons/debris2.wav", 0.55f, ATTN_NORM ); break;
			case 2:	g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "hlclassic/weapons/debris3.wav", 0.55f, ATTN_NORM ); break;
		}

		pev.effects |= EF_NODRAW;
		SetThink( ThinkFunction(this.Smoke) );
		pev.velocity = g_vecZero;
		pev.nextthink = g_Engine.time + 0.3f;

		if( iContents != CONTENTS_WATER )
		{
			int sparkCount = Math.RandomLong(0, 3);
			for( int i = 0; i < sparkCount; i++ )
				g_EntityFuncs.Create( "spark_shower", pev.origin, pTrace.vecPlaneNormal, false );
		}
	}

	void Smoke()
	{
		if( g_EngineFuncs.PointContents(pev.origin) == CONTENTS_WATER )
			g_Utility.Bubbles( pev.origin - Vector(64, 64, 64), pev.origin + Vector(64, 64, 64), 100 );
		else
		{
			NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin );
				smoke.WriteByte( TE_SMOKE );
				smoke.WriteCoord( pev.origin.x );
				smoke.WriteCoord( pev.origin.y );
				smoke.WriteCoord( pev.origin.z );
				smoke.WriteShort( g_sModelIndexSmoke );
				smoke.WriteByte( int((pev.dmg - 50) * 0.80f) ); // scale * 10
				smoke.WriteByte( 12 ); // framerate
			smoke.End();
		}

		g_EntityFuncs.Remove( self );
	}

	void Killed( entvars_t@ pevAttacker, int iGib )
	{
		Detonate();
	}

	// Timed grenade, this think is called when time runs out.
	void DetonateUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		SetThink( ThinkFunction(this.Detonate) );
		pev.nextthink = g_Engine.time;
	}

	void Detonate()
	{
		TraceResult tr;
		Vector		vecSpot;

		vecSpot = pev.origin + Vector (0 , 0 , 8);
		g_Utility.TraceLine( vecSpot, vecSpot + Vector (0, 0, -40), ignore_monsters, self.edict(), tr);

		Explode( tr, DMG_BLAST );
	}

	void BounceTouch( CBaseEntity@ pOther )
	{
		// don't hit the guy that launched this grenade
		if( pOther.edict() is pev.owner )
			return;

		// only do damage if we're moving fairly fast
		if( self.m_flNextAttack < g_Engine.time and self.pev.velocity.Length() > 100 )
		{
			entvars_t@ pevOwner = self.pev.owner.vars;
			if( pevOwner !is null )
			{
				TraceResult tr = g_Utility.GetGlobalTrace();
				g_WeaponFuncs.ClearMultiDamage();
				pOther.TraceAttack( pevOwner, 1, g_Engine.v_forward, tr, DMG_CLUB );
				g_WeaponFuncs.ApplyMultiDamage( self.pev, pevOwner);
			}

			self.m_flNextAttack = g_Engine.time + 1.0f; // debounce
		}

		Vector vecTestVelocity;
		// pev.avelocity = Vector (300, 300, 300);

		// this is my heuristic for modulating the grenade velocity because grenades dropped purely vertical
		// or thrown very far tend to slow down too quickly for me to always catch just by testing velocity. 
		// trimming the Z velocity a bit seems to help quite a bit.
		vecTestVelocity = pev.velocity; 
		vecTestVelocity.z *= 0.45f;

		if( !m_bRegisteredSound and vecTestVelocity.Length() <= 60 )
		{
			//g_Game.AlertMessage( at_console, "Grenade Registered!: %1\n", vecTestVelocity.Length() );

			// grenade is moving really slow. It's probably very close to where it will ultimately stop moving. 
			// go ahead and emit the danger sound.
			
			// register a radius louder than the explosion, so we make sure everyone gets out of the way
			GetSoundEntInstance().InsertSound( bits_SOUND_DANGER, pev.origin, int(pev.dmg / 0.4f), 0.3f, self ); 
			m_bRegisteredSound = true;
		}

		if( (pev.flags & FL_ONGROUND) != 0 )
		{
			// add a bit of static friction
			pev.velocity = pev.velocity * 0.8f;

			pev.sequence = Math.RandomLong(1, 1);
		}
		else
		{
			// play bounce sound
			BounceSound();
		}

		pev.framerate = pev.velocity.Length() / 200.0f;
		if( pev.framerate > 1.0f )
			pev.framerate = 1;
		else if( pev.framerate < 0.5f )
			pev.framerate = 0;

	}

	void BounceSound()
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pBounceSounds[Math.RandomLong(0, pBounceSounds.length()-1)], 0.25f, ATTN_NONE );
	}

	void TumbleThink()
	{
		if( !self.IsInWorld() )
		{
			g_EntityFuncs.Remove( self );
			return;
		}

		self.StudioFrameAdvance();
		pev.nextthink = g_Engine.time + 0.1f;

		if( pev.dmgtime - 1 < g_Engine.time )
			GetSoundEntInstance().InsertSound( bits_SOUND_DANGER, pev.origin + pev.velocity * (pev.dmgtime - g_Engine.time), 400, 0.1f, self ); 

		if( pev.dmgtime <= g_Engine.time )
			SetThink( ThinkFunction(this.Detonate) );
			
		if( pev.waterlevel != WATERLEVEL_DRY )
		{
			pev.velocity = pev.velocity * 0.5f;
			pev.framerate = 0.2f;
		}
	}
}

dynamite ShootTimed( entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity, float time )
{
	CBaseEntity@ cbeGrenade = g_EntityFuncs.CreateEntity( "dynamite", null,  false );
	dynamite@ pGrenade = cast<dynamite@>(CastToScriptClass(cbeGrenade));
	g_EntityFuncs.DispatchSpawn( pGrenade.self.edict() );

	g_EntityFuncs.SetOrigin( pGrenade.self, vecStart );

	pGrenade.pev.velocity = vecVelocity;
	pGrenade.pev.angles = Math.VecToAngles(pGrenade.pev.velocity);
	@pGrenade.pev.owner = pevOwner.get_pContainingEntity();

	pGrenade.SetTouch( TouchFunction(pGrenade.BounceTouch) );	// Bounce if touched

	// Take one second off of the desired detonation time and set the think to PreDetonate. PreDetonate
	// will insert a DANGER sound into the world sound list and delay detonation for one second so that 
	// the grenade explodes after the exact amount of time specified in the call to ShootTimed(). 

	pGrenade.pev.dmgtime = g_Engine.time + time;
	pGrenade.SetThink( ThinkFunction(pGrenade.TumbleThink) );
	pGrenade.pev.nextthink = g_Engine.time + 0.1f;
	if( time < 0.1f )
	{
		pGrenade.pev.nextthink = g_Engine.time;
		pGrenade.pev.velocity = g_vecZero;
	}

	pGrenade.pev.sequence = Math.RandomLong(3, 6);
	pGrenade.pev.framerate = 1.0f;

	// Tumble through the air
	// pGrenade.pev.avelocity.x = -400;

	pGrenade.pev.gravity = 0.5f;
	pGrenade.pev.friction = 0.8f;

	g_EntityFuncs.SetModel( pGrenade.self, "models/wanted/w_dynamite.mdl" );
	pGrenade.pev.dmg = 100;

	return pGrenade;
}

class weapon_dynamite : CBaseCustomWeapon
{
	float m_flStartThrow;
	float m_flReleaseThrow;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, self.GetW_Model("models/wanted/w_dynamite.mdl") );
		self.pev.dmg = DYNAMITE_DAMAGE;
		self.m_iDefaultAmmo = DYNAMITE_DEFAULT_GIVE;
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/w_dynamite.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_dynamitet.mdl" );
		g_Game.PrecacheModel( "models/wanted/v_dynamite.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_dynamite.mdl" );

		g_SoundSystem.PrecacheSound( "items/gunpickup2.wav" );

		for( uint i = 0; i < pBounceSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pBounceSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pBounceSounds[i] ); // client has to download
		}

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud3.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud6.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_dynamite.txt" );

		g_Game.PrecacheOther( "dynamite" );
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
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= DYNAMITE_MAX_CARRY;
		info.iAmmo1Drop	= 1;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 4;
		info.iPosition = 9;
		info.iId = g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iWeight = DYNAMITE_WEIGHT;
		info.iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;

		return true;
	}

	void Materialize()
	{
		BaseClass.Materialize();
		//SetTouch( TouchFunction(CustomTouch) );
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

		if( pPlayer.HasNamedPlayerItem( GetDynamiteName() ) !is null )
		{
	  		if( pPlayer.GiveAmmo( DYNAMITE_DEFAULT_GIVE, GetDynamiteName(), DYNAMITE_MAX_CARRY) != -1 )
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

	bool Deploy()
	{
		m_flReleaseThrow = -1;
		bool bResult;
		{
			m_fDropped = false;
			bResult = self.DefaultDeploy( self.GetV_Model("models/wanted/v_dynamite.mdl"), self.GetP_Model("models/wanted/p_dynamite.mdl"), ANIM_DRAW, "crowbar" );
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5f;
			return bResult;
		}
	}

	bool CanHolster()
	{
		// can only holster hand grenades when not primed!
		return (m_flStartThrow == 0);
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
		self.m_fInReload = false;
		SetThink( null );

		m_pPlayer.pev.viewmodel = string_t();

		self.m_flNextPrimaryAttack = g_Engine.time + 0.5f;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) > 0 )
		{
			self.SendWeaponAnim( ANIM_HOLSTER );
		}
		else if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 && !m_fDropped )
		{
			// no more grenades!
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName( self.pev.classname ) );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}

		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "common/null.wav", 1.0f, ATTN_NORM );

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( m_flStartThrow <= 0 and m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) > 0 )
		{
			m_flStartThrow = g_Engine.time;
			m_flReleaseThrow = 0;

			self.SendWeaponAnim( ANIM_PINPULL );
			self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;
		}
	}

	void WeaponIdle()
	{
		if( m_flReleaseThrow == 0 and m_flStartThrow > 0 )
			 m_flReleaseThrow = g_Engine.time;

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_flStartThrow > 0 )
		{
			Vector angThrow = m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle;

			if( angThrow.x < 0 )
				angThrow.x = -10 + angThrow.x * ((90 - 10) / 90.0f);
			else
				angThrow.x = -10 + angThrow.x * (( 90 + 10) / 90.0f);

			float flVel = (90 - angThrow.x) * 4;
			if( flVel > 500 )
				flVel = 500;

			Math.MakeVectors( angThrow );

			Vector vecSrc = m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs + g_Engine.v_forward * 16;

			Vector vecThrow = g_Engine.v_forward * flVel + m_pPlayer.pev.velocity;

			// alway explode 4 seconds after the pin was pulled
			float time = m_flStartThrow - g_Engine.time + 4.0f;
			if( time < 0 )
				time = 0;

			ShootTimed( m_pPlayer.pev, vecSrc, vecThrow, time );

			if( flVel < 500 )
				self.SendWeaponAnim( ANIM_THROW1 );
			else if( flVel < 1000 )
				self.SendWeaponAnim( ANIM_THROW2 );
			else
				self.SendWeaponAnim( ANIM_THROW3 );

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_flReleaseThrow = 0;
			m_flStartThrow = 0;
			self.m_flNextPrimaryAttack = g_Engine.time + 0.5f; //GetNextAttackDelay
			self.m_flTimeWeaponIdle = g_Engine.time + 0.5f; //UTIL_WeaponTimeBase

			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) - 1 );

			if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0 )
			{
				// just threw last grenade
				// set attack times in the future, and weapon idle in the future so we can see the whole throw
				// animation, weapon idle will automatically retire the weapon for us.
				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = g_Engine.time + 0.5f;// ensure that the animation can finish playing
			}

			return;
		}
		else if( m_flReleaseThrow > 0 )
		{
			// we've finished the throw, restart.
			m_flStartThrow = 0;

			if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) > 0 )
				self.SendWeaponAnim( ANIM_DRAW );
			else
			{
				self.RetireWeapon();
				return;
			}

			self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			m_flReleaseThrow = -1;
			return;
		}

		if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) > 0 )
		{
			int iAnim;
			float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
			if( flRand <= 0.75 )
			{
				iAnim = ANIM_IDLE;
				self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 5, 10 );// how long till we do this again.
			}
			else 
			{
				iAnim = ANIM_FIDGET;
				self.m_flTimeWeaponIdle = g_Engine.time + 3.4;
			}

			self.SendWeaponAnim( iAnim );
		}
	}
}

string GetDynamiteName()
{
	return "weapon_dynamite";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Dynamite::dynamite", "dynamite" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Dynamite::weapon_dynamite", GetDynamiteName() );
	g_ItemRegistry.RegisterWeapon( GetDynamiteName(), "wanted", GetDynamiteName(), "", GetDynamiteName() );
}

} //namespace HLWanted_Dynamite END