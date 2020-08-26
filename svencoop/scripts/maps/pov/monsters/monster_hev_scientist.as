namespace HEVSCIENTIST
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEADS,
	BODYGROUP_WEAPONS
}

enum HeadSubModel
{
	HEAD_GORDON = 0,
	HEAD_EINSTEIN,
	HEAD_HELMET
}

enum WeaponSubModel
{
	GUN_PISTOLHOLSTERED = 0,
	GUN_PISTOLDRAWN,
	GUN_357,
	GUN_MP5,
	GUN_SHOTGUN,
	GUN_NONE,
	GUN_PLASMA // Grenade? Plasma gun?
}

class monster_hev_scientist : HEVORANGE::monster_hev_orangehelmet
{
	void Spawn()
	{
		HEVORANGE::monster_hev_orangehelmet::Spawn();

		if( string( self.m_FormattedName ).IsEmpty() )
		{
			self.m_FormattedName = "HEV Scientist";
		}

		self.SetBodygroup( BODYGROUP_HEADS, HEAD_EINSTEIN );
	}
}

void Register()
{
	HEVORANGE::InitSchedules();
	g_CustomEntityFuncs.RegisterCustomEntity( "HEVSCIENTIST::monster_hev_scientist", "monster_hev_scientist" );
}

} // end of namespace