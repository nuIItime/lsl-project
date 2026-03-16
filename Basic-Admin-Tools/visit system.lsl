string webhook_url = ""; //url

integer flag = AGENT_LIST_REGION; //detect agent on the sim flag type
integer limit_character_footer_name = 15; //character limit 20
integer limit_character_root_name = 15; //character limit 20
integer limit_character_name = 30; //character limit 60
integer footer_name_display = 20; //footer limit 30
integer parcel_name = TRUE; //show parcel name
integer time_event = 3; //script runtime

string embed_color0 = "100000"; //enter
string embed_color1 = "9807270"; //left
string embed_color2 = "16711680"; //alert

string root_sitting(key avatar){list a = llGetObjectDetails(avatar,([OBJECT_ROOT]));return llList2String(a,0);}
string detect_bot(key avatar){if(llGetAgentInfo(avatar) & AGENT_AUTOMATED){return "🤖";}return " ";}
string name(string a){return llDeleteSubString(a,limit_character_footer_name,1000000);}
string in_out(integer A){if(A == 1){return embed_color0;}return embed_color1;}
string flag_list(){if(flag==AGENT_LIST_REGION){return"sim";}return"parcel";}

string avatar_parcel(vector pos)
{
list data0 = llGetParcelDetails(pos,[PARCEL_DETAILS_NAME]);
return llDeleteSubString(llList2String(data0,0),30,1000000);
}
string getTime(integer secs)
{
string timeStr; integer days; integer hours; integer minutes;
if(secs>=86400){days=llFloor(secs/86400);secs=secs%86400;timeStr+=(string)days+" day";if (days>1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>=3600){hours=llFloor(secs/3600);secs=secs%3600;timeStr+=(string)hours+" hour";if(hours!=1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>=60){minutes=llFloor(secs/60);secs=secs%60;timeStr+=(string)minutes+" minute";if(minutes!=1){timeStr+="s";}if(secs>0){timeStr+=", ";}}
if(secs>0){timeStr+=(string)secs+" second";if(secs!=1){timeStr+="s";}}return timeStr;
}
string A_status(key avatar)
{
if(llGetAgentInfo(avatar) & AGENT_ON_OBJECT)
{ 
list a = llGetObjectDetails(root_sitting(avatar),([OBJECT_PHYSICS]));
if(llList2Integer(a,0) == 1){ return "🚗"; }
return "🪑"; 
}

if(llGetAgentInfo(avatar) & AGENT_SITTING){ return "🧘"; }

if(llGetAgentInfo(avatar) & AGENT_ALWAYS_RUN){ return "🏃"; }
if(llGetAgentInfo(avatar) & AGENT_MOUSELOOK){ return "👀"; }
if(llGetAgentInfo(avatar) & AGENT_WALKING){ return "🚶"; }
if(llGetAgentInfo(avatar) & AGENT_TYPING){ return "🗨️"; }

if(llGetAgentInfo(avatar) & AGENT_AUTOMATED){ return "🤖"; }

if(llGetAgentInfo(avatar) & AGENT_FLYING){ return "🪽️"; }
if(llGetAgentInfo(avatar) & AGENT_IN_AIR){ return "🪽"; }

if(llGetAgentInfo(avatar) & AGENT_BUSY){ return "⛔"; }
if(llGetAgentInfo(avatar) & AGENT_AWAY){ return "💤"; }
return "🧍";
}
data_delete(string a)
{
   integer counter; integer x;
   integer Lengthx = llLinksetDataCountKeys();
   for ( ; x < Lengthx; x += 1)
   { 
   string b = llLinksetDataRead("data"+(string)x);
   if(a == "data"+(string)x){ }else{llLinksetDataWrite("temp"+(string)counter,b);counter = counter + 1;} 
   }   
   llLinksetDataDeleteFound("data",""); integer v; 
   integer Length = llLinksetDataCountKeys();
   for ( ; v < Length; v += 1)
   {
   string b = llLinksetDataRead("temp"+(string)v);
   llLinksetDataWrite("data"+(string)v,b);
   }  
   llLinksetDataDeleteFound("temp","");
}
integer data_check(string uuid)
{
   integer x;
   integer Length = llLinksetDataCountKeys();
   for ( ; x < Length; x += 1)
   { 
      string b = llLinksetDataRead("data"+(string)x);
      list items = llParseString2List(b,["|"],[]);
      if((key)llList2String(items,3))
      {
         if(uuid == llList2String(items,3))
         {
         list details = llGetObjectDetails(uuid,([OBJECT_NAME,OBJECT_POS]));
         vector ovF = llList2Vector(details,1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
         string position = "("+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c)+")";
         llLinksetDataWrite("data"+(string)x,llList2String(items,0)+"|"+position+"|"+detect_bot(uuid)+"|"+uuid+"|"+llList2String(items,4));
         return 1;
         }
      }
      else
      {
      data_delete("data"+(string)x);  
      }
   }return 0;
}
agent_IN()
{
  list List = llGetAgentList(flag,[]);
  integer Length = llGetListLength(List);
  if (!Length){return;}else{integer x;for ( ; x < Length; x += 1)
  {
      list details = llGetObjectDetails(llList2String(List,x),([OBJECT_NAME,OBJECT_POS]));
      vector ovF = llList2Vector(details,1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
      string position = "("+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c)+")";
      if (data_check(llList2String(List,x)) == 0)
      { 
      string Name = llDeleteSubString(llList2String(details,0),limit_character_name,1000000);
      string Data = Name+"|"+position+"|"+detect_bot(llList2String(List,x))+"|"+llList2String(List,x)+"|"+(string)llGetUnixTime();
      visit_logs_send(Data,1); llLinksetDataWrite("data"+(string)llLinksetDataCountKeys(),Data);
      }
    }
  }
}
agent_OUT()
{
  integer x;
  integer Length = llLinksetDataCountKeys();
  for ( ; x < Length; x += 1)
  { 
      string b = llLinksetDataRead("data"+(string)x);
      list items = llParseString2List(b,["|"],[]);
      if((key)llList2String(items,3))
      {
        vector agent = llGetAgentSize(llList2String(items,3));
        if(agent){ }else
        {
        integer time = (integer)llGetUnixTime() - llList2Integer(items,4);
        string Data = llList2String(items,0)+"|"+llList2String(items,1)+"|"+llList2String(items,2)+"|"+llList2String(items,3)+"|"+(string)time;
        visit_logs_send(Data,2); data_delete("data"+(string)x);
        }
      }
      else
      {
      data_delete("data"+(string)x);
      }
   }
}
string pos_int(string position,key ID)
{
  vector ovF = (vector)position; float a = ovF.x; float b = ovF.y; float c = ovF.z;
  string position_A = (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c);
  if(parcel_name==TRUE){ return position_A+" | "+avatar_parcel(ovF)+" | "+A_status(ID); }
  return position_A+" | "+A_status(ID);
}
string region_avatar_list() 
{
   list List = llGetAgentList(flag,[]);
   integer Length = llGetListLength(List);
   list detect_list = [];
   if (!Length){ return "No One Detected"; }else
   {
      integer x;
      for ( ; x < Length; x += 1)
      {
         integer count = llGetListLength(detect_list);
         if (count > footer_name_display) 
         {
         detect_list += "..."+"\n";
         return "Agent : "+(string)Length+"\n"+(string)detect_list;
         }else{
         list details = llGetObjectDetails(llList2Key(List, x), ([OBJECT_NAME,OBJECT_POS]));
         detect_list += name(llList2String(details,0))+" ( "+pos_int((string)llList2Vector(details,1),llList2Key(List, x))+" )"+"\n";
         }       
      }
   }return "Agent : "+(string)Length+"\n"+(string)detect_list; 
}
visit_logs_send(string A,integer B) 
{
  string detail0 = ""; 
  string detail1 = "";
  
  list items = llParseString2List(A, ["|"], []);
  
  if((key)llList2String(items,3))
  {
    if(B == 1)
    {
    string pos = llList2String(items,1);

    pos = llReplaceSubString(pos, "(", "<", 0);   
    pos = llReplaceSubString(pos, ")", ">", 0);

    detail1 = "has entered the "+flag_list();
    detail0 =
    "Uuid : "+llList2String(items,3)+"\n"+
    "Spawn Position : "+llList2String(items,1)+"\n";
    if(parcel_name==TRUE){ detail0 += "Parcel : "+avatar_parcel((vector)pos); }

    }
    if(B == 2)
    {
    string pos = llList2String(items,1);    

    pos = llReplaceSubString(pos, "(", "", 0);   
    pos = llReplaceSubString(pos, ")", "", 0); 
    pos = "<"+pos+">";  
        
    detail1 = "has left the "+flag_list();
    detail0 =
    "Uuid : "+llList2String(items,3)+"\n"+
    "Last Position : "+llList2String(items,1)+"\n";
    if(parcel_name==TRUE){ detail0 += "Parcel : "+avatar_parcel((vector)pos)+"\n"; }
    detail0 += "Visit Time : "+getTime((integer)llList2String(items,4));
    
    }
    list json =[
    "username",llGetRegionName()+"","embeds",llList2Json(JSON_ARRAY,[llList2Json(JSON_OBJECT,[
    "color",in_out(B),"title",llList2String(items,2)+llList2String(items,0),
    "description",detail0+"\nPosted : <t:"+(string)llGetUnixTime()+":R>","url","https://world.secondlife.com/resident/"+llList2String(items,3),
    "author",llList2Json(JSON_OBJECT,["name",detail1]),
    "footer",llList2Json(JSON_OBJECT,["text",region_avatar_list()])])])];

    llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
    "application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
    HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
    llSleep(.5);
  }
}
alert_log(string Message)
{
    list json =[
    "username",llGetRegionName()+"","embeds",llList2Json(JSON_ARRAY,[llList2Json(JSON_OBJECT,[
    "color",embed_color2,"title",Message,"description","Posted : <t:"+(string)llGetUnixTime()+":R>","url",""])])];

    llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
    "application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
    HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json));
    llSleep(.5);
}
default
{
    changed(integer change)
    {
      if (change & CHANGED_REGION_START)
      {
      agent_OUT();    
      alert_log("Region_Restart : "+llGetDate()); 
      llResetScript();
      }
    }
    on_rez(integer start_param)
    {
    llResetScript();
    }
    state_entry()
    {
    llLinksetDataReset();    
    llSetTimerEvent(time_event);
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    if(num == 5){ alert_log(msg); }
    }
    timer()
    {
    if(llGetFreeMemory() < 10000){ agent_OUT(); llResetScript(); }
    agent_OUT();
    agent_IN();
    }
}
