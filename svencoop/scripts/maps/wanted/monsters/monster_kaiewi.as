namespace HLWanted_Kaiewi
{
void Precache()
{
	g_Game.PrecacheModel( "models/wanted/kaiewi.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/kaiewi01.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/kaiewi02.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/kaiewi03.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/kaiewiT.mdl" );

/*	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}*/
}

} // end of HLWanted_Kaiewi namespace