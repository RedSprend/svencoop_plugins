namespace HLWanted_Bow
{
const int ARROW_DMG 		= 70;

const string AMMO_TYPE		= "bow";

const int BOW_DEFAULT_AMMO 	= 5;
const int BOW_MAX_CARRY 	= 35;
const int BOW_MAX_CLIP 		= 1;
const int BOW_WEIGHT 		= 5;

enum Animation
{
	BOW_IDLE1 = 0,
	BOW_IDLE2,
	BOW_IDLE3,
	BOW_IDLE4,
	BOW_IDLE5,
	BOW_IDLE6,
	BOW_DRAW,
	BOW_HOLSTER,
	BOW_RELOAD,
	BOW_PULLBACK,
	BOW_PULLBACK_IDLE,
	BOW_FIRE,
	BOW_DRYFIRE
};

const array<string> pHitSounds =
{
	"wanted/weapons/bow_hitbod1.wav",
	"wanted/weapons/bow_hitbod2.wav"
};

class weapon_bow : CBaseCustomWeapon
{
	float m_flStartThrow;
	float m_flReleaseThrow;
	float flVelocity, flGravity = 0.8;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_bow.mdl" );
		
		self.m_iDefaultAmmo = BOW_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_bow.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_bow.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_bowT.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_bow.mdl" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/bow_fire1.wav" ); // fire sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/bow_fire1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/bow_reload1.wav" ); // reloading sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/bow_reload1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/bow_empty.wav" ); // empty sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/bow_empty.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_bow.txt" );

		g_Game.PrecacheOther( GetArrowName() );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= BOW_MAX_CARRY;
		info.iAmmo1Drop = BOW_DEFAULT_AMMO;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip 	= BOW_MAX_CLIP;
		info.iSlot 	= 2;
		info.iPosition 	= 8;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= ITEM_FLAG_NOAUTOSWITCHEMPTY;
		info.iWeight 	= BOW_WEIGHT;

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

	bool CanHolster()
	{
		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_bow.mdl" ), self.GetP_Model( "models/wanted/p_bow.mdl" ), BOW_DRAW, "onehanded" );

			self.m_flNextPrimaryAttack = g_Engine.time + 0.6f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		SetThink( null );
		self.m_fInReload = false;

		self.m_flNextPrimaryAttack = g_Engine.time + 0.5f;
		self.m_flNextSecondaryAttack = g_Engine.time + 0.5f;
		self.m_flTimeWeaponIdle = g_Engine.time + 0.5f;

		m_flStartThrow = 0;
		m_flReleaseThrow = -1.0f;

		BaseClass.Holster( skipLocal );
	}

	void PlayEmptySound()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/bow_empty.wav", 1.0f, ATTN_NORM, 0, 100 + Math.RandomLong( -5, 5 ) );
	}

	void PrimaryAttack()
	{
		flVelocity = 600 + Math.RandomLong( 0, 200 );

		if( m_flStartThrow <= 0 and self.m_iClip > 0 )
		{
			m_flStartThrow = g_Engine.time;
			m_flReleaseThrow = 0;

			self.SendWeaponAnim( BOW_PULLBACK, 0, 0 );
			self.m_flTimeWeaponIdle = g_Engine.time + 0.5f;
		}

		if( self.m_iClip <= 0 )
		{
			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				self.SendWeaponAnim( BOW_DRYFIRE, 0, 0 );

				self.m_flNextPrimaryAttack = g_Engine.time + 1.7f;
				self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack + 1.0f;

				SetThink( ThinkFunction( PlayEmptySound ) );
				pev.nextthink = g_Engine.time + 1.0f;
			}
			else
				self.Reload();
		}

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_flStartThrow > 0 ) // Charged bolt
		{
			flVelocity *= 2;
			flGravity = 0.4;
		}
		else
			flGravity = 0.8;
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == BOW_MAX_CLIP ) // Can't reload if we have a full magazine already!
			return;

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "wanted/weapons/bow_reload1.wav", 1.0f, ATTN_NORM, 0, PITCH_NORM );

		self.m_flNextPrimaryAttack = g_Engine.time + 0.5f;
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack + 0.5f;

		self.DefaultReload( BOW_MAX_CLIP, BOW_RELOAD, 0.6, 0 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		m_pPlayer.GetAutoaimVector( AUTOAIM_2DEGREES );

		if( m_flReleaseThrow == 0 and m_flStartThrow > 0 )
			 m_flReleaseThrow = g_Engine.time;

		self.ResetEmptySound();

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_flStartThrow > 0 )
		{
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/bow_fire1.wav", 1.0f, ATTN_NORM, 0, 100 + Math.RandomLong( -5, 5 ) );

			self.SendWeaponAnim( BOW_FIRE, 0, 0 );

			m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;

			Vector vecSrc = m_pPlayer.GetGunPosition();

			Math.MakeVectors( m_pPlayer.pev.v_angle );

			CBaseEntity@ pArrow = g_EntityFuncs.Create( GetArrowName(), vecSrc, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
			if( pArrow !is null )
			{
				pArrow.pev.velocity = g_Engine.v_forward * flVelocity;
				pArrow.pev.angles = Math.VecToAngles( pArrow.pev.velocity );
				pArrow.pev.avelocity.z = 10;
				pArrow.pev.gravity = flGravity;
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_flReleaseThrow = 0;
			m_flStartThrow = 0;
			self.m_flNextPrimaryAttack = g_Engine.time + 1.0f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack;

			m_pPlayer.pev.punchangle.x = -2.0;

			--self.m_iClip;

			if( self.m_iClip <= 0 )
			{
				self.m_flTimeWeaponIdle = g_Engine.time + 1.4f;
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
			}
			return;
		}
		else if( m_flReleaseThrow > 0 )
		{
			// we've finished the fire, restart.
			m_flStartThrow = 0;

			self.m_flTimeWeaponIdle = 3.0f;
			m_flReleaseThrow = -1;
			return;
		}

		int iAnim;
		if( self.m_iClip != 0 )
		{
			switch( Math.RandomLong(0, 1) )
			{
				case 0:
				{
					iAnim = BOW_IDLE3;
					self.m_flTimeWeaponIdle = g_Engine.time + 3.0f;
				}
				break;
				case 1:
				{
					iAnim = BOW_IDLE4;
					self.m_flTimeWeaponIdle = g_Engine.time + 3.0f;
				}
				break;
			}
		}
		else
		{
			switch( Math.RandomLong(0, 2) )
			{
				case 0:
				{
					iAnim = BOW_IDLE1;
					self.m_flTimeWeaponIdle = g_Engine.time + 4.0f;
				}
				break;
				case 1:
				{
					iAnim = BOW_IDLE2;
					self.m_flTimeWeaponIdle = g_Engine.time + 4.0f;
				}
				break;
			}
		}
		self.SendWeaponAnim( iAnim );
	}
}

