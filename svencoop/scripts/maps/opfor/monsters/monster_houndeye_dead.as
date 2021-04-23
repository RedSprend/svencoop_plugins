
namespace HoundEyeDead
{
const string g_szDefaultModel = "models/opfor/houndeye_dead.mdl";

class monster_houndeye_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "dead_on_stomach" };

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "pose" )
		{
			m_iPose = atoi( szValue );
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

		self.m_bloodColor 	= BLOOD_COLOR_YELLOW;
		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.pev.takedamage 	= DAMAGE_YES;

		self.SetClassification( CLASS_ALIEN_MONSTER );

		self.m_FormattedName = "Dead Houndeye";

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead gonome with bad pose\n" );
		}
	}
}

void RegisterHoundEyeDead()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HoundEyeDead::monster_houndeye_dead", "monster_houndeye_dead" );
}

} // end of namespace