namespace HLWanted_Kaiewi
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEAD,
	BODYGROUP_GUN
}

enum HeadSubModel
{
	HEAD_1 = 0,
	HEAD_2,
	HEAD_3
}

enum WeaponSubModel
{
	GUN_BOW = 0,
	GUN_WINCHESTER,
	GUN_NONE
}

/*class monster_kaiewi : ScriptBaseMonsterEntity
{
	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/kaiewi.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/kaiewi01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/kaiewi02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/kaiewi03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/kaiewiT.mdl" );

		for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
		{
			g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
			g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
		}
	}
}*/

class monster_kaiewi_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "deadstomach", "deadside", "deadsitting" };

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
		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( self, "models/wanted/kaiewi.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/kaiewi.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );

		const float flHealth = self.pev.health;

		self.MonsterInitDead();

		self.pev.health = flHealth;

		if( self.pev.health == 0 )
			self.pev.health = 8;

		self.m_bloodColor 	= BLOOD_COLOR_RED;
		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.pev.takedamage 	= DAMAGE_YES;

		self.SetClassification( CLASS_HUMAN_MILITARY );

		self.m_FormattedName = "Dead Kaiewi";

		self.SetBodygroup( BODYGROUP_GUN, GUN_NONE );

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_3) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead kaiewi with bad pose\n" );
		}
	}
}

void Register()
{
	//g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Kaiewi::monster_kaiewi", "monster_kaiewi" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Kaiewi::monster_kaiewi_dead", "monster_kaiewi_dead" );
}

} // end of HLWanted_Kaiewi namespace