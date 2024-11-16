string notecardName = "!uuids";
integer arrow_play_sound = FALSE;
integer ichannel = 07899;
integer cur_page = 1;
integer notecardLine;
integer chanhandlr;
integer counter;
integer music;
key notecardQueryId;
key notecardKey;
key userUUID;

startup()
{
llLinksetDataDeleteFound("m-","");ReadNotecard();
}
ReadNotecard()
{
    if (llGetInventoryKey(notecardName) == NULL_KEY)
    {
    llOwnerSay( "Notecard '" + notecardName + "' missing or unwritten.");
    return;
    }
    else if (llGetInventoryKey(notecardName) == notecardKey) return;
    notecardKey = llGetInventoryKey(notecardName);
    notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
}
list order_buttons(list buttons)
{
return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
list numerizelist(list tlist, integer start, string apnd)
{
list newlist; integer lsize = llGetListLength(tlist); integer i;
for(; i < lsize; i++)
{
newlist += [(string)(start + i) + apnd + llList2String(tlist, i)];
}return newlist;}
dialog_songmenu(integer page)
{
integer slist_size = music;
integer pag_amt = llCeil((float)slist_size / 9.0);
if(page > pag_amt) page = 1;
else if(page < 1) page = pag_amt;
cur_page = page; integer songsonpage;
if(page == pag_amt)
songsonpage = slist_size % 9;
if(songsonpage == 0)
songsonpage = 9; integer fspnum = (page*9)-9; list dbuf; integer i;
for(; i < songsonpage; ++i)
{
dbuf += ["Play #" + (string)(fspnum+i)];
}
list snlist = numerizelist(make_list(fspnum,i), fspnum, ". ");
llDialog(userUUID,"music selection"+"\n\n"+
llDumpList2String(snlist, "\n"),order_buttons(dbuf + ["<<<", "[  ♫  ]", ">>>"]),ichannel);
}
list make_list(integer a,integer b) 
{
  list inventory; integer i;
  for(i = 0; i < b; ++i)
  {
  list items = llParseString2List(llLinksetDataRead("m-"+(string)(a+i)),["|"],[]);
  inventory += llDeleteSubString(llList2String(items,0),40,1000);
  }return inventory;
}
dialog0()
{
ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, ""); dialog_songmenu(cur_page);
}
arrow_music()
{
  if(arrow_play_sound == TRUE){counter = counter + 1;}else{counter = counter - 1;}
  if(-1>=counter){counter = (music-1);}if((counter)>(music-1)){counter = 0;}else
  {
  llMessageLinked(LINK_THIS, 0,"notecard="+llLinksetDataRead("m-"+(string)counter)+"=menu",""); cur_page = (counter/9)+1; return;
  }
  llMessageLinked(LINK_THIS, 0,"notecard="+llLinksetDataRead("m-0")+"=menu",""); cur_page = (counter/9)+1; return;
}
default 
{
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    changed(integer change)
    {
    if(change & CHANGED_INVENTORY){llResetScript();}
    }
    state_entry() 
    {
    startup();
    }
    listen(integer chan, string sname, key skey, string text)
    {  
    if(skey == userUUID) 
    {
        llMessageLinked(LINK_THIS,0,"menu_in_use",""); 
        if(text == "[  ♫  ]"){llMessageLinked(LINK_THIS, 0,"type", "");}
        else if(text == ">>>") dialog_songmenu(cur_page+1);
        else if(text == "<<<") dialog_songmenu(cur_page-1);
        else if(llToLower(llGetSubString(text,0,5)) == "play #")
        {
        integer pnum = (integer)llGetSubString(text,6,-1);
        llMessageLinked(LINK_THIS, 0,"notecard="+llLinksetDataRead("m-"+(string)pnum),"");
        dialog0();
    } } }
    link_message(integer sender_num, integer num, string msg, key id)
    {
      list items = llParseString2List(msg,["="],[]); 
      if(llList2String(items,0) == "notecard_uuid"){userUUID = llList2String(items,1); dialog0();}
      if(msg == "owner_ride"){userUUID = llGetOwner(); return;}
      if(msg == "⏪"){arrow_play_sound = FALSE;arrow_music();}
      if(msg == "exit_out"){userUUID = "";}
      if(msg == "⏩"){arrow_play_sound = TRUE;arrow_music();}
      if(msg == "🔀")
      {
      integer x = llFloor(llFrand(music)); counter = x; cur_page = (x/9)+1;   
      llMessageLinked(LINK_THIS, 0,"notecard="+llLinksetDataRead("m-"+(string)x),"");
      llMessageLinked(LINK_THIS, 0,"main", "");
      } 
      list x = llParseString2List(msg, ["="], []);
      if(llList2String(x, 0) == "Search")
      {
      list A = llParseString2List(llList2String(x,1), ["|"], []);
      if (llGetInventoryType(llList2String(A,0))==INVENTORY_NONE){ counter = (integer)llList2String(A,1); cur_page = ((integer)llList2String(A,2)/9)+1; return;}
      }
    }
    dataserver(key query_id, string data)
    {
        if (query_id == notecardQueryId)
        {
            if (data == EOF){llLinksetDataWrite("uuid",(string)music);}else
            {
            if (data == ""){ }else{llLinksetDataWrite("m-"+(string)music,data); music = music + 1;}
            ++notecardLine; notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
            }
        }
    }
}
