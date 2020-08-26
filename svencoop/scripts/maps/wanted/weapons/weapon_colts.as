namespace HLWanted_Colts
{
const string AMMO_TYPE		= "colts";

const int COLTS_DEFAULT_AMMO 	= 12;
const int COLTS_MAX_CARRY 	= 36;
const int COLTS_MAX_CLIP 	= 12;
const int COLTS_WEIGHT 		= 5;

enum Animation
{
	COLTS_IDLE1 = 0,
	COLTS_IDLE2,
	COLTS_FIDGET,
	COLTS_DRAW,
	COLTS_LEFT_FIRE,
	COLTS_RIGHT_FIRE,
	COLTS_DUAL_FIRE,
	COLTS_RELOAD,
	COLTS_HOLSTER
};

const array<string> pFireSounds =
{
	"wanted/weapons/coltsfire1.wav",
	"wanted/weapons/coltsfire2.wav"
};

class weapon_colts : CBaseCustomWeapon
{
	private int m_iSwing;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_colts.mdl" );
		
		self.m_iDefaultAmmo = COLTS_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_colts.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_colts.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_coltsT.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_colts.mdl" );

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/coltsreload1.wav" ); // reloading sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/coltsreload1.wav" );
		g_SoundSystem.PrecacheSound( "wanted/weapons/pistol_cock1.wav" ); // empty sound
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/pistol_cock1.wav" );

		for( uint i = 0; i < pFireSounds.length(); i++ ) // firing sounds
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

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_colts.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= COLTS_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= COLTS_MAX_CLIP;
		info.iSlot 	= 1;
		info.iPosition 	= 6;
		info.iFlags 	= 0;
		info.iWeight 	= COLTS_WEIGHT;

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
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_colts.mdl" ), self.GetP_Model( "models/wanted/p_colts.mdl" ), COLTS_DRAW, "uzis" );
			self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat(1.0, 2.0);
			return bResult;
		}
	}

	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void PrimaryAttack()
	{
		ColtsFire( 0.01, 0.6, false );
	}

	void SecondaryAttack()
	{
		if( self.m_iClip <= 1 )
		{
			PrimaryAttack();
			return;
		}

		ColtsFire( 0.08, 0.6, true );
	}

	void ColtsFire( float flSpread, float flCycleTime, bool fUseBoth )
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;
		}

		// for some reason the dual uzi shooting animation uses a different reference set
		if( flSpread >= 0.08 )
		{
			self.SendWeaponAnim( COLTS_DUAL_FIRE );
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pFireSounds[1], 1.0f, ATTN_NORM, 0, PITCH_NORM );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0f;

			self.m_iClip -= 2;

			m_pPlayer.m_Activity = ACT_RELOAD;
			m_pPlayer.pev.frame = 0;
			m_pPlayer.pev.sequence = m_pPlayer.LookupSequence( "ref_shoot_uzis_both" );
			m_pPlayer.ResetSequenceInfo();
		}
		else
		{
			m_pPlayer.m_Activity = ACT_RELOAD;
			m_pPlayer.pev.frame = 0;
			switch( ( m_iSwing++ ) % 2 )
			{
			case 0:
			{
				self.SendWeaponAnim( COLTS_LEFT_FIRE );
				m_pPlayer.pev.sequence = m_pPlayer.LookupSequence( "ref_shoot_uzis_left" );
			}
			break;
			case 1:
			{
				self.SendWeaponAnim( COLTS_RIGHT_FIRE );
				m_pPlayer.pev.sequence = m_pPlayer.LookupSequence( "ref_shoot_uzis_right" );
			}
			break;
			}
			m_pPlayer.ResetSequenceInfo();

			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pFireSounds[0], 1.0f, ATTN_NORM, 0, PITCH_NORM );

			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );

			--self.m_iClip;
		}

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		TraceResult tr;
		float x, y;

		int m_iBulletDamage = 15; // 15 per shot, 30 if both hit
		if( fUseBoth )
		{
			for( uint i = 0; i < 2; i++ )
			{
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, Vector( flSpread, flSpread, flSpread ), 8192, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );

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
		}
		else
		{
			m_iBulletDamage = 20;
			m_pPlayer.FireBullets( 1, vecSrc, vecAiming, Vector( flSpread, flSpread, flSpread ), 8192, BULLET_PLAYER_CUSTOMDAMAGE, 0, m_iBulletDamage );

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
		self.m_flNextPrimaryAttack = g_Engine.time + flCycleTime;
		self.m_flNextSecondaryAttack = g_Engine.time + flCycleTime;

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2.0, 2.0 );
		m_pPlayer.pev.punchangle.y = Math.RandomFloat( -3.0, 3.0 );
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == COLTS_MAX_CLIP ) // Can't reload if we have a full magazine already!
			return;

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "wanted/weapons/coltsreload1.wav", 1.0f, ATTN_NORM, 0, PITCH_NORM );

		self.m_flNextPrimaryAttack = g_Engine.time + 2.0f;
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack;

		self.DefaultReload( COLTS_MAX_CLIP, COLTS_RELOAD, 1.5, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );

		m_pPlayer.m_Activity = ACT_RELOAD;
		m_pPlayer.pev.frame = 0;
		m_pPlayer.pev.sequence = 135;
		m_pPlayer.ResetSequenceInfo();
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

			switch( Math.RandomLong(0, 2) )
			{
				case 0:
				{
					iAnim = COLTS_IDLE1;
					self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.7f;
				}
				break;
				case 1:
				{
					iAnim = COLTS_IDLE2;
					self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.8f;
				}
				break;
			}

			self.SendWeaponAnim( iAnim );
		}
	}
}

string GetColtsName()
{
	return "weapon_colts";
}

// Ammo class
class ammo_colts : CBaseCustomAmmo
{
	string AMMO_MODEL = "models/wanted/w_coltsbox.mdl";

	ammo_colts()
	{
		m_strModel = AMMO_MODEL;
		m_strName = AMMO_TYPE;
		m_iAmount = COLTS_DEFAULT_AMMO;
		m_iMax = COLTS_MAX_CARRY;
	}
}

string GetColtsAmmoName()
{
	return "ammo_colts";
}

void Register()
{
	g_Game.PrecacheModel( "models/wanted/w_coltsbox.mdl" );
	g_Game.PrecacheModel( "models/wanted/w_coltsboxt.mdl" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Colts::ammo_colts", GetColtsAmmoName() );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Colts::weapon_colts", GetColtsName() );
	g_ItemRegistry.RegisterWeapon( GetColtsName(), "wanted", "colts", "", "ammo_colts", "" );
}

} //namespace HLWanted_Colts END