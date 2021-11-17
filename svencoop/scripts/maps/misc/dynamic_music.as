/* Dynamic music system
*
* Include in MapInit():
* g_DynamicMusic.MapInit();
*
* Include in MapActivate():
* g_DynamicMusic.MapActivate();
*
*/

// NOTE:
// Fade in & out not possible!

Music::MusicClass g_DynamicMusic();

namespace Music
{
final class MusicClass
{
	string g_szMusicPeaceName = "";
	string g_szMusicMediumName = "";
	string g_szMusicTensionName = "";

	private int iMaxVolume = 10;
	private bool bStartOn = true;

	bool bMediumOn = false, bPeaceOn = false, bTensionOn = false, bTensionMusic = false, bTensionDouble = false;
	bool bDeleteAmbientMusic = false;

	private int iTensionTime = 0;
	private float flTensionTime = 0.0f;

	CScheduledFunction@ g_pThink = null;

	void ClearTimer()
	{
		if( g_pThink !is null )
		{
			g_Scheduler.RemoveTimer( g_pThink );
			@g_pThink = null;
		}
	}

	void Precache()
	{
		g_SoundSystem.PrecacheSound( g_szMusicPeaceName );
		g_Game.PrecacheGeneric( "sound/" + g_szMusicPeaceName );
		g_SoundSystem.PrecacheSound( g_szMusicMediumName );
		g_Game.PrecacheGeneric( "sound/" + g_szMusicMediumName );

		g_SoundSystem.PrecacheSound( g_szMusicTensionName );
		g_Game.PrecacheGeneric( "sound/" + g_szMusicTensionName );
	}

	void MapInit()
	{
		LoadMusicFile();
		Precache();

		g_Hooks.RegisterHook( Hooks::Game::MapChange, MapChangeHook( this.MapChange ) );

		CBaseEntity@ pEntity = null;
		if( !g_szMusicPeaceName.IsEmpty() )
		{
			bPeaceOn = true;
			
			dictionary keyvalues;
			keyvalues["targetname"] = "peace_music";
			keyvalues["message"] = g_szMusicPeaceName;
			keyvalues["volume"] = string(iMaxVolume);
			if( bStartOn )
				keyvalues["spawnflags"] = "2";
			else
				keyvalues["spawnflags"] = "3";
			@pEntity = g_EntityFuncs.CreateEntity( "ambient_music", keyvalues, true );
		}

		if( !g_szMusicMediumName.IsEmpty() )
		{
			dictionary keyvalues;
			keyvalues["targetname"] = "medium_music";
			keyvalues["message"] = g_szMusicMediumName;
			keyvalues["volume"] = string(iMaxVolume);
			keyvalues["spawnflags"] = "3";
			@pEntity = g_EntityFuncs.CreateEntity( "ambient_music", keyvalues, true );
		}

		if( !g_szMusicTensionName.IsEmpty() )
		{
			dictionary keyvalues;
			keyvalues["targetname"] = "tension_music";
			keyvalues["message"] = g_szMusicTensionName;
			keyvalues["volume"] = string(iMaxVolume);
			keyvalues["spawnflags"] = "3";
			@pEntity = g_EntityFuncs.CreateEntity( "ambient_music", keyvalues, true );

			bTensionMusic = true;
		}
	}

