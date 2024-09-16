integer distance_limit = 30;
integer channel = 1463;
float timeout = 1;
default
{ 
    on_rez(integer start_param)
    {
    llResetScript();
    }
    state_entry()
    {    
    llVolumeDetect(TRUE);
    llListen(channel,"","","");
    }
    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner())
        { 
        llRegionSay(channel,(string)llGetPos()+"|"+(string)llGetRot()+"|"+llGetObjectName());
        state A;
        }
    }
    listen(integer c,string n, key i, string m)
    {
       if(llGetOwnerKey(i)==llGetOwner())
       {
          list items = llParseString2List(m, ["|"], []);
          if(llList2String(items,2) == llGetObjectName())
          {
          llSetObjectDesc(llList2String(items,0)+"="+llList2String(items,1));
          llRegionSayTo(llGetOwner(),0,llList2String(items,0)+"=="+llList2String(items,1)+" establish connection");
          }
       }  
    }
    collision_start(integer total_number)
    {
    key ID = llDetectedKey(0);
    if(llGetAgentInfo(llGetOwnerKey(ID)) & AGENT_SITTING)
    {
    float dist=llVecDist(llList2Vector(llGetObjectDetails(ID,[OBJECT_POS]),0),llGetPos()); 
    if(dist>distance_limit){ return; }else
    { 
      list items = llParseString2List(llGetObjectDesc(), ["="], []);
      if((vector)llList2String(items,0) != ZERO_VECTOR){ if(llDetectedType(0) & ACTIVE)
      { 
          llRegionSayTo(ID,channel,llList2String(items,0)+"|"+llList2String(items,1)+"|teleport");
          state A;
          } 
        }
      }  
    }
  }
}
state A
{
    state_entry()
    {
    llSetTimerEvent(timeout);
    }
    timer()
    {
    llSetTimerEvent(0);     
    state default;       
    }    
}
