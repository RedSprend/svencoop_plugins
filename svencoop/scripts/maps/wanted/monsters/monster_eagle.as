namespace HLWanted_Eagle
{
array<string> g_Sounds =
{
	"wanted/eagle/eagle_alert1.wav",
	"wanted/eagle/eagle_alert2.wav",
	"wanted/eagle/eagle_idle1.wav",
	"wanted/eagle/eagle_idle2.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/eagle.mdl" );

	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}
}

} // end of HLWanted_Eagle namespace