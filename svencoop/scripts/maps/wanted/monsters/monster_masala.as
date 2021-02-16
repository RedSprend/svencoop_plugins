namespace HLWanted_Masala
{
class monster_masala : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/masala/nbaagghh.wav",
		"wanted/masala/nbaahhh.wav",
		"wanted/masala/nbaayyee.wav",
		"wanted/masala/nbarrghh.wav",
		"wanted/masala/nbasktika.wav",
		"wanted/masala/nbcrazywoman.wav",
		"wanted/masala/nbcure.wav",
		"wanted/masala/nbcurse.wav",
		"wanted/masala/nbdanger.wav",
		"wanted/masala/nbdontscare.wav",
		"wanted/masala/nbdosomething.wav",
		"wanted/masala/nbeeerrr.wav",
		"wanted/masala/nbergg.wav",
		"wanted/masala/nbhappyan.wav",
		"wanted/masala/nbheal.wav",
		"wanted/masala/nbhellohat.wav",
		"wanted/masala/nbhey.wav",
		"wanted/masala/nbifollow.wav",
		"wanted/masala/nbillshowim.wav",
		"wanted/masala/nbinotgo.wav",
		"wanted/masala/nbiwaithere.wav",
		"wanted/masala/nbkinky.wav",
		"wanted/masala/nbloincloth.wav",
		"wanted/masala/nbno.wav",
		"wanted/masala/nbnosquaws.wav",
		"wanted/masala/nbok.wav",
		"wanted/masala/nbokiwait.wav",
		"wanted/masala/nboldshoes.wav",
		"wanted/masala/nboowwww.wav",
		"wanted/masala/nbouch.wav",
		"wanted/masala/nbpaleface.wav",
		"wanted/masala/nbprey.wav",
		"wanted/masala/nbprotectme.wav",
		"wanted/masala/nbquiet.wav",
		"wanted/masala/nbrun.wav",
		"wanted/masala/nbscript0.wav",
		"wanted/masala/nbscript1.wav",
		"wanted/masala/nbsoundpale.wav",
		"wanted/masala/nbspear.wav",
		"wanted/masala/nbtallhat.wav",
		"wanted/masala/nbthirsty.wav",
		"wanted/masala/nbthreelegs.wav",
		"wanted/masala/nbtooshort.wav",
		"wanted/masala/nbtotempole.wav",
		"wanted/masala/nbuhhuh.wav",
		"wanted/masala/nbummerrr.wav",
		"wanted/masala/nbwhiskey.wav",
		"wanted/masala/pain1.wav",
		"wanted/masala/pain2.wav",
		"wanted/masala/pain3.wav",
		"wanted/masala/pain4.wav",
		"wanted/masala/pain5.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/masala.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala04.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala05.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala06.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masala07.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/masalat.mdl" );

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
			{ "model", "models/wanted/masala.mdl" },
			{ "soundlist", "../wanted/masala/masala.txt" },
			{ "is_not_revivable", "1" },
			{ "displayname", "Masala" }
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

class monster_masala_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/masala.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/masala.mdl" );
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

		self.m_FormattedName = "Dead Masala";

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead masala with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Masala::monster_masala", "monster_masala" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Masala::monster_masala_dead", "monster_masala_dead" );
}

} // end of HLWanted_Masala namespace