
namespace CleansuitScientistDead
{
const string g_szDefaultModel = "models/opfor/cleansuit_scientist.mdl";

enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEADS,
	BODYGROUP_NEEDLE
}

enum HeadSubModel
{
	HEAD_GLASSES = 0,
	HEAD_EINSTEIN,
	HEAD_LUTHER,
	HEAD_SLICK
}

enum NeedleSubModel
{
	NEEDLE_OFF = 0,
	NEEDLE_ON
}

class monster_cleansuit_scientist_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "lying_on_back", "lying_on_stomach", "dead_sitting", "dead_table1", "dead_table2", "dead_table3", "scientist_deadpose1", "dead_against_wall" };

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

		self.m_bloodColor 	= BLOOD_COLOR_RED;
		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.pev.takedamage 	= DAMAGE_YES;

		self.SetClassification( CLASS_HUMAN_PASSIVE );

		self.m_FormattedName = "Dead Cleansuit Scientist";

		switch( self.pev.body )
		{
		case 0: self.SetBodygroup( BODYGROUP_HEADS, HEAD_GLASSES ); break;
		case 1: self.SetBodygroup( BODYGROUP_HEADS, HEAD_EINSTEIN ); break;
		case 2: self.SetBodygroup( BODYGROUP_HEADS, HEAD_LUTHER ); break;
		case 3: self.SetBodygroup( BODYGROUP_HEADS, HEAD_SLICK ); break;
		default: self.SetBodygroup( BODYGROUP_HEADS, Math.RandomLong(HEAD_GLASSES, HEAD_SLICK) ); break;
		}

		// Luther is black, make his hands black
		if ( self.pev.body == HEAD_LUTHER )
			self.pev.skin = 1;
		else
			self.pev.skin = 0;

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead cleansuit scientist with bad pose\n" );
		}
	}
}

void RegisterCleansuitScientistDead()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CleansuitScientistDead::monster_cleansuit_scientist_dead", "monster_cleansuit_scientist_dead" );
}

} // end of namespace