string GetBowName()
{
	return "weapon_bow";
}

class arrow : ScriptBaseEntity
{
	private string MODEL = "models/wanted/arrow.mdl";

	array<string> pHitSounds =
	{
		"wanted/weapons/bow_hitbod1.wav",
		"wanted/weapons/bow_hitbod2.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( MODEL );

		g_SoundSystem.PrecacheSound( "wanted/weapons/bow_hit1.wav" ); // miss sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/bow_hit1.wav" );

		for( uint i = 0; i < pHitSounds.length(); i++ ) // hit sounds
		{
			g_SoundSystem.PrecacheSound( pHitSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pHitSounds[i] ); // client has to download
		}
	}

	void Spawn()
	{
		Precache();
		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_SLIDEBOX;

		g_EntityFuncs.SetModel( self, MODEL );

		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, Vector(-0.0, -0.0, -0.0), Vector(0.0, 0.0, 0.0) );

		self.pev.gravity = 0.8;

		self.pev.nextthink = g_Engine.time + 0.2;
	}

	void Think( void )
	{
		pev.nextthink = g_Engine.time + 0.1;

		if( pev.waterlevel != 0 )
		{
			pev.velocity = pev.velocity * 0.5;
		}

		Vector vecAngles;
		vecAngles = Math.VecToAngles( pev.velocity ); // Angle the arrow depending on the velocity
		pev.angles = vecAngles;
	}

	void Touch( CBaseEntity@ pOther )
	{
		SetThink( null );
		SetTouch( null );

		if( pOther.pev.takedamage > DAMAGE_NO )
		{
			TraceResult tr = g_Utility.GetGlobalTrace( );

			g_WeaponFuncs.ClearMultiDamage();
			pOther.TraceAttack( pev.owner.vars, ARROW_DMG, g_Engine.v_forward, tr, DMG_NEVERGIB );  
			g_WeaponFuncs.ApplyMultiDamage( self.pev, pev.owner.vars );

			pev.velocity = g_vecZero;

			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_BODY, pHitSounds[Math.RandomLong(0, pHitSounds.length()-1)], 1.0f, ATTN_NORM, 0, PITCH_NORM );

			self.SUB_Remove();
		}
		else
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_BODY, "wanted/weapons/bow_hit1.wav", 1.0f, ATTN_NORM, 0, PITCH_NORM );

			SetThink( ThinkFunction( ThinkRemove ) );
			pev.nextthink = g_Engine.time;

			if( pOther.pev.ClassNameIs( "worldspawn" ) )
			{
				// if what we hit is static architecture, can stay around for a while.
				Vector vecDir = pev.velocity.Normalize();
				pev.origin = pev.origin - vecDir * Math.RandomLong(15, 20);
				pev.solid = SOLID_NOT;
				pev.movetype = MOVETYPE_FLY;
				pev.velocity = g_vecZero;
				pev.avelocity.z = 0;
				SetThink( ThinkFunction( ThinkRemove ) );
				pev.nextthink = g_Engine.time + 10.0;
			}

			if( g_EngineFuncs.PointContents(self.pev.origin) != CONTENTS_WATER )
			{
				g_Utility.Sparks( pev.origin );
			}
		}
	}

	void ThinkRemove( void )
	{
		self.SUB_Remove();
	}
}

string GetArrowName()
{
	return "arrow";
}

// Ammo class
class ammo_bow : CBaseCustomAmmo
{
	string AMMO_MODEL = "models/wanted/w_bowammo.mdl";

	ammo_bow()
	{
		m_strModel = AMMO_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = BOW_DEFAULT_AMMO;
		m_iMax = BOW_MAX_CARRY;
	}
}

string GetBowAmmoName()
{
	return "ammo_bow";
}

void Register()
{
	g_Game.PrecacheModel( "models/wanted/w_bowammo.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_bowammoT.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Bow::ammo_bow", GetBowAmmoName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Bow::arrow", GetArrowName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Bow::weapon_bow", GetBowName() );
	g_ItemRegistry.RegisterWeapon( GetBowName(), "wanted", "bow", "", "ammo_bow", "" );
}

} //namespace HLWanted_Bow END