string webhook_url = "XXXX";

integer rezz_threshold = 50;
integer timer_event = 3;
 
string get_name(string id)
{
list details = llGetObjectDetails(id,([OBJECT_NAME]));  
if(llList2String(details,0) == ""){ return "click-info🔗"; }
return llList2String(details,0);
}
string rezz_level(integer count)
{
if(count>rezz_threshold*4)return "16711680";//Red
if(count>rezz_threshold*3)return "14177041";//Orange
if(count>rezz_threshold*2)return "16705372";//Yellow
return "5763719";//Green
}
logs_send(string id,string User_Rezz,string color) 
{
    integer prim_left = (integer)llGetParcelMaxPrims(llGetPos(),FALSE) - (integer)llGetParcelPrimCount(llGetPos(),PARCEL_COUNT_TOTAL,FALSE);
    
    string info = 
    "Rezz Activity"+"\n\n"+
    User_Rezz+"\n"+
    "Prims used: "+(string)llGetParcelPrimCount(llGetPos(),PARCEL_COUNT_TOTAL,FALSE)+"/"+(string)llGetParcelMaxPrims(llGetPos(),FALSE)+"\n"+
    "Prims left: "+(string)prim_left;
    
    string region_info =
    "Sim Statistics"+"\n\n"+
    "Time Dilation: "+(string)llRound((1-llGetRegionTimeDilation())*100)+"\n"+
    "Fps: "+llDeleteSubString((string)llGetRegionFPS(),4,100)
    ;

    list json =[
    "username",llGetRegionName()+"","embeds",llList2Json(JSON_ARRAY,[llList2Json(JSON_OBJECT,[
    "color",color,"title",get_name(id),
    "description","Uuid : "+id+"\n"+"Posted : <t:"+(string)llGetUnixTime()+":R>","url","https://world.secondlife.com/resident/"+id,
    "author",llList2Json(JSON_OBJECT,["text","info"]),
    "footer",llList2Json(JSON_OBJECT,["text",info+"\n\n"+region_info])
    ])])];

    llHTTPRequest(webhook_url,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
    "application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
    HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,json)); 
    llSleep(.5);
}
Monitor_Rezz() 
{   
  list TempList = llGetParcelPrimOwners(llGetPos());
  integer Length = llGetListLength(TempList);
  if(!Length){ return; }else
  {
    integer z;
    for ( ; z < Length; z += 2)
    {
      integer previous_rezz = (integer)llLinksetDataRead(llList2String(TempList,z)); 
      string uuid = llList2String(TempList,z);  
      string rezz = llList2String(TempList,z+1);
      if(llLinksetDataRead(uuid) == "")
      {
      logs_send(uuid,"User rezz: 0 < "+rezz,rezz_level((integer)rezz-previous_rezz));
      llLinksetDataWrite(uuid,rezz);
      }
      if((integer)rezz >= previous_rezz+rezz_threshold)
      { 
      logs_send(uuid,"User rezz: "+(string)previous_rezz+" < "+rezz,rezz_level((integer)rezz-previous_rezz));
      llLinksetDataWrite(uuid,rezz);
      }
      if((integer)rezz <= previous_rezz-rezz_threshold)
      {
      logs_send(uuid,"User rezz: "+(string)previous_rezz+" > "+rezz,"9807270");
      llLinksetDataWrite(uuid,rezz);
      }
    }
  }
}
start_up() 
{
  list TempList = llGetParcelPrimOwners(llGetPos());
  integer Length = llGetListLength(TempList);
  if(!Length){ return; }else
  {
    integer z;
    for ( ; z < Length; z += 2)
    {
    llLinksetDataWrite(llList2String(TempList,z),llList2String(TempList,z+1));
    }
  }
}
default
{
    changed(integer change)
    {
    if (change & CHANGED_REGION_START){ llResetScript(); }
    } 
    on_rez(integer start_param) 
    {
    llResetScript();
    }
    state_entry()
    {
    llLinksetDataReset();       
    llSetTimerEvent(timer_event);  
    start_up(); 
    }
    timer()
    {  
    Monitor_Rezz();
    }
}