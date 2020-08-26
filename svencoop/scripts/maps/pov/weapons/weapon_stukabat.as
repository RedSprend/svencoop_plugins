// TO-DO:
// - Reload animation
// - (?) Set a limit of how many each player can have?

namespace XENSTUKABAT
{
const string ViewModel = "models/hlclassic/pov/v_stukabat.mdl";
const string WorldModel = "models/hlclassic/pov/w_stukabat.mdl";
//const string PlayerModel = "models/hlclassic/pov/p_stukabat.mdl"; // needs a proper model

const int STUKABAT_DEFAULT_GIVE = 1;
const int STUKABAT_MAX_CARRY 	= 10;
const int STUKABAT_WEIGHT 	= 5;

enum stukabat_e
{
	STUKABAT_IDLE1 = 0,
	STUKABAT_FIDGET,
	STUKABAT_RELOAD,
	STUKABAT_FIRE,
	STUKABAT_HOLSTER,
	STUKABAT_DRAW,
	STUKABAT_HOLSTER2,
	STUKABAT_DRAW2,
	STUKABAT_IDLE2,
	STUKABAT_FIDGET2
};

class weapon_stukabat : ScriptBasePlayerWeaponEntity
{
	protected CBasePlayer@ m_pPlayer
	{
		get const { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set { self.m_hPlayer = EHandle( @value ); }
	}

	void Spawn()
	{
		Precache( );
		//self.m_iId = WEAPON_STUKABAT;
		g_EntityFuncs.SetModel( self, WorldModel );

		self.m_iDefaultAmmo = STUKABAT_DEFAULT_GIVE;

		self.FallInit();

		self.pev.sequence = 1;
		self.pev.animtime = g_Engine.time;
		self.pev.framerate = 1.0;
	}

	void Precache( void )
	{
		g_Game.PrecacheModel( ViewModel );
		g_Game.PrecacheModel( "models/hlclassic/pov/v_stukabatt.mdl" );
		g_Game.PrecacheModel( WorldModel );
		//g_Game.PrecacheModel( PlayerModel );

		g_SoundSystem.PrecacheSound( "stukabat/stkb_deploy1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "stukabat/stkb_deploy1.wav" );
		g_SoundSystem.PrecacheSound( "stukabat/stkb_deploy2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "stukabat/stkb_deploy2.wav" );
		g_SoundSystem.PrecacheSound( "stukabat/stkb_fire1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "stukabat/stkb_fire1.wav" );
		g_SoundSystem.PrecacheSound( "stukabat/stkb_fire2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "stukabat/stkb_fire2.wav" );
		g_SoundSystem.PrecacheSound( "stukabat/stkb_idle1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "stukabat/stkb_idle1.wav" );

		g_SoundSystem.PrecacheSound( "items/gunpickup2.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "pov/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud7.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "pov/weapon_stukabat.txt" );

		g_Game.PrecacheOther( "monster_stukabat" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 = STUKABAT_MAX_CARRY;
		info.iAmmo1Drop	= 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 4;
		info.iPosition = 11;
		info.iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
		info.iId = g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iWeight = STUKABAT_WEIGHT;

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

	protected bool m_fDropped;
	CBasePlayerItem@ DropItem()
	{
		m_fDropped = true;
		return self;
	}

	bool Deploy()
	{
		bool bResult;
		{
			m_fDropped = false;
			bResult = self.DefaultDeploy( self.GetV_Model( ViewModel ), self.GetP_Model( "" ), STUKABAT_DRAW, "squeak" );
			self.m_flNextPrimaryAttack = g_Engine.time + 1.2f;
			self.m_flTimeWeaponIdle = g_Engine.time + 2.0;

			// play hunt sound
			float flRndSound = Math.RandomFloat( 0, 1 );

			if( flRndSound <= 0.5 )
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "stukabat/stkb_deploy1.wav", 1, ATTN_NORM, 0, 100 );
			else
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "stukabat/stkb_deploy2.wav", 1, ATTN_NORM, 0, 100 );

			return bResult;
		}
	}

	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) != 0;
	}

	void DestroyThink( void )
	{
		SetThink( null );
		self.DestroyItem();
	}

	void Holster( int skiplocal /* = 0 */ )
	{
		self.m_fInReload = false;
		SetThink( null );

		m_pPlayer.pev.viewmodel = string_t();

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 && !m_fDropped )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName( self.pev.classname ) );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		else
		{
			self.SendWeaponAnim( STUKABAT_HOLSTER );
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "common/null.wav", 1.0f, ATTN_NORM );
		}

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			Math.MakeVectors( m_pPlayer.pev.v_angle );
			TraceResult tr;
			Vector trace_origin;

			// HACK HACK:  Ugly hacks to handle change in origin based on new physics code for players
			// Move origin up if crouched and start trace a bit outside of body ( 20 units instead of 16 )
			trace_origin = m_pPlayer.pev.origin;
			if ( m_pPlayer.pev.flags & FL_DUCKING != 0 )
			{
				trace_origin = trace_origin - ( VEC_HULL_MIN - VEC_DUCK_HULL_MIN );
			}

			// find place to toss monster
			g_Utility.TraceLine( trace_origin + g_Engine.v_forward * 20, trace_origin + g_Engine.v_forward * 64, dont_ignore_monsters, null, tr );

			if( tr.fAllSolid == 0 && tr.fStartSolid == 0 && tr.flFraction > 0.25 )
			{
				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

				// GAME BUG!! If Stukabat has an owner = no collision
				CBaseEntity@ pStukaBat = g_EntityFuncs.Create( "monster_stukabat", tr.vecEndPos, m_pPlayer.pev.v_angle, true/*, m_pPlayer.edict()*/ );
				g_EntityFuncs.DispatchKeyValue( pStukaBat.edict(), "is_player_ally", "1" );
				g_EntityFuncs.DispatchSpawn( pStukaBat.edict() );

				// Follow the owner
				CBaseMonster@ pMonster = cast<CBaseMonster@>( pStukaBat );
				if( pMonster !is null )
				{
					pMonster.m_FormattedName = ""+m_pPlayer.pev.netname+"'s Stukabat";
					pMonster.FollowerPlayerUse( m_pPlayer, m_pPlayer, USE_ON, USE_ON );
				}

				// play hunt sound
				float flRndSound = Math.RandomFloat( 0, 1 );

				if ( flRndSound <= 0.5 )
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "stukabat/stkb_fire1.wav", 1, ATTN_NORM, 0, PITCH_NORM);
				else 
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "stukabat/stkb_fire2.wav", 1, ATTN_NORM, 0, PITCH_NORM);

				m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;

				m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
				self.SendWeaponAnim( STUKABAT_FIRE );

				self.m_flNextPrimaryAttack = g_Engine.time + 1.2f;
				self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

				SetThink( ThinkFunction( this.Reload ) );
				self.pev.nextthink = g_Engine.time + 0.2;
			}
		}
	}

	void SecondaryAttack( void )
	{
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		self.m_flNextPrimaryAttack = g_Engine.time + 1.2f;
		self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

		self.DefaultReload( STUKABAT_MAX_CARRY, STUKABAT_RELOAD, 1.2, 0 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle( void )
	{
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			self.RetireWeapon();
			return;
		}

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if (flRand <= 0.75)
		{
			iAnim = STUKABAT_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + 30.0 / 16 * (2);
		}
		else if (flRand <= 0.875)
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, m_pPlayer.edict() );
				message.WriteString( "spk stukabat/stkb_idle1" );
			message.End();

			iAnim = STUKABAT_FIDGET;
			self.m_flTimeWeaponIdle = g_Engine.time + 70.0 / 16.0;
		}
		else
		{
			iAnim = STUKABAT_IDLE2;
			self.m_flTimeWeaponIdle = g_Engine.time + 80.0 / 16.0;
		}
		self.SendWeaponAnim( iAnim );
	}

	void Materialize()
	{
		BaseClass.Materialize();
	}

	bool CanHaveDuplicates()
	{
		return true;
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "XENSTUKABAT::weapon_stukabat", "weapon_stukabat" );
	g_ItemRegistry.RegisterWeapon( "weapon_stukabat", "pov", "weapon_stukabat", "", "weapon_stukabat" );
}

} //namespace XENSTUKABAT END