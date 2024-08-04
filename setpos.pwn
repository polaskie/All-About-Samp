CMD:setpos(playerid, params[])
{
	if(pData[playerid][pAdmin] < 1) return SendClientMessage(playerid, -1, "You not authorized use this command");
	new str[250], Float:xpos, Float:ypos, Float:zpos;
	if (sscanf(params, "p<,>fff", xpos,ypos,zpos)) return 1;

	SetPlayerPos(playerid, xpos,ypos,zpos);
	format(str, sizeof(str), "position %f,%f,%f", xpos,ypos,zpos);
	SendClientMessage(playerid, -1, str);
	return 1;
}

👤:how to use?
/setpos 239.863067, 109.675773, 1005.075012//cordinate
