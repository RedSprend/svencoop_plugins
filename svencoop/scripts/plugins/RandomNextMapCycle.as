void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Rick" );
	g_Module.ScriptInfo.SetContactInfo( "gameswitch.org" );
}

array<string> g_pMapName;
int g_iMapNums;
string g_szCurrentMap;

void MapActivate()
{
	g_iMapNums = 0;
	g_pMapName.resize( 0 );
	g_szCurrentMap = g_Engine.mapname;
}

void MapStart()
{
	RandomNextMapCycle();
}

bool RandomNextMapCycle()
{
	File@ pFile = g_FileSystem.OpenFile( "scripts/plugins/store/nextmapcycle.txt", OpenFile::READ );

	if( pFile is null || !pFile.IsOpen() )
	{
		g_EngineFuncs.ServerPrint("ERROR: scripts/plugins/store/nextmapcycle.txt failed to open\n");
		return true;
	}

	g_szCurrentMap.ToLowercase();
	string szLine;

	while( !pFile.EOFReached() )
	{
		pFile.ReadLine( szLine );
		szLine.Trim();

		if( szLine.Length() < 1 || szLine[0] == '/' && szLine[1] == '/' || szLine[0] == '#' || szLine[0] == ';' )
			continue;

		szLine.ToLowercase();

		if( g_szCurrentMap == szLine )
			continue;

		g_iMapNums++;
		g_pMapName.insertLast( szLine );
	}

	if( g_iMapNums > 0 )
	{
		execRandomNextMap();
	}

	pFile.Close();

	return false;
}

void execRandomNextMap()
{
	if ( g_pMapName.length() == 0 )
		return;

	// Random choose
	uint target = Math.RandomLong( 0, g_pMapName.length() - 1 );

	while ( g_pMapName[target] == g_szCurrentMap || !g_EngineFuncs.IsMapValid( g_pMapName[target] ) )
		target = Math.RandomLong( 0, g_pMapName.length() - 1 );

	g_EngineFuncs.ServerCommand( "mp_nextmap_cycle " + g_pMapName[target] + "\n" );
	g_EngineFuncs.ServerExecute();

	g_iMapNums = 0;
	g_pMapName.resize( 0 );
}