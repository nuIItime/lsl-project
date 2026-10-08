integer parcel_mode = TRUE;
integer Channel = 1111;

list ignore 
=[
"00000000-0000-0000-0000-000000000000",
"00000000-0000-0000-0000-000000000000"
];

key only_listen = "00000000-0000-0000-0000-000000000000";

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
    llListen(Channel,"","","");
    llSetLinkTextureAnim(LINK_THIS, ANIM_ON | LOOP, ALL_SIDES,4,2, 0, 64, 8 );
    }
    listen(integer c,string n, key i, string m)
    { 
    list items = llParseString2List(m, ["|"], []);
    if(parcel_mode = TRUE)
    { 
      if(llGetOwnerKey(i)==only_listen)
      {   
        if(llList2String(items,0) =="pass"){llAddToLandPassList(llList2String(items,1),0);}
        if(llList2String(items,0) =="unbanned"){llRemoveFromLandBanList(llList2String(items,1));}
      
        if (~llListFindList(ignore,[(string)llList2String(items,1)])){ }else
        {
        if(llList2String(items,0) =="unpass"){llRemoveFromLandPassList(llList2String(items,1));}
        if(llList2String(items,0) =="banned"){llTeleportAgentHome(llList2String(items,1)); llAddToLandBanList(llList2String(items,1),0);}
        } 
      }
    }else{
      if(llGetOwnerKey(i)==llGetOwner())
      {
        if(llList2String(items,0) == "pass"){ llManageEstateAccess(ESTATE_ACCESS_ALLOWED_AGENT_ADD, llList2String(items,1)); }
        if(llList2String(items,0) == "unbanned"){ llManageEstateAccess(ESTATE_ACCESS_BANNED_AGENT_REMOVE, llList2String(items,1)); }

        if (~llListFindList(ignore,[(string)llList2String(items,1)])){ }else
        {
        if(llList2String(items,0) == "unpass"){ llManageEstateAccess(ESTATE_ACCESS_ALLOWED_AGENT_REMOVE, llList2String(items,1)); } 
        if(llList2String(items,0) == "banned"){ llManageEstateAccess(ESTATE_ACCESS_BANNED_AGENT_ADD, llList2String(items,1)); }         
        } 
      }
    }
  }
}