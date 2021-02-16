namespace HLWanted_MexBandit
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
	HEAD_ONE_GAT,
	HEAD_TWO_GAT,
	HEAD_THREE_GAT,
	HEAD_FOUR_GAT
}

enum WeaponSubModel
{
	GUN_PISTOL = 0,
	GUN_GAT,
	GUN_NONE
}

class monster_mexbandit : ScriptBaseMonsterEntity
{
	private array<string> g_Sounds =
	{
		"wanted/mexbandit/mballclear.wav",
		"wanted/mexbandit/mbayee.wav",
		"wanted/mexbandit/mbayeee.wav",
		"wanted/mexbandit/mbayeeeee.wav",
		"wanted/mexbandit/mbbetterfarm.wav",
		"wanted/mexbandit/mbbigtrouble.wav",
		"wanted/mexbandit/mbcactusdrt.wav",
		"wanted/mexbandit/mbcanthide.wav",
		"wanted/mexbandit/mbcantsee.wav",
		"wanted/mexbandit/mbchiko.wav",
		"wanted/mexbandit/mbcoverme.wav",
		"wanted/mexbandit/mbdynrun.wav",
		"wanted/mexbandit/mbeyesopen.wav",
		"wanted/mexbandit/mbfightornot.wav",
		"wanted/mexbandit/mbforyou.wav",
		"wanted/mexbandit/mbgetaway.wav",
		"wanted/mexbandit/mbgetdown.wav",
		"wanted/mexbandit/mbgethim.wav",
		"wanted/mexbandit/mbgetsherrif.wav",
		"wanted/mexbandit/mbghost.wav",
		"wanted/mexbandit/mbgiveup.wav",
		"wanted/mexbandit/mbhavntseen.wav",
		"wanted/mexbandit/mbhereicome.wav",
		"wanted/mexbandit/mbheyamigos.wav",
		"wanted/mexbandit/mbhiding.wav",
		"wanted/mexbandit/mbiseehim.wav",
		"wanted/mexbandit/mbiseenothing.wav",
		"wanted/mexbandit/mbiseeyou.wav",
		"wanted/mexbandit/mbiseeyous.wav",
		"wanted/mexbandit/mbitsgringo.wav",
		"wanted/mexbandit/mbkeepdown.wav",
		"wanted/mexbandit/mblazy.wav",
		"wanted/mexbandit/mblookout.wav",
		"wanted/mexbandit/mblookout2.wav",
		"wanted/mexbandit/mbmanorchook.wav",
		"wanted/mexbandit/mbmissmaria.wav",
		"wanted/mexbandit/mbmotherburo.wav",
		"wanted/mexbandit/mbnonebutus.wav",
		"wanted/mexbandit/mbnope.wav",
		"wanted/mexbandit/mbnosign.wav",
		"wanted/mexbandit/mbnosign2.wav",
		"wanted/mexbandit/mbnothinhere.wav",
		"wanted/mexbandit/mbnotime.wav",
		"wanted/mexbandit/mbohno.wav",
		"wanted/mexbandit/mbok.wav",
		"wanted/mexbandit/mbokok.wav",
		"wanted/mexbandit/mbotherside.wav",
		"wanted/mexbandit/mboverhere.wav",
		"wanted/mexbandit/mbpassmatch.wav",
		"wanted/mexbandit/mbpedrosee.wav",
		"wanted/mexbandit/mbpresent.wav",
		"wanted/mexbandit/mbquiet.wav",
		"wanted/mexbandit/mbrun.wav",
		"wanted/mexbandit/mbrun2.wav",
		"wanted/mexbandit/mbrunaway.wav",
		"wanted/mexbandit/mbrustleout.wav",
		"wanted/mexbandit/mbsantadwn.wav",
		"wanted/mexbandit/mbsantam.wav",
		"wanted/mexbandit/mbscorpions.wav",
		"wanted/mexbandit/mbshit.wav",
		"wanted/mexbandit/mbshitno.wav",
		"wanted/mexbandit/mbshootkill.wav",
		"wanted/mexbandit/mbshutup.wav",
		"wanted/mexbandit/mbsi.wav",
		"wanted/mexbandit/mbsickfood.wav",
		"wanted/mexbandit/mbsnakesdung.wav",
		"wanted/mexbandit/mbstaydown.wav",
		"wanted/mexbandit/mbstayput.wav",
		"wanted/mexbandit/mbstopshout.wav",
		"wanted/mexbandit/mbsurething.wav",
		"wanted/mexbandit/mbtakecover.wav",
		"wanted/mexbandit/mbtakethis.wav",
		"wanted/mexbandit/mbtakethis2.wav",
		"wanted/mexbandit/mbtherehe.wav",
		"wanted/mexbandit/mbtiredbynow.wav",
		"wanted/mexbandit/mbtombstone.wav",
		"wanted/mexbandit/mbwantcorn.wav",
		"wanted/mexbandit/mbwellhiden.wav",
		"wanted/mexbandit/mbwheredyn.wav",
		"wanted/mexbandit/mbwind.wav",
		"wanted/mexbandit/mbyes.wav",
		"wanted/mexbandit/mb_die1.wav",
		"wanted/mexbandit/mb_die2.wav",
		"wanted/mexbandit/mb_die3.wav",
		"wanted/mexbandit/mb_pain1.wav",
		"wanted/mexbandit/mb_pain2.wav",
		"wanted/mexbandit/mb_pain3.wav",
		"wanted/mexbandit/mb_pain4.wav",
		"wanted/mexbandit/mb_pain5.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/bandit_mex.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/bandit_mex01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/bandit_mex02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/bandit_mex03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/bandit_mext.mdl" );

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
			pev.body = Math.RandomLong( HEAD_ONE_PISTOL, HEAD_FOUR_GAT );

		dictionary keyvalues = {
			{ "model", "models/wanted/bandit_mex.mdl" },
			{ "soundlist", "../wanted/mexbandit/mexbandit.txt" },
			{ "displayname", "Mexican Bandit" }
		};
		string szClassname = "monster_human_grunt";

		switch( pev.body )
		{
		case HEAD_ONE_GAT:
		case HEAD_TWO_GAT:
		case HEAD_THREE_GAT:
		case HEAD_FOUR_GAT:
			keyvalues = {
				{ "model", "models/wanted/bandit_mex.mdl" },
				{ "soundlist", "../wanted/mexbandit/mexbandit.gat.txt" },
				{ "is_player_ally", "1" },
				{ "displayname", "Mexican Bandit" }
			};
			szClassname = "monster_human_grunt_ally";
			break;
		}

		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( szClassname, keyvalues, false );

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

class monster_mexbandit_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/bandit_mex.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/bandit_mex.mdl" );
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

		self.m_FormattedName = "Dead Mexican Bandit";

		self.SetBodygroup( BODYGROUP_GUN, GUN_NONE );

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_ONE_PISTOL, HEAD_FOUR_GAT) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead mexbandit with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_MexBandit::monster_mexbandit", "monster_mexbandit" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_MexBandit::monster_mexbandit_dead", "monster_mexbandit_dead" );
}

} // end of HLWanted_MexBandit namespace