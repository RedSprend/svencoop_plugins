
namespace MaleAssassinDead
{
const string g_szDefaultModel = "models/opfor/massn.mdl";

enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEADS,
	BODYGROUP_WEAPONS
}

enum HeadSubModel
{
	HEAD_WHITE = 0,
	HEAD_BLACK,
	HEAD_NVG
}

enum WeaponSubModel
{
	GUN_MP5 = 0,
	GUN_SNIPER,
	GUN_NONE
}

class monster_massassin_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	int m_head = 0;
	private array<string>m_szPoses = { "deadstomach", "deadside", "deadsitting" };

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "pose" )
		{
			m_iPose = atoi( szValue );
			return true;
		}
		else if( szKey == "head" )
		{
			m_head = atoi( szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Precache()
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( self, g_szDefaultModel );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();
		
		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, g_szDefaultModel );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );

		//MonsterInitDead resets this
		const float flHealth = self.pev.health;

		//MonsterInitDead sets up some stuff that we'll change below
		self.MonsterInitDead();

		self.pev.health = flHealth;

		//Allow custom health
		//Note: dead monsters require that at least this much damage is applied in one attack in order to gib the corpse
		if( self.pev.health == 0 )
			self.pev.health = 8;

		self.m_bloodColor 	= BLOOD_COLOR_RED;
		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.pev.takedamage 	= DAMAGE_YES;

		self.SetClassification( CLASS_HUMAN_MILITARY );

		self.m_FormattedName = "Dead Male Assassin";

		switch( self.pev.weapons )
		{
		case 0: self.SetBodygroup( BODYGROUP_WEAPONS, GUN_NONE ); break;
		case 1: self.SetBodygroup( BODYGROUP_WEAPONS, GUN_MP5 ); break;
		case 2: self.SetBodygroup( BODYGROUP_WEAPONS, GUN_SNIPER ); break;
		default: self.SetBodygroup( BODYGROUP_WEAPONS, Math.RandomLong(GUN_MP5, GUN_NONE) ); break;
		}

		switch( m_head )
		{
		case 0: self.SetBodygroup( BODYGROUP_HEADS, HEAD_WHITE ); break;
		case 1: self.SetBodygroup( BODYGROUP_HEADS, HEAD_BLACK ); break;
		case 2: self.SetBodygroup( BODYGROUP_HEADS, HEAD_NVG ); break;
		default: self.SetBodygroup( BODYGROUP_HEADS, Math.RandomLong(HEAD_WHITE, HEAD_NVG) ); break;
		}

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead male assassin with bad pose\n" );
		}
	}
}

void RegisterMaleAssassinDead()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "MaleAssassinDead::monster_massassin_dead", "monster_massassin_dead" );
}

} // end of namespace