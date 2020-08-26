namespace HLWanted_Cowboy
{
array<string> g_Sounds =
{
	"wanted/cowboy/cocanthere.wav",
	"wanted/cowboy/co_die1.wav",
	"wanted/cowboy/co_die2.wav",
	"wanted/cowboy/co_die3.wav",
	"wanted/cowboy/co_pain1.wav",
	"wanted/cowboy/co_pain2.wav",
	"wanted/cowboy/co_pain3.wav",
	"wanted/cowboy/co_pain4.wav",
	"wanted/cowboy/co_pain5.wav",
	"wanted/cowboy/olanniefake.wav",
	"wanted/cowboy/olawhell.wav",
	"wanted/cowboy/olcantseeem.wav",
	"wanted/cowboy/olcantseenothin.wav",
	"wanted/cowboy/olcatch.wav",
	"wanted/cowboy/olchicken.wav",
	"wanted/cowboy/olcomeonout.wav",
	"wanted/cowboy/olcomeout.wav",
	"wanted/cowboy/olcoverme.wav",
	"wanted/cowboy/oldamn.wav",
	"wanted/cowboy/oldelivery.wav",
	"wanted/cowboy/oldust.wav",
	"wanted/cowboy/oldynamite.wav",
	"wanted/cowboy/oleyesopen.wav",
	"wanted/cowboy/olfart.wav",
	"wanted/cowboy/olfoundhim.wav",
	"wanted/cowboy/olfoundtrouble.wav",
	"wanted/cowboy/olgetback.wav",
	"wanted/cowboy/olgetdown.wav",
	"wanted/cowboy/olgetthesherriff.wav",
	"wanted/cowboy/olhellnoone.wav",
	"wanted/cowboy/olheybill.wav",
	"wanted/cowboy/olheysee.wav",
	"wanted/cowboy/olheyseethat.wav",
	"wanted/cowboy/olhideallday.wav",
	"wanted/cowboy/olholdon.wav",
	"wanted/cowboy/olidontsee.wav",
	"wanted/cowboy/oligothim.wav",
	"wanted/cowboy/oliseehim.wav",
	"wanted/cowboy/olitsthesherriff.wav",
	"wanted/cowboy/oljeezus.wav",
	"wanted/cowboy/oljustacactus.wav",
	"wanted/cowboy/olkeepdown.wav",
	"wanted/cowboy/ollookiehere.wav",
	"wanted/cowboy/ollookinferyou.wav",
	"wanted/cowboy/ollookout.wav",
	"wanted/cowboy/ollookoutt.wav",
	"wanted/cowboy/olmeneither.wav",
	"wanted/cowboy/olmoveit.wav",
	"wanted/cowboy/olnooneheren.wav",
	"wanted/cowboy/olnope.wav",
	"wanted/cowboy/olnosign.wav",
	"wanted/cowboy/olnothinhere.wav",
	"wanted/cowboy/olok.wav",
	"wanted/cowboy/oloutofammo.wav",
	"wanted/cowboy/olpassgelly.wav",
	"wanted/cowboy/olpassrifle.wav",
	"wanted/cowboy/olpoppasaid.wav",
	"wanted/cowboy/olredeye.wav",
	"wanted/cowboy/olroundback.wav",
	"wanted/cowboy/olrunferit.wav",
	"wanted/cowboy/olrunhide.wav",
	"wanted/cowboy/olseeanythin.wav",
	"wanted/cowboy/olseehim.wav",
	"wanted/cowboy/olseenothinhere.wav",
	"wanted/cowboy/olsharpeye.wav",
	"wanted/cowboy/olshit.wav",
	"wanted/cowboy/olshitno.wav",
	"wanted/cowboy/olshitseenoone.wav",
	"wanted/cowboy/olshoothim.wav",
	"wanted/cowboy/olshussh.wav",
	"wanted/cowboy/olsixin.wav",
	"wanted/cowboy/olsmelllawman.wav",
	"wanted/cowboy/olsnakes.wav",
	"wanted/cowboy/olstayontoes.wav",
	"wanted/cowboy/olstillwithme.wav",
	"wanted/cowboy/olstoodin.wav",
	"wanted/cowboy/olsurethang.wav",
	"wanted/cowboy/oltakethis.wav",
	"wanted/cowboy/olthereheis.wav",
	"wanted/cowboy/oltrythison.wav",
	"wanted/cowboy/oluponrock.wav",
	"wanted/cowboy/olusehelp.wav",
	"wanted/cowboy/olvisitor.wav",
	"wanted/cowboy/olwatchbacks.wav",
	"wanted/cowboy/olwhat.wav",
	"wanted/cowboy/olyesiree.wav",
	"wanted/cowboy/olyewaw.wav",
	"wanted/cowboy/olyouincharge.wav",
	"wanted/cowboy/olyoustayhere.wav",
	"wanted/cowboy/olyup.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/Cowboy.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/Cowboy01.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/Cowboy02.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/Cowboy03.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/Cowboyt.mdl" );

	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}
}

} // end of HLWanted_Cowboy namespace