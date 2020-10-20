namespace HLWanted_Gattlinggun
{
const int GAT_DEFAULT_AMMO 	= 100;
const int GAT_MAX_CARRY 	= 200;
const int GAT_MAX_CLIP 		= 100;
const int GAT_WEIGHT 		= 15;

enum Animation
{
	GAT_IDLE1 = 0,
	GAT_IDLE2,
	GAT_IDLE3,
	GAT_SPINUP,
	GAT_FIRE,
	GAT_SPINDOWN,
	GAT_DRAW,
	GAT_HOLSTER,
	GAT_JAMMED,
	GAT_UNJAM,
	GAT_RELOAD,
	GAT_DRYFIRE
};

const array<string> pGunSounds =
{
	"wanted/weapons/gat_jamb.wav",
	"wanted/weapons/gat_reload.wav",
	"wanted/weapons/gat_shoot1.wav",
	"wanted/weapons/gat_spindown.wav",
	"wanted/weapons/gat_spinup.wav",
	"wanted/weapons/gat_unjamb.wav",
	"wanted/weapons/gat_dryfire.wav",
	"wanted/player/gat_jamb.wav"
};

class weapon_gattlinggun : CBaseCustomWeapon
{
	float m_flStartThrow = 0.0f;
	bool bGunJammed = false;
	int iCounter = GAT_DEFAULT_AMMO;
	int m_iShell;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_gattlinggun.mdl" );

		self.m_iDefaultAmmo = GAT_DEFAULT_AMMO;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/wanted/v_gattlinggun.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_gattlinggun.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_gattlinggunT.mdl" );
		g_Game.PrecacheModel( "models/wanted/p_gattlinggun.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/wanted/shell.mdl" ); // brass casing

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );

		for( uint i = 0; i < pGunSounds.length(); i++ ) // firing sounds
		{
			g_SoundSystem.PrecacheSound( pGunSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pGunSounds[i] ); // client has to download
		}

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_gattlinggun.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= GAT_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= GAT_MAX_CLIP;
		info.iSlot 	= 3;
		info.iPosition 	= 5;
		info.iId     	= g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iFlags 	= 0;
		info.iWeight 	= GAT_WEIGHT;

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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_gattlinggun.mdl" ), self.GetP_Model( "models/wanted/p_gattlinggun.mdl" ), GAT_DRAW, "saw" );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
			if( bGunJammed )
			{
				self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.0;
			}
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.5;
			return bResult;
		}
	}

	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void Holster( int skipLocal = 0 )
	{
		SetThink( null );
		self.m_fInReload = false;

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[4], 1.0f, ATTN_NORM, SND_STOP, PITCH_NORM );

		if( m_flStartThrow != 0 )
		{
			if( !bGunJammed )
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[3], 1.0f, ATTN_NORM, 0, PITCH_NORM );
				self.SendWeaponAnim( GAT_SPINDOWN, 0, 0 );
				iCounter = GAT_DEFAULT_AMMO;
			}

			m_flStartThrow = 0.0f;
		}

		BaseClass.Holster( skipLocal );
	}

	void SpinUp()
	{
		float flSpinTime = m_flStartThrow;

		flSpinTime = 1.4f;
		m_flStartThrow = flSpinTime;
	}

	void PrimaryAttack()
	{
		float flSpinTime = m_flStartThrow;

		if( bGunJammed )
		{
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.0;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			if( flSpinTime != 0 )
			{
				self.SendWeaponAnim( GAT_DRYFIRE, 0, 0 );

				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[6], 1.0f, ATTN_NORM, 0, PITCH_NORM );

				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.1;
			}

			return;
		}

		if( flSpinTime == 0 )
		{
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[4], 1.0f, ATTN_NORM, 0, PITCH_NORM );
		}

		if( flSpinTime <= 0.0f )
		{
			self.SendWeaponAnim( GAT_SPINUP, 0, 0 );

			SetThink( ThinkFunction( this.SpinUp ) );
			pev.nextthink = g_Engine.time + 1.3f;

			self.m_flNextPrimaryAttack = pev.nextthink + 0.1;
			self.m_flTimeWeaponIdle = pev.nextthink + 0.1;

			return;
		}
		else if( flSpinTime > 1.3f )
		{
			if( iCounter < 60 && Math.RandomLong(0, 10) == 5 )
			{
				self.SendWeaponAnim( GAT_JAMMED, 0, 0 );

				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[0], 1.0f, ATTN_NORM, 0, PITCH_NORM );
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_VOICE, pGunSounds[7], 1.0f, ATTN_NORM, 0, PITCH_NORM );

				bGunJammed = true;
				self.m_flNextSecondaryAttack = g_Engine.time + 1.0;

				return;
			}

			iCounter--;

			self.SendWeaponAnim( GAT_FIRE, 0, 0 );

			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[2], 1.0f, ATTN_NORM, 0, PITCH_NORM );

			Vector vecShellVelocity, vecShellOrigin;

			GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 12, 7, -8 );

			vecShellVelocity.y *= 2;

			g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[1], m_iShell, TE_BOUNCE_SHELL );

			m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

			--self.m_iClip;

			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			Vector vecSrc	 = m_pPlayer.GetGunPosition();
			Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

			int m_iBulletDamage = 12;
			if ( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_20DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else if ( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_5DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}
			else
			{
				m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );
			}

			m_pPlayer.pev.punchangle.x = Math.RandomLong( -2, 2 );
			m_pPlayer.pev.punchangle.y = Math.RandomLong( -2, 2 );
			m_pPlayer.pev.velocity = -64 * g_Engine.v_forward; // Knockback!

			self.m_flNextPrimaryAttack = g_Engine.time + 0.08;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.0;

			TraceResult tr;
			float x, y;
		
			g_Utility.GetCircularGaussianSpread( x, y );
		
			Vector vecDir;

			if ( !( m_pPlayer.pev.flags & FL_ONGROUND != 0 ) )
			{
				vecDir = vecAiming + x * VECTOR_CONE_20DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_20DEGREES.y * g_Engine.v_up;
			}
			else if ( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
			}
			else
			{
				vecDir = vecAiming + x * Vector(0.0, 0.0, 0.00873) * g_Engine.v_right + y * Vector(0.0, 0.0, 0.00873) * g_Engine.v_up;
			}

			Vector vecEnd = vecSrc + vecDir * 4096;

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

		m_flStartThrow = flSpinTime;
		self.m_flNextPrimaryAttack = g_Engine.time + 0.1;
		self.m_flNextSecondaryAttack = -1.0;
		self.m_flTimeWeaponIdle = g_Engine.time + 0.1;
	}

	void SecondaryAttack()
	{
		if( !bGunJammed || self.m_flNextSecondaryAttack == -1.0f )
		{
			return;
		}

		self.m_flNextSecondaryAttack = 9999.0;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.0f;

		self.SendWeaponAnim( GAT_UNJAM, 0, 0 );
		SetThink( ThinkFunction( this.UnJam ) );

		self.pev.nextthink = g_Engine.time + 0.2f;
	}

	void UnJam()
	{
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[5], 1.0f, ATTN_NORM, 0, PITCH_NORM );
		SetThink( ThinkFunction( this.UnJammed ) );
		self.pev.nextthink = g_Engine.time + 0.6f;
	}

	void UnJammed()
	{
		m_flStartThrow = 0.0f;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5;
		self.m_flNextPrimaryAttack = g_Engine.time + 0.5;

		bGunJammed = false;
		iCounter = GAT_DEFAULT_AMMO;
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 || self.m_iClip == GAT_MAX_CLIP ) // Can't reload if we have a full magazine already!
			return;

		SetThink( null );

		if( m_flStartThrow != 0 )
		{
			if( !bGunJammed )
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[3], 1.0f, ATTN_NORM, 0, PITCH_NORM );
			}

			m_flStartThrow = 0.0f;
		}

		self.m_flNextPrimaryAttack = g_Engine.time + 2.5f;
		self.m_flNextSecondaryAttack = g_Engine.time + 2.5f;

		self.DefaultReload( GAT_MAX_CLIP, GAT_RELOAD, 2.0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void ItemPreFrame()
	{
		if( ( m_pPlayer.pev.button & IN_ATTACK2 ) != 0 && !bGunJammed )
		{ // Player is holding +attack2 button
			m_pPlayer.pev.button &= ~IN_ATTACK2;
		}

		BaseClass.ItemPreFrame();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if( m_flStartThrow != 0 )
		{
			if( !bGunJammed )
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pGunSounds[3], 1.0f, ATTN_NORM, 0, PITCH_NORM );
				self.SendWeaponAnim( GAT_SPINDOWN, 0, 0 );
				iCounter = GAT_DEFAULT_AMMO;
			}
			m_flStartThrow = 0.0f;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.7;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack + 1.0f;
			return;
		}

		int iAnim;
		float flNextIdle;

		switch( Math.RandomLong(0, 2) )
		{
			case 0:
			{
				iAnim = GAT_IDLE1;
				flNextIdle = Math.RandomFloat(1.0, 3.0);
			}
			break;
			case 1:
			{
				iAnim = GAT_IDLE2;
				flNextIdle = 1.8f;
			}
			break;
			case 2:
			{
				iAnim = GAT_IDLE3;
				flNextIdle = 1.4f;
			}
			break;
		}

		self.m_flTimeWeaponIdle = WeaponTimeBase() + flNextIdle;
		self.SendWeaponAnim( iAnim );
	}
}

string GetGattlinggunName()
{
	return "weapon_gattlinggun";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Gattlinggun::weapon_gattlinggun", GetGattlinggunName() );
	g_ItemRegistry.RegisterWeapon( GetGattlinggunName(), "wanted", "556", "", "ammo_556", "" );
}

} //namespace HLWanted_Gattlinggun END