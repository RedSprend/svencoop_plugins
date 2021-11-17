// UNDONE: Spores (never used in the Op4 campaign anyway)

/*
#include "items/env_blowercannon"

void MapInit()
{
	OFBlowerCannon::Register();
}
*/

namespace OFBlowerCannon
{
enum WeaponType
{
	SporeRocket = 1,
	SporeGrenade,
	ShockBeam,
	DisplacerBall
};

enum FireType
{
	Toggle = 1,
	FireOnTrigger,
};

class CBlowerCannon : ScriptBaseEntity
{
	float m_flDelay;
	int m_iZOffset;
	int m_iWeaponType;
	int m_iFireType;

	bool KeyValue(const string& in szKey, const string& in szValue)
	{
		if( szKey == "delay" )
		{
			m_flDelay = atof( szValue );
			return true;
		}
		else if( szKey == "weaptype" )
		{
			m_iWeaponType = atoi( szValue );
			return true;
		}
		else if( szKey == "firetype" )
		{
			m_iFireType = atoi( szValue );
			return true;
		}
		else if( szKey == "zoffset" )
		{
			m_iZOffset = atoi( szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Precache()
	{
		g_Game.PrecacheOther( "displacer_portal" );
		g_Game.PrecacheOther( "sporegrenade" );
		g_Game.PrecacheOther( "shock_beam" );
	}

	void Spawn()
	{
		SetThink( null );
		SetUse( UseFunction(BlowerCannonStart) );

		self.pev.nextthink = g_Engine.time + 0.1;

		if( m_flDelay < 0 )
		{
			m_flDelay = 1;
		}

		Precache();
	}

	void BlowerCannonStart( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		SetUse( UseFunction(BlowerCannonStop) );
		SetThink( ThinkFunction(BlowerCannonThink) );

		self.pev.nextthink = g_Engine.time + m_flDelay;
	}

	void BlowerCannonStop( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		SetUse( UseFunction(BlowerCannonStart) );
		SetThink( null );
	}

	void BlowerCannonThink()
	{
		entvars_t@ pTarget = self.GetNextTarget().pev;
		if( pTarget is null )
			return;

		CBaseEntity@ pEntity = null;

		Vector distance = pTarget.origin - self.pev.origin;
		distance.z += m_iZOffset;

		Vector angles = Math.VecToAngles( distance );
		angles.z = -angles.z;

		switch( m_iWeaponType )
		{
		case WeaponType::SporeRocket:
		case WeaponType::SporeGrenade:
			@pEntity = g_EntityFuncs.Create( "sporegrenade", self.pev.origin, angles, true );
			if( m_iWeaponType == WeaponType::SporeRocket )
			{
				pEntity.pev.velocity = angles;
				pEntity.pev.angles = Math.VecToAngles( angles );
			}
			else
				pEntity.pev.angles = angles;
			break;

		case WeaponType::ShockBeam:
			@pEntity = g_EntityFuncs.Create( "shock_beam", self.pev.origin, angles, true );

			pEntity.pev.angles = angles;
			Math.MakeVectors( pEntity.pev.angles );

			pEntity.pev.velocity = g_Engine.v_forward * 2000;
			pEntity.pev.velocity.z = -pEntity.pev.velocity.z;

			pEntity.pev.dmg = uint(g_EngineFuncs.CVarGetFloat("sk_plr_shockrifle"));

			break;

		case WeaponType::DisplacerBall:
			@pEntity = g_EntityFuncs.Create( "displacer_portal", self.pev.origin, angles, true );

			angles.x = -angles.x;
			pEntity.pev.angles = angles;
			Math.MakeVectors( angles );

			pEntity.pev.velocity = g_Engine.v_forward * 500;

			pEntity.pev.dmg = uint(g_EngineFuncs.CVarGetFloat("sk_plr_displacer_other")); // Damage done to targets hit with the teleport portal
			pEntity.pev.fuser1 = uint(g_EngineFuncs.CVarGetFloat("sk_plr_displacer_radius")); // Damage radius

			break;

		default: break;
		}

		@pEntity.pev.owner = self.edict();
		g_EntityFuncs.DispatchSpawn( pEntity.edict() );

		if( m_iFireType == FireType::FireOnTrigger )
		{
			SetUse( UseFunction(BlowerCannonStart) );
			SetThink( null );
		}

		self.pev.nextthink = g_Engine.time + m_flDelay;
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "OFBlowerCannon::CBlowerCannon", "env_blowercannon" );
}
} // end of namespace