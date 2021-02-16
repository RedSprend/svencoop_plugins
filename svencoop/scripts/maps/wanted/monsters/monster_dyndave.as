namespace HLWanted_DynDave
{
class monster_dyndave : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/dyndave/ddaskpope.wav",
		"wanted/dyndave/ddbathmonth.wav",
		"wanted/dyndave/ddbathnight.wav",
		"wanted/dyndave/ddbegorrah.wav",
		"wanted/dyndave/ddblownit.wav",
		"wanted/dyndave/ddbuyrock.wav",
		"wanted/dyndave/ddcompany.wav",
		"wanted/dyndave/ddcouldbeso.wav",
		"wanted/dyndave/dddamnfuse.wav",
		"wanted/dyndave/dddontknow.wav",
		"wanted/dyndave/dddropofirish.wav",
		"wanted/dyndave/dddrythroat.wav",
		"wanted/dyndave/ddfershure.wav",
		"wanted/dyndave/ddfinished.wav",
		"wanted/dyndave/ddgash.wav",
		"wanted/dyndave/ddgaw.wav",
		"wanted/dyndave/ddgetback.wav",
		"wanted/dyndave/ddgiveago.wav",
		"wanted/dyndave/ddgrandday.wav",
		"wanted/dyndave/ddhowudoin.wav",
		"wanted/dyndave/ddillwait.wav",
		"wanted/dyndave/ddjesss.wav",
		"wanted/dyndave/ddkegblow.wav",
		"wanted/dyndave/ddlanigans.wav",
		"wanted/dyndave/ddlookout.wav",
		"wanted/dyndave/ddmajor.wav",
		"wanted/dyndave/ddminersweekly.wav",
		"wanted/dyndave/ddmother.wav",
		"wanted/dyndave/ddmothergod.wav",
		"wanted/dyndave/ddnevermind.wav",
		"wanted/dyndave/ddnoprob.wav",
		"wanted/dyndave/ddnotgoon.wav",
		"wanted/dyndave/ddnotneeded.wav",
		"wanted/dyndave/ddnotsure.wav",
		"wanted/dyndave/ddohgod.wav",
		"wanted/dyndave/ddohmy.wav",
		"wanted/dyndave/ddopenyet.wav",
		"wanted/dyndave/ddrailroad.wav",
		"wanted/dyndave/ddsaloon.wav",
		"wanted/dyndave/ddseeright.wav",
		"wanted/dyndave/ddshantmove.wav",
		"wanted/dyndave/ddshould.wav",
		"wanted/dyndave/ddsocks.wav",
		"wanted/dyndave/ddstare.wav",
		"wanted/dyndave/ddstartrun.wav",
		"wanted/dyndave/ddstaying.wav",
		"wanted/dyndave/ddthanks.wav",
		"wanted/dyndave/ddtomornin.wav",
		"wanted/dyndave/ddtoodrunk.wav",
		"wanted/dyndave/ddtoriver.wav",
		"wanted/dyndave/ddwelcome.wav",
		"wanted/dyndave/ddwhatdevil.wav",
		"wanted/dyndave/ddwithyou.wav",
		"wanted/dyndave/ddyouok.wav",
		"wanted/dyndave/ddyousure.wav",
		"wanted/dyndave/pain1.wav",
		"wanted/dyndave/pain2.wav",
		"wanted/dyndave/pain3.wav",
		"wanted/dyndave/pain4.wav",
		"wanted/dyndave/pain5.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/dyndave.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/dyndaveT.mdl" );

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
			{ "model", "models/wanted/dyndave.mdl" },
			{ "soundlist", "../wanted/dyndave/dave.txt" },
			{ "is_not_revivable", "1" },
			{ "displayname", "Dave" }
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

class monster_dyndave_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/dyndave.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/dyndave.mdl" );
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

		self.m_FormattedName = "Dead Dave";

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead dave with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_DynDave::monster_dyndave", "monster_dyndave" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_DynDave::monster_dyndave_dead", "monster_dyndave_dead" );
}

} // end of HLWanted_DynDave namespace