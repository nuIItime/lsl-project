integer permission = FALSE;
integer ichannel = 188;
integer cur_page = 1;
integer chanhandlr;
integer intLine1;
integer count;
integer input;

string default_settings = "1#1#1#30";
string default_notecard = "@Default";
string once_only;
string notecard;
string select;

string hover = "null";
string stand = "null";
string walk = "null";
string gsit = "null";
string sit = "null";
string run = "null";

integer standtimer;
integer stand_mode;
integer power_sit;
integer power;

key keyConfigQueryhandle;
key keyConfigUUID;
key owner;

update_settings(){once_only="";llLinksetDataWrite("[ Settings ]",(string)stand_mode+"#"+(string)power_sit+"#"+(string)power+"#"+(string)standtimer);}
random(){ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel,"",NULL_KEY,"");}
string return_button(){if(llGetInventoryType(select)==INVENTORY_NOTECARD){return "[ main ]";}else{return "[ anim ]";}}
string button1(){if(stand_mode==1){return "[ sequent ]";}else{return "[ random ]";}}
string button2(){if(power_sit==1){return "[ sit on ]";}else{return "[ sit off ]";}}
string button3(){if(power==1){return "[ on ]";}else{return "[ off ]";}}
startup()
{
  Settings();
  start_animation("NULL");
  if(llLinksetDataRead("[ Load Notecard ]") == "")
  { 
  ReadNotecard(default_notecard); 
  }else{
  configload();llSetTimerEvent(1);
  }
}
check_animation(string A,string B)
{
  integer x;
  list a = llParseString2List(B,["|"],[]);
  integer C = llGetListLength(a);
  if(A == "[ Default Pose ]"){return;} if (!C){return;}
  for ( ; x < C; x += 1)
  {
    if(llGetInventoryKey(llList2String(a,x)) == NULL_KEY)
    {
    if(llList2String(a,x) == "NULL"){ }else{llOwnerSay(A+"="+llList2String(a,x)+" missing!");}
    } 
  }
}
ReadNotecard(string note)
{
    notecard = note;
    if(llGetInventoryKey(notecard) == NULL_KEY)
    {        
    llOwnerSay("Notecard '" + note + "' missing or unwritten.");
    }else{
    intLine1 = 0;
    llLinksetDataWrite("[ Load Notecard ]",notecard);
    keyConfigQueryhandle = llGetNotecardLine(notecard, intLine1); 
    keyConfigUUID = llGetInventoryKey(notecard);
    llOwnerSay("reading notecard [ "+note+" ]");
    }
}
Settings()
{
  list a = llParseString2List(llLinksetDataRead("[ Settings ]"),["#"],[]);
  if(llLinksetDataRead("[ Settings ]") == ""){llLinksetDataWrite("[ Settings ]",default_settings);}else
  {
  stand_mode = (integer)llList2String(a,0); power_sit = (integer)llList2String(a,1); 
  power = (integer)llList2String(a,2); standtimer = (integer)llList2String(a,3);
  }
}
reset_config()
{
list a = llParseString2List(llLinksetDataRead("[ Default Pose ]"),["#"],[]);  
list b = llParseString2List(llLinksetDataRead("[ Standing ]"),["|"],[]);
hover=llList2String(a,5); walk=llList2String(a,4); run=llList2String(a,3); 
gsit=llList2String(a,2); sit=llList2String(a,1); stand=llList2String(b,0);
llLinksetDataWrite("[ Temp ]",stand+"#"+sit+"#"+gsit+"#"+run+"#"+walk+"#"+hover);
}  
configload()
{
  start_animation("NULL"); Settings();
  list a = llParseString2List(llLinksetDataRead("[ Temp ]"),["#"],[]);
  if(llLinksetDataRead("[ Temp ]") == ""){reset_config();}else
  {
  hover=llList2String(a,5); walk=llList2String(a,4); run=llList2String(a,3); 
  gsit=llList2String(a,2); sit=llList2String(a,1); stand=llList2String(a,0);
  }
}
list order_buttons(list buttons)
{
return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
dialog_songmenu(integer page,string A)
{
integer slist_size;
list a = llParseString2List(llLinksetDataRead(A),["|"],[]);
if(llGetInventoryType(A)==INVENTORY_NOTECARD){slist_size = llGetInventoryNumber(INVENTORY_NOTECARD);}
if(llGetInventoryType(A)==INVENTORY_NONE){slist_size = llGetListLength(a);}
integer pag_amt = llCeil((float)slist_size / 9.0);
if(page > pag_amt) page = 1;
else if(page < 1) page = pag_amt;
cur_page = page; integer songsonpage;
if(page == pag_amt)
songsonpage = slist_size % 9;
if(songsonpage == 0)
songsonpage = 9; integer fspnum = (page*9)-9; list dbuf; integer i;
for(; i < songsonpage; ++i){dbuf += [(string)(fspnum+i)+"'゜"];}
llDialog(owner,"page - "+(string)page+"\n\n"+make_list(fspnum,i,A),order_buttons(dbuf + ["<<<",return_button(), ">>>"]),ichannel);
}
string make_list(integer a,integer b,string A)
{
  string inventory; integer i;
  for(i = 0; i < b; ++i)
  { 
    if(llGetInventoryType(A)==INVENTORY_NOTECARD)
    {
    inventory += (string)(a+i)+". "+llGetInventoryName(INVENTORY_NOTECARD,a+i)+"\n";
    }else{
    list B = llParseString2List(llLinksetDataRead(A),["|"],[]);
    inventory += (string)(a+i)+". "+llList2String(B,a+i)+"\n";
    }
  }return inventory;
}
dialog0(){random(); dialog_songmenu(cur_page,select);}
dialog1()
{
random();
llDialog(owner,"Main Menu \n\n"+
"memory = [ S-"+(string)llGetFreeMemory()+" | L-"+(string)llLinksetDataAvailable()+" ]\n"+
"notecard = "+llLinksetDataRead("[ Load Notecard ]")+"\n"+
"stand time = "+(string)standtimer+"\n",[
button2(),button1(),"[ stand time ]",
"[ load ]","[ anim ]","[ reset set ]",
"[ sync ]",button3(),"[ reset ]",
" ✖ ","..."," ☰ "],ichannel);
}
dialog2()
{
random();
llDialog(owner,"Animation \n\n"+
"ground-sitting = "+gsit+"\n"+
"sitting = "+sit+"\n\n"+
"walking = "+walk+"\n"+
"running = "+run+"\n\n"+
"hovering = "+hover+"\n"+
"standing = "+stand+"\n",[
"[ hovering ]","[ running ]","[ ground sit ]",
"[ standing ]","[ walking ]","[ sitting ]",
" ✖ "," ↺ "," ☰ "],ichannel);
}
dialog3()
{
random();
llTextBox(owner,"\n"+"stand time = "+(string)standtimer+"\n\n"+"Select '0' to turn off stand auto-cycling.",ichannel);
}
start_animation(string A)
{ 
  integer x;
  list items = llGetAnimationList(owner);
  integer c = llGetInventoryNumber(INVENTORY_ANIMATION);
  for( ; x < c; x += 1)
  {
    if(llGetOwner() == owner)
    {
    string animation = llGetInventoryName(INVENTORY_ANIMATION,x);
    if(~llListFindList(items,[llGetInventoryKey(animation)])){if(A == animation){ }else{llStopAnimation(animation);}}
    if(A == animation){llStartAnimation(animation);}
    }
  }
}
animation(string A,float B,integer C)
{
  if(llLinksetDataRead("[ Temp ]") == ""){ }else{llLinksetDataWrite("[ Temp ]",stand+"#"+sit+"#"+gsit+"#"+run+"#"+walk+"#"+hover);}  
  if(C == 0){if(A == once_only){ }else{start_animation(A);once_only = A;}}
  if(C == 1)
  {
    list a = llParseString2List(llLinksetDataRead(A),["|"],[]);
    if(llList2String(a,0) == once_only){ }else
    {
    start_animation(llList2String(a,0));
    once_only = llList2String(a,0);
    }
  }llSetTimerEvent(B);
}
random_stand()
{
  if(llGetTime()>standtimer)
  {
  llResetTime();
  list a = llParseString2List(llLinksetDataRead("[ Standing ]"),["|"],[]);
  stand = llList2String(a,llFloor(llFrand(llGetListLength(a))));
  }
}
sequence_stand()
{
  if(llGetTime()>standtimer)
  {
    llResetTime();
    list a = llParseString2List(llLinksetDataRead("[ Standing ]"),["|"],[]);
    integer Length = llGetListLength(a);
    if(count>=Length)
    {
    count = 0;    
    stand = llList2String(a,count);
    count = count + 1;
    }else{
    stand = llList2String(a,count);
    count = count + 1;
    }
  }
}
run_time(string A)
{
  llSetTimerEvent(0);
  vector pos = llGetPos();

  if(power == 0){animation("NULL",1,0); return;}
  if(power_sit == 0){if(llGetAgentInfo(owner) & AGENT_ON_OBJECT){animation("NULL",1,0); return;}}   

  if(standtimer == 0){ }else{if(stand_mode == 0){random_stand();}}
  if(standtimer == 0){ }else{if(stand_mode == 1){sequence_stand();}}

  if(A=="Sitting on Ground"){animation(gsit,1,0);return;}
  if(A=="Standing"){animation(stand,.1,0);return;}
  if(A=="Walking"){animation(walk,.3,0);return;}
  if(A=="Sitting"){animation(sit,1,0);return;}
  if(A=="Running"){animation(run,.3,0);return;}

  if(A=="Turning Right"){animation("[ Turning Right ]",.1,1);return;}
  if(A=="Turning Left"){animation("[ Turning Left ]",.1,1);return;}

  if(A=="Falling Down"){animation("[ Falling ]",.1,1);return;}
  if(A=="Soft Landing"){animation("[ Landing ]",1,1);return;}

  if(A=="CrouchWalking"){animation("[ Crouch Walking ]",.1,1);return;}
  if(A=="Crouching"){animation("[ Crouching ]",.1,1);return;}

  if(A=="Standing Up"){animation("[ Standing Up ]",.1,1);return;}
  if(A=="PreJumping"){animation("[ Pre Jumping ]",1,1);return;}
  if(A=="Jumping"){animation("[ Jumping ]",.1,1);return;}
  if(A=="Landing"){animation("[ Landing ]",1,1);return;}

  if((llWater(llGetPos())-0.5) > pos.z)
  { 
  if(A=="Hovering Down"){animation("[ Swimming Up ]",.1,1);return;}
  if(A=="Hovering Up"){animation("[ Swimming Down ]",.1,1);return;}
  if(A=="Hovering"){animation("[ Floating ]",.1,1);return;}
  if(A=="FlyingSlow"){animation("[ Swimming Forward ]",.1,1);return;}
  if(A=="Flying"){animation("[ Swimming Forward ]",.1,1);return;}
  }else{
  if(A=="Hovering Down"){animation("[ Flying Down ]",.1,1);return;}
  if(A=="Hovering Up"){animation("[ Flying Up ]",.1,1);return;}
  if(A=="Hovering"){animation(hover,.1,0);return;}
  if(A=="FlyingSlow"){animation("[ Flying Slow ]",.1,1);return;}
  if(A=="Flying"){animation("[ Flying ]",.1,1);return;}
  }
  llSetTimerEvent(.1);
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
    if(change & CHANGED_OWNER){llResetScript();}
    }
    state_entry()
    { 
    owner = llGetOwner();
    llRequestPermissions(llGetOwner(),PERMISSION_TAKE_CONTROLS|PERMISSION_TRIGGER_ANIMATION);
    }
    touch_start(integer total_number)
    {
    if(llDetectedKey(0) == owner){dialog1();}
    }
    run_time_permissions(integer perm)
    {
    if(PERMISSION_TAKE_CONTROLS & perm){permission = TRUE; llTakeControls( CONTROL_BACK|CONTROL_FWD,TRUE,TRUE); startup();}
    }
    listen(integer chan,string sname,key skey,string text)
    {  
    if(skey == owner) 
    {
      if(text == "[ ground sit ]"){cur_page = 1;select = "[ Sitting On Ground ]"; dialog0();return;}   
      if(text == "[ standing ]"){cur_page = 1;select = "[ Standing ]"; dialog0();return;}
      if(text == "[ hovering ]"){cur_page = 1;select = "[ Hovering ]"; dialog0();return;}    
      if(text == "[ walking ]"){cur_page = 1;select = "[ Walking ]"; dialog0();return;}      
      if(text == "[ running ]"){cur_page = 1;select = "[ Running ]"; dialog0();return;}
      if(text == "[ sitting ]"){cur_page = 1;select = "[ Sitting ]"; dialog0();return;}     

      if(text == "[ stand time ]"){input = 1;dialog3();return;}    

      if(text == "[ reset set ]"){llLinksetDataWrite("[ Settings ]",default_settings);Settings();dialog1();return;} 
      if(text == "[ reset ]"){start_animation("NULL");llLinksetDataReset();llResetScript();} 
      if(text == "[ load ]"){cur_page = 1;select = default_notecard; dialog0();return;} 
      if(text == "[ sync ]"){once_only="";dialog1();return;}  
      if(text == "[ anim ]"){dialog2();return;}
      if(text == "[ main ]"){dialog1();return;}  

      if(text == " ☰ "){dialog1();return;}      
      if(text == "..."){dialog1();return;}

      if(text == " ↺ "){reset_config();dialog2();return;}

      if(text == "[ sequent ]"){stand_mode=0;update_settings();dialog1();return;}
      if(text == "[ random ]"){stand_mode=1;update_settings();dialog1();return;}  

      if(text == "[ sit on ]"){power_sit=0;update_settings();dialog1();return;}
      if(text == "[ sit off ]"){power_sit=1;update_settings();dialog1();return;}

      if(text == "[ on ]"){power=0;update_settings();dialog1();return;}
      if(text == "[ off ]"){power=1;update_settings();dialog1();return;}  

      if(text == ">>>"){dialog_songmenu(cur_page+1,select);return;}
      if(text == "<<<"){dialog_songmenu(cur_page-1,select);return;}

      list items = llParseString2List(text,["'"], []);
      if(llList2String(items,1) == "゜")
      {
        list a = llParseString2List(llLinksetDataRead(select),["|"],[]);
        if(select=="[ Sitting On Ground ]"){gsit = llList2String(a,(integer)llList2String(items,0));}
        if(select=="[ Hovering ]"){hover = llList2String(a,(integer)llList2String(items,0));}
        if(select=="[ Standing ]"){stand = llList2String(a,(integer)llList2String(items,0));}
        if(select=="[ Walking ]"){walk = llList2String(a,(integer)llList2String(items,0));}
        if(select=="[ Running ]"){run = llList2String(a,(integer)llList2String(items,0));}
        if(select=="[ Sitting ]"){sit = llList2String(a,(integer)llList2String(items,0));}
        if(llGetInventoryType(select)==INVENTORY_NOTECARD)
        {
        llSetTimerEvent(0); start_animation("NULL"); llLinksetDataDelete("[ Temp ]");
        ReadNotecard(llGetInventoryName(INVENTORY_NOTECARD,(integer)llList2String(items,0))); dialog1();
        }else{
        llOwnerSay(select+" = "+llList2String(a,(integer)llList2String(items,0))); dialog0();
        }
        return;
      }
      if(input == 1)
      {
        if((integer)text){standtimer=(integer)text; update_settings();}
        if(text=="0"){standtimer=(integer)text; update_settings();}
        input = 0; dialog1();
        return;
        }
      }
    }
    dataserver(key keyQueryId, string strData)
    {
    if(keyQueryId == keyConfigQueryhandle)
    {
        if(strData == EOF){configload(); llOwnerSay("finish loading."); llSetTimerEvent(1);}else
        {
          keyConfigQueryhandle = llGetNotecardLine(notecard, ++intLine1);
          strData = llStringTrim(strData, STRING_TRIM_HEAD); list a = llParseString2List(strData,["="],[]);
          if(llGetSubString(strData,0,0) != "#")
          {
          check_animation(llList2String(a,0),llList2String(a,1));  
          llLinksetDataWrite(llList2String(a,0),llList2String(a,1));
          }
        }
      }
    }
    timer()
    {
    run_time(llGetAnimation(owner));
    }
}