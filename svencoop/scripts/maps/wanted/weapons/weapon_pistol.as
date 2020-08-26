namespace HLWanted_Pistol
{
const string AMMO_TYPE		= "pistol";

const int PISTOL_DEFAULT_AMMO 	= 6;
const int PISTOL_MAX_CARRY 	= 36;
const int PISTOL_MAX_CLIP 	= 6;
const int PISTOL_WEIGHT 	= 5;

enum Animation
{
	PISTOL_IDLE1 = 0,
	PISTOL_FIDGET,
	PISTOL_SHOOT,
	PISTOL_RELOAD,
	PISTOL_HOLSTER,
	PISTOL_DRAW,
	PISTOL_IDLE2,
	PISTOL_IDLE3,
	PISTOL_QUICK_READY,
	PISTOL_QUICK_SHOOT,
	PISTOL_QUICK_RELAX
};

const array<string> pFireSounds =
{
	"wanted/weapons/pistol_shot1.wav",
	"wanted/weapons/pistol_shot2.wav"
};

class weapon_pistol : CBaseCustomWeapon
{
	private bool bQuickFire = false;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_pistol.mdl" );
		
		self.m_iDefaultAmmo = PISTOL_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_pistol.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_pistol.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_pistol.mdl" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/pistol_reload1.wav" ); // reloading sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/pistol_reload1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/pistol_cock1.wav" ); // empty sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/pistol_cock1.wav" );

		for( uint i = 0; i < pFireSounds.length(); i++ ) // firing sounds
		{
			g_SoundSystem.PrecacheSound( pFireSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pFireSounds[i] ); // client has to download
		}

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_pistol.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= PISTOL_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= PISTOL_MAX_CLIP;
		info.iSlot 	= 1;
		info.iPosition 	= 5;
		info.iFlags 	= 0;
		info.iWeight 	= PISTOL_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;

		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
		
		return true;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/pistol_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		bQuickFire = false;
		return self.DefaultDeploy( self.GetV_Model( "models/wanted/v_pistol.mdl" ), self.GetP_Model( "models/wanted/p_pistol.mdl" ), PISTOL_DRAW, "onehanded" );
	}

	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void PrimaryAttack()
	{
		PistolFire( 0.01, 0.8, false );
	}

	void SecondaryAttack()
	{
		PistolFire( 0.05, 0.3, true );
	}

	void PistolFire( float flSpread, float flCycleTime, bool fUseAutoAim )
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}

		if( flSpread >= 0.05 )
		{
			bQuickFire = true;
			self.SendWeaponAnim( PISTOL_QUICK_SHOOT, 0, 0 );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;
		}
		else
		{
			bQuickFire = false;
			self.SendWeaponAnim( PISTOL_SHOOT, 0, 0 );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		}

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pFireSounds[Math.RandomLong(0, pFireSounds.length()-1)], 1.0f, ATTN_NORM, 0, PITCH_NORM );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		int m_iBulletDamage = 20;
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, Vector( flSpread, flSpread, flSpread ), 8192, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );
		self.m_flNextPrimaryAttack = g_Engine.time + flCycleTime;
		self.m_flNextSecondaryAttack = g_Engine.time + flCycleTime;

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2.0, 2.0 );
		m_pPlayer.pev.punchangle.y = Math.RandomFloat( -3.0, 3.0 );
		
		TraceResult tr;
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
			+ x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right 
			+ y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_9MM );
			}
		}
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == PISTOL_MAX_CLIP ) // Can't reload if we have a full magazine already!
			return;

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/pistol_reload1.wav", 1.0f, ATTN_NORM, 0, PITCH_NORM );

		self.m_flNextPrimaryAttack = g_Engine.time + 3.0f;
		self.m_flNextSecondaryAttack = g_Engine.time + 3.0f;

		self.DefaultReload( PISTOL_MAX_CLIP, PISTOL_RELOAD, 1.5, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		//if( self.m_iClip != 0 )

		{
			int iAnim;
			float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
	
			if( bQuickFire )
			{
				bQuickFire = false;

				iAnim = PISTOL_QUICK_RELAX;
				self.SendWeaponAnim( iAnim, 0, 0 );
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
				self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 2.0, 3.0 );

				return;
			}

			switch( Math.RandomLong(0, 2) )
			{
				case 0:
				{
					iAnim = PISTOL_IDLE1;
					self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;
				}
				break;
				case 1:
				{
					iAnim = PISTOL_IDLE2;
					self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;
				}
				break;
				case 2:
				{
					iAnim = PISTOL_IDLE3;
					self.m_flTimeWeaponIdle = WeaponTimeBase() + 3.0f;
				}
				break;
			}

			self.SendWeaponAnim( iAnim );
		}
	}
}

string GetPistolName()
{
	return "weapon_pistol";
}

// Ammo class
class ammo_pistol : CBaseCustomAmmo
{
	string AMMO_MODEL = "models/wanted/w_pistolammobox.mdl";

	ammo_pistol()
	{
		m_strModel = AMMO_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = PISTOL_DEFAULT_AMMO;
		m_iMax = PISTOL_MAX_CARRY;
	}
}

string GetPistolAmmoName()
{
	return "ammo_pistol";
}

void Register()
{
	g_Game.PrecacheModel( "models/wanted/w_pistolammobox.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_pistolammoboxt.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Pistol::ammo_pistol", GetPistolAmmoName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Pistol::weapon_pistol", GetPistolName() );
	g_ItemRegistry.RegisterWeapon( GetPistolName(), "wanted", "pistol", "", "ammo_pistol", "" );
}

} //namespace HLWanted_Pistol END