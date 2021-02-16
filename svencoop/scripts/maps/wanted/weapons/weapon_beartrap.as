// Suggestion(s):
// - Remove if there are too many traps?

namespace HLWanted_Beartrap
{
const int BEARTRAP_DEFAULT_GIVE = 2;
const int BEARTRAP_MAX_CARRY 	= 10;
const int BEARTRAP_WEIGHT 	= 5;

const float BEARTRAP_DMG = 70.0;

uint WEAPON_BEARTRAP = 16;

class monster_beartrap : ScriptBaseMonsterEntity
{
	private float m_flKillVictimTime;
	private int m_iLifeTime;
	private float m_flNextBounceSound;

	void Spawn()
	{
		Precache( );

		self.pev.movetype = MOVETYPE_BOUNCE;
		self.pev.solid = SOLID_TRIGGER;

		g_EntityFuncs.SetModel( self, "models/wanted/w_beartrap.mdl" );
		g_EntityFuncs.SetSize( self.pev, Vector(-4, -4, -4), Vector(4, 4, 4) );	// Uses point-sized, and can be stepped over
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		self.pev.sequence = self.LookupSequence( "idle" );
		self.pev.frame = 0;
		self.ResetSequenceInfo();

		self.pev.friction = 0.95f;

		m_iLifeTime = 300 * 10; // life * 10

		m_flNextBounceSound = g_Engine.time;

		SetTouch( TouchFunction( this.BeartrapSlide ) );
		SetThink( ThinkFunction( this.BeartrapThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/w_beartrap.mdl" );
		g_Game.PrecacheModel( "models/wanted/w_beartrapT.mdl" );

		g_SoundSystem.PrecacheSound( "weapons/g_bounce1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/g_bounce3.wav" );

		g_SoundSystem.PrecacheSound( "wanted/weapons/beartrap_sprung.wav" );
		g_Game.PrecacheGeneric( "sound/" + "wanted/weapons/beartrap_sprung.wav" );
	}

	void BeartrapSlide( CBaseEntity@ pOther )
	{
		TraceResult tr;

		g_Utility.TraceLine( pev.origin, pev.origin - Vector(0,0,10), ignore_monsters, self.edict(), tr );

		if( tr.flFraction < 1.0 )
		{
			// add a bit of static friction
			pev.velocity = pev.velocity * 0.95;
			pev.avelocity = pev.avelocity * 0.9;
		}

		if( (pev.flags & FL_ONGROUND) != 0 && pev.velocity.Length2D() > 10 )
		{
			BounceSound();
		}

		self.StudioFrameAdvance();

		if( pev.velocity.Length2D() > 0 || !pOther.IsPlayer() && !pOther.IsMonster() || !pOther.IsAlive() || pOther.pev.takedamage == DAMAGE_NO || pOther.pev.flags & FL_GODMODE != 0 )
			return;

		CBaseEntity@ pOwner = g_EntityFuncs.Instance( pev.owner );
		if( pOwner !is null )
		{
			if( pOther != pOwner && (pOwner.Classify() >= CLASS_TEAM1 && pOwner.Classify() <= CLASS_TEAM4 && pOther.Classify() == pOwner.Classify() || pOwner.IRelationship(pOther) <= R_NO) )
				return;

			int g_npckill = int( g_EngineFuncs.CVarGetFloat( "mp_npckill" ) );
			if( pOwner.Classify() == CLASS_PLAYER && pOther.IsMonster() && pOther.IsPlayerAlly() && (g_npckill == 0 || g_npckill == 2) ) // NPCs are disallowed to be killed
				return;
		}

		self.m_hEnemy = pOther;

		SetTouch( null );

		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "wanted/weapons/beartrap_sprung.wav", 1.0f, ATTN_NORM );

		self.StudioFrameAdvance();
	}

	void BeartrapThink()
	{
		pev.nextthink = g_Engine.time + 0.1f;

		//CBaseEntity@ pEnemy = g_EntityFuncs.Instance( pev.enemy );
		CBaseEntity@ pEnemy = self.m_hEnemy.GetEntity();
		if( pEnemy !is null )
		{
			if( pev.sequence == 1 && self.m_fSequenceFinished && pev.frame >= 255 )
			{
				pev.sequence = self.LookupSequence( "closed" );
				pev.frame = 0;
				self.ResetSequenceInfo();
			}

			if( !pEnemy.IsAlive() )
			{
				@pEnemy = null;
				SetThink( ThinkFunction( FadeOut ) );
				pev.nextthink = g_Engine.time + 15.0f;
				return;
			}

			if( pEnemy.pev.takedamage <= DAMAGE_NO || pEnemy.pev.flags & FL_GODMODE != 0 )
			{
				@pEnemy = null;
				SetThink( null );
				g_EntityFuncs.Remove( self );
				return;
			}

			pEnemy.pev.velocity = g_vecZero;

			pEnemy.pev.basevelocity = g_vecZero;
			pEnemy.pev.origin.x = pev.origin.x;
			pEnemy.pev.origin.y = pev.origin.y;

			// has trapped somebody!
			if( m_flKillVictimTime != -1 && g_Engine.time > m_flKillVictimTime )
			{
				if( pev.sequence != 1 && pev.sequence != 2 )
				{
					pev.sequence = self.LookupSequence( "fire" );
					pev.frame = 0;
					self.ResetSequenceInfo();
				}

				if( pev.owner !is null )
					pEnemy.TakeDamage( self.pev, self.pev.owner.vars, BEARTRAP_DMG, DMG_NEVERGIB );
				else
					pEnemy.TakeDamage( self.pev, self.pev, BEARTRAP_DMG, DMG_NEVERGIB );

				SetTouch( null );

				if( !pEnemy.IsAlive() )
				{
					@pEnemy = null;
					SetThink( ThinkFunction( FadeOut ) );
					pev.nextthink = g_Engine.time + 15.0f;
					return;
				}

				m_flKillVictimTime = g_Engine.time + 1.0f; // damage every 1 sec

				return;
			}
		}

		if( !self.IsInWorld() || m_iLifeTime <= 0 )
		{
			g_EntityFuncs.Remove( self );
			return;
		}

		m_iLifeTime--;

		if( (pev.flags & FL_ONGROUND) != 0 )
		{
			pev.movetype = MOVETYPE_BOUNCE;
			pev.velocity = pev.velocity * 0.5;
		}
	}

	void BounceSound()
	{
		if( m_flNextBounceSound > g_Engine.time )
			return;

		m_flNextBounceSound = g_Engine.time + 0.3;

		switch( Math.RandomLong( 0, 2 ) )
		{
		case 0:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "weapons/g_bounce1.wav", 1, ATTN_NORM); break;
		case 1:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "weapons/g_bounce2.wav", 1, ATTN_NORM); break;
		case 2:	g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "weapons/g_bounce3.wav", 1, ATTN_NORM); break;
		}
	}

	void DestroyThink( void )
	{
		g_EntityFuncs.Remove( self );
	}

	void FadeOut()
	{
		pev.nextthink = g_Engine.time + 0.1;

		if( pev.rendermode == kRenderNormal )
		{
			pev.renderamt = 255;
			pev.rendermode = kRenderTransTexture;
		}

		if( pev.renderamt > 7 )
		{
			pev.renderamt -= 7;
		}
		else
		{
			pev.renderamt = 0;
			pev.nextthink = g_Engine.time + 0.1f;
			SetThink( ThinkFunction( this.DestroyThink ) );
			return;
		}
	}
}

