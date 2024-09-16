key keyConfigQueryhandle;
key keyConfigUUID;
integer intLine1;
integer rat_mode;
integer c = 80;
string  note_name;
integer readnote(string notename)
{
    note_name = notename;
    if (llGetInventoryKey(note_name) == NULL_KEY)
    {
    return 0; 
    }
    else
    {
    intLine1 = 0;
    keyConfigQueryhandle = llGetNotecardLine(note_name, intLine1); 
    keyConfigUUID = llGetInventoryKey(note_name);
    return 1;
    }
}
default 
{
    on_rez(integer start_param) 
    {
    llResetScript();
    }  
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
        llResetScript();
        }
    }
    state_entry() 
    {
    llSetLinkTextureAnim(2, ANIM_ON | LOOP, 2, 3, 6, 0, 64, 6.4 );
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
    list params = llParseString2List(msg, ["|"], []);
    string cmd = llList2String(params, 0);
    string param1 = llList2String(params, 1);
    if(cmd == "fetch_note_rationed")
    {
          string nname = llDumpList2String(llList2ListStrided(params, 1, -1, 1), " ");
          llMessageLinked(LINK_THIS,0,"erase", NULL_KEY);
          if(readnote(nname) == 0)
          {
          llSay(0,"error could not find notecard");
          }
       }
    }
    dataserver(key keyQueryId, string strData)
    {
        if (keyQueryId == keyConfigQueryhandle)
        {
            if (strData == EOF)
            {
            llMessageLinked(LINK_THIS,0,"start", NULL_KEY); 
            }
            else
            {
                keyConfigQueryhandle = llGetNotecardLine(note_name, ++intLine1);
                strData = llStringTrim(strData, STRING_TRIM_HEAD);
                if (llGetSubString (strData, 0, 0) != "#")
                {
                llMessageLinked(LINK_THIS, 0, "upload_note|" + strData, NULL_KEY);
                }
            }
        }
    }
}
