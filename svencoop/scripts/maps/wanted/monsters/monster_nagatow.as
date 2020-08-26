namespace HLWanted_Nagatow
{
array<string> g_Sounds =
{
	"wanted/nagatow/niatemother.wav",
	"wanted/nagatow/nibeatone.wav",
	"wanted/nagatow/nibeswift.wav",
	"wanted/nagatow/nibrave.wav",
	"wanted/nagatow/nidamnchooks.wav",
	"wanted/nagatow/nieagle.wav",
	"wanted/nagatow/niforicecream.wav",
	"wanted/nagatow/niguardme.wav",
	"wanted/nagatow/niheadband.wav",
	"wanted/nagatow/nihewillknow.wav",
	"wanted/nagatow/niibelieve.wav",
	"wanted/nagatow/niiscream.wav",
	"wanted/nagatow/niitis.wav",
	"wanted/nagatow/niitisso.wav",
	"wanted/nagatow/niitwasso.wav",
	"wanted/nagatow/niiwill.wav",
	"wanted/nagatow/nijoindead.wav",
	"wanted/nagatow/nimedicine.wav",
	"wanted/nagatow/nimoon.wav",
	"wanted/nagatow/ninewcloth.wav",
	"wanted/nagatow/nino.wav",
	"wanted/nagatow/ninosquaws.wav",
	"wanted/nagatow/ninotgood.wav",
	"wanted/nagatow/niok.wav",
	"wanted/nagatow/niooww.wav",
	"wanted/nagatow/niow.wav",
	"wanted/nagatow/nipaleface.wav",
	"wanted/nagatow/nipeacefull.wav",
	"wanted/nagatow/nirace.wav",
	"wanted/nagatow/niscream5.wav",
	"wanted/nagatow/niscream6.wav",
	"wanted/nagatow/niscript0.wav",
	"wanted/nagatow/niscript1.wav",
	"wanted/nagatow/niscript2.wav",
	"wanted/nagatow/nismell.wav",
	"wanted/nagatow/nisoontime.wav",
	"wanted/nagatow/nispirits.wav",
	"wanted/nagatow/nistarbright.wav",
	"wanted/nagatow/nistarman.wav",
	"wanted/nagatow/nistarstrue.wav",
	"wanted/nagatow/nisunfall.wav",
	"wanted/nagatow/nisunleaves.wav",
	"wanted/nagatow/nithewind.wav",
	"wanted/nagatow/nitruepath.wav",
	"wanted/nagatow/niwardance.wav",
	"wanted/nagatow/niweallscream.wav",
	"wanted/nagatow/niwhisky.wav",
	"wanted/nagatow/niyourwish.wav",
	"wanted/nagatow/niyouscream.wav",
	"wanted/nagatow/pain1.wav",
	"wanted/nagatow/pain2.wav",
	"wanted/nagatow/pain3.wav",
	"wanted/nagatow/pain4.wav",
	"wanted/nagatow/pain5.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/nagatow.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow01.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow02.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow03.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow04.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow05.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow06.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatow07.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/nagatowt.mdl" );

	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}
}

} // end of HLWanted_Nagatow namespace