enum beartrap_e
{
	BEARTRAP_DRAW = 0,
	BEARTRAP_HOLSTER,
	BEARTRAP_IDLE,
	BEARTRAP_FIDGET,
	BEARTRAP_THROW
};

class weapon_beartrap : CBaseCustomWeapon
{
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/wanted/w_beartrap.mdl" );

		self.m_iDefaultAmmo = BEARTRAP_DEFAULT_GIVE;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel("models/wanted/v_beartrap.mdl");
		g_Game.PrecacheModel("models/wanted/w_beartrap.mdl");
		g_Game.PrecacheModel("models/wanted/w_beartrapT.mdl");
		g_Game.PrecacheModel("models/wanted/p_beartrap.mdl");

		g_SoundSystem.PrecacheSound( "items/gunpickup2.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud3.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud6.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "wanted/640hud7.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "wanted/weapon_beartrap.txt" );

		g_Game.PrecacheOther( "monster_beartrap" );
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

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 = BEARTRAP_MAX_CARRY;
		info.iAmmo1Drop	= 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop	= -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 4;
		info.iPosition = 10;
		info.iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
		info.iId = g_ItemRegistry.GetIdForName( self.pev.classname );
		info.iWeight = BEARTRAP_WEIGHT;

		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			m_fDropped = false;
			bResult = self.DefaultDeploy( self.GetV_Model( "models/wanted/v_beartrap.mdl" ), self.GetP_Model( "models/wanted/p_beartrap.mdl" ), BEARTRAP_DRAW, "trip" );
			self.m_flNextPrimaryAttack = g_Engine.time + 1.0f;
			self.m_flTimeWeaponIdle = g_Engine.time + 3.0f;
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

