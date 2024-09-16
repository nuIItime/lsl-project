string notecardName = "!whitelist";
integer distant_limit = 30;
integer only_once = TRUE;
integer notecardLine;
key notecardQueryId;
key notecardKey;
key userUUID;
list whitelist;

ReadNotecard()
{
  if(only_once == TRUE) 
  {
  if (llGetInventoryKey(notecardName) == NULL_KEY)
  {
  only_once = TRUE; llOwnerSay("Notecard '" + notecardName + "' missing or unwritten."); return;
  }
  else if (llGetInventoryKey(notecardName) == notecardKey) return;
  notecardKey = llGetInventoryKey(notecardName); notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
  }
}
default
{
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    changed(integer change)
    {
    if (change & CHANGED_INVENTORY){llResetScript();}
    }
    state_entry()
    {
    if(only_once == TRUE){ReadNotecard();}
    llSetLinkTextureAnim(2, ANIM_ON | LOOP, 2, 3, 6, 0, 64, 6.4 );
    }  
    touch_start(integer total_number)
    {
    if(only_once == FALSE) 
    {
      key ID = llDetectedKey(0); vector pos=llList2Vector(llGetObjectDetails(ID,[OBJECT_POS]),0); float dist=llVecDist(pos,llGetPos()); 
      if(dist>distant_limit){return;}else
      {
      if(~llListFindList(whitelist,[(string)ID])){userUUID = ID; state menu_selection;}
      if(llDetectedKey(0) == llGetOwner()){userUUID = ID; state menu_selection;}
    }}}
    dataserver(key query_id, string data)
    {
    if (query_id == notecardQueryId){if (data == EOF)
    {
       only_once = FALSE;
       }else{
       list params = llParseString2List(data, ["="], []);
       if((key)llList2String(params,0))
       {     
       whitelist += llList2String(params,0); ++notecardLine;
       notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
       }else{
       ++notecardLine;    
       notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
  }}}}}
  state menu_selection
  {
    on_rez(integer start_param) 
    {
    llResetScript();
    } 
    changed(integer change)
    {
    if (change & CHANGED_INVENTORY){llResetScript();}
    }
    state_entry()
    {    
    llMessageLinked(LINK_THIS, 0,(string)userUUID,"");
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    if(msg == "exit_out"){userUUID = ""; llSetTimerEvent(0); state default;}
    }
    touch_start(integer total_number)
    {
    key ID = llDetectedKey(0); vector pos=llList2Vector(llGetObjectDetails(ID,[OBJECT_POS]),0);float dist=llVecDist(pos,llGetPos()); 
    if(dist>distant_limit){return;}else
    {
      if(ID==userUUID)
      {
      llMessageLinked(LINK_THIS, 0,(string)userUUID,"");return;
      }
      if(ID==llGetOwner())
      {
      llRegionSayTo(userUUID,0,"owner_override");  
      llMessageLinked(LINK_THIS,0,"owner_ride",""); userUUID = ID;return;
   }}}}