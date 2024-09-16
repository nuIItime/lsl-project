
//(SCM)

integer check_song_finish = FALSE;
integer music_num; 
integer channel = 45665; 
float timing_subtraction =1.0;
float music_timing;
float rate = 0.1;
list music_song;

length_mode_sound(float a,string b)
{
llLinkSetSoundRadius(LINK_THIS,(float)llLinksetDataRead("r"));
if (a > 56) 
  { 
  llLoopSound(b,(float)llLinksetDataRead("v")); 
  llRegionSay(channel,"Loop="+b+"="+llLinksetDataRead("v"));
  }else{ 
  llPlaySound(b,(float)llLinksetDataRead("v")); 
  llRegionSay(channel,"Play="+b+"="+llLinksetDataRead("v"));
  }
}
playmusic()
{
  if(check_song_finish == TRUE){if(llLinksetDataRead("a") == "1")
  {
    llRegionSay(channel,"StopSound");llStopSound(); music_song = []; music_timing = 0;
    llMessageLinked(LINK_THIS, 0,"[autoplay]",""); return;
  } } 
  integer Length = llGetListLength(music_song);
  if (music_num < Length)
  {
  music_timing = music_timing;
  length_mode_sound(music_timing,llList2String(music_song, music_num)); music_num += 1;
  if((key)llList2String(music_song, music_num)){ llPreloadSound(llList2String(music_song, music_num));  
  }else{
  music_num = 0;
  if(llLinksetDataRead("a") == "1"){check_song_finish = TRUE;}
}}}
sound_upload(string uuid)
{ 
  if((key)uuid)
  {
  music_song += (list)[uuid];
  }else{  
  if((float)uuid)
  {
  music_timing =(float)((float)uuid-timing_subtraction);
}}}
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
    llStopSound();
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    }
    run_time_permissions(integer perm)
    {
    if(PERMISSION_TAKE_CONTROLS & perm){llTakeControls( CONTROL_BACK|CONTROL_FWD, TRUE, TRUE );}
    }
    timer()
    {
    llSetTimerEvent(0); playmusic(); llSetTimerEvent(music_timing);
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
      list items1 = llParseString2List(msg, ["|"], []); list items0 = llParseString2List(msg, ["/"], []);
      if(llList2String(items1,0) == "upload_note"){sound_upload(llList2String(items1,1));}       
      if(llList2String(items0,0) == "v"){ llRegionSay(channel,"volume="+(string)llList2Float(items0,1));llAdjustSoundVolume(llList2Float(items0,1));}
      if(llList2String(items0,0) == "r"){llLinkSetSoundRadius(LINK_THIS,llList2Float(items0,1));}
      if(msg == "erase"){llRegionSay(channel,"StopSound");check_song_finish = FALSE; music_num = 0; llStopSound(); music_song = []; llSetTimerEvent(0);}
      if(msg == "start"){llRegionSay(channel,"StopSound");music_num = 0; llStopSound(); llSetTimerEvent(rate);}
      if(msg == "start_over"){llRegionSay(channel,"StopSound");music_num = 0; llStopSound(); llSetTimerEvent(0.1);}
      if(msg == "[ Reset ]"){llRegionSay(channel,"StopSound");music_num = 0; llStopSound(); music_song = []; llSetTimerEvent(0);}
      if(msg == "[ Pause ]"){llRegionSay(channel,"StopSound");llStopSound(); llSetTimerEvent(0);}
      if(msg == "[ Play ]"){llSetTimerEvent(0.1);}
    } }

////////////////////////////////////////////////////////////////////////////////

command message

//llRegionSay(channel,"Loop="+b+"="+llLinksetDataRead("v"));
//llRegionSay(channel,"Play="+b+"="+llLinksetDataRead("v"));
//llRegionSay(channel,"volume="+(string)llList2Float(items0,1));
//llRegionSay(channel,"StopSound");

////////////////////////////////////////////////////////////////////////////////

speaker


integer channel = 45665; 
default
{
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    llStopSound();    
    llListen(channel,"","","");
    }
    listen(integer c,string n, key i, string m)
    { 
    if(llGetOwnerKey(i)==llGetOwner())
    {   
      list items = llParseString2List(m, ["="], []);  
      if(llList2String(items,0) == "volume")
      {
      llAdjustSoundVolume((float)llList2String(items,1));
      }
      if(llList2String(items,0) == "StopSound")
      {
      llStopSound();    
      }      
      if(llList2String(items,0) == "Loop")
      {
      llLoopSound(llList2String(items,1),(float)llList2String(items,2)); 
      }
      if(llList2String(items,0) == "Play")
      {
      llPlaySound(llList2String(items,1),(float)llList2String(items,2));       
      }
    }
  }  
}