		m_pPlayer.m_flNextAttack = g_Engine.time + 0.5;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 && !m_fDropped )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName( self.pev.classname ) );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		else
		{
			self.SendWeaponAnim( BEARTRAP_HOLSTER );
			g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "common/null.wav", 1.0f, ATTN_NORM );
		}

		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			Vector vecThrow = g_Engine.v_forward * 274 + m_pPlayer.pev.velocity;
			CBaseEntity@ pBeartrap = g_EntityFuncs.Create( "monster_beartrap", m_pPlayer.pev.origin, g_vecZero, false, m_pPlayer.edict() );
			pBeartrap.pev.velocity = vecThrow;
			pBeartrap.pev.avelocity.y = 400;

			self.SendWeaponAnim( BEARTRAP_THROW );

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

			self.m_flNextPrimaryAttack = g_Engine.time + 1.0f;
			self.m_flTimeWeaponIdle = g_Engine.time + 1.0f;
		}
	}

	void WeaponIdle()
	{
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0 )
		{
			self.RetireWeapon();
			return;
		}

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		switch( Math.RandomLong(0,1) )
		{
		case 0: iAnim = BEARTRAP_IDLE;
			self.m_flTimeWeaponIdle = g_Engine.time + 3.6;
			break;
		case 1: iAnim = BEARTRAP_FIDGET;
			self.m_flTimeWeaponIdle = g_Engine.time + 2.6;
			break;
		}

		self.SendWeaponAnim( iAnim );
	}

	//=========================================================
	// DeactivateBeartraps - removes all beartraps owned by
	// the provided player. Should only be used upon death.
	//
	// Made this global on purpose.
	//=========================================================
	/*void DeactivateBeartraps( CBasePlayer@ pOwner )
	{
		edict_t@ pFind; 

		pFind = g_EntityFuncs.FindEntityByClassname( null, "monster_beartrap" );

		while( !FNullEnt( pFind ) )
		{
			CBaseEntity@ pEnt = g_EntityFuncs.Instance( pFind );
			CBeartrapCharge@ pBeartrap = (CBeartrapCharge@)pEnt;

			if( pBeartrap )
			{
				if ( pBeartrap.pev.owner == pOwner.edict() )
				{
					pBeartrap.pev.solid = SOLID_NOT;
					g_EntityFuncs.Remove( pBeartrap );
				}
			}

			pFind = g_EntityFuncs.FindEntityByClassname( pFind, "monster_beartrap" );
		}
	}*/

	void Materialize()
	{
		BaseClass.Materialize();
		//SetTouch( TouchFunction( CustomTouch ) );
	}

	bool CanHaveDuplicates()
	{
		return true;
	}

/*	void CustomTouch( CBaseEntity@ pOther ) 
	{
		if( !pOther.IsPlayer() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

		if( pPlayer.HasNamedPlayerItem( GetBeartrapName() ) !is null )
		{
	  		if( pPlayer.GiveAmmo( BEARTRAP_DEFAULT_GIVE, GetBeartrapName(), BEARTRAP_MAX_CARRY ) != -1 )
			{
				self.CheckRespawn();
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );

				g_EntityFuncs.Remove( self );
	  		}

	  		return;
		}
		else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
	  		self.AttachToPlayer( pPlayer );
	  		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
		}
	}*/
}

string GetBeartrapName()
{
	return "weapon_beartrap";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Beartrap::monster_beartrap", "monster_beartrap" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Beartrap::weapon_beartrap", GetBeartrapName() );
	g_ItemRegistry.RegisterWeapon( GetBeartrapName(), "wanted", GetBeartrapName(), "", GetBeartrapName() );
}

} //namespace HLWanted_Beartrap END