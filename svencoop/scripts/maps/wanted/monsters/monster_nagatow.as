namespace HLWanted_Nagatow
{
class monster_nagatow : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/nagatow/niatemother.wav",
		"wanted/nagatow/nibeatone.wav",
		"wanted/nagatow/nibeswift.wav",
		"wanted/nagatow/nibrave.wav",
		"wanted/nagatow/nidamnchooks.wav",
		"wanted/nagatow/nieagle.wav",
		"wanted/nagatow/niforicecream.wav",
		"wanted/nagatow/niguardme.wav",
		"wanted/nagatow/niheadband.wav",
		"wanted/nagatow/nihewillknow.wav",
		"wanted/nagatow/niibelieve.wav",
		"wanted/nagatow/niiscream.wav",
		"wanted/nagatow/niitis.wav",
		"wanted/nagatow/niitisso.wav",
		"wanted/nagatow/niitwasso.wav",
		"wanted/nagatow/niiwill.wav",
		"wanted/nagatow/nijoindead.wav",
		"wanted/nagatow/nimedicine.wav",
		"wanted/nagatow/nimoon.wav",
		"wanted/nagatow/ninewcloth.wav",
		"wanted/nagatow/nino.wav",
		"wanted/nagatow/ninosquaws.wav",
		"wanted/nagatow/ninotgood.wav",
		"wanted/nagatow/niok.wav",
		"wanted/nagatow/niooww.wav",
		"wanted/nagatow/niow.wav",
		"wanted/nagatow/nipaleface.wav",
		"wanted/nagatow/nipeacefull.wav",
		"wanted/nagatow/nirace.wav",
		"wanted/nagatow/niscream5.wav",
		"wanted/nagatow/niscream6.wav",
		"wanted/nagatow/niscript0.wav",
		"wanted/nagatow/niscript1.wav",
		"wanted/nagatow/niscript2.wav",
		"wanted/nagatow/nismell.wav",
		"wanted/nagatow/nisoontime.wav",
		"wanted/nagatow/nispirits.wav",
		"wanted/nagatow/nistarbright.wav",
		"wanted/nagatow/nistarman.wav",
		"wanted/nagatow/nistarstrue.wav",
		"wanted/nagatow/nisunfall.wav",
		"wanted/nagatow/nisunleaves.wav",
		"wanted/nagatow/nithewind.wav",
		"wanted/nagatow/nitruepath.wav",
		"wanted/nagatow/niwardance.wav",
		"wanted/nagatow/niweallscream.wav",
		"wanted/nagatow/niwhisky.wav",
		"wanted/nagatow/niyourwish.wav",
		"wanted/nagatow/niyouscream.wav",
		"wanted/nagatow/pain1.wav",
		"wanted/nagatow/pain2.wav",
		"wanted/nagatow/pain3.wav",
		"wanted/nagatow/pain4.wav",
		"wanted/nagatow/pain5.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/nagatow.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow04.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow05.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow06.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatow07.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/nagatowt.mdl" );

		for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
		{
			g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
			g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
		}
	}

	void Spawn( void )
	{
		Precache();

		pev.solid = SOLID_NOT;

		dictionary keyvalues = {
			{ "model", "models/wanted/nagatow.mdl" },
			{ "soundlist", "../wanted/nagatow/nagatow.txt" },
			{ "is_not_revivable", "1" },
			{ "displayname", "Nagatow" }
		};
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "monster_scientist", keyvalues, false );

		CBaseMonster@ pSci = pEntity.MyMonsterPointer();

		pSci.pev.origin = pev.origin;
		pSci.pev.angles = pev.angles;
		pSci.pev.health = pev.health;
		pSci.pev.targetname = pev.targetname;
		pSci.pev.netname = pev.netname;
		pSci.pev.weapons = pev.weapons;
		pSci.pev.body = pev.body;
		pSci.pev.skin = pev.skin;
		pSci.pev.mins = pev.mins;
		pSci.pev.maxs = pev.maxs;
		pSci.pev.scale = pev.scale;
		pSci.pev.rendermode = pev.rendermode;
		pSci.pev.renderamt = pev.renderamt;
		pSci.pev.rendercolor = pev.rendercolor;
		pSci.pev.renderfx = pev.renderfx;
		pSci.pev.spawnflags = pev.spawnflags;

		g_EntityFuncs.DispatchSpawn( pSci.edict() );

		pSci.m_iTriggerCondition = self.m_iTriggerCondition;
		pSci.m_iszTriggerTarget = self.m_iszTriggerTarget;

		g_EntityFuncs.Remove( self );
	}
}

class monster_nagatow_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "lying_on_back", "lying_on_stomach", "dead_sitting", "dead_hang", "dead_table1", "dead_table2", "dead_table3" };

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
			g_Game.PrecacheModel( self, "models/wanted/nagatow.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/nagatow.mdl" );
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

		self.SetClassification( CLASS_PLAYER_ALLY );

		self.m_FormattedName = "Dead Nagatow";

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead nagatow with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Nagatow::monster_nagatow", "monster_nagatow" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Nagatow::monster_nagatow_dead", "monster_nagatow_dead" );
}

} // end of HLWanted_Nagatow namespace