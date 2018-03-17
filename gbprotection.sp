#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.3"

public Plugin:myinfo =
{
    name = "GB-Protection",
    author = "Artlinedev.com",
    description = "Pervents multiple players to go on one player.",
    version = PLUGIN_VERSION,
	url = "http://artlinedev.com"
}

new clientProtected[66];
new Handle:GangTimer[66];
new RenderOffs;

public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath, EventHookMode:1);
	RenderOffs = FindSendPropOffs("CBasePlayer", "m_clrRender");
}

public Event_PlayerDeath(Handle:event, String:name[], bool:broadcast)
{
	new attackerId = GetEventInt(event, "attacker");
	new victimId = GetEventInt(event, "victim");
	new attacker = GetClientOfUserId(attackerId);
	new victim = GetClientOfUserId(victimId);
	if (victim != attacker)
	{
		SetEntProp(attacker, PropType:1, "m_takedamage", any:0, 1, 0);
		if (IsClientInGame(attacker))
		{
			clientProtected[attacker] = 0;
			CreateTimer(0.3, RemoveProtection, attacker, 0);
			CreateTimer(0.8, RemoveProtection2, attacker, 0);
			CreateTimer(0.1, ClearTimers, attacker, 0);
			if (GangTimer[victim])
			{
				KillTimer(GangTimer[victim], false);
				GangTimer[victim] = 0;
			}
			if (GetClientTeam(attacker) == 2)
			{
				set_rendering(attacker, FX:14, 244, 208, 111, Render:0, 255);
			}
			if (GetClientTeam(attacker) == 3)
			{
				set_rendering(attacker, FX:14, 135, 164, 232, Render:0, 255);
			}
		}
	}
	return 0;
}

public Action:RemoveProtection(Handle:timer, any:client)
{
	if (IsClientInGame(client) || !IsFakeClient(client))
	{
		GangTimer[client] = CreateTimer(0.9, RemoveRendering, client, 0);
	}
	return Action:0;
}

public Action:RemoveProtection2(Handle:timer, any:client)
{
	if (IsClientInGame(client) || !IsFakeClient(client))
	{
		clientProtected[client] = 1;
	}
	return Action:0;
}

public Action:RemoveRendering(Handle:timer, any:client)
{
	if (IsClientInGame(client) || !IsFakeClient(client) || clientProtected[client] == 1)
	{
		SetEntProp(client, PropType:1, "m_takedamage", any:2, 1, 0);
		set_rendering(client, FX:0, 255, 255, 255, Render:0, 255);
		GangTimer[client] = 0;
	}
	return Action:0;
}

public Action:ClearTimers(Handle:timer, any:client)
{
	if (IsClientInGame(client) || !IsFakeClient(client))
	{
		if (GangTimer[client])
		{
			KillTimer(GangTimer[client], false);
			GangTimer[client] = 0;
		}
	}
	return Action:0;
}

set_rendering(index, FX:fx, r, g, b, Render:render, amount)
{
	SetEntProp(index, PropType:0, "m_nRenderFX", fx, 1, 0);
	SetEntProp(index, PropType:0, "m_nRenderMode", render, 1, 0);
	SetEntData(index, RenderOffs, r, 1, true);
	SetEntData(index, RenderOffs + 1, g, 1, true);
	SetEntData(index, RenderOffs + 2, b, 1, true);
	SetEntData(index, RenderOffs + 3, amount, 1, true);
	return 0;
}
