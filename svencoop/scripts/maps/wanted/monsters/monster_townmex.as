namespace HLWanted_TownMex
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEAD,
	BODYGROUP_BOTTLE
}

enum HeadSubModel
{
	HEAD_1 = 0,
	HEAD_2,
	HEAD_3,
	HEAD_4
}

enum BottleSubModel
{
	NONE = 0,
	BOTTLE
}

class monster_townmex : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/townmex/ahhh.wav",
		"wanted/townmex/argh.wav",
		"wanted/townmex/arghhhh.wav",
		"wanted/townmex/askmigeal.wav",
		"wanted/townmex/askoldman.wav",
		"wanted/townmex/askpadre.wav",
		"wanted/townmex/ayee.wav",
		"wanted/townmex/badday.wav",
		"wanted/townmex/badmen.wav",
		"wanted/townmex/baityou.wav",
		"wanted/townmex/banditsaway.wav",
		"wanted/townmex/beansandcorn.wav",
		"wanted/townmex/believeso.wav",
		"wanted/townmex/blackday.wav",
		"wanted/townmex/boresmetodeath.wav",
		"wanted/townmex/buzzard.wav",
		"wanted/townmex/cactus.wav",
		"wanted/townmex/cantgoon.wav",
		"wanted/townmex/chafe.wav",
		"wanted/townmex/changemind.wav",
		"wanted/townmex/comehelpus.wav",
		"wanted/townmex/crazymad.wav",
		"wanted/townmex/cursevillage.wav",
		"wanted/townmex/cutout.wav",
		"wanted/townmex/deadfear.wav",
		"wanted/townmex/donthurtme.wav",
		"wanted/townmex/doyouneverstop.wav",
		"wanted/townmex/drinkthis.wav",
		"wanted/townmex/dullpain.wav",
		"wanted/townmex/eek.wav",
		"wanted/townmex/enoughbullets.wav",
		"wanted/townmex/evilmen.wav",
		"wanted/townmex/fertiliser.wav",
		"wanted/townmex/fightlastnight.wav",
		"wanted/townmex/findburo.wav",
		"wanted/townmex/goldinteeth.wav",
		"wanted/townmex/gonemad.wav",
		"wanted/townmex/greko.wav",
		"wanted/townmex/gringo.wav",
		"wanted/townmex/hearrustling.wav",
		"wanted/townmex/hearsomething.wav",
		"wanted/townmex/hearthat.wav",
		"wanted/townmex/helllo.wav",
		"wanted/townmex/hello.wav",
		"wanted/townmex/helpme.wav",
		"wanted/townmex/helpus.wav",
		"wanted/townmex/heyamigo.wav",
		"wanted/townmex/holiday.wav",
		"wanted/townmex/hottoday.wav",
		"wanted/townmex/howpossible.wav",
		"wanted/townmex/ifitoldyou.wav",
		"wanted/townmex/iforgot.wav",
		"wanted/townmex/ifyousayso.wav",
		"wanted/townmex/iknownothing.wav",
		"wanted/townmex/illfollowyou.wav",
		"wanted/townmex/imshot.wav",
		"wanted/townmex/inthisworld.wav",
		"wanted/townmex/ithinkso.wav",
		"wanted/townmex/iwish.wav",
		"wanted/townmex/laterhuh.wav",
		"wanted/townmex/letsbegoing.wav",
		"wanted/townmex/lookfunny.wav",
		"wanted/townmex/lunchtoday.wav",
		"wanted/townmex/madcrazy.wav",
		"wanted/townmex/madman.wav",
		"wanted/townmex/mariasmustache.wav",
		"wanted/townmex/mistake.wav",
		"wanted/townmex/mnogo.wav",
		"wanted/townmex/moreguns.wav",
		"wanted/townmex/mrsherriffsir.wav",
		"wanted/townmex/mygoodfriend.wav",
		"wanted/townmex/needsome.wav",
		"wanted/townmex/newbeans.wav",
		"wanted/townmex/newspaper.wav",
		"wanted/townmex/no.wav",
		"wanted/townmex/noburo.wav",
		"wanted/townmex/nogood.wav",
		"wanted/townmex/noicant.wav",
		"wanted/townmex/noo.wav",
		"wanted/townmex/nowait.wav",
		"wanted/townmex/ofcourse.wav",
		"wanted/townmex/oherrrr.wav",
		"wanted/townmex/ohhahh.wav",
		"wanted/townmex/ohhh.wav",
		"wanted/townmex/ohno.wav",
		"wanted/townmex/ok.wav",
		"wanted/townmex/onlyachicken.wav",
		"wanted/townmex/onlycamefor.wav",
		"wanted/townmex/opengate.wav",
		"wanted/townmex/pain1.wav",
		"wanted/townmex/pain2.wav",
		"wanted/townmex/pain3.wav",
		"wanted/townmex/pain4.wav",
		"wanted/townmex/pain5.wav",
		"wanted/townmex/pleasesenior.wav",
		"wanted/townmex/prayyouknow.wav",
		"wanted/townmex/resthere.wav",
		"wanted/townmex/ridenburo.wav",
		"wanted/townmex/runoutoftown.wav",
		"wanted/townmex/rusure.wav",
		"wanted/townmex/santamaria.wav",
		"wanted/townmex/seensombrero.wav",
		"wanted/townmex/sherriff.wav",
		"wanted/townmex/sherriffintown.wav",
		"wanted/townmex/shout.wav",
		"wanted/townmex/si.wav",
		"wanted/townmex/siesta.wav",
		"wanted/townmex/siestatime.wav",
		"wanted/townmex/signore.wav",
		"wanted/townmex/simplefarmers.wav",
		"wanted/townmex/simplepeasant.wav",
		"wanted/townmex/slowingudown.wav",
		"wanted/townmex/smallhat.wav",
		"wanted/townmex/squeeeeek.wav",
		"wanted/townmex/stainsout.wav",
		"wanted/townmex/stareat.wav",
		"wanted/townmex/stench.wav",
		"wanted/townmex/stitchwound.wav",
		"wanted/townmex/sure.wav",
		"wanted/townmex/talktomuch.wav",
		"wanted/townmex/tendhorses.wav",
		"wanted/townmex/teqilaonyou.wav",
		"wanted/townmex/terriblesmell.wav",
		"wanted/townmex/thathurt.wav",
		"wanted/townmex/thinkitstrue.wav",
		"wanted/townmex/tireofspeak.wav",
		"wanted/townmex/todangerous.wav",
		"wanted/townmex/ugh.wav",
		"wanted/townmex/untrue.wav",
		"wanted/townmex/useashot.wav",
		"wanted/townmex/waitforothers.wav",
		"wanted/townmex/wastebullets.wav",
		"wanted/townmex/weakback.wav",
		"wanted/townmex/wearefarmers.wav",
		"wanted/townmex/whatdoyoumean.wav",
		"wanted/townmex/whattheywant.wav",
		"wanted/townmex/whatthink.wav",
		"wanted/townmex/whatyoudo.wav",
		"wanted/townmex/whitewash.wav",
		"wanted/townmex/whydothis.wav",
		"wanted/townmex/whynot.wav",
		"wanted/townmex/wifekillme.wav",
		"wanted/townmex/worriedwife.wav",
		"wanted/townmex/wyatterp.wav",
		"wanted/townmex/yeowww.wav",
		"wanted/townmex/yes.wav",
		"wanted/townmex/yess.wav",
		"wanted/townmex/youarecrazy.wav",
		"wanted/townmex/youareshot.wav",
		"wanted/townmex/youbadday.wav",
		"wanted/townmex/youlookhurt.wav",
		"wanted/townmex/youngboys.wav",
		"wanted/townmex/youngones.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/townmex.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex04.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex05.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex06.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmex07.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/townmext.mdl" );

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
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_4) );

		dictionary keyvalues = {
			{ "model", "models/wanted/townmex.mdl" },
			{ "soundlist", "../wanted/townmex/townmex.txt" },
			{ "displayname", "Townie" }
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

class monster_townmex_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/townmex.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/townmex.mdl" );
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

		self.m_FormattedName = "Dead Townie";

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_4) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead townie with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_TownMex::monster_townmex", "monster_townmex" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_TownMex::monster_townmex_dead", "monster_townmex_dead" );
}

} // end of HLWanted_TownMex namespace