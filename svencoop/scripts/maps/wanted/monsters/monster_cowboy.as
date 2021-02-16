namespace HLWanted_Cowboy
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEAD,
	BODYGROUP_GUN
}

enum HeadSubModel
{
	HEAD_ONE_PISTOL = 0,
	HEAD_TWO_PISTOL,
	HEAD_THREE_PISTOL,
	HEAD_FOUR_PISTOL,
	HEAD_ONE_SHOTGUN,
	HEAD_TWO_SHOTGUN,
	HEAD_THREE_SHOTGUN,
	HEAD_FOUR_SHOTGUN
}

enum WeaponSubModel
{
	GUN_PISTOL = 0,
	GUN_SHOTGUN,
	GUN_NONE
}

class monster_cowboy : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/cowboy/cocanthere.wav",
		"wanted/cowboy/co_die1.wav",
		"wanted/cowboy/co_die2.wav",
		"wanted/cowboy/co_die3.wav",
		"wanted/cowboy/co_pain1.wav",
		"wanted/cowboy/co_pain2.wav",
		"wanted/cowboy/co_pain3.wav",
		"wanted/cowboy/co_pain4.wav",
		"wanted/cowboy/co_pain5.wav",
		"wanted/cowboy/olanniefake.wav",
		"wanted/cowboy/olawhell.wav",
		"wanted/cowboy/olcantseeem.wav",
		"wanted/cowboy/olcantseenothin.wav",
		"wanted/cowboy/olcatch.wav",
		"wanted/cowboy/olchicken.wav",
		"wanted/cowboy/olcomeonout.wav",
		"wanted/cowboy/olcomeout.wav",
		"wanted/cowboy/olcoverme.wav",
		"wanted/cowboy/oldamn.wav",
		"wanted/cowboy/oldelivery.wav",
		"wanted/cowboy/oldust.wav",
		"wanted/cowboy/oldynamite.wav",
		"wanted/cowboy/oleyesopen.wav",
		"wanted/cowboy/olfart.wav",
		"wanted/cowboy/olfoundhim.wav",
		"wanted/cowboy/olfoundtrouble.wav",
		"wanted/cowboy/olgetback.wav",
		"wanted/cowboy/olgetdown.wav",
		"wanted/cowboy/olgetthesherriff.wav",
		"wanted/cowboy/olhellnoone.wav",
		"wanted/cowboy/olheybill.wav",
		"wanted/cowboy/olheysee.wav",
		"wanted/cowboy/olheyseethat.wav",
		"wanted/cowboy/olhideallday.wav",
		"wanted/cowboy/olholdon.wav",
		"wanted/cowboy/olidontsee.wav",
		"wanted/cowboy/oligothim.wav",
		"wanted/cowboy/oliseehim.wav",
		"wanted/cowboy/olitsthesherriff.wav",
		"wanted/cowboy/oljeezus.wav",
		"wanted/cowboy/oljustacactus.wav",
		"wanted/cowboy/olkeepdown.wav",
		"wanted/cowboy/ollookiehere.wav",
		"wanted/cowboy/ollookinferyou.wav",
		"wanted/cowboy/ollookout.wav",
		"wanted/cowboy/ollookoutt.wav",
		"wanted/cowboy/olmeneither.wav",
		"wanted/cowboy/olmoveit.wav",
		"wanted/cowboy/olnooneheren.wav",
		"wanted/cowboy/olnope.wav",
		"wanted/cowboy/olnosign.wav",
		"wanted/cowboy/olnothinhere.wav",
		"wanted/cowboy/olok.wav",
		"wanted/cowboy/oloutofammo.wav",
		"wanted/cowboy/olpassgelly.wav",
		"wanted/cowboy/olpassrifle.wav",
		"wanted/cowboy/olpoppasaid.wav",
		"wanted/cowboy/olredeye.wav",
		"wanted/cowboy/olroundback.wav",
		"wanted/cowboy/olrunferit.wav",
		"wanted/cowboy/olrunhide.wav",
		"wanted/cowboy/olseeanythin.wav",
		"wanted/cowboy/olseehim.wav",
		"wanted/cowboy/olseenothinhere.wav",
		"wanted/cowboy/olsharpeye.wav",
		"wanted/cowboy/olshit.wav",
		"wanted/cowboy/olshitno.wav",
		"wanted/cowboy/olshitseenoone.wav",
		"wanted/cowboy/olshoothim.wav",
		"wanted/cowboy/olshussh.wav",
		"wanted/cowboy/olsixin.wav",
		"wanted/cowboy/olsmelllawman.wav",
		"wanted/cowboy/olsnakes.wav",
		"wanted/cowboy/olstayontoes.wav",
		"wanted/cowboy/olstillwithme.wav",
		"wanted/cowboy/olstoodin.wav",
		"wanted/cowboy/olsurethang.wav",
		"wanted/cowboy/oltakethis.wav",
		"wanted/cowboy/olthereheis.wav",
		"wanted/cowboy/oltrythison.wav",
		"wanted/cowboy/oluponrock.wav",
		"wanted/cowboy/olusehelp.wav",
		"wanted/cowboy/olvisitor.wav",
		"wanted/cowboy/olwatchbacks.wav",
		"wanted/cowboy/olwhat.wav",
		"wanted/cowboy/olyesiree.wav",
		"wanted/cowboy/olyewaw.wav",
		"wanted/cowboy/olyouincharge.wav",
		"wanted/cowboy/olyoustayhere.wav",
		"wanted/cowboy/olyup.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/Cowboy.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/Cowboy01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/Cowboy02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/Cowboy03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/Cowboyt.mdl" );

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

		if( pev.body == -1 )
			pev.body = Math.RandomLong( HEAD_ONE_PISTOL, HEAD_FOUR_SHOTGUN );

		dictionary keyvalues = {
			{ "model", "models/wanted/Cowboy.mdl" },
			{ "soundlist", "../wanted/cowboy/cowboy.txt" },
			{ "displayname", "Cowboy" }
		};
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "monster_human_grunt", keyvalues, false );

		CBaseMonster@ pGrunt = pEntity.MyMonsterPointer();

		pGrunt.pev.origin = pev.origin;
		pGrunt.pev.angles = pev.angles;
		pGrunt.pev.health = pev.health;
		pGrunt.pev.targetname = pev.targetname;
		pGrunt.pev.netname = pev.netname;
		pGrunt.pev.weapons = pev.weapons;
		pGrunt.pev.body = pev.body;
		pGrunt.pev.skin = pev.skin;
		pGrunt.pev.mins = pev.mins;
		pGrunt.pev.maxs = pev.maxs;
		pGrunt.pev.scale = pev.scale;
		pGrunt.pev.rendermode = pev.rendermode;
		pGrunt.pev.renderamt = pev.renderamt;
		pGrunt.pev.rendercolor = pev.rendercolor;
		pGrunt.pev.renderfx = pev.renderfx;
		pGrunt.pev.spawnflags = pev.spawnflags;

		g_EntityFuncs.DispatchSpawn( pGrunt.edict() );

		pGrunt.m_iTriggerCondition = self.m_iTriggerCondition;
		pGrunt.m_iszTriggerTarget = self.m_iszTriggerTarget;

		g_EntityFuncs.Remove( self );
	}
}

class monster_cowboy_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/Cowboy.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/Cowboy.mdl" );
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

		self.m_FormattedName = "Dead Cowboy";

		self.SetBodygroup( BODYGROUP_GUN, GUN_NONE );

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_ONE_PISTOL, HEAD_FOUR_SHOTGUN) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead cowboy with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Cowboy::monster_cowboy", "monster_cowboy" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Cowboy::monster_cowboy_dead", "monster_cowboy_dead" );
}

} // end of HLWanted_Cowboy namespace