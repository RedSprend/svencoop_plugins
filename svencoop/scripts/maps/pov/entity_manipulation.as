array<string> chargerValuesStr;

void ManipulateEntities()
{
	string strMap = g_Engine.mapname;
	CBaseEntity@ pWorld = g_EntityFuncs.Instance( 0 );

	for( int i = 0; i < g_Engine.maxEntities; ++i )
	{
		CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );

		if( pEntity is null )
			continue;

		/*if( pEntity.pev.classname == "item_battery" || pEntity.pev.classname == "item_healthkit" )
		{
			g_EntityFuncs.Remove( pEntity );
			continue;
		}*/

		if( pEntity.pev.classname == "func_recharge" || pEntity.pev.classname == "func_healthcharger" )
		{
			chargerValuesStr.insertLast(pEntity.pev.model);
			chargerValuesStr.insertLast(pEntity.pev.classname);
			string aStr = "" + pEntity.pev.origin.x + " " + pEntity.pev.origin.y + " " + pEntity.pev.origin.z;
			chargerValuesStr.insertLast(aStr);
			aStr = "" + pEntity.pev.angles.x + " " + pEntity.pev.angles.y + " " + pEntity.pev.angles.z;
			chargerValuesStr.insertLast(aStr);
			
			g_EntityFuncs.Remove( pEntity );
			continue;
		}
	}

	g_Scheduler.SetTimeout( "ManipulateEntities2", 0.1f );
}

void ManipulateEntities2()
{
	for( uint i = 0; i < chargerValuesStr.size(); i += 4 )
	{
		dictionary keyvalues =
		{
			{ "model", chargerValuesStr[i] },
			{ "origin", chargerValuesStr[i+2] },
			{ "angles", chargerValuesStr[i+3] },
			{ "CustomRechargeTime", "86400" },
			{ "CustomJuice", "1" }
		};
		g_EntityFuncs.CreateEntity( chargerValuesStr[i+1], keyvalues, true );
	}

	chargerValuesStr.resize(0);
}