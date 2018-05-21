/* [CS:GO] Knife Round
 *
 *  Copyright (C) 2018 Miguel 'Kewaii' Viegas
 * 
 * All Rights reserved
 */
#include <sdktools>
#include <kewlib>
#include <csgocolors>
#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_TAG "{blue}[{pink}KnifeRound{blue}]{green}"
#define NAME "Knife Round"
#define AUTHOR "Kewaii"
#define DESC "Automatic & Manual knife rounds "
#define VERSION "0.0.3"

ConVar g_bAllowedFlags, g_iTimesPerMap;

bool isKnifeRound = false;
bool knifeRoundScheduled = false;
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
	LoadTranslations("kewaii_kniferound.phrases");
	RegConsoleCmd("sm_kniferound", Command_KnifeRound);
	g_bAllowedFlags = CreateConVar("kewaii_kniferound_allowedflags", "b", "Allowed flags to start a Knife Round or a vote for it", _, true, 0.0, true, 1.0);
	g_iTimesPerMap = CreateConVar("kewaii_kniferound_maxtimespermmap", "0", "Max amount of times a knife round can occur. 0 for unlimited", _, true, 0.0, false);
	AutoExecConfig(true, "kewaii_kniferound");
	HookEvent("round_start", OnRoundStart);
	HookEvent("item_pickup", OnWeaponPickup);
	SetDefaultValues();
}

public Action OnWeaponPickup(Event event, const char[] name, bool dontBroadcast)
{
	if (isKnifeRound) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));	
		StripAllWeapons(client);
	}
}

public Action Command_KnifeRound(int client, int args) {
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}
	char allowedFlags[16];
	GetConVarString(g_bAllowedFlags, allowedFlags, sizeof(allowedFlags));
	if (!HasClientFlag(client, allowedFlags)) {
		return Plugin_Handled;
	}
	int maxKnifeRounds = GetConVarInt(g_iTimesPerMap);
	if (knifeRounds == maxKnifeRounds && maxKnifeRounds != 0) {
		return Plugin_Handled;		
	}
	ScheduleKnifeRound();
	return Plugin_Handled;
}

void ScheduleKnifeRound() {
	knifeRoundScheduled = true;
	CPrintToChatAll("%s %t", PLUGIN_TAG, "KnifeRound Scheduled");
}

public void OnMapStart() {
	SetDefaultValues();
}

public void SetDefaultValues() {
	knifeRounds = 0;
	isKnifeRound = false;
	knifeRoundScheduled = false;
}
	
public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast) {	
	if (isKnifeRound) {
		isKnifeRound = false;
	}
	if (knifeRoundScheduled) {
		CreateTimer(0.5, Timer_KnifeRound, _);
		knifeRoundScheduled = false;
		isKnifeRound = true;
		knifeRounds++;
		CPrintToChatAll("%s %t", PLUGIN_TAG, "KnifeRound Started");
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
	