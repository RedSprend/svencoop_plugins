namespace HLWanted_Hoss
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_GUN
}

enum WeaponSubModel
{
	GUN_HOLSTER = 0,
	GUN_DRAWN,
	GUN_NONE
}

class monster_hoss : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/hoss/aimforbelly.wav",
		"wanted/hoss/aintnotellin.wav",
		"wanted/hoss/aintscared.wav",
		"wanted/hoss/aintsosure.wav",
		"wanted/hoss/ambush.wav",
		"wanted/hoss/anycloser.wav",
		"wanted/hoss/askalready.wav",
		"wanted/hoss/badfeelin.wav",
		"wanted/hoss/betonit.wav",
		"wanted/hoss/bigolmess.wav",
		"wanted/hoss/boughtit.wav",
		"wanted/hoss/bulletstilin.wav",
		"wanted/hoss/busynow.wav",
		"wanted/hoss/cantfigureit.wav",
		"wanted/hoss/cantgetworse.wav",
		"wanted/hoss/cantgoon.wav",
		"wanted/hoss/cantnowsorry.wav",
		"wanted/hoss/careful.wav",
		"wanted/hoss/catchbreath.wav",
		"wanted/hoss/coffinfit.wav",
		"wanted/hoss/crackshot.wav",
		"wanted/hoss/didyouseethat.wav",
		"wanted/hoss/dirtonboots.wav",
		"wanted/hoss/doclookat.wav",
		"wanted/hoss/dontfigure.wav",
		"wanted/hoss/dontguesso.wav",
		"wanted/hoss/dontlikesound.wav",
		"wanted/hoss/dontthink.wav",
		"wanted/hoss/dragdrunk.wav",
		"wanted/hoss/everbeenshot.wav",
		"wanted/hoss/foolzak.wav",
		"wanted/hoss/fromhere.wav",
		"wanted/hoss/gethellout.wav",
		"wanted/hoss/getoutalive.wav",
		"wanted/hoss/goingtoscar.wav",
		"wanted/hoss/gonna.wav",
		"wanted/hoss/goodidea.wav",
		"wanted/hoss/goshshooting.wav",
		"wanted/hoss/gotanother.wav",
		"wanted/hoss/gotone.wav",
		"wanted/hoss/hattoobig.wav",
		"wanted/hoss/hearthatnoise.wav",
		"wanted/hoss/heysheriff.wav",
		"wanted/hoss/heythere.wav",
		"wanted/hoss/heyup.wav",
		"wanted/hoss/hinicecoat.wav",
		"wanted/hoss/hmmm.wav",
		"wanted/hoss/homeonerange.wav",
		"wanted/hoss/howdy.wav",
		"wanted/hoss/howdyboss.wav",
		"wanted/hoss/howdydo.wav",
		"wanted/hoss/ho_attack0.wav",
		"wanted/hoss/ho_attack1.wav",
		"wanted/hoss/ho_attack2.wav",
		"wanted/hoss/ho_die0.wav",
		"wanted/hoss/ho_die2.wav",
		"wanted/hoss/ho_die3.wav",
		"wanted/hoss/ho_pain0.wav",
		"wanted/hoss/ho_pain1.wav",
		"wanted/hoss/ho_pain2.wav",
		"wanted/hoss/hurtrealbad.wav",
		"wanted/hoss/iaintsure.wav",
		"wanted/hoss/iainttakinno.wav",
		"wanted/hoss/ifthatstheway.wav",
		"wanted/hoss/igotem.wav",
		"wanted/hoss/iguessso.wav",
		"wanted/hoss/illwaithere.wav",
		"wanted/hoss/illwhistle.wav",
		"wanted/hoss/imhit.wav",
		"wanted/hoss/imyourman.wav",
		"wanted/hoss/ireckon.wav",
		"wanted/hoss/iwanrnedyou.wav",
		"wanted/hoss/justdontknow.wav",
		"wanted/hoss/keeplookout.wav",
		"wanted/hoss/knife_miss1.wav",
		"wanted/hoss/lendahand.wav",
		"wanted/hoss/lockedin.wav",
		"wanted/hoss/lockin.wav",
		"wanted/hoss/lookdrunk.wav",
		"wanted/hoss/lookout.wav",
		"wanted/hoss/lookslike.wav",
		"wanted/hoss/lowerst.wav",
		"wanted/hoss/luckwilturn.wav",
		"wanted/hoss/madasramone.wav",
		"wanted/hoss/madassnake.wav",
		"wanted/hoss/maproudofme.wav",
		"wanted/hoss/mariaprety.wav",
		"wanted/hoss/maybee.wav",
		"wanted/hoss/maybenot.wav",
		"wanted/hoss/needstitch.wav",
		"wanted/hoss/neverthought.wav",
		"wanted/hoss/newboots.wav",
		"wanted/hoss/nope.wav",
		"wanted/hoss/nosense.wav",
		"wanted/hoss/nosirree.wav",
		"wanted/hoss/nothurting.wav",
		"wanted/hoss/noway.wav",
		"wanted/hoss/okillcover.wav",
		"wanted/hoss/okillwait.wav",
		"wanted/hoss/okmoveout.wav",
		"wanted/hoss/okthatsit.wav",
		"wanted/hoss/pick.wav",
		"wanted/hoss/poetry.wav",
		"wanted/hoss/poormiss.wav",
		"wanted/hoss/practice.wav",
		"wanted/hoss/quickordead.wav",
		"wanted/hoss/quityappin.wav",
		"wanted/hoss/reachsky.wav",
		"wanted/hoss/reckontrue.wav",
		"wanted/hoss/rightbehind.wav",
		"wanted/hoss/sasparella.wav",
		"wanted/hoss/seeyoulater.wav",
		"wanted/hoss/sheriff.wav",
		"wanted/hoss/shootem.wav",
		"wanted/hoss/smellsbaad.wav",
		"wanted/hoss/smellsbad.wav",
		"wanted/hoss/somethindied.wav",
		"wanted/hoss/sonbitch.wav",
		"wanted/hoss/soundsabout.wav",
		"wanted/hoss/soundsright.wav",
		"wanted/hoss/sshhquietdown.wav",
		"wanted/hoss/ssshhh.wav",
		"wanted/hoss/sssshhhh.wav",
		"wanted/hoss/standback.wav",
		"wanted/hoss/sucker.wav",
		"wanted/hoss/surething.wav",
		"wanted/hoss/surewasugly.wav",
		"wanted/hoss/takethis.wav",
		"wanted/hoss/tellthinking.wav",
		"wanted/hoss/thatsmarts.wav",
		"wanted/hoss/triggerfinger.wav",
		"wanted/hoss/tune.wav",
		"wanted/hoss/twistankle.wav",
		"wanted/hoss/usewhisky.wav",
		"wanted/hoss/waititsme.wav",
		"wanted/hoss/waitothers.wav",
		"wanted/hoss/waterhorse.wav",
		"wanted/hoss/wayiseeit.wav",
		"wanted/hoss/whataredoing.wav",
		"wanted/hoss/whatblazes.wav",
		"wanted/hoss/whatfellers.wav",
		"wanted/hoss/whathaveidone.wav",
		"wanted/hoss/whatinblazes.wav",
		"wanted/hoss/whatthe.wav",
		"wanted/hoss/whatyouthinkn.wav",
		"wanted/hoss/wildwest.wav",
		"wanted/hoss/yaseezak.wav",
		"wanted/hoss/yellifihear.wav",
		"wanted/hoss/yep.wav",
		"wanted/hoss/yessiree.wav",
		"wanted/hoss/youhearthat.wav",
		"wanted/hoss/zebhit.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/hoss.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/hoss01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/hoss02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/hoss03.mdl" );
		g_Game.PrecacheModel( "models/wanted/hossT.mdl" );

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
			{ "model", "models/wanted/hoss.mdl" },
			{ "soundlist", "../wanted/hoss/hoss.txt" },
			{ "displayname", "Hoss" }
		};
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "monster_barney", keyvalues, false );

		CBaseMonster@ pBa = pEntity.MyMonsterPointer();

		pBa.pev.origin = pev.origin;
		pBa.pev.angles = pev.angles;
		pBa.pev.health = pev.health;
		pBa.pev.targetname = pev.targetname;
		pBa.pev.netname = pev.netname;
		pBa.pev.weapons = pev.weapons;
		pBa.pev.body = pev.body;
		pBa.pev.skin = pev.skin;
		pBa.pev.mins = pev.mins;
		pBa.pev.maxs = pev.maxs;
		pBa.pev.scale = pev.scale;
		pBa.pev.rendermode = pev.rendermode;
		pBa.pev.renderamt = pev.renderamt;
		pBa.pev.rendercolor = pev.rendercolor;
		pBa.pev.renderfx = pev.renderfx;
		pBa.pev.spawnflags = pev.spawnflags;

		g_EntityFuncs.DispatchSpawn( pBa.edict() );

		pBa.m_iTriggerCondition = self.m_iTriggerCondition;
		pBa.m_iszTriggerTarget = self.m_iszTriggerTarget;

		g_EntityFuncs.Remove( self );
	}
}

class monster_hoss_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "lying_on_back", "lying_on_side", "lying_on_stomach" };

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
			g_Game.PrecacheModel( self, "models/wanted/hoss.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/hoss.mdl" );
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

		self.m_FormattedName = "Dead Hoss";

		self.SetBodygroup( BODYGROUP_GUN, GUN_NONE );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead hoss with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Hoss::monster_hoss", "monster_hoss" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Hoss::monster_hoss_dead", "monster_hoss_dead" );
}

} // end of HLWanted_Hoss namespace