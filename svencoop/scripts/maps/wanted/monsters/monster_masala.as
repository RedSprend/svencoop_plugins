namespace HLWanted_Masala
{
array<string> g_Sounds =
{
	"wanted/masala/nbaagghh.wav",
	"wanted/masala/nbaahhh.wav",
	"wanted/masala/nbaayyee.wav",
	"wanted/masala/nbarrghh.wav",
	"wanted/masala/nbasktika.wav",
	"wanted/masala/nbcrazywoman.wav",
	"wanted/masala/nbcure.wav",
	"wanted/masala/nbcurse.wav",
	"wanted/masala/nbdanger.wav",
	"wanted/masala/nbdontscare.wav",
	"wanted/masala/nbdosomething.wav",
	"wanted/masala/nbeeerrr.wav",
	"wanted/masala/nbergg.wav",
	"wanted/masala/nbhappyan.wav",
	"wanted/masala/nbheal.wav",
	"wanted/masala/nbhellohat.wav",
	"wanted/masala/nbhey.wav",
	"wanted/masala/nbifollow.wav",
	"wanted/masala/nbillshowim.wav",
	"wanted/masala/nbinotgo.wav",
	"wanted/masala/nbiwaithere.wav",
	"wanted/masala/nbkinky.wav",
	"wanted/masala/nbloincloth.wav",
	"wanted/masala/nbno.wav",
	"wanted/masala/nbnosquaws.wav",
	"wanted/masala/nbok.wav",
	"wanted/masala/nbokiwait.wav",
	"wanted/masala/nboldshoes.wav",
	"wanted/masala/nboowwww.wav",
	"wanted/masala/nbouch.wav",
	"wanted/masala/nbpaleface.wav",
	"wanted/masala/nbprey.wav",
	"wanted/masala/nbprotectme.wav",
	"wanted/masala/nbquiet.wav",
	"wanted/masala/nbrun.wav",
	"wanted/masala/nbscript0.wav",
	"wanted/masala/nbscript1.wav",
	"wanted/masala/nbsoundpale.wav",
	"wanted/masala/nbspear.wav",
	"wanted/masala/nbtallhat.wav",
	"wanted/masala/nbthirsty.wav",
	"wanted/masala/nbthreelegs.wav",
	"wanted/masala/nbtooshort.wav",
	"wanted/masala/nbtotempole.wav",
	"wanted/masala/nbuhhuh.wav",
	"wanted/masala/nbummerrr.wav",
	"wanted/masala/nbwhiskey.wav",
	"wanted/masala/pain1.wav",
	"wanted/masala/pain2.wav",
	"wanted/masala/pain3.wav",
	"wanted/masala/pain4.wav",
	"wanted/masala/pain5.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/masala.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala01.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala02.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala03.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala04.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala05.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala06.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masala07.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/masalat.mdl" );

	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}
}

} // end of HLWanted_Masala namespace