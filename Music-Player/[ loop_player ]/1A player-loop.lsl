list type_mode = ["[  ◩  ]","[  ◪  ]"];
string default_radius = "0";
string default_volume = "1";
string music_selection = "none";
string music_song = "none";
integer arrow_play_sound = FALSE;
integer play_sound = FALSE;
integer ichannel = 07899;
integer sound_type = 0;
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
get_inventory(){if (llGetInventoryKey(music_selection)==NULL_KEY){llOwnerSay(music_selection+"|"+music_song);}else{llGiveInventory(llGetOwner(),music_selection);}}
string play_sound_0(){if(music_selection == "none"){return"[  ◼  ]";}if(play_sound == FALSE){return"[  ▶  ]";}else{return"[  ⏸  ]";}}
string sound_type_1(integer a){if(a == 0){return"[  ◩  ]";}if(a == 1){return"[  ◪  ]";}return"null";}
string sound_type_0(integer a){if(a == 0){return"sound";}if(a == 1){return"uuid";}return"null";}
type_option(){llDialog(llGetOwner(),"type",["[ sound ]","[ main ]","[ uuid ]","[  🞪  ]"],ichannel);}
dialog_topmenu()
{
list a =llGetLinkPrimitiveParams(2,[PRIM_DESC]);
llDialog(llGetOwner(),"main"+"\n"+"\n"+
"Playing = "+music_selection+"\n"+
"Sound Type = "+sound_type_0(sound_type)+"\n"+
"Sound Radius = "+(string)llDeleteSubString(check_output((float)llLinksetDataRead("r")),4,300)+"\n"+
"Volume = "+(string)llDeleteSubString(check_output((float)llLinksetDataRead("v")),4,300)+"\n"
,["[ ⚙ setting ]","[  🔀  ]","[ 🛠️️ option ]","[  ⏪  ]",play_sound_0(),"[  ⏩  ]","[  🞪  ]","[  ♫  ]",sound_type_1(sound_type)],ichannel);
}
dialog_option()
{
  if(sound_type == 0)
  {
  llDialog(llGetOwner(),"option"+"\n"+"\n"+"Uuid = "+(string)llGetInventoryKey(music_song)+"\n"+"Music = "+music_selection+"\n",["[ 📁 get ]","[ ⟳ reset ]","[ main ]"],ichannel);
  }else{  
  llDialog(llGetOwner(),"option"+"\n"+"\n"+"Uuid = "+music_song+"\n"+"Music = "+music_selection+"\n",["[ 📁 get ]","[ ⟳ reset ]","[ main ]"],ichannel);
  } 
}
dialog_songmenu(integer page)
{
integer slist_size = llGetInventoryNumber(INVENTORY_SOUND);
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
llDialog(llGetOwner(),"music selection\n\n"+llDumpList2String(snlist, "\n"),order_buttons(dbuf + ["<<<","[  ♫  ]", ">>>"]),ichannel);
}
list make_list(integer a,integer b) 
{
list inventory;
integer i;
for (i = 0; i < b; ++i){string name = llGetInventoryName(INVENTORY_SOUND,a+i);inventory += llDeleteSubString(name,40,1000);}
return inventory;
}
dialog0()
{
ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, ""); dialog_topmenu();
}
search_music(string search)
{
integer Lengthx = llGetInventoryNumber(INVENTORY_SOUND); integer x;
for ( ; x < Lengthx; x += 1)
{
string A = llToLower(search); string B = llToLower(llGetInventoryName(INVENTORY_SOUND, x));
integer search_found = ~llSubStringIndex(B,A);
if (search_found)
{
integer Division= x / 9 ; llOwnerSay("[ "+llGetInventoryName(INVENTORY_SOUND,x)+" ] [ page = "+(string)(Division+1)+" list = "+(string)x+" ]");
dialog_songmenu(Division+1);  
return;
}}llMessageLinked(LINK_THIS, 0,"search="+search,NULL_KEY);}
string check_output(float A){if(.01<=A){return(string)A;}return"OFF";}
option_topmenu()
{
list a=llGetLinkPrimitiveParams(2,[PRIM_DESC]);
integer music_list = llGetInventoryNumber(INVENTORY_SOUND)+(llLinksetDataCountKeys()-2);   
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
  if(-1>=counter){counter = llGetInventoryNumber(INVENTORY_SOUND)-1;}if((counter)>llGetInventoryNumber(INVENTORY_SOUND)-1){counter = 0;}else
  {
  music_selection = llGetInventoryName(INVENTORY_SOUND,counter);
  music_song = llGetInventoryName(INVENTORY_SOUND,counter);
  playmusic(); cur_page = (counter/9)+1; return;
  }
  music_selection = llGetInventoryName(INVENTORY_SOUND,0);
  music_song = llGetInventoryName(INVENTORY_SOUND,0);
  playmusic(); cur_page = (counter/9)+1; return;
}
playmusic()
{
if(play_sound == TRUE)
{
    llLinkSetSoundRadius(LINK_THIS,(float)llLinksetDataRead("r"));
    if(sound_type == 0)
    {
    llLoopSound(music_song,(float)llLinksetDataRead("v"));
    }else{
    if((key)music_song){llLoopSound(music_song,(float)llLinksetDataRead("v"));}else{llOwnerSay("error invalid [ " +music_song+" ]");}
    }
  }llOwnerSay(" Playing [ " +music_selection+" ]");
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
    run_time_permissions(integer perm)
    {
    if(PERMISSION_TAKE_CONTROLS & perm){llTakeControls( CONTROL_BACK|CONTROL_FWD, TRUE, TRUE );}
    }
    state_entry()
    {
    startup();
    }
    touch_start(integer total_number)
    {
    if(llDetectedKey(0) == llGetOwner()){dialog0();}
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
      if(msg == "type"){type_option();}
      if(msg == "main"){dialog_topmenu();}
      list items0 = llParseString2List(msg, ["="], []);
      if((string)llList2String(items0,0) == "notecard")
      {
      sound_type = 1; play_sound = TRUE;    
      list items1 = llParseString2List(llList2String(items0,1), ["|"], []);  
      music_selection = llList2String(items1,0); music_song = llList2String(items1,1); 
      playmusic(); if((string)llList2String(items0,2) == "menu"){dialog_topmenu();}
    } }
    listen(integer chan, string sname, key skey, string text)
    {
    list items0 = llParseString2List(text, ["/"], []);
    if(skey == llGetOwner()) 
    { 
      if(chan == c){if (text == "menu"){dialog0();}}
      if(text == "[  ♫  ]"){type_option();}
      if(text == "[  ◼  ]"){dialog_topmenu();}
      if(text == "[ main ]"){dialog_topmenu();}
      if(text == "[ 📁 get ]"){get_inventory();}
      if(text == "[ 🛠️️ option ]"){dialog_option();}
      if(text == "[ ⚙ setting ]"){option_topmenu();}
      if(text == "[ sound ]"){dialog_songmenu(cur_page);}
      if(text == "[  ▶  ]"){play_sound = TRUE; playmusic();dialog_topmenu();}
      if(text == "[  ⏸  ]"){play_sound = FALSE; llStopSound();dialog_topmenu();}
      if(text == "[ uuid ]"){llMessageLinked(LINK_THIS, 0,"notecard_uuid","");}
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
      if (~llListFindList(type_mode,[text])) 
      {
      if(sound_type == 0){sound_type = 1;dialog_topmenu();return;}
      if(sound_type == 1){sound_type = 0;dialog_topmenu();return;}
      }
      if(text == "[  ⏩  ]")
      {
        if(sound_type == 0)
        {
        sound_type = 0; play_sound = TRUE;arrow_play_sound = TRUE;arrow_music();dialog_topmenu();
        }else{
        sound_type = 1; llMessageLinked(LINK_THIS, 0,"⏩","");
      } }
      if(text == "[  ⏪  ]")
      {
        if(sound_type == 0)
        {   
        sound_type = 0; play_sound = TRUE;arrow_play_sound = FALSE;arrow_music();dialog_topmenu();
        }else{
        sound_type = 1; llMessageLinked(LINK_THIS, 0,"⏪","");
      } }
      if(text == "[  🔀  ]")
      {
        if(sound_type == 0)
        {
        sound_type = 0; play_sound = TRUE;
        integer x = llFloor(llFrand(llGetInventoryNumber(INVENTORY_SOUND)));
        music_selection = llGetInventoryName(INVENTORY_SOUND,x);
        music_song = llGetInventoryName(INVENTORY_SOUND,x);
        counter = x; playmusic(); dialog_topmenu();
        cur_page = (x/9)+1;
        }else{
        sound_type = 1; llMessageLinked(LINK_THIS, 0,"🔀","");
      } }
      if(text == "[ ⟳ reset ]")
      {
      llLinksetDataReset();llLinksetDataWrite("r",default_radius);llLinksetDataWrite("v",default_volume);play_sound = FALSE; sound_type = 0; 
      music_song = "none"; music_selection = "none"; cur_page = 1; llStopSound(); llSleep(0.2); dialog_topmenu();llMessageLinked(LINK_THIS, 0,"[ reset ]","");
      }
      else if(text == ">>>") dialog_songmenu(cur_page+1);
      else if(text == "<<<") dialog_songmenu(cur_page-1);
      else if(llToLower(llGetSubString(text,0,5)) == "play #")
      {
      sound_type = 0; play_sound = TRUE; integer pnum = (integer)llGetSubString(text, 6, -1); counter = pnum;
      music_selection = llGetInventoryName(INVENTORY_SOUND,pnum);
      music_song = llGetInventoryName(INVENTORY_SOUND,pnum);
      dialog_songmenu(cur_page);
      playmusic();
} } } }
