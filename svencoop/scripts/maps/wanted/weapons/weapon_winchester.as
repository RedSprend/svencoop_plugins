namespace HLWanted_Winchester
{
const string AMMO_TYPE		= "winchesterclip";

const int WINCHESTER_DEFAULT_AMMO = 11;
const int WINCHESTER_MAX_CARRY 	= 70;
const int WINCHESTER_MAX_CLIP 	= 11;
const int WINCHESTER_WEIGHT 	= 15;

enum Animation
{
	WINCHESTER_IDLE = 0,
	WINCHESTER_FIRE,
	WINCHESTER_RELOAD,
	WINCHESTER_PUMP,
	WINCHESTER_START_RELOAD,
	WINCHESTER_DRAW,
	WINCHESTER_HOLSTER
};

const array<string> pFireSounds =
{
	"wanted/weapons/winchester_fire1.wav",
	"wanted/weapons/winchester_fire2.wav",
	"wanted/weapons/winchester_fire3.wav"
};

const array<string> pReloadSounds =
{
	"wanted/weapons/winchester_reload1.wav",
	"wanted/weapons/winchester_reload2.wav"
};

class weapon_winchester : CBaseCustomWeapon
{
	float m_flNextReload;
	int m_iShell;
	float m_flPumpTime;
	bool m_fPlayPumpSound;
	bool m_fWinchesterReload;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_winchester.mdl" );

		self.m_iDefaultAmmo = WINCHESTER_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_winchester.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_winchester.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_winchesterT.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_winchester.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/wanted/shell.mdl" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		for( uint i = 0; i < pFireSounds.length(); i++ ) // firing sounds
		{
			g_SoundSystem.PrecacheSound( pFireSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pFireSounds[i] ); // client has to download
		}

		for( uint i = 0; i < pReloadSounds.length(); i++ ) // firing sounds
		{
			g_SoundSystem.PrecacheSound( pReloadSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pReloadSounds[i] ); // client has to download
		}

		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" ); // gun empty sound

		g_SoundSystem.PrecacheSound( "wanted/weapons/winchester_closebreak.wav" ); // cache
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/winchester_closebreak.wav" ); // client has to download

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_winchester.txt" );
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
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= WINCHESTER_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= WINCHESTER_MAX_CLIP;
		info.iSlot 	= 2;
		info.iPosition 	= 5;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= 0;
		info.iWeight 	= WINCHESTER_WEIGHT;

		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_winchester.mdl" ), self.GetP_Model( "models/wanted/p_winchester.mdl" ), WINCHESTER_DRAW, "shotgun" );
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		m_fWinchesterReload = false;

		SetThink( null );
		self.m_fInReload = false;
		BaseClass.Holster( skipLocal );
	}

	void ItemPostFrame()
	{
		if( m_flPumpTime != 0 && m_flPumpTime < g_Engine.time && m_fPlayPumpSound )
		{
			m_fPlayPumpSound = false;
		}

		BaseClass.ItemPostFrame();
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
			self.m_flNextPrimaryAttack = self.m_flTimeWeaponIdle = g_Engine.time + 0.75;
			self.Reload();
			self.PlayEmptySound();
			return;
		}

		self.SendWeaponAnim( WINCHESTER_FIRE, 0, 0 );

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pFireSounds[Math.RandomLong(0, pFireSounds.length()-1)], 1.0f, ATTN_NORM, 0, PITCH_NORM );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		int m_iBulletDamage = 75;
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );

		if( self.m_iClip != 0 )
			m_flPumpTime = g_Engine.time + 0.5;

		m_pPlayer.pev.punchangle.x = -5.0;

		self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
		self.m_flTimeWeaponIdle = g_Engine.time + 5.0;

		m_fWinchesterReload = false;
		m_fPlayPumpSound = true;

		TraceResult tr;
		float x, y;

		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;

		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 25, 7, -7 );

		vecShellVelocity.y *= 1;

		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
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

	void SecondaryAttack()
	{
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == WINCHESTER_MAX_CLIP )
			return;

		if( m_flNextReload > g_Engine.time )
			return;

		// don't reload until recoil is done
		if( self.m_flNextPrimaryAttack > g_Engine.time && !m_fWinchesterReload )
			return;

		// check to see if we're ready to reload
		if( !m_fWinchesterReload )
		{
			self.SendWeaponAnim( WINCHESTER_START_RELOAD, 0, 0 );
			m_pPlayer.m_flNextAttack = 0.6;	//Always uses a relative time due to prediction
			self.m_flTimeWeaponIdle	= g_Engine.time + 0.6;
			self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
			self.m_flNextSecondaryAttack = g_Engine.time + 1.0;
			m_fWinchesterReload = true;
			return;
		}
		else if( m_fWinchesterReload )
		{
			if( self.m_flTimeWeaponIdle > g_Engine.time )
				return;

			if( self.m_iClip == WINCHESTER_MAX_CLIP )
			{
				m_fWinchesterReload = false;
				return;
			}

			self.SendWeaponAnim( WINCHESTER_RELOAD, 0 );
			m_flNextReload = g_Engine.time + 0.5;
			self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
			self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
				
			// Add them to the clip
			self.m_iClip += 1;
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

			switch( Math.RandomLong( 0, 1 ) )
			{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, pReloadSounds[0], 1, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, pReloadSounds[1], 1, ATTN_NORM, 0, PITCH_NORM ); break;
			}
		}

		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle < g_Engine.time )
		{
			if( self.m_iClip == 0 && !m_fWinchesterReload && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) != 0 )
			{
				self.Reload();
			}
			else if( m_fWinchesterReload )
			{
				if( self.m_iClip != WINCHESTER_MAX_CLIP && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
				{
					self.Reload();
				}
				else
				{
					// reload debounce has timed out
					self.SendWeaponAnim( WINCHESTER_PUMP, 0, 0 );

					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "wanted/weapons/winchester_closebreak.wav", 1, ATTN_NORM, 0, 95 + Math.RandomLong( 0,0x1f ) );
					m_fWinchesterReload = false;
					self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
				}
			}
			else
			{
				self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
				self.SendWeaponAnim( WINCHESTER_IDLE, 0, 0 );
			}
		}
	}
}

string GetWinchesterName()
{
	return "weapon_winchester";
}

// Ammo class
class ammo_winchesterclip : CBaseCustomAmmo
{
	string AMMO_MODEL = "models/wanted/w_winchesterclip.mdl";

	ammo_winchesterclip()
	{
		m_strModel = AMMO_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = WINCHESTER_DEFAULT_AMMO;
		m_iMax = WINCHESTER_MAX_CARRY;
	}
}

string GetWinchesterAmmoName()
{
	return "ammo_winchesterclip";
}

void Register()
{
	g_Game.PrecacheModel( "models/wanted/w_winchesterclip.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_winchesterclipt.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Winchester::weapon_winchester", GetWinchesterName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Winchester::ammo_winchesterclip", GetWinchesterAmmoName() );
	g_ItemRegistry.RegisterWeapon( GetWinchesterName(), "wanted", AMMO_TYPE, "", GetWinchesterAmmoName(), "" );
}

} //namespace HLWanted_Winchester END