	void MapActivate()
	{
		ClearTimer();
		if( bStartOn )
			@g_pThink = g_Scheduler.SetInterval( @this, "Think", 0.3f );

		string szFileName = "scripts/maps/Configs/dynamic_music/"+g_Engine.mapname+".txt";
		File@ pFile = g_FileSystem.OpenFile( szFileName, OpenFile::READ );

		if( pFile is null || !pFile.IsOpen() )
			return;

		string szLine;

		while( !pFile.EOFReached() )
		{
			pFile.ReadLine( szLine );

			if( szLine.IsEmpty() || szLine.SubString(0,1) == "#" || szLine.IsEmpty() )
				continue;

			if( szLine.Find("Delete All Other Music: ") == 0)
			{
				string szDeleteAmbientMusic = szLine.SubString( 24 );

				if( szDeleteAmbientMusic.opEquals("True") || szDeleteAmbientMusic.opEquals("Yes") || szDeleteAmbientMusic.opEquals("1") )
					bDeleteAmbientMusic = true;
				else if( szDeleteAmbientMusic.opEquals("False") || szDeleteAmbientMusic.opEquals("No") || szDeleteAmbientMusic.opEquals("0") )
					bDeleteAmbientMusic = false;

				if( bDeleteAmbientMusic )
				{
					CBaseEntity@ pEntity = null;
					while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "ambient_music")) !is null )
					{
						if( pEntity.GetTargetname() != "peace_music" && pEntity.GetTargetname() != "medium_music" && pEntity.GetTargetname() != "tension_music" )
						{
							g_EntityFuncs.Remove( pEntity );
						}
					}
				}
			}
		}

		pFile.Close();
	}

	void Think()
	{
		CBaseEntity@ pEntity = null;
		CBaseMonster@ pMonster = null;
		bool bFound = false;
		while( (@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "monster_*")) !is null )
		{
			@pMonster = cast<CBaseMonster@>( pEntity );

			if( !pMonster.IsAlive() )
				continue;

			if( pMonster.m_hEnemy.IsValid() )
			{
				if( pMonster.m_hEnemy.GetEntity().IsPlayer() )
				{
					bFound = true;
				}
			}
		}

		@pEntity = null;

		if( bFound )
		{
			if( bPeaceOn )
			{
				while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "peace_music" ) ) !is null )
				{
					pEntity.Use( null, null, USE_OFF, 0 );
					bPeaceOn = false;
				}
			}

			if( bTensionOn )
			{
				while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "tension_music" ) ) !is null )
				{
					pEntity.Use( null, null, USE_OFF, 0 );
					bTensionOn = false;
				}
			}

			while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "medium_music" ) ) !is null )
			{
				if( string(pEntity.pev.message).IsEmpty() )
					continue;

				if( !bMediumOn )
				{
					pEntity.Use( null, null, USE_ON, 0 );

					bPeaceOn = false;
					bTensionOn = false;
					bMediumOn = true;
				}
			}
		}
		else
		{
			if( bMediumOn )
			{
				while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "medium_music" ) ) !is null )
				{
					pEntity.Use( null, null, USE_OFF, 0 );
					bPeaceOn = false;
					bMediumOn = false;

					if( bTensionMusic )
					{
						if( !bTensionOn )
						{
							while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "tension_music" ) ) !is null )
							{
								pEntity.Use( null, null, USE_ON, 0 );
								bTensionOn = true;

								if( bTensionDouble && Math.RandomLong(0,99) >= 75 )
								{
									flTensionTime = g_Engine.time;
									flTensionTime += atof( iTensionTime ) * 2;
								}
								else
								{
									flTensionTime = g_Engine.time + atof( iTensionTime );
								}
							}
						}
					}
				}
			}

			if( bTensionMusic )
			{
				if( flTensionTime > g_Engine.time )
					return;
			}

			if( bTensionOn )
			{
				while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "tension_music" ) ) !is null )
				{
					pEntity.Use( null, null, USE_OFF, 0 );
					bTensionOn = false;
				}
			}

			while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "peace_music" ) ) !is null )
			{
				if ( string(pEntity.pev.message).IsEmpty() )
					continue;

				if( !bPeaceOn )
				{
					pEntity.Use( null, null, USE_ON, 0 );

					bMediumOn = false;
					bTensionOn = false;
					bPeaceOn = true;
				}
			}
		}
	}

	void LoadMusicFile()
	{
		string szFileName = "scripts/maps/Configs/dynamic_music/"+g_Engine.mapname+".txt";
		File@ pFile = g_FileSystem.OpenFile( szFileName, OpenFile::READ );

		if( pFile is null || !pFile.IsOpen() )
			return;

		string szLine;

		while( !pFile.EOFReached() )
		{
			pFile.ReadLine( szLine );

			if( szLine.IsEmpty() || szLine.SubString(0,1) == "#" || szLine.IsEmpty() )
				continue;

			if( g_szMusicPeaceName.IsEmpty() )
			{
				if( szLine.Find("Peace: ") == 0)
				{
					g_szMusicPeaceName = szLine.SubString( 7 );
				}
			}

			if( g_szMusicMediumName.IsEmpty() )
			{
				if( szLine.Find("Medium: ") == 0)
				{
					g_szMusicMediumName = szLine.SubString( 8 );
				}
			}

			if( g_szMusicTensionName.IsEmpty() )
			{
				if( szLine.Find("Tension: ") == 0)
				{
					g_szMusicTensionName = szLine.SubString( 9 );
				}
			}

			if( szLine.Find("Volume: ") == 0)
			{
				iMaxVolume = atoi( szLine.SubString( 8 ) );
			}

			if( szLine.Find("Start On: ") == 0)
			{
				string szStartOn = szLine.SubString( 10 );

				if( szStartOn.opEquals("True") || szStartOn.opEquals("Yes") || szStartOn.opEquals("1") )
					bStartOn = true;
				else if( szStartOn.opEquals("False") || szStartOn.opEquals("No") || szStartOn.opEquals("0") )
					bStartOn = false;
			}

			if( szLine.Find("Tension time: ") == 0)
			{
				iTensionTime = atoi( szLine.SubString( 14 ) );
			}

			if( szLine.Find("Tension double: ") == 0)
			{
				string szTensionDouble = szLine.SubString( 16 );

				if( szTensionDouble.opEquals("True") || szTensionDouble.opEquals("Yes") || szTensionDouble.opEquals("1") )
					bTensionDouble = true;
			}
		}

		pFile.Close();
	}

	HookReturnCode MapChange()
	{
		ClearTimer();
		return HOOK_CONTINUE;
	}

	void Activate()
	{
		CBaseEntity@ pEntity = null;
		while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "peace_music" ) ) !is null )
		{
			pEntity.Use( null, null, USE_OFF, 0 );
			bPeaceOn = false;
		}

		@g_pThink = g_Scheduler.SetInterval( @this, "Think", 0.3f );
	}
} // end of class
} // end of namespace

void ActivateMusic(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_DynamicMusic.Activate();
}