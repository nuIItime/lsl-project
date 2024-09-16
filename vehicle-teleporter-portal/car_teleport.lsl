string listen_only = "XXXX";
integer channel = 1463;
float teleport_timeout = 1;
default
{
    on_rez(integer start_param)
    {
    llResetScript();
    }
    state_entry()
    {
    llListen(channel,"","","");
    }
    listen(integer channel, string name, key id, string message)
    {
    if(llGetOwnerKey(id) == listen_only)
    { 
         list items = llParseString2List(message, ["|"], []);  
         if(llList2String(items,2) == "teleport")
         {            
         llSetStatus(STATUS_PHYSICS, FALSE);
         llSetRegionPos((vector)llList2String(items,0));
         llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_ROT_LOCAL,(rotation)llList2String(items,1)]);
         llSetStatus(STATUS_PHYSICS, TRUE);
         state A;
         }
      }
   }
}   
state A
{
    state_entry()
    {
    llSetTimerEvent(teleport_timeout);
    }
    timer()
    {
    llSetTimerEvent(0);     
    state default;       
    }    
}