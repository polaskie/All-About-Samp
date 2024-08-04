#include <a_samp>
#include <a_mysql>
#include <crashdetect>
#include <foreach>
#include <zcmd>
#include <sscanf2>
#include <streamer>

#define MYSQL_HOST    "127.0.0.1"
#define MYSQL_USER    "root"
#define MYSQL_PASS    ""
#define MYSQL_DBSE    "testsamp"

new MySQL:g_SQL; 

enum
{
	DIALOG_REGISTER,
	DIALOG_LOGIN,
}

enum PlayerInfo
{
	pID,
	bool:IsLoggedIn,
	pName[MAX_PLAYER_NAME],
	Float:pHealth,Float:pArmour,
	Float:pPosX,Float:pPosY,Float:pPosZ,Float:pAngle,
	pVW,pInt,
	pSkin,
	pLevel,
	pMoney,
	pAdmin
}
new PlayerData[MAX_PLAYERS][PlayerInfo];

main()
{
	print("\n----------------------------------");
	print(" MySQL");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("MySQL");
	MySQL_SetupConnection();

	return 1;
}

public OnGameModeExit()
{
	mysql_close(g_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	enumreset(playerid);
	GetName(playerid);
	return 1;
}

public OnPlayerRequestClass(playerid)
{
	if(!PlayerData[playerid][IsLoggedIn])
	{
		new query[128];
		mysql_format(g_SQL, query, sizeof(query), "SELECT id FROM players WHERE name = '%e'", PlayerData[playerid][pName]);
		mysql_pquery(g_SQL, query, "CheckPlayer", "d", playerid);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(!PlayerData[playerid][IsLoggedIn])
	{
		SendClientMessage(playerid, -1, "{FF0000}You need to login first!");
		return 0;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
	{
		if(!response) return Kick(playerid);

		if(strlen(inputtext) < 3) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "Enter password for register:\n{FF0000}Minim 3 word!", "Enter", "Cancel");

		new query[256];
		mysql_format(g_SQL, query, sizeof(query), "INSERT INTO players (name, password) VALUES ('%e', MD5('%e'))", PlayerData[playerid][pName], inputtext);

		mysql_pquery(g_SQL, query, "RegisterPlayer", "d", playerid);
		return 1;
	}
	if(dialogid == DIALOG_LOGIN)
	{
		if(!response) return Kick(playerid);

		if(strlen(inputtext) < 3) return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Enter password for login to account:\n{FF0000}Minim 3 word!", "Enter", "Cancel");

		new query[256];
		mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM players WHERE name = '%e' AND password = MD5('%e')", PlayerData[playerid][pName], inputtext);

		mysql_pquery(g_SQL, query, "LoginPlayer", "d", playerid);
		return 1;
	}
	return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
	{
		SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
		SetPlayerArmour(playerid, PlayerData[playerid][pArmour]);
		SetPlayerSkin(playerid, PlayerData[playerid][pSkin]);
	}
	PlayerSave(playerid);
	return 1;
}

forward CheckPlayer(playerid);
public CheckPlayer(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"Register", "Enter password for register:", "Enter", "Cancel");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login", "Enter password for login to account:", "Enter", "Cancel");
	}
	return 1;
}

