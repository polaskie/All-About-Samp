CMD:kick(playerid, params[])
{
    new targetid, reason[128];
  
    if(pData[playerid][pAdmin] < 1) return SendClientMessage(playerid, -1, "You not authorized use this command");
		
	if(sscanf(params, "us[128]", targetid, reason)) return SendClientMessage(playerid, -1, "/kick [playerid/name] [reason]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "player not valid!");
        
    new str[256];
    format(str, sizeof(str), "%s was kick from server with reason:%s", GetName(targetid), reason);
    SendClientMessageToAll(-1, str);
    KickEx(targetid);
	return 1;
}

KickEx(playerid, time = 500))
{
	SetTimerEx("KickPlayer", time, false, "i", playerid);
	return 1;
}

function KickPlayer(playerid)
{
	Kick(playerid);
	return 1;
}
