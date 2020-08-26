final class CTalkMonster
{
	int g_fMinerQuestion = 0; // true if an idle miner asked a question. Cleared when someone answers.

	float g_talkWaitTime = g_Engine.time;
}

CTalkMonster@ g_TalkMonster;

class CBaseCustomMonster : ScriptBaseMonsterEntity
{
	int SF_MONSTER_GAG = 2;
	int SF_MONSTER_FADECORPSE = 512;

	Vector VecCheckToss( edict_t@& in pEdict, const Vector& in vecSpot1, Vector vecSpot2, const float flGravityAdj = 1.0 )
	{
		TraceResult	tr;
		Vector		vecMidPoint;// halfway point between Spot1 and Spot2
		Vector		vecApex;// highest point 
		Vector		vecScale;
		Vector		vecGrenadeVel;
		Vector		vecTemp;
		//float flGravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" ) * flGravityAdj;
		float flGravity = 800.0f * flGravityAdj;

		if( vecSpot2.z - vecSpot1.z > 500 )
			return g_vecZero; // to high, fail

		g_EngineFuncs.MakeVectors(pev.angles);

		// toss a little bit to the left or right, not right down on the enemy's bean (head). 
		vecSpot2 = vecSpot2 + g_Engine.v_right * ( Math.RandomFloat(-8,8) + Math.RandomFloat(-16,16) );
		vecSpot2 = vecSpot2 + g_Engine.v_forward * ( Math.RandomFloat(-8,8) + Math.RandomFloat(-16,16) );

		// calculate the midpoint and apex of the 'triangle'
		// UNDONE: normalize any Z position differences between spot1 and spot2 so that triangle is always RIGHT

		// How much time does it take to get there?

		// get a rough idea of how high it can be thrown
		vecMidPoint = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5;
		g_Utility.TraceLine(vecMidPoint, vecMidPoint + Vector(0,0,500), ignore_monsters, self.edict(), tr);
		vecMidPoint = tr.vecEndPos;
		// (subtract 15 so the grenade doesn't hit the ceiling)
		vecMidPoint.z -= 15;

		if( vecMidPoint.z < vecSpot1.z || vecMidPoint.z < vecSpot2.z )
			return g_vecZero; // to not enough space, fail

		// How high should the grenade travel to reach the apex
		float distance1 = (vecMidPoint.z - vecSpot1.z);
		float distance2 = (vecMidPoint.z - vecSpot2.z);

		// How long will it take for the grenade to travel this distance
		float time1 = sqrt( distance1 / (0.5 * flGravity) );
		float time2 = sqrt( distance2 / (0.5 * flGravity) );

		if( time1 < 0.1 )
			return g_vecZero; // too close

		// how hard to throw sideways to get there in time.
		vecGrenadeVel = (vecSpot2 - vecSpot1) / (time1 + time2);
		// how hard upwards to reach the apex at the right time.
		vecGrenadeVel.z = flGravity * time1;

		// find the apex
		vecApex  = vecSpot1 + vecGrenadeVel * time1;
		vecApex.z = vecMidPoint.z;

		g_Utility.TraceLine(vecSpot1, vecApex, dont_ignore_monsters, self.edict(), tr);
		if (tr.flFraction != 1.0)
			return g_vecZero; // fail!

		// UNDONE: either ignore monsters or change it to not care if we hit our enemy
		g_Utility.TraceLine(vecSpot2, vecApex, ignore_monsters, self.edict(), tr); 
		if (tr.flFraction != 1.0)
			return g_vecZero; // fail!

		return vecGrenadeVel;
	}

	Vector VecCheckThrow( edict_t@& in pEdict, const Vector& in vecSpot1, Vector vecSpot2, const float flSpeed, const float flGravityAdj = 1.0 )
	{
		//float flGravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" ) * flGravityAdj;
		float flGravity = 800.0f * flGravityAdj;

		Vector vecGrenadeVel = (vecSpot2 - vecSpot1);

		// throw at a constant time
		float time = vecGrenadeVel.Length( ) / flSpeed;
		vecGrenadeVel = vecGrenadeVel * (1.0 / time);

		// adjust upward toss to compensate for gravity loss
		vecGrenadeVel.z += flGravity * time * 0.5;

		Vector vecApex = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5;
		vecApex.z += 0.5 * flGravity * (time * 0.5) * (time * 0.5);

		TraceResult tr;
		g_Utility.TraceLine(vecSpot1, vecApex, dont_ignore_monsters, pEdict, tr);
		if (tr.flFraction != 1.0)
				return g_vecZero; // fail!

		g_Utility.TraceLine(vecSpot2, vecApex, ignore_monsters, pEdict, tr);
		if (tr.flFraction != 1.0)
				return g_vecZero; // fail!

		return vecGrenadeVel;
	}
}