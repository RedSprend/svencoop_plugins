namespace XENHANDS
{
const string ViewModel = "models/hlclassic/pov/v_xenhands.mdl";
const string WorldModel = "models/dy/w_slave.mdl";
const string PlayerModel = "models/dy/p_slave.mdl";

const int m_iClawDmg = 10;
const int m_iZapDmg = 10; // per beam (2 arms, 10 * 2 = 20)

const int iMaxChargeTime = 20; // in milliseconds

enum ISlaveWeaponAnimation
{
	ISLWEP_IDLE1 = 0,
	ISLWEP_IDLE2,
	ISLWEP_IDLE3,
	ISLWEP_ATTACK1_HIT,
	ISLWEP_ATTACK1_MISS,
	ISLWEP_ATTACK2_HIT,
	ISLWEP_ATTACK2_MISS,
	ISLWEP_ATTACK3_HIT,
	ISLWEP_ATTACK3_MISS,
	ISLWEP_ZAP,
	ISLWEP_CHARGE,
	ISLWEP_HOLSTER,
	ISLWEP_DRAW,
};

class weapon_slave : ScriptBasePlayerWeaponEntity
{
	protected CBasePlayer@ m_pPlayer
	{
		get const { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set { self.m_hPlayer = EHandle( @value ); }
	}

	float m_flNextAnimTime;
	int m_iSwing;
	int m_iMode;
	int m_iMaxBeams;
	int m_fInAttack;
	int iRange = 0;

	EHandle m_hDead;
	
	void Spawn()
	{
		Precache();
		//g_EntityFuncs.SetModel( self, WorldModel );

		m_iMode = 0;
		m_iMaxBeams = 2;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( "sprites/lgtning.spr" );
		g_Game.PrecacheModel( ViewModel );
		/*g_Game.PrecacheModel( WorldModel );
		g_Game.PrecacheModel( PlayerModel );*/

		g_SoundSystem.PrecacheSound( "debris/zap4.wav" );
		g_SoundSystem.PrecacheSound( "weapons/electro4.wav" );
		g_SoundSystem.PrecacheSound( "weapons/xhand_fire1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/xhand_fire1.wav" ); // client has to download
		//g_SoundSystem.PrecacheSound( "hassault/hw_shoot1.wav" );
		g_SoundSystem.PrecacheSound( "headcrab/hc_headbite.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cbar_miss1.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_strike1.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_strike2.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_strike3.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_miss1.wav" );
		g_SoundSystem.PrecacheSound( "zombie/claw_miss2.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "pov/320hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/320hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "pov/crosshairs.spr" );

		g_Game.PrecacheGeneric( "sprites/" + "pov/weapon_slave.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= -1;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 	= 0;
		info.iPosition 	= 7;
		info.iFlags 	= 0;
		info.iWeight 	= 100;

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

		pPlayer.pev.armortype = 0;

		return true;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( ViewModel ), "", ISLWEP_DRAW, "mp5" );
	}

	void Holster(int skiplocal)
	{
		self.m_fInReload = false;
		SetThink( null );
		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( !Swing( 1 ) )
		{
			SetThink( ThinkFunction( this.SwingAgain ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}
	}

	void SwingAgain()
	{
		Swing( 0 );
	}

	bool Swing( int fFirst )
	{
		CancelCharge(); // Reset charge if charged

		bool fDidHit = false;

		TraceResult tr;

		Math.MakeVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc	= m_pPlayer.GetGunPosition();
		Vector vecEnd	= vecSrc + g_Engine.v_forward * 32;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		if ( tr.flFraction >= 1.0 )
		{
			g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
			if ( tr.flFraction < 1.0 )
			{
				// Calculate the point of intersection of the line (or hull) and the object we hit
				// This is and approximation of the "best" intersection
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				if ( pHit is null || pHit.IsBSPModel() )
					g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
				vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
			}
		}

		if ( tr.flFraction >= 1.0 )
		{
			if( fFirst != 0 )
			{
				// miss
				switch( ( m_iSwing++ ) % 3 )
				{
				case 0: self.SendWeaponAnim( ISLWEP_ATTACK1_MISS ); break;
				case 1: self.SendWeaponAnim( ISLWEP_ATTACK2_MISS ); break;
				case 2: self.SendWeaponAnim( ISLWEP_ATTACK3_MISS ); break;
				}
				self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
				// play wiff or swish sound
				switch( Math.RandomLong(0,1) )
				{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_miss1.wav", 1, ATTN_NORM, 0, PITCH_NORM ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_miss1.wav", 1, ATTN_NORM, 0, PITCH_NORM ); break;
				}

				// player "shoot" animation
				m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 
			}
		}
		else
		{
			// hit
			fDidHit = true;
			
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			switch( ( ( m_iSwing++ ) % 3 ) )
			{
			case 0: self.SendWeaponAnim( ISLWEP_ATTACK1_HIT ); break;
			case 1: self.SendWeaponAnim( ISLWEP_ATTACK2_HIT ); break;
			case 2: self.SendWeaponAnim( ISLWEP_ATTACK3_HIT ); break;
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 ); 

			float flDamage = m_iClawDmg;
			if ( self.m_flCustomDmg > 0 )
				flDamage = self.m_flCustomDmg;

			g_WeaponFuncs.ClearMultiDamage();
			if ( self.m_flNextPrimaryAttack + 1 < g_Engine.time )
			{
				// first swing does full damage
				pEntity.TraceAttack( m_pPlayer.pev, flDamage, g_Engine.v_forward, tr, DMG_CLUB );	
			}
			else
			{
				// subsequent swings do 50% (Changed -Sniper) (Half)
				pEntity.TraceAttack( m_pPlayer.pev, flDamage * 0.5, g_Engine.v_forward, tr, DMG_CLUB );	
			}	
			g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

			//m_flNextPrimaryAttack = gpGlobals->time + 0.30; //0.25

			// play thwack, smack, or dong sound
			float flVol = 1.0;
			bool fHitWorld = true;

			if( pEntity !is null )
			{
				/*self.m_flNextPrimaryAttack = g_Engine.time + 0.30;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.30;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.30;*/
				self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.5;

				if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
				{
					if( pEntity.IsPlayer() ) // lets pull them
					{
						pEntity.pev.velocity = pEntity.pev.velocity + ( self.pev.origin - pEntity.pev.origin ).Normalize() * 120;
					}

					// play thwack or smack sound
					switch( Math.RandomLong( 0, 2 ) )
					{
					case 0: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", 1, ATTN_NORM ); break;
					case 1: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", 1, ATTN_NORM ); break;
					case 2: g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", 1, ATTN_NORM ); break;
					}
					m_pPlayer.m_iWeaponVolume = 128; 
					if( !pEntity.IsAlive() )
						return true;
					else
						flVol = 0.1;

					fHitWorld = false;
				}
			}

			// play texture hit sound
			// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line
			if( fHitWorld == true )
			{
				float fvolbar = g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2, BULLET_PLAYER_CROWBAR );
				
				/*self.m_flNextPrimaryAttack = g_Engine.time + 0.25;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.25;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.25;*/
				self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
				
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.
				fvolbar = 1;

				// also play crowbar strike
				switch( Math.RandomLong( 0, 2 ) )
				{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike1.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike2.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				case 2: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "zombie/claw_strike3.wav", fvolbar, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) ); break;
				}
			}

			m_pPlayer.m_iWeaponVolume = int( flVol * 512 ); 
		}
		return fDidHit;
	}

	void SecondaryAttack()
	{
		if( m_iMode == 0 )
		{
			// Animation doesn't nothing
			/*m_pPlayer.pev.frame = 0;
			m_pPlayer.pev.sequence = m_pPlayer.LookupSequence( "CHARGE" );
			m_pPlayer.ResetSequenceInfo();*/

			self.SendWeaponAnim( ISLWEP_CHARGE );
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "debris/zap4.wav", 1, ATTN_NORM, 0, PITCH_NORM );
		}

		Vector vecSrc, vecAim, vecDummy;
		vecSrc = m_pPlayer.GetGunPosition();
		vecAim = m_pPlayer.GetAutoaimVector( 0.0f );

		NetworkMessage msg( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			msg.WriteByte( TE_DLIGHT );
			msg.WriteCoord( vecSrc.x );
			msg.WriteCoord( vecSrc.y );
			msg.WriteCoord( vecSrc.z );
			msg.WriteByte( 8 + iRange );
			msg.WriteByte( 255 );
			msg.WriteByte( 180 );
			msg.WriteByte( 96 );
			msg.WriteByte( 6 );
			msg.WriteByte( 0 );
		msg.End();

		if( iRange < 4 )
			iRange++;

		if( m_iMode < iMaxChargeTime )
		{
			if( CheckForDeadAllies() )
			{
				WackBeam( 1, m_hDead );
				WackBeam( 2, m_hDead );
			}
			else
			{
				ArmBeam( 1 );
				ArmBeam( 2 );
			}

			m_iMode++;
		}

		if( m_fInAttack == 0 )
		{
			m_fInAttack = 1;

			self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
		}
		else if( m_fInAttack == 1 )
		{
			if( self.m_flTimeWeaponIdle < g_Engine.time )
			{
				m_fInAttack = 2;
			}
		}
		else
		{
			if( m_iMode == iMaxChargeTime )
			{
				m_fInAttack = 0;

				self.SendWeaponAnim( ISLWEP_IDLE2 );

				self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
				self.m_flNextSecondaryAttack = g_Engine.time + 1.0;
				self.m_flTimeWeaponIdle = g_Engine.time + 1.0;

				return;
			}
		}

		self.m_flNextPrimaryAttack = g_Engine.time + 0.25;
		self.m_flNextSecondaryAttack = g_Engine.time + 0.1;
		self.m_flTimeWeaponIdle = g_Engine.time + 0.2;
	}

	bool CheckForDeadAllies()
	{
		m_hDead = null;

		float flDist = 256;

		CBaseEntity@ pEntity = null;
		CBaseMonster@ pMonster = null;
		CBasePlayer@ pPlayer = null;
		while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "*")) !is null )
		{
			if( pEntity.GetClassname() == "deadplayer" )
			{
				/*CBaseEntity@ pevOwner = g_EntityFuncs.Instance( pEntity.pev.owner );
				if( pevOwner !is null ) // deadplayer entities has no owner?
				{
					//g_EngineFuncs.ServerPrint("-- DEBUG: Found "+pevOwner.pev.netname+"'s body!\n" );

					@pPlayer = cast<CBasePlayer@>(pevOwner);
					if( pPlayer !is null && pPlayer.IsConnected() )
					{
						if( pPlayer.FInViewCone( pEntity ) && pPlayer.FVisible( pEntity, false ) )
						{
							float d = (m_pPlayer.pev.origin - pPlayer.pev.origin).Length();
							if( d < flDist )
							{
								m_hDead = pPlayer;
								flDist = d;
							}
						}
					}
				}*/
			}
			else if( pEntity.GetClassname() == "player" )
			{
				@pPlayer = cast<CBasePlayer@>(pEntity);
				if( pPlayer !is null && pPlayer.IsConnected() )
				{
					if( !pPlayer.IsAlive() && !pPlayer.GetObserver().IsObserver() && pPlayer.pev.effects & EF_NODRAW == 0 )
					{
						if( m_pPlayer.FInViewCone( pPlayer ) && m_pPlayer.FVisible( pPlayer, true ) )
						{
							float d = (m_pPlayer.pev.origin - pPlayer.pev.origin).Length();
							if( d < flDist )
							{
								m_hDead = pPlayer;
								flDist = d;
							}
						}
					}
				}
			}
			else if( pEntity.GetClassname() == "monster_alien_slave" )
			{
				@pMonster = cast<CBaseMonster@>(pEntity);

				if( pMonster.pev.deadflag != DEAD_DEAD )
					continue;

				if( m_pPlayer.FInViewCone( pEntity ) && m_pPlayer.FVisible( pEntity, true ) )
				{
					float d = (m_pPlayer.pev.origin - pMonster.pev.origin).Length();
					if( d < flDist )
					{
						m_hDead = pMonster;
						flDist = d;
					}
				}
			}
		}

		if( m_hDead.IsValid() )
			return true;

		return false;
	}

	void WackBeam( int iAttachment, CBaseEntity@ pEntity )
	{
		if( pEntity is null )
			return;

		Math.MakeAimVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc = m_pPlayer.GetGunPosition(), vecDummy;

		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), iAttachment, vecSrc, vecDummy );

		CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 30 );
		if( m_pBeam !is null )
		{
			m_pBeam.PointEntInit( pEntity.Center(), m_pPlayer.entindex() );
			m_pBeam.SetEndAttachment( iAttachment );
			m_pBeam.SetColor( 180, 255, 96 );
			m_pBeam.SetBrightness( 64 );
			m_pBeam.SetNoise( 80 );
			m_pBeam.LiveForTime( 0.3 );

			int b = m_iMode * 32;
			if( b > 255 )
				b = 255;

			if( m_pBeam.pev.renderamt != 255 ) 
			{
				m_pBeam.pev.renderamt = b;
			}
		}
	}

	void ArmBeam( int iAttachment )
	{
		TraceResult tr;
		float flDist = 1.0;

		Math.MakeAimVectors( m_pPlayer.pev.v_angle );
		Vector vecSrc = m_pPlayer.GetGunPosition(), vecDummy;

		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), iAttachment, vecSrc, vecDummy );
		Vector vecAim = g_Engine.v_right * Math.RandomFloat( -1.0, 1.0 ) + g_Engine.v_up * Math.RandomFloat( -1.0, 1.0 ) + g_Engine.v_forward * Math.RandomFloat( -0.75, 0.75 );
		TraceResult tr1;
		g_Utility.TraceLine( vecSrc, vecSrc + vecAim * 512, dont_ignore_monsters, m_pPlayer.edict(), tr1 );
		if( flDist > tr1.flFraction )
		{
			tr = tr1;
			flDist = tr.flFraction;
		}

		// Couldn't find anything close enough
		if( flDist == 1.0 )
			return;

		g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_CROWBAR );

		CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 30 );
		if( m_pBeam !is null )
		{
			m_pBeam.PointEntInit( tr.vecEndPos, m_pPlayer.entindex() );
			m_pBeam.SetEndAttachment( iAttachment );
			m_pBeam.SetColor( 96, 128, 16 );
			m_pBeam.SetBrightness( 64 );
			m_pBeam.SetNoise( 80 );
			m_pBeam.LiveForTime( 0.3 );

			int b = m_iMode * 32;
			if( b > 255 )
				b = 255;

			if( m_pBeam.pev.renderamt != 255 ) 
			{
				m_pBeam.pev.renderamt = b;
			}
		}
	}

	void ZapBeam( int iAttachment )
	{
		Vector vecSrc, vecAim, vecDummy;
		TraceResult tr;
		float flAttackRange = 1024 * 2;

		vecSrc = m_pPlayer.GetGunPosition();
		vecAim = m_pPlayer.GetAutoaimVector( 0.0f );

		g_Utility.TraceLine( vecSrc, vecSrc + vecAim * flAttackRange, dont_ignore_monsters, m_pPlayer.edict(), tr );
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), iAttachment, vecSrc, vecDummy );

		if( m_hDead.IsValid() )
		{
			if( m_hDead.GetEntity().IsPlayer() )
			{
				CBasePlayer@ pPlayer = cast<CBasePlayer@>(m_hDead.GetEntity());
				if( pPlayer !is null && pPlayer.IsConnected() )
				{
					pPlayer.GetObserver().RemoveDeadBody();
					pPlayer.SetOrigin( m_hDead.GetEntity().pev.origin );
					pPlayer.Revive();

					g_PlayerFuncs.ScreenFade(m_pPlayer, Vector(180, 255, 96), 0.2, 0.1, 128, FFADE_IN);
					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/xhand_fire1.wav", 1, ATTN_NORM, 0, PITCH_NORM );

					return;
				}
			}
			else
			{
				Vector vecDest = m_hDead.GetEntity().pev.origin + Vector( 0, 0, 38 );
				TraceResult trace;
				g_Utility.TraceHull( vecDest, vecDest, dont_ignore_monsters, human_hull, m_hDead.GetEntity().edict(), trace );

				if( trace.fStartSolid == 0 )
				{
					CBaseEntity@ pNew = g_EntityFuncs.Create( "monster_alien_slave", m_hDead.GetEntity().pev.origin, m_hDead.GetEntity().pev.angles, true );
					g_EntityFuncs.DispatchKeyValue( pNew.edict(), "is_player_ally", "1" );
					g_EntityFuncs.DispatchSpawn( pNew.edict() );

					pNew.pev.health = m_hDead.GetEntity().pev.max_health / 2;
					pNew.pev.max_health = m_hDead.GetEntity().pev.max_health;
					pNew.pev.netname = m_hDead.GetEntity().pev.netname;
					pNew.pev.frags = m_hDead.GetEntity().pev.frags;

					pNew.pev.sequence = m_hDead.GetEntity().pev.sequence;
					pNew.pev.frame -= 255;

					pNew.pev.spawnflags |= 1;

					WackBeam( 1, pNew );
					WackBeam( 2, pNew );

					g_EntityFuncs.Remove( m_hDead.GetEntity() );
					//g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hassault/hw_shoot1.wav", 1, ATTN_NORM, 0, Math.RandomLong( 130, 160 ) );

					g_PlayerFuncs.ScreenFade(m_pPlayer, Vector(180, 255, 96), 0.2, 0.1, 128, FFADE_IN);
					g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/xhand_fire1.wav", 1, ATTN_NORM, 0, PITCH_NORM );

					return;
				}
			}
		}

		CBeam@ m_pBeam = g_EntityFuncs.CreateBeam( "sprites/lgtning.spr", 50 );
		m_pBeam.PointEntInit( tr.vecEndPos, m_pPlayer.entindex() );
		m_pBeam.SetEndAttachment( iAttachment );
		m_pBeam.SetColor( 180, 255, 96 );
		m_pBeam.SetBrightness( 255 );
		m_pBeam.SetNoise( 20 );
		m_pBeam.LiveForTime( 0.5 );

		vecAim = m_pPlayer.GetAutoaimVector( 0.0f ); // somehow necessary to not fuck things up

		CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

		if( pEntity !is null )
		{
			if( pEntity.pev.classname == "player" )
			{
				CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
				if( pPlayer !is null && pPlayer.IsConnected() )
				{
					if( pPlayer.IsAlive() )
					{
						if( pPlayer.pev.health < pPlayer.pev.max_health )
						{
							pPlayer.pev.health += 5.0;

							if( pPlayer.pev.health > pPlayer.pev.max_health )
								pPlayer.pev.health = pPlayer.pev.max_health;
						}
						g_WeaponFuncs.ClearMultiDamage();
						pPlayer.TraceAttack( pev, 0.0, vecAim, tr, DMG_SHOCK ); 
						g_WeaponFuncs.ApplyMultiDamage( self.pev, self.pev );
					}
					else
					{
						pPlayer.GetObserver().RemoveDeadBody();
						pPlayer.Revive();
					}
				}
			}
			else if( pEntity.pev.classname == "monster_alien_slave" ||
				pEntity.pev.classname == "monster_stukabat" )
			{
				CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);
				if( pMonster !is null )
				{
					if( pMonster.IsAlive() && pMonster.IsPlayerAlly() )
					{
						if( pMonster.pev.health < pMonster.pev.max_health )
						{
							pMonster.pev.health += 5.0;

							if( pMonster.pev.health > pMonster.pev.max_health )
								pMonster.pev.health = pMonster.pev.max_health;
						}
					}
				}
			}
			else
			{
				g_WeaponFuncs.ClearMultiDamage();
				pEntity.TraceAttack( m_pPlayer.pev, float(m_iZapDmg), vecAim, tr, DMG_SHOCK );
				g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );
			}
		}

		g_PlayerFuncs.ScreenFade(m_pPlayer, Vector(180, 255, 96), 0.2, 0.1, 128, FFADE_IN);
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/xhand_fire1.wav", 1, ATTN_NORM, 0, PITCH_NORM );
		//g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hassault/hw_shoot1.wav", 1, ATTN_NORM, 0, Math.RandomLong( 130, 160 ) );
	}

	void ItemPostFrame()
	{
		if( m_iMode == iMaxChargeTime )
		{
			if( ( m_pPlayer.pev.button & IN_ATTACK2 ) != 0 )
			{
				m_pPlayer.pev.button &= ~IN_ATTACK2;

				iRange = 0;
				m_iMode = 0;
				m_fInAttack = 0;

				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro4.wav", 1, ATTN_NORM, 0, PITCH_NORM );

				g_PlayerFuncs.ScreenFade(m_pPlayer, Vector(180, 255, 96), 0.2, 0.1, 128, FFADE_IN);
				self.SendWeaponAnim( ISLWEP_IDLE3 );

				self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
				self.m_flNextSecondaryAttack = g_Engine.time + 1.0;
				self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
			}
		}

		BaseClass.ItemPostFrame();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		if( m_fInAttack != 0 )
		{
			if( m_iMode > 4 && m_iMode < iMaxChargeTime )
			{
				// Animation doesn't nothing
				/*m_pPlayer.pev.frame = 0;
				m_pPlayer.pev.sequence = m_pPlayer.LookupSequence( "FIRE" );
				m_pPlayer.ResetSequenceInfo();*/

				ZapBeam(1);
				ZapBeam(2);

				iRange = 0;
				m_iMode = 0;
				m_fInAttack = 0;

				self.SendWeaponAnim( ISLWEP_ZAP );

				self.m_flNextPrimaryAttack = g_Engine.time + 0.8;
				self.m_flNextSecondaryAttack = g_Engine.time + 0.8;
				self.m_flTimeWeaponIdle = g_Engine.time + 5.0;

				return;
			}

			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/electro4.wav", 1, ATTN_NORM, 0, PITCH_NORM );
			self.SendWeaponAnim( ISLWEP_IDLE3 );

			self.m_flNextPrimaryAttack = g_Engine.time + 0.8;
			self.m_flNextSecondaryAttack = g_Engine.time + 0.8;
			self.m_flTimeWeaponIdle = g_Engine.time + 0.5;
		}
		else
		{
			iRange = 0;

			int iAnim;
			switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,	0, 1 ) )
			{
			case 0:	iAnim = ISLWEP_IDLE1; break;
			case 1: iAnim = ISLWEP_IDLE2; break;
			default: iAnim = ISLWEP_IDLE2; break;
			}

			self.SendWeaponAnim( iAnim );

			self.m_flTimeWeaponIdle = g_Engine.time + 5.0; // how long till we do this again.
		}

		m_iMode = 0;
		m_fInAttack = 0;
	}

	void CancelCharge()
	{
		m_iMode = 0;
		m_fInAttack = 0;
		iRange = 0;
	}

	CBasePlayerItem@ DropItem() 
	{
		return null;
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "XENHANDS::weapon_slave", "weapon_slave" );
	g_ItemRegistry.RegisterWeapon( "weapon_slave", "pov" );
}

}// end namespace