forward RegisterPlayer(playerid);
public RegisterPlayer(playerid)
{
	PlayerData[playerid][pID] = cache_insert_id();
	PlayerData[playerid][IsLoggedIn]  = true;

	SetSpawnInfo(playerid, 0, 98, 1682.6084, -2327.8940, 13.5469, 3.4335, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}

forward LoginPlayer(playerid);
public LoginPlayer(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Enter password for login to account:\n{FF0000}Wrong password!", "Enter", "Cancel");
	}
	else
	{
 		cache_get_value_name_int(0, "id", PlayerData[playerid][pID]);
 		cache_get_value_name_float(0, "health", PlayerData[playerid][pHealth]);
 		cache_get_value_name_float(0, "armour", PlayerData[playerid][pArmour]);
 		cache_get_value_name_float(0, "posx", PlayerData[playerid][pPosX]);
 		cache_get_value_name_float(0, "posy", PlayerData[playerid][pPosY]);
 		cache_get_value_name_float(0, "posz", PlayerData[playerid][pPosZ]);
 		cache_get_value_name_float(0, "angel", PlayerData[playerid][pAngle]);
		cache_get_value_name_int(0, "interior", PlayerData[playerid][pInt]);
		cache_get_value_name_int(0, "virtualworld", PlayerData[playerid][pVW]);
		cache_get_value_name_int(0, "skin", PlayerData[playerid][pSkin]);
		cache_get_value_name_int(0, "level", PlayerData[playerid][pLevel]);
		cache_get_value_name_int(0, "money", PlayerData[playerid][pMoney]);
		cache_get_value_name_int(0, "admin", PlayerData[playerid][pAdmin]);
		PlayerData[playerid][IsLoggedIn]  = true;

		SetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
		SetPlayerArmour(playerid, PlayerData[playerid][pArmour]);
		GivePlayerMoney(playerid, PlayerData[playerid][pMoney]);
		SetSpawnInfo(playerid, -1, PlayerData[playerid][pSkin], PlayerData[playerid][pPosX], PlayerData[playerid][pPosY], PlayerData[playerid][pPosZ], PlayerData[playerid][pAngle], -1, -1, -1, -1, -1, -1);
		SpawnPlayer(playerid);
		SetPlayerInterior(playerid, PlayerData[playerid][pInt]);
		SetPlayerVirtualWorld(playerid, PlayerData[playerid][pVW]);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

stock PlayerSave(playerid)
{
	if(!PlayerData[playerid][IsLoggedIn]) return 1;

	GetPlayerHealth(playerid, PlayerData[playerid][pHealth]);
	GetPlayerArmour(playerid, PlayerData[playerid][pArmour]);
	GetPlayerPos(playerid, PlayerData[playerid][pPosX], PlayerData[playerid][pPosY], PlayerData[playerid][pPosZ]);
	GetPlayerFacingAngle(playerid, PlayerData[playerid][pAngle]);
	PlayerData[playerid][pMoney] = GetPlayerMoney(playerid);	
	PlayerData[playerid][pInt] 	= GetPlayerInterior(playerid);
	PlayerData[playerid][pVW] 	= GetPlayerVirtualWorld(playerid);
	PlayerData[playerid][pSkin]	= GetPlayerSkin(playerid);

	new query[500];
	mysql_format(g_SQL, query, sizeof(query), "UPDATE players SET health = '%f', armour = '%f', posx = '%f', posy = '%f', posz = '%f', angel = '%f', interior = '%d', virtualworld = '%d', skin = '%d', level = '%d', money = '%d' WHERE id = '%d'",
		PlayerData[playerid][pHealth], PlayerData[playerid][pArmour], 
		PlayerData[playerid][pPosX], PlayerData[playerid][pPosY], PlayerData[playerid][pPosZ], PlayerData[playerid][pAngle],
		PlayerData[playerid][pInt], PlayerData[playerid][pVW], PlayerData[playerid][pSkin],
		PlayerData[playerid][pLevel], PlayerData[playerid][pMoney],
		PlayerData[playerid][pID]);

	mysql_pquery(g_SQL, query);
	return 1;
}

stock MySQL_SetupConnection(ttl = 3)
{
	print("[MySQL] Connecting to database...");

	g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DBSE);

	if(mysql_errno(g_SQL) != 0)
	{
		if(ttl > 1)
		{
			print("[MySQL] Connect to database fail.");
			printf("[MySQL] Try more (TTL: %d).", ttl-1);
			return MySQL_SetupConnection(ttl-1);
		}
		else
		{
			print("[MySQL] Connecting to database fail.");
			print("[MySQL] Check MySQL login information.");
			print("[MySQL] Shutdown Server");
			return SendRconCommand("exit");
		}
	}
	printf("[MySQL] Connecting to database succes! Total: %d", _:g_SQL);
	return 1;
}

stock GetName(playerid)
{
	GetPlayerName(playerid, PlayerData[playerid][pName], MAX_PLAYER_NAME);
	return PlayerData[playerid][pName];
}

enumreset(playerid)
{
	PlayerData[playerid][pID]       = 0;
	PlayerData[playerid][IsLoggedIn]  = false;
	PlayerData[playerid][pLevel]     = 0;
	PlayerData[playerid][pMoney]     = 0;
	PlayerData[playerid][pInt] 		= 0;
	PlayerData[playerid][pVW] 		= 0;
	PlayerData[playerid][pSkin]		= 0;
	PlayerData[playerid][pAdmin] = 0;
}
