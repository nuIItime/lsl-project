list type_mode = ["[ 🔊 ]","[ 🆔 ]","[ 📄 ]"];
list blacklist_notecard = ["!uuids","!whitelist"];

string default_radius = "0";
string default_volume = "1";
string default_mode = "0";
string music_selection = "none";
string music_song = "none";
string note_name;

key userUUID;

integer dialog_select_switch = FALSE;
integer arrow_play_sound = FALSE;
integer play_sound = FALSE;
integer only_once = FALSE;
integer ichannel = 07899;
integer sound_type = 0;
integer cur_page0 = 1;
integer cur_page = 1;
integer chanhandlr;
integer counter;
integer counte;
integer c = 80;
integer intLine1;

integer menu_time = 30;

key keyConfigQueryhandle;
key keyConfigUUID;

integer readnote(string notename)
{
    note_name = notename;
    if (llGetInventoryKey(note_name) == NULL_KEY){ return 0; }else
    {
    intLine1 = 0;
    keyConfigQueryhandle = llGetNotecardLine(note_name, intLine1); 
    keyConfigUUID = llGetInventoryKey(note_name);
    return 1;
    }
}
list order_buttons(list buttons)
{
return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
list numerizelist(list tlist, integer start, string apnd)
{
    list newlist;
    integer lsize = llGetListLength(tlist); integer i;
    for(; i < lsize; i++)
    {
    newlist += [(string)(start + i) + apnd + llList2String(tlist, i)];
    }return newlist;
}
get_inventory(){if (llGetInventoryKey(music_selection)==NULL_KEY){llOwnerSay(music_selection+"|"+music_song);}else{llGiveInventory(llGetOwner(),music_selection);}}
string show_uuid(){if (llGetInventoryType(music_selection)==INVENTORY_SOUND){return (string)llGetInventoryKey(music_song);}return music_song;}
string play_sound_0(){if(music_selection == "none"){return"[  ◼  ]";}if(play_sound == FALSE){return"[  ▶  ]";}else{return"[  ⏸  ]";}}
string sound_type_0(integer a){if(a == 0){return"sound";}if(a == 1){return"uuid";}return"notecard";}
string sound_type_1(integer a){if(a == 0){return"[ 🔊 ]";}if(a == 1){return"[ 🆔 ]";}return"[ 📄 ]";}
string play_mode(){if(llLinksetDataRead("a") == "1"){return"auto";}else{return"loop";}}
type_option(){llDialog(userUUID,"type",["[ sound ]","[ note ]","[ uuid ]","[  🞪  ]","[ ... ]","[ main ]"],ichannel);}
dialog_topmenu()
{
llDialog(userUUID,"main"+"\n"+"\n"+
"Playing = "+music_selection+"\n"+
"Sound Type = "+sound_type_0(sound_type)+"\n"
,["[ ⚙ setting ]","[  🔀  ]","[ 🛠️️ option ]","[  ⏪  ]",play_sound_0(),"[  ⏩  ]","[  🞪  ]","[  ♫  ]",sound_type_1(sound_type)],ichannel);
}
dialog_option()
{
if(llGetInventoryType(music_selection)==INVENTORY_NOTECARD){llDialog(llGetOwner(),"option"+"\n"+"\n"+"Music = "+music_selection+"\n"+"Mode = "+play_mode()+"\n",["[ 📁 get ]","[ ⟳ reset ]","[ main ]","[ "+play_mode()+" ]"],ichannel);return;}  
llDialog(llGetOwner(),"option"+"\n"+"\n"+"Uuid = "+show_uuid()+"\n"+"Music = "+music_selection+"\n",["[ 📁 get ]","[ ⟳ reset ]","[ main ]"],ichannel);
}
dialog_songmenu(integer page,integer inventory_type)
{
    integer slist_size = llGetInventoryNumber(inventory_type);
    integer pag_amt = llCeil((float)slist_size / 9.0);
    if(page > pag_amt) page = 1;
    if(page < 1) page = pag_amt; if(dialog_select_switch == TRUE){cur_page = page;}else{cur_page0 = page;}
    integer songsonpage;
    if(page == pag_amt) songsonpage = slist_size % 9;
    if(songsonpage == 0) songsonpage = 9;
    integer fspnum = (page*9)-9;
    list dbuf;
    integer i;
    for(; i < songsonpage; ++i)
    {
    dbuf += ["Play #" + (string)(fspnum+i)];
    }
    list snlist = numerizelist(make_list(fspnum,i,inventory_type), fspnum, ". ");
    llDialog(userUUID,"music selection\n\n"+llDumpList2String(snlist, "\n"),order_buttons(dbuf + ["<<<","[  ♫  ]", ">>>"]),ichannel);
}
list make_list(integer a,integer b,integer B) 
{
  list inventory;integer i;for (i = 0; i < b; ++i)
  {
  string name = llGetInventoryName(B,a+i);
  if (~llListFindList(blacklist_notecard,[name])){inventory += "null";}else{inventory += llDeleteSubString(name,40,1000);}
  }return inventory;
}
dialog0()
{
ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, ""); dialog_topmenu();
}
integer search(string search,integer inventory_type)
{
  integer Lengthx = llGetInventoryNumber(inventory_type); integer x;
  for ( ; x < Lengthx; x += 1)
  {
    string A = llToLower(search); string B = llToLower(llGetInventoryName(inventory_type, x));
    integer search_found = ~llSubStringIndex(B,A);
    if (search_found)
    {
    integer Division= x / 9 ; llRegionSayTo(userUUID,0,"[ "+llGetInventoryName(inventory_type,x)+" ] [ page = "+(string)(Division+1)+" list = "+(string)x+" ]");
    dialog_songmenu(Division+1,inventory_type);
    return 1;
} }return 0;}
search_music(string search)
{
dialog_select_switch = TRUE;if(search(search,INVENTORY_SOUND) == 1){return;}
dialog_select_switch = FALSE;if(search(search,INVENTORY_NOTECARD) == 1){return;}
llMessageLinked(LINK_THIS, 0,"search="+search+"="+(string)userUUID,NULL_KEY); return;
}
string check_output(float A){if(.01<=A){return(string)A;}return"OFF";}
integer getLinkNum(string primName)
{
integer primCount = llGetNumberOfPrims();
integer i;
for (i=0; i<primCount+1;i++){  
if (llGetLinkName(i)==primName) return i;
}return FALSE;}
arrow_music(integer inventory_type)
{
  if(arrow_play_sound == TRUE){counter = counter + 1;}else{counter = counter - 1;}
  if(-1>=counter){counter = llGetInventoryNumber(inventory_type)-1;}if((counter)>llGetInventoryNumber(inventory_type)-1){counter = 0;}else
  {
  music_selection = llGetInventoryName(inventory_type,counter); music_song = llGetInventoryName(inventory_type,counter);
  playmusic(); cur_page = (counter/9)+1; return;
  }
  music_selection = llGetInventoryName(inventory_type,0); music_song = llGetInventoryName(inventory_type,0);
  playmusic(); cur_page = (counter/9)+1; return;
}
arrow_music_1(integer inventory_type)
{
  if(arrow_play_sound == TRUE){counte = counte + 1;}else{counte = counte - 1;}
  if(-1>=counte){counte = llGetInventoryNumber(inventory_type)-1;}if((counte)>llGetInventoryNumber(inventory_type)-1){counte = 0;}else
  {
  music_selection = llGetInventoryName(inventory_type,counte); music_song = llGetInventoryName(inventory_type,counte);
  if (~llListFindList(blacklist_notecard,[music_selection])){ }else{llMessageLinked(LINK_THIS,0,"fetch_note_rationed|"+music_selection,"");}cur_page0 = (counte/9)+1; return;
  }
  music_selection = llGetInventoryName(inventory_type,0); music_song = llGetInventoryName(inventory_type,0);
  if (~llListFindList(blacklist_notecard,[music_selection])){ }else{llMessageLinked(LINK_THIS,0,"fetch_note_rationed|"+music_selection,"");}cur_page0 = (counte/9)+1; return;
}
playmusic()
{
if(play_sound == TRUE)
{
    llLinkSetSoundRadius(LINK_THIS,(float)llLinksetDataRead("r"));
    if (llGetInventoryType(music_selection) == INVENTORY_SOUND)
    {
    llLoopSound(music_selection,(float)llLinksetDataRead("v"));
    }else{
    if((key)music_song){llLoopSound(music_song,(float)llLinksetDataRead("v"));}else{llRegionSayTo(userUUID,0,"error invalid [ " +music_song+" ]");}
    }
  }llRegionSayTo(userUUID,0," Playing [ " +music_selection+" ]");
}
option_topmenu()
{
integer music_list = (llGetInventoryNumber(INVENTORY_NOTECARD)-2)+llGetInventoryNumber(INVENTORY_SOUND)+(integer)llLinksetDataRead("uuid");
integer page=(music_list / 9) + 1;
llTextBox(userUUID,
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
    llStopSound();
    }
    touch_start(integer total_number)
    {
    if(llDetectedKey(0) == userUUID){if(only_once == TRUE){dialog0();}}
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
      if(only_once == FALSE){if((key)msg){llSetTimerEvent(0);only_once = TRUE; userUUID = msg; llSetTimerEvent(menu_time);return;}}
      if(msg == "owner_ride"){llSetTimerEvent(0);userUUID = llGetOwner(); dialog0();llSetTimerEvent(menu_time);only_once = TRUE;return;}
      if(msg == "[autoplay]"){play_sound = TRUE;arrow_play_sound = FALSE;arrow_music_1(INVENTORY_NOTECARD);}
      if(msg == "menu_in_use"){llSetTimerEvent(0); llSetTimerEvent(menu_time);}
      if(msg == "main"){dialog_topmenu();}
      if(msg == "type"){type_option();}
      list k = llParseString2List(msg, ["|"], []);
      list x = llParseString2List(msg, ["="], []);
      if(llList2String(k, 0) == "fetch_note_rationed")
      {
      play_sound = TRUE; llMessageLinked(LINK_THIS,0,"erase", NULL_KEY);
      string nname = llDumpList2String(llList2ListStrided(k, 1, -1, 1), " ");
      if(readnote(nname) == 0){ llRegionSayTo(userUUID,0,"error could not find notecard"); }
      sound_type = 2; llRegionSayTo(userUUID,0," Playing [ " + music_selection+" ]");
      }
      if((string)llList2String(x,0) == "notecard")
      {
      sound_type = 1; play_sound = TRUE;
      list items1 = llParseString2List(llList2String(x,1), ["|"], []);  
      music_selection = llList2String(items1,0); music_song = llList2String(items1,1); 
      playmusic(); if((string)llList2String(x,2) == "menu"){dialog_topmenu();}
      } 
      if(llList2String(x,0) == "Search")
      {
        list A = llParseString2List(llList2String(x,1), ["|"], []);
        if (llGetInventoryType(llList2String(A,0))==INVENTORY_NONE)
        { 
        music_song = llList2String(A,1); music_selection = llList2String(A,0);
        sound_type = 1; play_sound = TRUE; playmusic();
        return;
        }
        if (llGetInventoryType(llList2String(A,0))==INVENTORY_SOUND)
        {
        music_song = llList2String(A,0); music_selection = llList2String(A,0); 
        sound_type = 0; play_sound = TRUE; counter = (integer)llList2String(A,1); cur_page = ((integer)llList2String(A,1)/9)+1; playmusic();
        return;
        }
        if (llGetInventoryType(llList2String(A,0))==INVENTORY_NOTECARD)
        {
        music_song = llList2String(A,0); music_selection = llList2String(A,0);   
        sound_type = 2; play_sound = TRUE; counte = (integer)llList2String(A,1); cur_page0 = ((integer)llList2String(A,1)/9)+1; 
        llMessageLinked(LINK_THIS,0,"fetch_note_rationed|"+music_selection,"");
        return;
    } } }
    listen(integer chan, string sname, key skey, string text)
    {
    list items0 = llParseString2List(text, ["/"], []);
    if(skey == userUUID) 
    {
      llSetTimerEvent(0);
      llSetTimerEvent(menu_time);
      if(text == "[ ... ]"){type_option();}
      if(text == "[  ♫  ]"){type_option();}
      if(text == "[  ◼  ]"){dialog_topmenu();}
      if(text == "[ 📁 get ]"){get_inventory();}
      if(text == "[ ⚙ setting ]"){option_topmenu();}
      if(text == "[ main ]"){dialog_topmenu();}
      if(text == "[ uuid ]"){llMessageLinked(LINK_THIS, 0,"notecard_uuid="+(string)userUUID,"");}
      if(text == "[ sound ]"){dialog_select_switch = TRUE;dialog_songmenu(cur_page,INVENTORY_SOUND);}
      if(text == "[ 🛠️️ option ]"){if(userUUID==llGetOwner()){dialog_option();return;}dialog_topmenu();}
      if(text == "[ note ]"){dialog_select_switch = FALSE;dialog_songmenu(cur_page0,INVENTORY_NOTECARD);}
      if(text == "[  ⏸  ]"){llMessageLinked(LINK_THIS, 0,"[ Pause ]",""); play_sound = FALSE; llStopSound(); dialog_topmenu();}
      if(text == "[  🞪  ]"){userUUID = "";only_once = FALSE;llSetTimerEvent(0);llMessageLinked(LINK_THIS,0,"exit_out","");}
      if(text == "[ auto ]"){llLinksetDataDelete("a");llLinksetDataWrite("a","0"); dialog_option();}
      if(text == "[ loop ]"){llLinksetDataDelete("a");llLinksetDataWrite("a","1"); dialog_option();}
      if(text == "[  ▶  ]")
      {
        if (llGetInventoryType(music_selection) == INVENTORY_NOTECARD)
        {
        play_sound = TRUE;llMessageLinked(LINK_THIS, 0,"[ Play ]","");dialog_topmenu();return;
        }
        play_sound = TRUE;playmusic();dialog_topmenu();
      }
      if((string)llList2String(items0,0) == "s"){llMessageLinked(LINK_THIS, 0,"search_engine="+llList2String(items0,1)+"="+(string)userUUID,"");}
      if((string)llList2String(items0,0) == "v")
      {
      llLinksetDataDelete("v");llLinksetDataWrite("v",llDeleteSubString((string)llList2Float(items0,1),10,300));
      llAdjustSoundVolume(llList2Float(items0,1)); 
      option_topmenu();
      }
      if((string)llList2String(items0,0) == "r")
      {
      llLinksetDataDelete("r");llLinksetDataWrite("r",llDeleteSubString((string)llList2Float(items0,1),10,300));
      llLinkSetSoundRadius(LINK_THIS,llList2Float(items0,1)); 
      option_topmenu();
      } 
      if (~llListFindList(type_mode,[text])) 
      {
      if(sound_type == 0){sound_type = 1;dialog_topmenu();return;}
      if(sound_type == 1){sound_type = 2;dialog_topmenu();return;}
      if(sound_type == 2){sound_type = 0;dialog_topmenu();return;}
      }
      if(text == "[  ⏩  ]")
      {
        if(sound_type == 2){sound_type = 2; play_sound = TRUE;arrow_play_sound = TRUE;arrow_music_1(INVENTORY_NOTECARD);dialog_topmenu();}   
        if(sound_type == 0){sound_type = 0; play_sound = TRUE;arrow_play_sound = TRUE;arrow_music(INVENTORY_SOUND);dialog_topmenu();}        
        if(sound_type == 1){sound_type = 1; llMessageLinked(LINK_THIS, 0,"⏩","");} 
      }
      if(text == "[  ⏪  ]")
      { 
        if(sound_type == 2){sound_type = 2; play_sound = TRUE;arrow_play_sound = FALSE;arrow_music_1(INVENTORY_NOTECARD);dialog_topmenu();}  
        if(sound_type == 0){sound_type = 0; play_sound = TRUE;arrow_play_sound = FALSE;arrow_music(INVENTORY_SOUND);dialog_topmenu();}        
        if(sound_type == 1){sound_type = 1; llMessageLinked(LINK_THIS, 0,"⏪","");} 
      }
      if(text == "[  🔀  ]")
      {
        if(sound_type == 1){sound_type = 1; llMessageLinked(LINK_THIS, 0,"🔀","");} 
        if(sound_type == 0)
        {
        sound_type = 0; play_sound = TRUE;
        integer x = llFloor(llFrand(llGetInventoryNumber(INVENTORY_SOUND)));
        music_selection = llGetInventoryName(INVENTORY_SOUND,x);
        music_song = llGetInventoryName(INVENTORY_SOUND,x);
        counter = x; playmusic(); dialog_topmenu();
        cur_page = (x/9)+1;
        }        
        if(sound_type == 2)
        {
        sound_type = 2; play_sound = TRUE;
        integer x = llFloor(llFrand(llGetInventoryNumber(INVENTORY_NOTECARD)));
        music_selection = llGetInventoryName(INVENTORY_NOTECARD,x);
        music_song = llGetInventoryName(INVENTORY_NOTECARD,x);
        if (~llListFindList(blacklist_notecard,[music_selection])){dialog_topmenu();return;}
        llMessageLinked(LINK_THIS,0,"fetch_note_rationed|"+music_selection,""); 
        counte = x; cur_page0 = (x/9)+1; dialog_topmenu();
        } 
      }
      if(text == "[ ⟳ reset ]")
      {
        if(userUUID==llGetOwner())
        {  
        llLinksetDataReset();llLinksetDataWrite("a",default_mode);llLinksetDataWrite("r",default_radius);llLinksetDataWrite("v",default_volume);play_sound = FALSE; sound_type = 0; 
        music_song = "none"; music_selection = "none"; cur_page = 1; llStopSound(); llSleep(0.2); dialog_topmenu();llMessageLinked(LINK_THIS, 0,"[ reset ]","");
      } }
          if(dialog_select_switch == TRUE)
          {
            if(text == ">>>") dialog_songmenu(cur_page+1,INVENTORY_SOUND);
            if(text == "<<<") dialog_songmenu(cur_page-1,INVENTORY_SOUND);
            if(llToLower(llGetSubString(text,0,5)) == "play #")
            { 
            sound_type = 0; play_sound = TRUE; integer pnum = (integer)llGetSubString(text, 6, -1); counter = pnum; 
            music_selection = llGetInventoryName(INVENTORY_SOUND,pnum);
            music_song = llGetInventoryName(INVENTORY_SOUND,pnum);
            dialog_songmenu(cur_page,INVENTORY_SOUND);
            playmusic();
          } }
          if(dialog_select_switch == FALSE)
          {
            if(text == ">>>") dialog_songmenu(cur_page0+1,INVENTORY_NOTECARD);
            if(text == "<<<") dialog_songmenu(cur_page0-1,INVENTORY_NOTECARD);
            if(llToLower(llGetSubString(text,0,5)) == "play #")
            {
              integer pnum = (integer)llGetSubString(text, 6, -1); 
              music_selection = llGetInventoryName(INVENTORY_NOTECARD,pnum);
              music_song = llGetInventoryName(INVENTORY_NOTECARD,pnum); counte = pnum; 
              if (~llListFindList(blacklist_notecard,[music_selection])){dialog_songmenu(cur_page,INVENTORY_NOTECARD);}else
              {
              sound_type = 2; play_sound = TRUE;
              llMessageLinked(LINK_THIS,0,"fetch_note_rationed|"+music_selection,"");  
              dialog_songmenu(cur_page0,INVENTORY_NOTECARD);
  }  }  }  }  }
  dataserver(key keyQueryId, string strData)
  {
        if (keyQueryId == keyConfigQueryhandle)
        {
            if (strData == EOF){llMessageLinked(LINK_THIS,0,"start", NULL_KEY);}else
            {
            keyConfigQueryhandle = llGetNotecardLine(note_name, ++intLine1);
            strData = llStringTrim(strData, STRING_TRIM_HEAD);
            if (llGetSubString (strData, 0, 0) != "#"){llMessageLinked(LINK_THIS, 0, "upload_note|" + strData, NULL_KEY);}
            }
       }
  }
  timer()
  {
  only_once = FALSE;
  llSetTimerEvent(0);
  llRegionSayTo(userUUID,0,"time_out");
  llMessageLinked(LINK_THIS,0,"exit_out",""); userUUID = "";
} }
