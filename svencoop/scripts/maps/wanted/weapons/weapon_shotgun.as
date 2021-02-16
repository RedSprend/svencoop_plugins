namespace HLWanted_Shotgun
{
const Vector VECTOR_CONE_DM_SHOTGUN( 0.17365, 0.17365, 0.17365 );
const Vector VECTOR_CONE_DM_DOUBLESHOTGUN( 0.17365, 0.17365, 0.08716 );

const int SHOTGUN_DEFAULT_AMMO 	= 6;
const int SHOTGUN_MAX_CARRY 	= 32;
const int SHOTGUN_MAX_CLIP 	= 2;
const int SHOTGUN_WEIGHT 	= 15;

const uint SHOTGUN_SINGLE_PELLETCOUNT = 6;

enum Animation
{
	SHOTGUN_IDLE1 = 0,
	SHOTGUN_IDLE2,
	SHOTGUN_IDLE3,
	SHOTGUN_HOLSTER,
	SHOTGUN_DRAW,
	SHOTGUN_SHOOT_1,
	SHOTGUN_SHOOT_2,
	SHOTGUN_RELOAD
};

class weapon_want_shotgun : CBaseCustomWeapon
{
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_shotgun.mdl" );
		
		self.m_iDefaultAmmo = SHOTGUN_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_shotgun.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_shotgun.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_shotgun.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/shotgunshell.mdl" ); // shotgun shell

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/dbarrel1.wav" ); //shotgun
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/dbarrel1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/sbarrel1.wav" ); //shotgun
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/sbarrel1.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/reload3.wav" ); // shotgun reload
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/reload3.wav" );

		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" ); // gun empty sound

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_want_shotgun.txt" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( g_ItemRegistry.GetIdForName( self.pev.classname ) );
		message.End();
		
		return true;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= SHOTGUN_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= SHOTGUN_MAX_CLIP;
		info.iSlot 	= 2;
		info.iPosition 	= 6;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= 0;
		info.iWeight 	= SHOTGUN_WEIGHT;

		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_shotgun.mdl" ), self.GetP_Model( "models/wanted/p_shotgun.mdl" ), SHOTGUN_DRAW, "shotgun" );
			self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat(1.0, 2.0);
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		SetThink( null );
		self.m_fInReload = false;
		BaseClass.Holster( skipLocal );
	}

	void CreatePelletDecals( const Vector& in vecSrc, const Vector& in vecAiming, const Vector& in vecSpread, const uint uiPelletCount )
	{
		TraceResult tr;
		
		float x, y;
		
		for( uint uiPellet = 0; uiPellet < uiPelletCount; ++uiPellet )
		{
			g_Utility.GetCircularGaussianSpread( x, y );
			
			Vector vecDir = vecAiming
				+ x * vecSpread.x * g_Engine.v_right 
				+ y * vecSpread.y * g_Engine.v_up;

			Vector vecEnd	= vecSrc + vecDir * 2048;
			
			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
			
			if( tr.flFraction < 1.0 )
			{
				if( tr.pHit !is null )
				{
					CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
					
					if( pHit is null || pHit.IsBSPModel() )
						g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_BUCKSHOT );
				}
			}
		}
	}

	void PrimaryAttack()
	{
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;
			self.Reload();
			return;
		}

		self.SendWeaponAnim( SHOTGUN_SHOOT_1, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/sbarrel1.wav", Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		int m_iBulletDamage = 15;

		for( uint i = 0; i < SHOTGUN_SINGLE_PELLETCOUNT; i++ )
		{
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_DM_SHOTGUN, 8196, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );

			CreatePelletDecals( vecSrc, vecAiming, VECTOR_CONE_DM_SHOTGUN, 1 );
		}

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5;

		if( self.m_iClip != 0 )
			self.m_flTimeWeaponIdle = g_Engine.time + 5.0;
		else
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;

		m_pPlayer.pev.punchangle.x = -5.0;
	}

	void SecondaryAttack()
	{
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;
			self.Reload();
			return;
		}

		if( self.m_iClip <= 1 )
		{
			return;
		}

		self.SendWeaponAnim( SHOTGUN_SHOOT_2, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/dbarrel1.wav", Math.RandomFloat( 0.98, 1.0 ), ATTN_NORM, 0, 85 + Math.RandomLong( 0, 0x1f ) );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		self.m_iClip -= 2;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		int m_iBulletDamage = 15;

		for( uint i = 0; i < SHOTGUN_SINGLE_PELLETCOUNT * 2; i++ )
		{
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_DM_DOUBLESHOTGUN, 8196, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );

			CreatePelletDecals( vecSrc, vecAiming, VECTOR_CONE_DM_DOUBLESHOTGUN, 1 );
		}

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 1.0f;
		
		if( self.m_iClip != 0 )
			self.m_flTimeWeaponIdle = g_Engine.time + 6.0;
		else
			self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
			
		m_pPlayer.pev.punchangle.x = -10.0;
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip > 0 )
			return;

		self.DefaultReload( SHOTGUN_MAX_CLIP, SHOTGUN_RELOAD, 3.4, 0 );
		self.m_flTimeWeaponIdle = g_Engine.time + 4.5f;

		//self.SendWeaponAnim( SHOTGUN_RELOAD );
		SetThink( ThinkFunction( this.CompleteReload ) );
		self.pev.nextthink = g_Engine.time + 3.4f;

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.pev.nextthink + 0.2;

		BaseClass.Reload();
	}

	void CompleteReload()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/reload3.wav", 1.0f, ATTN_NORM, 0, PITCH_NORM );
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle < g_Engine.time )
		{
			int iAnim;
			switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
			{
				case 0:
				iAnim = SHOTGUN_IDLE1;
				self.m_flTimeWeaponIdle = g_Engine.time + 3.0f;
				break;

				case 1:
				iAnim = SHOTGUN_IDLE2;
				self.m_flTimeWeaponIdle = g_Engine.time + 3.7f;
				break;

				case 2:
				iAnim = SHOTGUN_IDLE3;
				self.m_flTimeWeaponIdle = g_Engine.time + 3.8f;
				break;
			}
			self.SendWeaponAnim( iAnim );
		}
	}
}

string GetShotgunName()
{
	return "weapon_want_shotgun";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Shotgun::weapon_want_shotgun", GetShotgunName() );
	g_ItemRegistry.RegisterWeapon( GetShotgunName(), "wanted", "buckshot", "", "ammo_buckshot", "" );
}

} //namespace HLWanted_Shotgun END