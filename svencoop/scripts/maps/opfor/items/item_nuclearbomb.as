/*
#include "items/item_nuclearbomb"

void MapInit()
{
	OFNuclearBomb::Register();
}
*/

namespace OFNuclearBomb
{
const string NUKE_BUTTON_MODEL = "models/nuke_button.mdl";
const string NUKE_TIMER_MODEL = "models/nuke_timer.mdl";
const string NUKE_MODEL = "models/nuke_case.mdl";

class COFNuclearBombButton : ScriptBaseEntity
{
	void Precache()
	{
		g_Game.PrecacheModel( NUKE_BUTTON_MODEL );
	}

	void Spawn()
	{
		Precache();

		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NONE;

		g_EntityFuncs.SetModel( self, NUKE_BUTTON_MODEL );
		g_EntityFuncs.SetSize( self.pev, Vector(-16, -16, 0), Vector(16, 16, 32) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( g_EngineFuncs.DropToFloor( self.edict() ) == 0 )
		{
			g_EntityFuncs.Remove( self );
		}
		else
		{
			self.pev.skin = 0;
		}
	}

	void SetNuclearBombButton( bool fOn )
	{
		self.pev.skin = fOn ? 1 : 0;
	}
}

class COFNuclearBombTimer : ScriptBaseEntity
{
	int ObjectCaps() { return FCAP_DONT_SAVE; }

	bool bPlayBombSound;
	bool bBombSoundPlaying;

	void Precache()
	{
		g_Game.PrecacheModel( NUKE_TIMER_MODEL );
		g_SoundSystem.PrecacheSound( "common/nuke_ticking.wav" );
	}

	void Spawn()
	{
		Precache();

		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NONE;

		g_EntityFuncs.SetModel( self, NUKE_TIMER_MODEL );
		g_EntityFuncs.SetSize( self.pev, Vector(-16, -16, 0), Vector(16, 16, 32) );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( g_EngineFuncs.DropToFloor( self.edict() ) == 0 )
		{
			g_EntityFuncs.Remove( self );
		}
		else
		{
			self.pev.skin = 0;
			bPlayBombSound = true;
			bBombSoundPlaying = true;
		}
	}

	void NuclearBombTimerThink()
	{
		if( self.pev.skin <= 1 )
			++self.pev.skin;
		else
			self.pev.skin = 0;

		if( bPlayBombSound )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_BODY, "common/nuke_ticking.wav", 0.75, ATTN_IDLE );
			bBombSoundPlaying = true;

		}

		self.pev.nextthink = g_Engine.time + 0.1;
	}

	void SetNuclearBombTimer( bool fOn )
	{
		if( fOn )
		{
			SetThink( ThinkFunction(NuclearBombTimerThink) );
			self.pev.nextthink = g_Engine.time + 0.5;
			bPlayBombSound = true;
		}
		else
		{
			SetThink( null );
			self.pev.nextthink = g_Engine.time;

			self.pev.skin = 3;

			if( bBombSoundPlaying )
			{
				g_SoundSystem.StopSound( self.edict(), CHAN_BODY, "common/nuke_ticking.wav" );
				bBombSoundPlaying = false;
			}
		}
	}
}

class COFNuclearBomb : ScriptBaseEntity
{
	COFNuclearBombTimer@ m_pTimer = null;
	COFNuclearBombButton@ m_pButton = null;
	bool m_fOn;
	float m_flLastPush, m_flWait;
	int m_iPushCount;

	int ObjectCaps() { return BaseClass.ObjectCaps() | FCAP_IMPULSE_USE; }

	bool KeyValue(const string& in szKey, const string& in szValue)
	{
		if( szKey == "initialstate" )
		{
			m_fOn = atoi( szValue ) != 0;
			return true;
		}
		else if( szKey == "wait" )
		{
			m_flWait = atof( szValue );
			return true;
		}
		else
		{
			return BaseClass.KeyValue( szKey, szValue );
		}
	}

	void Precache()
	{
		g_Game.PrecacheModel( NUKE_MODEL );
		g_Game.PrecacheOther( "item_nuclearbombtimer" );
		g_Game.PrecacheOther( "item_nuclearbombbutton" );
		g_Game.PrecacheModel( NUKE_TIMER_MODEL );
		g_Game.PrecacheModel( NUKE_BUTTON_MODEL );
		g_SoundSystem.PrecacheSound( "buttons/button4.wav" );
		g_SoundSystem.PrecacheSound( "buttons/button6.wav" );

		CBaseEntity@ pre_pTimer = g_EntityFuncs.CreateEntity( "item_nuclearbombtimer", null, false );
		@m_pTimer = cast<COFNuclearBombTimer@>(CastToScriptClass(pre_pTimer));

		m_pTimer.pev.origin = self.pev.origin;
		m_pTimer.pev.angles = self.pev.angles;

		m_pTimer.Spawn();

		m_pTimer.SetNuclearBombTimer( m_fOn == true );

		CBaseEntity@ pre_pButton = g_EntityFuncs.CreateEntity( "item_nuclearbombbutton", null, false );
		@m_pButton = cast<COFNuclearBombButton@>(CastToScriptClass(pre_pButton));

		m_pButton.pev.origin = self.pev.origin;
		m_pButton.pev.angles = self.pev.angles;

		m_pButton.Spawn();

		m_pButton.pev.skin = 1; //m_fOn == true;
	}

	void Spawn()
	{
		Precache();

		self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_BBOX;

		g_EntityFuncs.SetModel( self, NUKE_MODEL );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, Vector(-16, -16, 0), Vector(16, 16, 32) );

		if( g_EngineFuncs.DropToFloor( self.edict() ) > 0 )
		{
			m_iPushCount = 0;
			m_flLastPush = g_Engine.time;
		}
		else
		{
			g_EntityFuncs.Remove( self );
		}
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		if( ( m_flWait != -1.0 || m_iPushCount <= 0 )
			&& m_flWait <= g_Engine.time - m_flLastPush
			&& self.ShouldToggle( useType, m_fOn ) )
		{
			if( m_fOn )
			{
				m_fOn = false;
				g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "buttons/button4.wav", VOL_NORM, ATTN_NORM );
			}
			else
			{
				m_fOn = true;
				g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "buttons/button6.wav", VOL_NORM, ATTN_NORM );
			}

			self.SUB_UseTargets( pActivator, USE_TOGGLE, 0 );

			if( m_pButton !is null )
			{
				m_pButton.SetNuclearBombButton( m_fOn == true );
			}

			if( m_pTimer !is null )
			{
				m_pTimer.SetNuclearBombTimer( m_fOn == true );
			}

			if( m_pTimer is null || !m_pTimer.bBombSoundPlaying )
			{
				++m_iPushCount;
				m_flLastPush = g_Engine.time;
			}
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "OFNuclearBomb::COFNuclearBombButton", "item_nuclearbombbutton" );
	g_CustomEntityFuncs.RegisterCustomEntity( "OFNuclearBomb::COFNuclearBombTimer", "item_nuclearbombtimer" );
	g_CustomEntityFuncs.RegisterCustomEntity( "OFNuclearBomb::COFNuclearBomb", "item_nuclearbomb" );
}
} // end of namespace