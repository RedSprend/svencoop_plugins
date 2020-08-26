namespace HLWanted_DynDave
{
array<string> g_Sounds =
{
	"wanted/dyndave/ddaskpope.wav",
	"wanted/dyndave/ddbathmonth.wav",
	"wanted/dyndave/ddbathnight.wav",
	"wanted/dyndave/ddbegorrah.wav",
	"wanted/dyndave/ddblownit.wav",
	"wanted/dyndave/ddbuyrock.wav",
	"wanted/dyndave/ddcompany.wav",
	"wanted/dyndave/ddcouldbeso.wav",
	"wanted/dyndave/dddamnfuse.wav",
	"wanted/dyndave/dddontknow.wav",
	"wanted/dyndave/dddropofirish.wav",
	"wanted/dyndave/dddrythroat.wav",
	"wanted/dyndave/ddfershure.wav",
	"wanted/dyndave/ddfinished.wav",
	"wanted/dyndave/ddgash.wav",
	"wanted/dyndave/ddgaw.wav",
	"wanted/dyndave/ddgetback.wav",
	"wanted/dyndave/ddgiveago.wav",
	"wanted/dyndave/ddgrandday.wav",
	"wanted/dyndave/ddhowudoin.wav",
	"wanted/dyndave/ddillwait.wav",
	"wanted/dyndave/ddjesss.wav",
	"wanted/dyndave/ddkegblow.wav",
	"wanted/dyndave/ddlanigans.wav",
	"wanted/dyndave/ddlookout.wav",
	"wanted/dyndave/ddmajor.wav",
	"wanted/dyndave/ddminersweekly.wav",
	"wanted/dyndave/ddmother.wav",
	"wanted/dyndave/ddmothergod.wav",
	"wanted/dyndave/ddnevermind.wav",
	"wanted/dyndave/ddnoprob.wav",
	"wanted/dyndave/ddnotgoon.wav",
	"wanted/dyndave/ddnotneeded.wav",
	"wanted/dyndave/ddnotsure.wav",
	"wanted/dyndave/ddohgod.wav",
	"wanted/dyndave/ddohmy.wav",
	"wanted/dyndave/ddopenyet.wav",
	"wanted/dyndave/ddrailroad.wav",
	"wanted/dyndave/ddsaloon.wav",
	"wanted/dyndave/ddseeright.wav",
	"wanted/dyndave/ddshantmove.wav",
	"wanted/dyndave/ddshould.wav",
	"wanted/dyndave/ddsocks.wav",
	"wanted/dyndave/ddstare.wav",
	"wanted/dyndave/ddstartrun.wav",
	"wanted/dyndave/ddstaying.wav",
	"wanted/dyndave/ddthanks.wav",
	"wanted/dyndave/ddtomornin.wav",
	"wanted/dyndave/ddtoodrunk.wav",
	"wanted/dyndave/ddtoriver.wav",
	"wanted/dyndave/ddwelcome.wav",
	"wanted/dyndave/ddwhatdevil.wav",
	"wanted/dyndave/ddwithyou.wav",
	"wanted/dyndave/ddyouok.wav",
	"wanted/dyndave/ddyousure.wav",
	"wanted/dyndave/pain1.wav",
	"wanted/dyndave/pain2.wav",
	"wanted/dyndave/pain3.wav",
	"wanted/dyndave/pain4.wav",
	"wanted/dyndave/pain5.wav"
};

void Precache()
{
	g_Game.PrecacheModel( "models/wanted/dyndave.mdl" );
	g_Game.PrecacheGeneric( "models/wanted/dyndaveT.mdl" );

	for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
	{
		g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
		g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
	}
}

} // end of HLWanted_DynDave namespace