namespace HLWanted_Annie
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

class monster_annie : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/annie/aimbetter.wav",
		"wanted/annie/aimsbetter.wav",
		"wanted/annie/an_attack0.wav",
		"wanted/annie/an_attack1.wav",
		"wanted/annie/an_attack2.wav",
		"wanted/annie/an_die0.wav",
		"wanted/annie/an_die2.wav",
		"wanted/annie/an_die3.wav",
		"wanted/annie/an_pain0.wav",
		"wanted/annie/an_pain1.wav",
		"wanted/annie/an_pain2.wav",
		"wanted/annie/an_pain3.wav",
		"wanted/annie/askyesterday.wav",
		"wanted/annie/beadhead.wav",
		"wanted/annie/beenhit.wav",
		"wanted/annie/beenpractise.wav",
		"wanted/annie/bigbutt.wav",
		"wanted/annie/binpractise.wav",
		"wanted/annie/bitleft.wav",
		"wanted/annie/brother.wav",
		"wanted/annie/cantfigure.wav",
		"wanted/annie/cantgetworse.wav",
		"wanted/annie/chorestodo.wav",
		"wanted/annie/coffee.wav",
		"wanted/annie/corsets.wav",
		"wanted/annie/countmein.wav",
		"wanted/annie/cutitout.wav",
		"wanted/annie/deadbird.wav",
		"wanted/annie/diddntthink.wav",
		"wanted/annie/dontaskme.wav",
		"wanted/annie/dontbeleive.wav",
		"wanted/annie/dontforget.wav",
		"wanted/annie/dontworry.wav",
		"wanted/annie/dothatfor.wav",
		"wanted/annie/eggsiseggs.wav",
		"wanted/annie/enoughis.wav",
		"wanted/annie/fiveminutes.wav",
		"wanted/annie/giveup.wav",
		"wanted/annie/gladpractise.wav",
		"wanted/annie/gladtohelp.wav",
		"wanted/annie/goget.wav",
		"wanted/annie/goshseethat.wav",
		"wanted/annie/gotochurch.wav",
		"wanted/annie/gunstraight.wav",
		"wanted/annie/hardone.wav",
		"wanted/annie/harmonica.wav",
		"wanted/annie/hearanoise.wav",
		"wanted/annie/hearsomethin.wav",
		"wanted/annie/hearthat.wav",
		"wanted/annie/hello.wav",
		"wanted/annie/hellothere.wav",
		"wanted/annie/hey.wav",
		"wanted/annie/hisheriff.wav",
		"wanted/annie/hithere.wav",
		"wanted/annie/hogwash.wav",
		"wanted/annie/holesock.wav",
		"wanted/annie/hopeaccident.wav",
		"wanted/annie/hosslike.wav",
		"wanted/annie/hosslikeme.wav",
		"wanted/annie/hotbath.wav",
		"wanted/annie/howdy.wav",
		"wanted/annie/howdysheriff.wav",
		"wanted/annie/idontknow.wav",
		"wanted/annie/idontthinkso.wav",
		"wanted/annie/iguesso.wav",
		"wanted/annie/illwaithere.wav",
		"wanted/annie/intuition.wav",
		"wanted/annie/ishotzeke.wav",
		"wanted/annie/lemonade.wav",
		"wanted/annie/letsgo.wav",
		"wanted/annie/liedown.wav",
		"wanted/annie/littlebusy.wav",
		"wanted/annie/lookcloud.wav",
		"wanted/annie/maybee.wav",
		"wanted/annie/missinteeth.wav",
		"wanted/annie/moveout.wav",
		"wanted/annie/needrest.wav",
		"wanted/annie/neverletme.wav",
		"wanted/annie/newbeans.wav",
		"wanted/annie/nope.wav",
		"wanted/annie/nosiree.wav",
		"wanted/annie/notelling.wav",
		"wanted/annie/notmakeit.wav",
		"wanted/annie/notscaredyou.wav",
		"wanted/annie/okillhide.wav",
		"wanted/annie/onebullet.wav",
		"wanted/annie/oneshot.wav",
		"wanted/annie/outhouse.wav",
		"wanted/annie/owww.wav",
		"wanted/annie/prayimiss.wav",
		"wanted/annie/putmoneyonit.wav",
		"wanted/annie/reckonso.wav",
		"wanted/annie/rudestare.wav",
		"wanted/annie/script1.wav",
		"wanted/annie/script2.wav",
		"wanted/annie/seemoveing.wav",
		"wanted/annie/seemyaim.wav",
		"wanted/annie/shootem.wav",
		"wanted/annie/shootwoman.wav",
		"wanted/annie/sightsout.wav",
		"wanted/annie/sixgotaway.wav",
		"wanted/annie/slowyoudown.wav",
		"wanted/annie/smell.wav",
		"wanted/annie/soundsbad.wav",
		"wanted/annie/soundsright.wav",
		"wanted/annie/stopitonce.wav",
		"wanted/annie/sunhotoday.wav",
		"wanted/annie/sureidmissed.wav",
		"wanted/annie/surething.wav",
		"wanted/annie/swellday.wav",
		"wanted/annie/takenomore.wav",
		"wanted/annie/tattle.wav",
		"wanted/annie/tellpractice.wav",
		"wanted/annie/thatdoesit.wav",
		"wanted/annie/thinkexcite.wav",
		"wanted/annie/thinking.wav",
		"wanted/annie/tincans.wav",
		"wanted/annie/toohardforme.wav",
		"wanted/annie/turnonme.wav",
		"wanted/annie/visitouthouse.wav",
		"wanted/annie/wanthelp.wav",
		"wanted/annie/wayyouwantit.wav",
		"wanted/annie/whatareyou.wav",
		"wanted/annie/whatmetodo.wav",
		"wanted/annie/whatnow.wav",
		"wanted/annie/whatsgoingon.wav",
		"wanted/annie/whatsmatter.wav",
		"wanted/annie/whatswrong.wav",
		"wanted/annie/whatthe.wav",
		"wanted/annie/wingsoff.wav",
		"wanted/annie/workwell.wav",
		"wanted/annie/woundclean.wav",
		"wanted/annie/woundpain.wav",
		"wanted/annie/yes.wav",
		"wanted/annie/youbeenhit.wav",
		"wanted/annie/youdontsay.wav",
		"wanted/annie/_comma.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/annie.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/annie01.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/annie02.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/annie03.mdl" );
		g_Game.PrecacheGeneric( "models/wanted/anniet.mdl" );

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
			{ "model", "models/wanted/annie.mdl" },
			{ "soundlist", "../wanted/annie/annie.txt" },
			{ "displayname", "Annie" }
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

class monster_annie_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/annie.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/annie.mdl" );
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

		self.m_FormattedName = "Dead Annie";

		self.SetBodygroup( BODYGROUP_GUN, GUN_NONE );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead annie with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Annie::monster_annie", "monster_annie" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Annie::monster_annie_dead", "monster_annie_dead" );
}

} // end of HLWanted_Annie namespace