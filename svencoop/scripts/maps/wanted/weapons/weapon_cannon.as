// Known bug(s):
// - ShootContact() doesn't damage breakable entities sometimes - deal with it

namespace HLWanted_Cannon
{
const int CANNON_DMG 		= 100;

const string AMMO_TYPE		= "cannon";

const int CANNON_DEFAULT_AMMO 	= 2;
const int CANNON_MAX_CARRY 	= 8;
const int CANNON_MAX_CLIP 	= 1;
const int CANNON_WEIGHT 	= 15;

enum Animation
{
	CANNON_DRAW = 0,
	CANNON_HOLSTER,
	CANNON_IDLE1,
	CANNON_IDLE2,
	CANNON_FIRE,
	CANNON_DRYFIRE,
	CANNON_RELOAD
};

const array<string> pGunSounds =
{
	//"wanted/weapons/cannon_empty.wav",
	"wanted/weapons/cannon_fire1.wav",
	"wanted/weapons/cannon_reload1.wav",
};

class weapon_cannon : CBaseCustomWeapon
{
	private int m_sModelIndexSmoke;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_cannon.mdl" );
		self.m_iDefaultAmmo = CANNON_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_cannon.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_cannon.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_cannonT.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_cannon.mdl" );
		g_Game.PrecacheModel( "models/wanted/cannonball.mdl" );

		m_sModelIndexSmoke = g_EngineFuncs.ModelIndex( "sprites/steam1.spr" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		for( uint i = 0; i < pGunSounds.length(); i++ ) // firing sounds
		{
			g_SoundSystem.PrecacheSound( pGunSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pGunSounds[i] ); // client has to download
		}

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_cannon.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= CANNON_MAX_CARRY;
		info.iAmmo1Drop = CANNON_DEFAULT_AMMO;
		info.iMaxAmmo2 	= -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip 	= CANNON_MAX_CLIP;
		info.iSlot 	= 3;
		info.iPosition 	= 6;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= 0;
		info.iWeight 	= CANNON_WEIGHT;

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
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_cannon.mdl" ), self.GetP_Model( "models/wanted/p_cannon.mdl" ), CANNON_DRAW, "saw" );
			self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
			self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		SetThink( null );
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

		self.SendWeaponAnim( CANNON_FIRE, 0, 0 );

		SetThink( ThinkFunction( this.FireCannon ) );

		self.pev.nextthink = g_Engine.time + 1.8f;
		self.m_flNextPrimaryAttack = g_Engine.time + 3.0;
		self.m_flTimeWeaponIdle = self.pev.nextthink;
	}

	void FireCannon()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[0], 1.0f, ATTN_NORM, 0, PITCH_NORM );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc = m_pPlayer.GetGunPosition();

		m_pPlayer.pev.velocity = -768 * g_Engine.v_forward; // Knockback!

		Math.MakeVectors( m_pPlayer.pev.v_angle );

		CGrenade@ pCannon = null;
		@pCannon = g_EntityFuncs.ShootContact( m_pPlayer.pev, vecSrc, g_Engine.v_forward * 1400 );
		if( pCannon !is null )
		{
			g_EntityFuncs.SetModel( pCannon, "models/wanted/cannonball.mdl" );
			pCannon.pev.dmg = CANNON_DMG;
			//pCannon.pev.eflags |= EFLAG_PROJECTILE; // for the future when exposed (if ever)
		}

		Vector vecGunPos = vecSrc + (g_Engine.v_forward * 20 + g_Engine.v_right * 5 - g_Engine.v_up * 15);
		NetworkMessage smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecGunPos );
			smoke.WriteByte( TE_SMOKE );
			smoke.WriteCoord( vecGunPos.x );
			smoke.WriteCoord( vecGunPos.y );
			smoke.WriteCoord( vecGunPos.z );
			smoke.WriteShort( m_sModelIndexSmoke );
			smoke.WriteByte( 10 ); // scale * 10
			smoke.WriteByte( 10  ); // framerate
		smoke.End();
	}

	void SecondaryAttack()
	{
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == CANNON_MAX_CLIP || self.m_flNextPrimaryAttack > g_Engine.time ) // Can't reload if we have a full magazine already!
			return;

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[1], 1.0f, ATTN_NORM, 0, PITCH_NORM );

		self.m_flNextPrimaryAttack = g_Engine.time + 2.5f;

		self.DefaultReload( CANNON_MAX_CLIP, CANNON_RELOAD, 2.5, 0 );

		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flNextIdle;

		switch( Math.RandomLong(0, 1) )
		{
			case 0:
			{
				iAnim = CANNON_IDLE1;
				flNextIdle = 2.6f;
			}
			break;
			case 1:
			{
				iAnim = CANNON_IDLE2;
				flNextIdle = 2.5f;
			}
			break;
		}

		self.m_flTimeWeaponIdle = g_Engine.time + flNextIdle;
		self.SendWeaponAnim( iAnim );
	}
}

string GetCannonName()
{
	return "weapon_cannon";
}

// Ammo class
class ammo_cannon : CBaseCustomAmmo
{
	string AMMO_MODEL = "models/wanted/w_cannonball.mdl";

	ammo_cannon()
	{
		m_strModel = AMMO_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = CANNON_DEFAULT_AMMO;
		m_iMax = CANNON_MAX_CARRY;
	}
}

string GetCannonAmmoName()
{
	return "ammo_cannon";
}

void Register()
{
	g_Game.PrecacheModel( "models/wanted/w_cannonball.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Cannon::ammo_cannon", GetCannonAmmoName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Cannon::weapon_cannon", GetCannonName() );
	g_ItemRegistry.RegisterWeapon( GetCannonName(), "wanted", AMMO_TYPE, "", GetCannonAmmoName(), "" );
}

} //namespace HLWanted_Cannon END