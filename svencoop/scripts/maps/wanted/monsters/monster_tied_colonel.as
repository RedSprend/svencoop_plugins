namespace HLWanted_ColonelTied
{
enum Colonel
{
	COLONEL_FIGHT = 0,
	COLONEL_TALK,
	COLONEL_DEAD
};

class monster_tied_colonel : CBaseCustomMonster
{
	int iSequence = 0;

	void Precache()
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
		{
			g_Game.PrecacheModel( self, "models/wanted/colonel_tied.mdl" );
			g_Game.PrecacheModel( self, "models/wanted/colonel_tiedT.mdl" );
		}
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, "models/wanted/colonel_tied.mdl" );

		g_EntityFuncs.SetSize( self.pev, Vector(-24, -24, 0), Vector(24, 24, 10) );

		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.m_bloodColor	= BLOOD_COLOR_RED;
		self.pev.takedamage 	= DAMAGE_YES;
		self.pev.health 	= 65.0f;
		self.pev.max_health 	= self.pev.health;
		self.pev.deadflag 	= DEAD_NO;
		//self.pev.flags 		|= FL_MONSTER;

		self.InitBoneControllers();

		SetUse( null );
		SetThink( null );

		self.SetClassification( CLASS_NONE );

		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Colonel" );
		g_EntityFuncs.DispatchKeyValue( self.edict(), "is_player_ally", "1" );

		iSequence = 0;

		self.pev.sequence = COLONEL_FIGHT;
		self.ResetSequenceInfo( );
		self.pev.frame = 0;
		self.SetBoneController( 0, 0 );
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		if( useType != USE_SET )
		{
			switch( iSequence )
			{
				case 0:
				{
					self.pev.sequence = COLONEL_TALK;
					iSequence++;
				}
				break;
				case 1:
				{
					self.pev.sequence = COLONEL_DEAD;
					self.pev.deadflag = DEAD_DEAD;
				}
				break;
			}
			self.pev.frame = 0;
			self.ResetSequenceInfo();
		}
	}

	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		return 0;
	}
}

string GetColonelTiedName()
{
	return "monster_tied_colonel";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_ColonelTied::monster_tied_colonel", GetColonelTiedName() );
}

} // end of namespace