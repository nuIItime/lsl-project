string notecardName = "!uuids";

integer ichannel = 07899;
integer cur_page = 1;
integer chanhandlr;
integer num;

key userUUID;

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
integer slist_size = num;
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
llDialog(userUUID,"result "+(string)num+"\n\n"+
llDumpList2String(snlist, "\n"),order_buttons(dbuf + ["<<<", "[ main ]", ">>>"]),ichannel);
}
list make_list(integer a,integer b) 
{
  list inventory; integer i;
  for(i = 0; i < b; ++i)
  {
  list items = llParseString2List(llLinksetDataRead("temp-"+(string)(a+i)),["|"],[]);
  string name = llDeleteSubString(llList2String(items,0),40,1000);
  if(name == notecardName){inventory += "null";}else{inventory += llDeleteSubString(name,40,1000);}
  }return inventory;
}
dialog0()
{
if (!num){llMessageLinked(LINK_THIS, 0,"main", ""); llRegionSayTo(userUUID,0,"Could not find anything");return;}
ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, ""); dialog_songmenu(cur_page);
}
match(string a,string b){if(~llSubStringIndex(llToLower(b),llToLower(a))){llLinksetDataWrite("temp-"+(string)num,b); num = num + 1;}}
search_engine(string search)
{
num=0;
llLinksetDataDeleteFound("temp-","");
integer x;
integer y0 = (integer)llLinksetDataRead("uuid");
integer y1 = llGetInventoryNumber(INVENTORY_SOUND);
integer y2 = llGetInventoryNumber(INVENTORY_NOTECARD);
for( ; x < y0; x += 1){match(search,llLinksetDataRead("m-"+(string)x));} x=0;
for( ; x < y1; x += 1){match(search,llGetInventoryName(INVENTORY_SOUND,x));} x=0;
for( ; x < y2; x += 1){match(search,llGetInventoryName(INVENTORY_NOTECARD,x));} x=0;
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
    llLinksetDataDeleteFound("temp-","");
    }
    listen(integer chan, string sname, key skey, string text)
    {
    if(skey == userUUID) 
    {
        llMessageLinked(LINK_THIS,0,"menu_in_use",""); 
        if(text == "[ main ]"){llMessageLinked(LINK_THIS, 0,"main", "");}
        else if(text == ">>>") dialog_songmenu(cur_page+1);
        else if(text == "<<<") dialog_songmenu(cur_page-1);
        else if(llToLower(llGetSubString(text,0,5)) == "play #")
        {
        string a = llLinksetDataRead("temp-"+llGetSubString(text,6,-1));            
        if(a == notecardName){ }else{llMessageLinked(LINK_THIS, 0,"Search="+a,"");}
        dialog0();
    } } }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    list item = llParseString2List(msg,["="],[]);
    if("search_engine"==llList2String(item,0)){ userUUID = llList2String(item,2); cur_page = 1;search_engine(llList2String(item,1));dialog0();}
    if(msg == "owner_ride"){userUUID = llGetOwner(); return;}
    if(msg == "[ reset ]"){llResetScript();}
    if(msg == "exit_out"){userUUID = "";}    
  } }
