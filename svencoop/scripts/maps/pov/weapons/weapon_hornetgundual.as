#include "../monsters/hornet"

namespace XENDHGun
{
const string ViewModel 			= "models/hlclassic/pov/v_dualhgun.mdl";
const string WorldModel 		= "models/hlclassic/w_hgun.mdl";
const string PlayerModel 		= "models/hlclassic/p_hgun.mdl";

const int DHGUN_MAX_CLIP 		= 100;
const int DHGUN_WEIGHT 			= 20;

const float DHGUN_DELAY_RECHARGE 	= 1.5f;

enum Animation
{
	DHGUN_IDLE1 = 0,
	DHGUN_IDLE2,
	DHGUN_IDLE3,
	DHGUN_FIDGETSWAY_L,
	DHGUN_FIDGETSWAY_R,
	DHGUN_FIDGETSHAKE_L,
	DHGUN_FIDGETSHAKE_R,
	DHGUN_DOWN,
	DHGUN_UP,
	DHGUN_SHOOT_R,
	DHGUN_SHOOT_L
};

enum Firemode
{
	FIREMODE_TRACK = 0,
	FIREMODE_FAST
};

const array<string> pFireSounds =
{
	"agrunt/ag_fire1.wav",
	"agrunt/ag_fire2.wav",
	"agrunt/ag_fire3.wav"
};

class weapon_hornetgundual : ScriptBasePlayerWeaponEntity
{
	protected CBasePlayer@ m_pPlayer
	{
		get const { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set { self.m_hPlayer = EHandle( @value ); }
	}

	private float m_flRechargeTimeR, m_flRechargeTimeL;
	private int m_iFirePhase;
	private int m_iRight;

	private int iMuzzleFlash;

	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, WorldModel );
		
		self.m_iDefaultAmmo = DHGUN_MAX_CLIP;
		self.m_iDefaultSecAmmo = DHGUN_MAX_CLIP;
		m_iFirePhase = 0;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( ViewModel );
		g_Game.PrecacheModel( PlayerModel );
		g_Game.PrecacheModel( WorldModel );

		iMuzzleFlash = g_Game.PrecacheModel( "sprites/muz4.spr" );

		for( uint i = 0; i < pFireSounds.length(); i++ ) // firing sounds
		{
			g_SoundSystem.PrecacheSound( pFireSounds[i] ); // cache
			g_Game.PrecacheGeneric( "sound/" + pFireSounds[i] ); // client has to download
		}

		g_Game.PrecacheGeneric( "sprites/" + "pov/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/320hudpv1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hudpv2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hudpv5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "pov/weapon_hornetgundual.txt" );

		g_Game.PrecacheOther( "hornet" );
		g_Game.PrecacheOther( "customhornet" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= DHGUN_MAX_CLIP;
		info.iMaxAmmo2 	= DHGUN_MAX_CLIP;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 	= 3;
		info.iPosition 	= 6;
		info.iFlags 	= ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_NOAUTORELOAD;
		info.iWeight 	= DHGUN_WEIGHT;

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

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( ViewModel ), self.GetP_Model( PlayerModel ), DHGUN_UP, "hive" );
			self.m_flNextPrimaryAttack = g_Engine.time + 1.0f;
			self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack;
			return bResult;
		}
	}

	void Holster(int skiplocal)
	{
		self.m_fInReload = false;
		SetThink( null );

		if( m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex()) <= 0 )
			m_pPlayer.m_rgAmmo( self.PrimaryAmmoIndex(), 1 );

		if( m_pPlayer.m_rgAmmo( self.SecondaryAmmoIndex()) <= 0 )
			m_pPlayer.m_rgAmmo( self.SecondaryAmmoIndex(), 1 );

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		Reload();

