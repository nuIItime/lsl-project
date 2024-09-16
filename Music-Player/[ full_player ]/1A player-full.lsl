string music_selection = "none";
string music_song = "none";
string default_radius = "0";
string default_volume = "1";
string default_mode = "0";
integer arrow_play_sound = FALSE;
integer play_sound = FALSE;
integer menu = TRUE;
integer notecard_music = 0;
integer ichannel = 07899;
integer cur_page = 1;
integer chanhandlr;
integer counter;
integer c = 80;

startup()
{
llStopSound(); llRequestPermissions(llGetOwner(),PERMISSION_TAKE_CONTROLS);
llOwnerSay("/"+(string)c+" "+"menu");
llListen(c,"",llGetOwner(),"");
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
string play_mode(){if(llLinksetDataRead("a") == "1"){return"auto";}else{return"loop";}}
get_inventory(){if (llGetInventoryKey(music_selection)==NULL_KEY){llOwnerSay(music_selection+"|"+music_song);}else{llGiveInventory(llGetOwner(),music_selection);}}
string play_sound_0(){if(music_selection == "none"){return"[  ◼  ]";}if(play_sound == FALSE){return"[  ▶  ]";}else{return"[  ⏸  ]";}}
dialog_topmenu()
{ 
list a =llGetLinkPrimitiveParams(2,[PRIM_DESC]);
list items = llParseString2List(llGetObjectDesc(),["="],[]);
llDialog(llGetOwner(),"main"+"\n"+"\n"+
"Playing = "+music_selection+"\n"+
"Sound Radius = "+(string)llDeleteSubString(check_output((float)llLinksetDataRead("r")),4,300)+"\n"+
"Volume = "+(string)llDeleteSubString(check_output((float)llLinksetDataRead("v")),4,300)+"\n"+
"Mode = "+play_mode()+"\n"
,["[ ⚙ setting ]","[  🔀  ]","[ 🛠️️ option ]","[  ⏪  ]",play_sound_0(),"[  ⏩  ]","[  🞪  ]","[  ♫  ]","[  ⭮  ]"],ichannel);
}
dialog_option()
{ 
llDialog(llGetOwner(),"option"+"\n"+"\n"+"Music = "+music_selection+"\n",["[ 📁 get ]","[ ⟳ reset ]","[ main ]","[  🞪  ]","[ "+play_mode()+" ]"],ichannel);
}
dialog_songmenu(integer page)
{
integer slist_size = llGetInventoryNumber(INVENTORY_NOTECARD);
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
llDialog(llGetOwner(),"music selection\n\n"+llDumpList2String(snlist, "\n"),order_buttons(dbuf + ["<<<","[ main ]", ">>>"]),ichannel);
}
list make_list(integer a,integer b) 
{
list inventory;
integer i;
for (i = 0; i < b; ++i){string name = llGetInventoryName(INVENTORY_NOTECARD,a+i);inventory += llDeleteSubString(name,40,1000);}
return inventory;
}
dialog0()
{
ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, ""); dialog_topmenu();
}
search_music(string search)
{
integer Lengthx = llGetInventoryNumber(INVENTORY_NOTECARD); integer x;
for ( ; x < Lengthx; x += 1)
{
string A = llToLower(search); string B = llToLower(llGetInventoryName(INVENTORY_NOTECARD, x));
integer search_found = ~llSubStringIndex(B,A);
if (search_found)
{
integer Division= x / 9 ; llOwnerSay("[ "+llGetInventoryName(INVENTORY_NOTECARD,x)+" ] [ page = "+(string)(Division+1)+" list = "+(string)x+" ]");
dialog_songmenu(Division+1);  
return;
}}llOwnerSay("Could not find anything");}
string check_output(float A){if(.01<=A){return(string)A;}return"OFF";}
option_topmenu()
{
integer music_list = llGetInventoryNumber(INVENTORY_NOTECARD);   
integer page=(music_list / 9) + 1 ;
llTextBox(llGetOwner(),
"\n"+"[ Status ]"+"\n\n"+
"Memory = "+(string)llLinksetDataAvailable()+"\n"+
"Sound Radius = "+(string)llDeleteSubString(check_output((float)llLinksetDataRead("r")),4,300)+"\n"+
"Volume = "+(string)llDeleteSubString(check_output((float)llLinksetDataRead("v")),4,300)+"\n"+
"Musics = "+(string)music_list+"\n\n"+
"[ Command Format ]"+"\n\n"+
"Search > ( s/music )"+"\n"+
"Volume > ( v/0.5 )"+"\n"+
"Radius > ( r/0 )"+"\n",ichannel);
}
arrow_music()
{
  if(arrow_play_sound == TRUE){counter = counter + 1;}else{counter = counter - 1;}
  if(-1>=counter){counter = llGetInventoryNumber(INVENTORY_NOTECARD)-1;}if((counter)>llGetInventoryNumber(INVENTORY_NOTECARD)-1){counter = 0;}else
  {
  music_selection = llGetInventoryName(INVENTORY_NOTECARD,counter);
  music_song = llGetInventoryName(INVENTORY_NOTECARD,counter);
  playmusic(); cur_page = (counter/9)+1; return;
  }
  music_selection = llGetInventoryName(INVENTORY_NOTECARD,0);
  music_song = llGetInventoryName(INVENTORY_NOTECARD,0);
  playmusic(); cur_page = (counter/9)+1; return;
}
playmusic()
{
  if(play_sound == TRUE)
  {
  llMessageLinked(LINK_THIS, 0,"fetch_note_rationed|" + music_selection,NULL_KEY);
} }
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
    startup();
    }
    run_time_permissions(integer perm)
    {
    if(PERMISSION_TAKE_CONTROLS & perm){llTakeControls( CONTROL_BACK|CONTROL_FWD, TRUE, TRUE );}
    }
    touch_start(integer total_number)
    {
    if(llDetectedKey(0) == llGetOwner()){dialog0();}
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    if(msg == "[autoplay]"){play_sound = TRUE;arrow_play_sound = FALSE;arrow_music();}
    }
    listen(integer chan, string sname, key skey, string text)
    {  
    list items0 = llParseString2List(text, ["/"], []);
    if(skey == llGetOwner()) 
    { 
      if(chan == c){if (text == "menu"){dialog0();}} 
      if(text == "[  ◼  ]"){dialog_topmenu();}
      if(text == "[ main ]"){dialog_topmenu();}
      if(text == "[ 📁 get ]"){get_inventory();}
      if(text == "[ 🛠️️ option ]"){dialog_option();}
      if(text == "[ ⚙ setting ]"){option_topmenu();}
      if(text == "[  ♫  ]"){dialog_songmenu(cur_page);}
      if(text == "[  ⭮  ]"){llStopSound();playmusic();dialog_topmenu();}
      if(text == "[  ⏩  ]"){play_sound = TRUE;arrow_play_sound = TRUE;arrow_music();dialog_topmenu();}
      if(text == "[  ⏪  ]"){play_sound = TRUE;arrow_play_sound = FALSE;arrow_music();dialog_topmenu();}
      if(text == "[  ▶  ]"){play_sound = TRUE; llMessageLinked(LINK_THIS, 0,"[ Play ]",""); dialog_topmenu();}
      if(text == "[  ⏸  ]"){play_sound = FALSE; llMessageLinked(LINK_THIS, 0,"[ Pause ]",""); dialog_topmenu();}
      if(text == "[ auto ]"){llLinksetDataDelete("a");llLinksetDataWrite("a","0"); dialog_option();}
      if(text == "[ loop ]"){llLinksetDataDelete("a");llLinksetDataWrite("a","1"); dialog_option();}
      if((string)llList2String(items0,0) == "s"){search_music(llList2String(items0,1));}
      if((string)llList2String(items0,0) == "v")
      {
      llLinksetDataDelete("v");llLinksetDataWrite("v",llDeleteSubString((string)llList2Float(items0,1),10,300));
      llAdjustSoundVolume(llList2Float(items0,1)); 
      dialog_topmenu();
      }
      if((string)llList2String(items0,0) == "r")
      {
      llLinksetDataDelete("r");llLinksetDataWrite("r",llDeleteSubString((string)llList2Float(items0,1),10,300));
      llLinkSetSoundRadius(LINK_THIS,llList2Float(items0,1)); 
      dialog_topmenu();
      }
      if(text == "[  🔀  ]")
      {
      play_sound = TRUE;
      integer x = llFloor(llFrand(llGetInventoryNumber(INVENTORY_NOTECARD)));
      music_selection = llGetInventoryName(INVENTORY_NOTECARD,x);
      music_song = llGetInventoryName(INVENTORY_NOTECARD,x);
      counter = x; playmusic(); dialog_topmenu();
      cur_page = (x/9)+1;
      }
      if(text == "[ ⟳ reset ]")
      {
      llLinksetDataReset();llLinksetDataWrite("a",default_mode);llLinksetDataWrite("r",default_radius);llLinksetDataWrite("v",default_volume); 
      music_song = "none"; music_selection = "none"; cur_page = 1; llStopSound(); llSleep(0.2); dialog_topmenu();
      play_sound = FALSE; menu = FALSE; llMessageLinked(LINK_THIS, 0,"[ Reset ]",NULL_KEY);
      }
      else if(text == ">>>") dialog_songmenu(cur_page+1);
      else if(text == "<<<") dialog_songmenu(cur_page-1);
      else if(llToLower(llGetSubString(text,0,5)) == "play #")
      {
      play_sound = TRUE; integer pnum = (integer)llGetSubString(text, 6, -1); counter = pnum;
      music_selection = llGetInventoryName(INVENTORY_NOTECARD,pnum);
      music_song = llGetInventoryName(INVENTORY_NOTECARD,pnum);
      dialog_songmenu(cur_page);
      playmusic();
} } } }
