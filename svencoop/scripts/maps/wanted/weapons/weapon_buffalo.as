namespace HLWanted_Buffalo
{
const Vector VECTOR_CONE_BUFFALO_ZOOMED( 0.00001, 0.01745, 0.00001 );

const string AMMO_TYPE		= "buffalo";

const int BUFFALO_DEFAULT_AMMO 	= 5;
const int BUFFALO_MAX_CARRY 	= 20;
const int BUFFALO_MAX_CLIP 	= 1;
const int BUFFALO_WEIGHT 	= 15;

enum Animation
{
	BUFFALO_DRAW = 0,
	BUFFALO_HOLSTER,
	BUFFALO_IDLE1,
	BUFFALO_IDLE2,
	BUFFALO_FIDGET,
	BUFFALO_FIRE,
	BUFFALO_DRYFIRE,
	BUFFALO_RELOAD
};

const array<string> pFireSounds =
{
	"wanted/weapons/buffalo_shoot1.wav",
	"wanted/weapons/buffalo_shoot2.wav"
};

class weapon_buffalo : CBaseCustomWeapon
{
	private int m_sModelIndexSmoke;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_buffalogun.mdl" );
		
		self.m_iDefaultAmmo = BUFFALO_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_buffalogun.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_buffalogun.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_buffalogunt.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_buffalogun.mdl" );

		m_sModelIndexSmoke = g_EngineFuncs.ModelIndex( "sprites/steam1.spr" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/buffalo_breakopen.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/buffalo_breakopen.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/buffalo_close.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/buffalo_close.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/buffalo_reload.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/buffalo_reload.wav" );

		for( uint i = 0; i < pFireSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pFireSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pFireSounds[i] ); // client has to download
		}

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_buffalo.txt" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
		
		return true;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= BUFFALO_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= BUFFALO_MAX_CLIP;
		info.iSlot 	= 2;
		info.iPosition 	= 7;
		info.iFlags 	= 0;
		info.iWeight 	= BUFFALO_WEIGHT;

		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_buffalogun.mdl" ), self.GetP_Model( "models/wanted/p_buffalogun.mdl" ), BUFFALO_DRAW, "sniper" );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5;
			return bResult;
		}
	}

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	void Holster( int skipLocal = 0 )
	{
		SetThink( null );

		if ( m_pPlayer.pev.fov != 0 )
		{
			SecondaryAttack();
		}

		self.m_fInReload = false;
		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if( self.m_iClip <= 0 || m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}

		self.SendWeaponAnim( BUFFALO_FIRE, 0, 0 );

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pFireSounds[Math.RandomLong(0, pFireSounds.length()-1)], 1.0f, ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );
		
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		int m_iBulletDamage = 110;
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, self.m_fInZoom ? VECTOR_CONE_BUFFALO_ZOOMED : VECTOR_CONE_2DEGREES, 8196, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );

		Vector vecGunPos = vecSrc + (g_Engine.v_forward * 30 + g_Engine.v_right * 5 - g_Engine.v_up * 15);
		NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecGunPos );
			smoke.WriteByte( TE_SMOKE );
			smoke.WriteCoord( vecGunPos.x );
			smoke.WriteCoord( vecGunPos.y );
			smoke.WriteCoord( vecGunPos.z );
			smoke.WriteShort( m_sModelIndexSmoke );
			smoke.WriteByte( 5 ); // scale * 10
			smoke.WriteByte( 10  ); // framerate
		smoke.End();

		m_pPlayer.pev.punchangle.x = -2.0;
		m_pPlayer.pev.velocity = -128 * g_Engine.v_forward; // Knockback!

		self.m_flNextPrimaryAttack = g_Engine.time + 3.0;
		self.m_flTimeWeaponIdle = g_Engine.time + 3.0;

		TraceResult tr;
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir = (self.m_fInZoom) ?
			vecAiming + x * VECTOR_CONE_BUFFALO_ZOOMED.x * g_Engine.v_right + y * VECTOR_CONE_BUFFALO_ZOOMED.y * g_Engine.v_up :
			vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
	}

	void SecondaryAttack()
	{
		if ( m_pPlayer.pev.fov != 0 )
		{
			m_pPlayer.pev.fov = 0;
			m_pPlayer.m_iFOV = 0;
			m_pPlayer.m_szAnimExtension = "sniper";
			self.m_fInZoom = false;
		}
		else if ( m_pPlayer.pev.fov != 20 )
		{
			m_pPlayer.pev.fov = 20;
			m_pPlayer.m_iFOV = 20;
			m_pPlayer.m_szAnimExtension = "sniperscope";
			self.m_fInZoom = true;
		}

		if ( self.m_flNextPrimaryAttack <= 0 )
			self.m_flNextPrimaryAttack = g_Engine.time + 0.1;

		self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip > 0 )
			return;

		if ( m_pPlayer.pev.fov != 0 )
		{
			SecondaryAttack();
		}

		self.DefaultReload( BUFFALO_MAX_CLIP, BUFFALO_RELOAD, 3.7, 0 );
		SetThink( ThinkFunction( this.Reload2 ) );
		self.pev.nextthink = g_Engine.time + 0.8f;

		BaseClass.Reload();
	}

	void Reload2()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/buffalo_breakopen.wav", 1.0f, ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );

		SetThink( ThinkFunction( this.Reload3 ) );
		self.pev.nextthink = g_Engine.time + 2.0f;
	}

	void Reload3()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/buffalo_reload.wav", 1.0f, ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );

		SetThink( ThinkFunction( this.ReloadComplete ) );
		self.pev.nextthink = g_Engine.time + 0.6f;
	}

	void ReloadComplete()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/buffalo_close.wav", 1.0f, ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0x1f ) );
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0:
			iAnim = BUFFALO_IDLE1;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;
			break;

			case 1:
			iAnim = BUFFALO_IDLE2;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;
			break;
		}
		self.SendWeaponAnim( iAnim );
	}
}

string GetBuffaloName()
{
	return "weapon_buffalo";
}

// Ammo class
class ammo_buffalo : CBaseCustomAmmo
{
	string AMMO_MODEL = "models/wanted/w_buffalobox.mdl";

	ammo_buffalo()
	{
		m_strModel = AMMO_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = BUFFALO_DEFAULT_AMMO;
		m_iMax = BUFFALO_MAX_CARRY;
	}
}

string GetBuffaloAmmoName()
{
	return "ammo_buffalo";
}

void Register()
{
	g_Game.PrecacheModel( "models/wanted/w_buffalobox.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Buffalo::ammo_buffalo", GetBuffaloAmmoName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Buffalo::weapon_buffalo", GetBuffaloName() );
	g_ItemRegistry.RegisterWeapon( GetBuffaloName(), "wanted", "buffalo", "", "ammo_buffalo", "" );
}

} //namespace HLWanted_Buffalo END