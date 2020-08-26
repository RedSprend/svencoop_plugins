// Base class for all Wanted weapons
// Author: GeckonCZ

class CBaseCustomWeapon : ScriptBasePlayerWeaponEntity
{
	// Possible workaround for the SendWeaponAnim() access violation crash.
	// According to R4to0 this seems to provide at least some improvement.
	// GeckoN: TODO: Remove this once the core issue is addressed.
	protected CBasePlayer@ m_pPlayer
	{
		get const { return cast<CBasePlayer@>( self.m_hPlayer.GetEntity() ); }
		set { self.m_hPlayer = EHandle( @value ); }
	}

	protected bool m_fDropped;
	CBasePlayerItem@ DropItem()
	{
		m_fDropped = true;
		return self;
	}

	void GetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity,
		Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale )
	{
		Vector vecForward, vecRight, vecUp;

		g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );

		const float fR = Math.RandomFloat( 50, 70 );
		const float fU = Math.RandomFloat( 100, 150 );

		for( int i = 0; i < 3; ++i )
		{
			ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * 25;
			ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
		}
	}
}

class CBaseCustomAmmo : ScriptBasePlayerAmmoEntity
{
	protected string m_strModel = "models/error.mdl";
	protected string m_strName;
	protected int m_iAmount = 0;
	protected int m_iMax = 0;

	protected string m_strPickupSound = "items/gunpickup2.wav";

	void Precache()
	{
		g_Game.PrecacheModel( m_strModel );

		g_SoundSystem.PrecacheSound( m_strPickupSound );
	}

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, m_strModel );
		BaseClass.Spawn();
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{
		if ( pOther.GiveAmmo( m_iAmount, m_strName, m_iMax, false ) == -1 )
			return false;

		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, m_strPickupSound, 1, ATTN_NORM );

		return true;
	}
}