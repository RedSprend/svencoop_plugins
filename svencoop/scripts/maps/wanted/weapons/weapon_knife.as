namespace HLWanted_Knife
{
const int KNIFE_DMG = 20;

enum knife_e
{
	KNIFE_IDLE1 = 0,
	KNIFE_DRAW,
	KNIFE_HOLSTER,
	KNIFE_ATTACK1HIT,
	KNIFE_ATTACK1MISS,
	KNIFE_ATTACK2MISS,
	KNIFE_ATTACK2HIT,
	KNIFE_ATTACK3MISS,
	KNIFE_ATTACK3HIT,
	KNIFE_IDLE2,
	KNIFE_IDLE3
};

class weapon_knife : CBaseCustomWeapon
{
	int m_iSwing;
	TraceResult m_trHit;

	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_knife.mdl" );
		self.m_iClip			= -1;
		self.m_flCustomDmg		= self.pev.dmg;

		self.FallInit();
		SetUse( UseFunction( this.CustomUse ) );
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( "models/wanted/v_knife.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_knife.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_knife.mdl" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/knife_hit1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/knife_hit1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/knife_hit2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/knife_hit2.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/knife_hitbod1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/knife_hitbod1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/knife_hitbod2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/knife_hitbod2.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/knife_hitbod3.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/knife_hitbod3.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/knife_miss1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/knife_miss1.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud4.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_knife.txt" );

		g_Game.PrecacheOther( GetTKnifeName() );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= -1;
		info.iAmmo1Drop	= -1;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot  	= 0;
		info.iPosition 	= 6;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= 0;
		info.iWeight 	= 0;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		SetThink( null );
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_knife.mdl" ), self.GetP_Model( "models/wanted/p_knife.mdl" ), KNIFE_DRAW, "crowbar" );	
			self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat(1.0, 2.0);
			return bResult;
		}
	}

	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false;// cancel any reload in progress.

		m_pPlayer.m_flNextAttack = g_WeaponFuncs.WeaponTimeBase() + 0.5;

		m_pPlayer.pev.viewmodel = "";

		SetThink( null );
	}

	void PrimaryAttack()
	{
		if( !Swing( 1 ) )
		{
			SetThink( ThinkFunction( this.SwingAgain ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}

	void SecondaryAttack()
	{
		self.TertiaryAttack();
	}

	void TertiaryAttack()
	{
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		m_pPlayer.pev.punchangle.x = -2.0f;

		Math.MakeVectors( m_pPlayer.pev.v_angle );

		CBaseEntity@ pTKnife = g_EntityFuncs.Create( GetTKnifeName(), m_pPlayer.pev.origin + g_Engine.v_forward * 16 + g_Engine.v_up * 24, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
		if( pTKnife !is null )
		{
			pTKnife.pev.velocity = g_Engine.v_forward * 1024;
			pTKnife.pev.angles = Math.VecToAngles( pTKnife.pev.velocity );
			pTKnife.pev.avelocity.z = 10;

			knife_throw@ pKnife = cast<knife_throw@>(CastToScriptClass(pTKnife));
			pKnife.SetThink( ThinkFunction( pKnife.Think ) );
			pKnife.pev.nextthink = g_Engine.time + 0.1;

			self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
			self.m_flNextSecondaryAttack = g_Engine.time + 1.0;
			self.m_flNextTertiaryAttack = g_Engine.time + 1.0;
			self.m_flTimeWeaponIdle = g_Engine.time + 1.0;

			CBasePlayerItem@ pItem = m_pPlayer.HasNamedPlayerItem( GetKnifeName() );
			if( pItem !is null )
			{
				m_pPlayer.RemovePlayerItem( pItem );
				m_pPlayer.SetItemPickupTimes( 0.0 ); // a fix
				g_EntityFuncs.Remove( self ); // prevent player from quick-switching
			}
		}
	}

	void Smack()
	{
		g_WeaponFuncs.DecalGunshot( m_trHit, BULLET_PLAYER_CROWBAR );
	}

	void SwingAgain()
	{
		Swing( 0 );
	}

	bool Swing( int fFirst )
	{
		bool fDidHit = false;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 32;

		self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat(1.0, 2.0);

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch( ( m_iSwing++ ) % 3 )
				{
				case 0: self.SendWeaponAnim( KNIFE_ATTACK1MISS ); break;
				case 1: self.SendWeaponAnim( KNIFE_ATTACK2MISS ); break;
				case 2: self.SendWeaponAnim( KNIFE_ATTACK3MISS ); break;
				}
				self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack;
				self.m_flNextTertiaryAttack = self.m_flNextPrimaryAttack;

				// play wiff or swish sound
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/knife_miss1.wav", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );

				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch( ( ( m_iSwing++ ) % 2 ) + 1 )
			{
			case 0: self.SendWeaponAnim( KNIFE_ATTACK1HIT ); break;
			case 1: self.SendWeaponAnim( KNIFE_ATTACK2HIT ); break;
			case 2: self.SendWeaponAnim( KNIFE_ATTACK3HIT ); break;
			}

			m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			float flDamage = KNIFE_DMG;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;

			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextPrimaryAttack + 1 < g_Engine.time )
			{
				// first swing does full damage
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );  
			}
			else
			{
				// subsequent swings do 50% (Changed -Sniper) (Half)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.5, g_Engine.v_forward, tr, DMG_CLUB );  
			}
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			//m_flNextPrimaryAttack = gpGlobals->time + 0.30; //0.25

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				self.m_flNextPrimaryAttack = g_Engine.time + 0.30; //0.25
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack;
				self.m_flNextTertiaryAttack = self.m_flNextPrimaryAttack;

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
					if( pEntity.IsPlayer() )
					{
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}
					// play thwack or smack sound
					switch( Math.RandomLong( 0, 2 ) )
					{
					case 0: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/knife_hitbod1.wav", 1, ATTN_NORM ); break;
					case 1: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/knife_hitbod2.wav", 1, ATTN_NORM ); break;
					case 2: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/knife_hitbod3.wav", 1, ATTN_NORM ); break;
					}
					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				self.m_flNextPrimaryAttack = g_Engine.time + 0.25; //0.25
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack;
				self.m_flNextTertiaryAttack = self.m_flNextPrimaryAttack;

				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.

				fvolbar = 1;

				// also play crowbar strike
				switch( Math.RandomLong( 0, 1 ) )
				{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/knife_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/knife_hit2.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				}
			}

			// delay the decal a bit
			m_trHit = tr;
			SetThink( ThinkFunction( this.Smack ) );
			self.pev.nextthink = g_Engine.time + 0.2;

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}

	void CustomUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		if( pActivator is null || pCaller is null )
			return;

		if( pActivator !is pCaller && !pCaller.IsPlayer() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pCaller );

		if( pPlayer.HasNamedPlayerItem( GetKnifeName() ) is null )
		{
			/*self.CheckRespawn();
			pPlayer.SetItemPickupTimes(0);
			pPlayer.GiveNamedItem( self.pev.classname );

			g_EntityFuncs.Remove( self );

	  		return;*/

			if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded ) // makes respawning sound but it works as expected at least
			{
				self.AttachToPlayer( pPlayer );
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
			}
		}
	}

	void WeaponIdle()
	{
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );

		switch( Math.RandomLong(0, 2) )
		{
			case 0:
			{
				iAnim = KNIFE_IDLE1;
				self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;
			}
			break;
			case 1:
			{
				iAnim = KNIFE_IDLE2;
				self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;
			}
			break;
			case 2:
			{
				iAnim = KNIFE_IDLE3;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.6f;
			}
			break;
		}

		self.SendWeaponAnim( iAnim );
	}

	void DestroyThink()
	{
		g_EntityFuncs.Remove( self );
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
			SetThink( ThinkFunction( this.DestroyThink ) );
			return;
		}
	}
}

