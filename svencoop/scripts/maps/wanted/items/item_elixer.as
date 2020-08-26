namespace HLWanted_Elixer
{
class item_elixer : ScriptBasePlayerItemEntity
{
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		return BaseClass.KeyValue( szKey, szValue );
	}

	/*bool AddToPlayer( CBasePlayer@ pPlayer ) // hud.txt is not customizable
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;

		NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
			message.WriteLong( g_ItemRegistry.GetIdForName( GetElixerName() ) );
		message.End();

		return true;
	}*/

	void Precache()
	{
		BaseClass.Precache();

		//g_Game.PrecacheModel( "sprites/wanted/320hud2.spr" ); // hud.txt is not customizable

		g_Game.PrecacheModel( "models/wanted/medicine.mdl" );

		g_SoundSystem.PrecacheSound( "wanted/items/medicine.wav" ); // cache
		g_Game.PrecacheGeneric( "sound/wanted/items/medicine.wav" ); // client has to download
	}

	void Spawn()
	{
		Precache();

		g_EntityFuncs.SetModel( self, "models/wanted/medicine.mdl" );

		BaseClass.Spawn();
	}

	void Touch( CBaseEntity@ pOther )
	{
		if( pOther is null || !pOther.IsPlayer() || !pOther.IsAlive() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );
		int iMaxHealth = int(pPlayer.pev.max_health);

		if( pPlayer.pev.health < iMaxHealth )
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
				//message.WriteString( GetElixerName() ); // hud.txt is not customizable
				message.WriteString( "item_healthkit" );
			message.End();

			g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, "wanted/items/medicine.wav", 1.0f, ATTN_NORM );

			pPlayer.m_bitsDamageType &= ~DMG_TIMEBASED;

			float juice = g_EngineFuncs.CVarGetFloat( "sk_healthkit" );
			float juice2 = juice - (pPlayer.pev.max_health - pPlayer.pev.health);

			pPlayer.TakeHealth( juice, DMG_GENERIC );

			if( juice2 > 0.0f )
			{
				int iGive = int(ceil(juice2));
				pPlayer.GiveAmmo( iGive, "health", iMaxHealth );
			}

			if( ( self.pev.spawnflags & SF_NORESPAWN ) != 0 )
			{
				self.Respawn();
			}
			else
			{
				g_EntityFuncs.Remove( self );
			}
		}
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		Touch( pActivator );
	}
}

string GetElixerName()
{
	return "item_elixer";
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Elixer::item_elixer", GetElixerName() );
	g_ItemRegistry.RegisterItem( GetElixerName(), "" );
}

} //namespace HLWanted_Elixer END