namespace HLWanted_MexBandit
{
array<string> g_Sounds =
{
	"wanted/mexbandit/mballclear.wav",
	"wanted/mexbandit/mbayee.wav",
	"wanted/mexbandit/mbayeee.wav",
	"wanted/mexbandit/mbayeeeee.wav",
	"wanted/mexbandit/mbbetterfarm.wav",
	"wanted/mexbandit/mbbigtrouble.wav",
	"wanted/mexbandit/mbcactusdrt.wav",
	"wanted/mexbandit/mbcanthide.wav",
	"wanted/mexbandit/mbcantsee.wav",
	"wanted/mexbandit/mbchiko.wav",
	"wanted/mexbandit/mbcoverme.wav",
	"wanted/mexbandit/mbdynrun.wav",
	"wanted/mexbandit/mbeyesopen.wav",
	"wanted/mexbandit/mbfightornot.wav",
	"wanted/mexbandit/mbforyou.wav",
	"wanted/mexbandit/mbgetaway.wav",
	"wanted/mexbandit/mbgetdown.wav",
	"wanted/mexbandit/mbgethim.wav",
	"wanted/mexbandit/mbgetsherrif.wav",
	"wanted/mexbandit/mbghost.wav",
	"wanted/mexbandit/mbgiveup.wav",
	"wanted/mexbandit/mbhavntseen.wav",
	"wanted/mexbandit/mbhereicome.wav",
	"wanted/mexbandit/mbheyamigos.wav",
	"wanted/mexbandit/mbhiding.wav",
	"wanted/mexbandit/mbiseehim.wav",
	"wanted/mexbandit/mbiseenothing.wav",
	"wanted/mexbandit/mbiseeyou.wav",
	"wanted/mexbandit/mbiseeyous.wav",
	"wanted/mexbandit/mbitsgringo.wav",
	"wanted/mexbandit/mbkeepdown.wav",
	"wanted/mexbandit/mblazy.wav",
	"wanted/mexbandit/mblookout.wav",
	"wanted/mexbandit/mblookout2.wav",
	"wanted/mexbandit/mbmanorchook.wav",
	"wanted/mexbandit/mbmissmaria.wav",
	"wanted/mexbandit/mbmotherburo.wav",
	"wanted/mexbandit/mbnonebutus.wav",
	"wanted/mexbandit/mbnope.wav",
	"wanted/mexbandit/mbnosign.wav",
	"wanted/mexbandit/mbnosign2.wav",
	"wanted/mexbandit/mbnothinhere.wav",
	"wanted/mexbandit/mbnotime.wav",
	"wanted/mexbandit/mbohno.wav",
	"wanted/mexbandit/mbok.wav",
	"wanted/mexbandit/mbokok.wav",
	"wanted/mexbandit/mbotherside.wav",
	"wanted/mexbandit/mboverhere.wav",
	"wanted/mexbandit/mbpassmatch.wav",
	"wanted/mexbandit/mbpedrosee.wav",
	"wanted/mexbandit/mbpresent.wav",
	"wanted/mexbandit/mbquiet.wav",
	"wanted/mexbandit/mbrun.wav",
	"wanted/mexbandit/mbrun2.wav",
	"wanted/mexbandit/mbrunaway.wav",
	"wanted/mexbandit/mbrustleout.wav",
	"wanted/mexbandit/mbsantadwn.wav",
	"wanted/mexbandit/mbsantam.wav",
	"wanted/mexbandit/mbscorpions.wav",
	"wanted/mexbandit/mbshit.wav",
	"wanted/mexbandit/mbshitno.wav",
	"wanted/mexbandit/mbshootkill.wav",
	"wanted/mexbandit/mbshutup.wav",
	"wanted/mexbandit/mbsi.wav",
	"wanted/mexbandit/mbsickfood.wav",
	"wanted/mexbandit/mbsnakesdung.wav",
	"wanted/mexbandit/mbstaydown.wav",
	"wanted/mexbandit/mbstayput.wav",
	"wanted/mexbandit/mbstopshout.wav",
	"wanted/mexbandit/mbsurething.wav",
	"wanted/mexbandit/mbtakecover.wav",
	"wanted/mexbandit/mbtakethis.wav",
	"wanted/mexbandit/mbtakethis2.wav",
	"wanted/mexbandit/mbtherehe.wav",
	"wanted/mexbandit/mbtiredbynow.wav",
	"wanted/mexbandit/mbtombstone.wav",
	"wanted/mexbandit/mbwantcorn.wav",
	"wanted/mexbandit/mbwellhiden.wav",
	"wanted/mexbandit/mbwheredyn.wav",
	"wanted/mexbandit/mbwind.wav",
	"wanted/mexbandit/mbyes.wav",
	"wanted/mexbandit/mb_die1.wav",
	"wanted/mexbandit/mb_die2.wav",
	"wanted/mexbandit/mb_die3.wav",
	"wanted/mexbandit/mb_pain1.wav",
	"wanted/mexbandit/mb_pain2.wav",
	"wanted/mexbandit/mb_pain3.wav",
	"wanted/mexbandit/mb_pain4.wav",
	"wanted/mexbandit/mb_pain5.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/bandit_mex.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/bandit_mex01.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/bandit_mex02.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/bandit_mex03.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/bandit_mext.mdl" );

	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}
}

} // end of HLWanted_MexBandit namespace