string GetKnifeName()
{
	return "weapon_knife";
}

class knife_throw : ScriptBaseEntity//ScriptBasePlayerWeaponEntity
{
	private string MODEL = "models/wanted/w_knife.mdl";

	array<string> pHitSounds =
	{
		"wanted/weapons/knife_hitbod1.wav",
		"wanted/weapons/knife_hitbod2.wav",
		"wanted/weapons/knife_hitbod3.wav"
	};

	array<string> pHitMissSounds =
	{
		"wanted/weapons/knife_hit1.wav",
		"wanted/weapons/knife_hit2.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( MODEL );

		for( uint uiIndex = 0; uiIndex < pHitSounds.length(); ++uiIndex )
		{
			g_SoundSystem.PrecacheSound( pHitSounds[ uiIndex ] );
			g_Game.PrecacheGeneric( "sound/" + pHitSounds[ uiIndex ] );
		}

		for( uint uiIndex = 0; uiIndex < pHitMissSounds.length(); ++uiIndex )
		{
			g_SoundSystem.PrecacheSound( pHitMissSounds[ uiIndex ] );
			g_Game.PrecacheGeneric( "sound/" + pHitMissSounds[ uiIndex ] );
		}
	}

	void Spawn()
	{
		Precache();
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_BBOX;

		g_EntityFuncs.SetModel( self, MODEL );

		self.pev.animtime = g_Engine.time;
		self.pev.framerate = 1.0f;
		self.pev.frame = 0.0f;

		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, Vector(-3.0, -3.0, -3.0), Vector(3.0, 3.0, 3.0) );
	}

	void Think( void )
	{
		pev.nextthink = g_Engine.time + 0.1;

		if( pev.waterlevel != 0 )
		{
			pev.velocity = pev.velocity * 0.5;
		}

		Vector vecAngle;
		vecAngle = Math.VecToAngles( pev.velocity ); // Angle the knife depending on the velocity
		pev.angles.x = vecAngle.x;
		pev.angles.y = vecAngle.y;
		pev.angles.z += 2.0f;
	}

	void Touch( CBaseEntity@ pOther )
	{
		SetThink( null );
		SetTouch( null );

		if( pOther.pev.takedamage > DAMAGE_NO )
		{
			TraceResult tr = g_Utility.GetGlobalTrace( );

			g_WeaponFuncs.ClearMultiDamage();
			pOther.TraceAttack( pev.owner.vars, KNIFE_DMG, g_Engine.v_forward, tr, DMG_NEVERGIB );  
			g_WeaponFuncs.ApplyMultiDamage( self.pev, pev.owner.vars );

			pev.velocity = g_vecZero;

			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_BODY, pHitSounds[Math.RandomLong(0, pHitSounds.length()-1)], 1.0f, ATTN_NORM, 0, PITCH_NORM );
		}
		else
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_BODY, pHitMissSounds[Math.RandomLong(0, pHitMissSounds.length()-1)], 1.0f, ATTN_NORM, 0, PITCH_NORM );

			if( pOther.pev.ClassNameIs( "worldspawn" ) )
			{
				// if what we hit is static architecture, can stay around for a while.
				Vector vecDir = pev.velocity.Normalize();
				pev.origin = pev.origin - vecDir * 1;
				pev.solid = SOLID_NOT;
				pev.movetype = MOVETYPE_FLY;
				pev.velocity = g_vecZero;
				pev.avelocity.z = 0;
			}

			if( g_EngineFuncs.PointContents(self.pev.origin) != CONTENTS_WATER )
			{
				g_Utility.Sparks( pev.origin );
			}
		}

		CBaseEntity @pEntity = g_EntityFuncs.CreateEntity( GetKnifeName(), null, false );
		if( pEntity !is null )
		{
			g_EntityFuncs.DispatchSpawn( pEntity.edict() );

			weapon_knife@ pKnife = cast<weapon_knife@>(CastToScriptClass(pEntity));
			g_EntityFuncs.SetOrigin( pEntity, self.pev.origin );
			pEntity.pev.spawnflags |= SF_NORESPAWN;

			pEntity.pev.angles.y = pev.angles.y;

			int iWeaponFade = int( g_EngineFuncs.CVarGetFloat( "mp_weaponfadedelay" ) );
			pKnife.SetThink( ThinkFunction( pKnife.FadeOut ) );
			pEntity.pev.nextthink = g_Engine.time + float( iWeaponFade );
		}

		g_EntityFuncs.Remove( self );
		pev.nextthink = g_Engine.time + 0.1;
	}
}

string GetTKnifeName()
{
	return "knife_throw";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Knife::weapon_knife", GetKnifeName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Knife::knife_throw", GetTKnifeName() );
	g_ItemRegistry.RegisterWeapon( GetKnifeName(), "wanted" );
}

} //namespace HLWanted_Knife END