		DHGunFire( FIREMODE_TRACK, 0.135 );
	}

	void SecondaryAttack()
	{
		Reload();

		DHGunFire( FIREMODE_FAST, 0.1 );
	}

	void DHGunFire( int iFireMode, float flNextAttack )
	{
		Math.MakeVectors( m_pPlayer.pev.v_angle );

		Vector vecSrc = m_pPlayer.GetGunPosition() + g_Engine.v_forward * 20 + g_Engine.v_up * -10;

		switch( ( m_iRight++ ) % 2 )
		{
			case 0:
			{
				if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0 )
					return;

				vecSrc = vecSrc + g_Engine.v_right * 8;

				NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSrc );
					message.WriteByte( TE_SPRITE );
					message.WriteCoord( vecSrc.x );		// pos
					message.WriteCoord( vecSrc.y );
					message.WriteCoord( vecSrc.z );
					message.WriteShort( iMuzzleFlash );	// model
					message.WriteByte( 3 );			// size * 10
					message.WriteByte( 128 );		// brightness
				message.End();

				self.SendWeaponAnim( DHGUN_SHOOT_R );
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

				if( iFireMode == FIREMODE_FAST )
				{
					m_iFirePhase++;
					switch( m_iFirePhase )
					{
					case 1: vecSrc = vecSrc + g_Engine.v_up * 8; break;
					case 2:
						vecSrc = vecSrc + g_Engine.v_up * 8;
						vecSrc = vecSrc + g_Engine.v_right * 8;
						break;
					case 3: vecSrc = vecSrc + g_Engine.v_right * 8; break;
					case 4:
						vecSrc = vecSrc + g_Engine.v_up * -8;
						vecSrc = vecSrc + g_Engine.v_right * 8;
						break;
					case 5: vecSrc = vecSrc + g_Engine.v_up * -8; break;
					case 6:
						vecSrc = vecSrc + g_Engine.v_up * -8;
						vecSrc = vecSrc + g_Engine.v_right * -8;
						break;
					case 7: vecSrc = vecSrc + g_Engine.v_right * -8; break;
					case 8:
						vecSrc = vecSrc + g_Engine.v_up * 8;
						vecSrc = vecSrc + g_Engine.v_right * -8;
						m_iFirePhase = 0;
						break;
					}

					m_pPlayer.pev.punchangle.x = Math.RandomFloat( 0.0, -2.0 );
				}

				m_flRechargeTimeR = g_Engine.time + DHGUN_DELAY_RECHARGE;
			}
			break;
			case 1:
			{
				if( m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 )
					return;

				vecSrc = vecSrc + g_Engine.v_right * -8;

				NetworkMessage message( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSrc );
					message.WriteByte( TE_SPRITE );
					message.WriteCoord( vecSrc.x );		// pos
					message.WriteCoord( vecSrc.y );
					message.WriteCoord( vecSrc.z );
					message.WriteShort( iMuzzleFlash );	// model
					message.WriteByte( 3 );			// size * 10
					message.WriteByte( 128 );		// brightness
				message.End();

				self.SendWeaponAnim( DHGUN_SHOOT_L );
				m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) - 1 );

				if( iFireMode == FIREMODE_FAST )
				{
					m_iFirePhase++;
					switch( m_iFirePhase )
					{
					case 1:
						vecSrc = vecSrc + g_Engine.v_up * -8;
						vecSrc = vecSrc + g_Engine.v_right * 8;
						break;
					case 2: vecSrc = vecSrc + g_Engine.v_right * 8; break;
					case 3:
						vecSrc = vecSrc + g_Engine.v_up * 8;
						vecSrc = vecSrc + g_Engine.v_right * 8;
						break;
					case 4: vecSrc = vecSrc + g_Engine.v_up * 8; break;
					case 5:
						vecSrc = vecSrc + g_Engine.v_up * 8;
						vecSrc = vecSrc + g_Engine.v_right * -8;
						break;
					case 6: vecSrc = vecSrc + g_Engine.v_right * -8; break;
					case 7:
						vecSrc = vecSrc + g_Engine.v_up * -8;
						vecSrc = vecSrc + g_Engine.v_right * -8;
						break;
					case 8:
						vecSrc = vecSrc + g_Engine.v_up * -8;
						m_iFirePhase = 0;
						break;
					}

					m_pPlayer.pev.punchangle.x = Math.RandomFloat( 0.0, -2.0 );
				}

				m_flRechargeTimeL = g_Engine.time + DHGUN_DELAY_RECHARGE;
			}
			break;
		}

		CBaseEntity@ cbeHornet = null;
		if( iFireMode == FIREMODE_FAST )
		{
			@cbeHornet = g_EntityFuncs.Create( "customhornet", vecSrc, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
			if( cbeHornet !is null )
			{
				cbeHornet.pev.dmg = 10;
				@cbeHornet.pev.owner = @m_pPlayer.edict();

				cbeHornet.pev.velocity = g_Engine.v_forward * 1200;
				cbeHornet.pev.angles = Math.VecToAngles( cbeHornet.pev.velocity );

				CHornet@ pHornet = cast<CHornet@>( CastToScriptClass( cbeHornet ) );
				pHornet.SetThink( ThinkFunction(pHornet.StartDart) );
			}
		}
		else
		{
			@cbeHornet = g_EntityFuncs.Create( "hornet", vecSrc, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
			if( cbeHornet !is null )
			{
				cbeHornet.pev.dmg = 10;
				@cbeHornet.pev.owner = @m_pPlayer.edict();
				cbeHornet.pev.velocity = g_Engine.v_forward * 300;
			}
		}

		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, pFireSounds[Math.RandomLong(0, pFireSounds.length()-1)], 1.0, ATTN_NORM, 0, PITCH_NORM );

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		self.m_flNextPrimaryAttack = g_Engine.time + flNextAttack;
		self.m_flNextSecondaryAttack = g_Engine.time + flNextAttack;
		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= DHGUN_MAX_CLIP )
		{
			while( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) < DHGUN_MAX_CLIP and m_flRechargeTimeR < g_Engine.time )
			{
				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) + 1 );
				m_flRechargeTimeR += DHGUN_DELAY_RECHARGE;
			}
		}

		if( m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) <= DHGUN_MAX_CLIP )
		{
			while( m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) < DHGUN_MAX_CLIP and m_flRechargeTimeL < g_Engine.time )
			{
				m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) + 1 );
				m_flRechargeTimeL += DHGUN_DELAY_RECHARGE;
			}
		}
	}

	void WeaponIdle()
	{
		Reload();

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  0, 1 );
		if (flRand <= 0.75)
		{
			switch( Math.RandomLong(0,2) )
			{
			case 0: iAnim = DHGUN_IDLE1; break;
			case 1: iAnim = DHGUN_IDLE2; break;
			case 2: iAnim = DHGUN_IDLE3; break;
			}
			self.m_flTimeWeaponIdle = g_Engine.time + 30.0 / 16 * (2);
		}
		else if (flRand <= 0.875)
		{
			switch( Math.RandomLong(0,1) )
			{
			case 0: iAnim = DHGUN_FIDGETSWAY_L; break;
			case 1: iAnim = DHGUN_FIDGETSWAY_R; break;
			}
			self.m_flTimeWeaponIdle = g_Engine.time + 40.0 / 16.0;
		}
		else
		{
			switch( Math.RandomLong(0,1) )
			{
			case 0: iAnim = DHGUN_FIDGETSHAKE_L; break;
			case 1: iAnim = DHGUN_FIDGETSHAKE_R; break;
			}
			self.m_flTimeWeaponIdle = g_Engine.time + 35.0 / 16.0;
		}
		self.SendWeaponAnim( iAnim );
	}

	/*CBasePlayerItem@ DropItem() 
	{
		return null;
	}*/
}

void Register()
{
	//CustomHornet::Register();
	g_CustomEntityFuncs.RegisterCustomEntity( "CHornet", "customhornet" );
	g_CustomEntityFuncs.RegisterCustomEntity( "XENDHGun::weapon_hornetgundual", "weapon_hornetgundual" );
	g_ItemRegistry.RegisterWeapon( "weapon_hornetgundual", "pov", "hornet", "customhornet" );
}

} //namespace XENDHGun END