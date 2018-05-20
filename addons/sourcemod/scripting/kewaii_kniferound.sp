/* [CS:GO] Knife Round
 *
 *  Copyright (C) 2018 Miguel 'Kewaii' Viegas
 * 
 * All Rights reserved
 */
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_TAG "{blue}[{pink}KnifeRound{blue}]{green}"
#define NAME "Knife Round"
#define AUTHOR "Kewaii"
#define DESC "Automatic & Manual knife rounds "
#define VERSION "0.0.3"

ConVar g_bAllowedFlags, g_iTimesPerMap;

bool isKnifeRound = false;
int knifeRounds = 0;
public Plugin myinfo = 
{
	name = NAME,
	author = AUTHOR,
	description = DESC,
	version = VERSION,
	url = "https://steamcommunity.com/id/KewaiiGamer"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_kniferound", Command_KnifeRound);
	g_bAllowedFlags = CreateConVar("kewaii_kniferound_allowedflags", "b", "Allowed flags to start a Knife Round or a vote for it", _, true, 0.0, true, 1.0);
	g_iTimesPerMap = CreateConVar("kewaii_kniferound_maxtimespermmap", "0", "Max amount of times a knife round can occur. 0 for unlimited", _, true, 0.0, false);
	AutoExecConfig(true, "kewaii_kniferound");
}

public Action Command_KnifeRound(int client, int args) {
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}
	char allowedFlags[16];
	GetConVarString(g_bAllowedFlags, allowedFlags, sizeof(allowedFlags));
	for (int i = 0; i < strlen(allowedFlags); i++) {
		if (HasClientFlag(client, allowedFlags[i])) {
			continue;
		}
	}
	int maxKnifeRounds = GetConVarInt(g_iTimesPerMap);
	if (knifeRounds == maxKnifeRounds && maxKnifeRounds != 0) {
		return Plugin_Handled;		
	}
	ScheduleKnifeRound();
	return Plugin_Handled;
}

void ScheduleKnifeRound() {
	isKnifeRound = true;
}

public void OnMapStart() {	
	knifeRounds = 0;
	isKnifeRound = false;
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (isKnifeRound) {
		CreateTimer(0.5, Timer_KnifeRound, _);
		isKnifeRound = false;
		knifeRounds++;
	}
}


public Action Timer_KnifeRound(Handle timer, any data) {
	StripAllPlayers();
}

public void StripAllPlayers() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i)) {	
			StripAllWeapons(i);
		}
	}
}
public void StripAllWeapons(int client) {
	int wp;
	for (int i = 0; i < 5; i++) {
		wp = GetPlayerWeaponSlot(client, i);
		if (i != 2) {
			if(IsValidEntity(wp)) {
				RemovePlayerItem(client, wp);
			}
		}
	}
}
	
bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!IsPlayerAlive(client) && !bAllowDead))
	{
		return false;
	}
	return true;
}

public bool HasClientFlag(int client, char[] flagLetter)
{
	int flag = ReadFlagString(flagLetter);
	return CheckCommandAccess(client, "", flag, true);	
}