string WEBHOOK_URL = "xxxx";

integer sim_relay = 1111;

key keyurl;

string name(string a)
{
return llDeleteSubString(a,30,1000000);
}
string formatMemory(integer bytes)
{
    float mb = (float)bytes / 1048576.0;
    return (string)mb + " MB";
}
string pos(string position)
{
  vector ovF = (vector)position; float a = ovF.x; float b = ovF.y; float c = ovF.z;
  string position = (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c);
  return position;
}
string get_sim_analysis()
{
    
    list List = llGetAgentList(AGENT_LIST_REGION,[]);
    
    integer x;
    integer agent = llGetListLength(List);

    string report =
    "\n"+
    "Prims used: "+(string)llGetParcelPrimCount(llGetPos(),PARCEL_COUNT_TOTAL,FALSE)+"/"+(string)llGetParcelMaxPrims(llGetPos(),FALSE)+"\n"+
    "Prims left: "+(string)(llGetParcelMaxPrims(llGetPos(),FALSE) - (integer)llGetParcelPrimCount(llGetPos(),PARCEL_COUNT_TOTAL,FALSE))+"\n\n";

    report +=
    "Time dilation: "+(string)llRound((1-llGetRegionTimeDilation())*100)+"\n"+
    "Fps: "+llDeleteSubString((string)llGetRegionFPS(),4,100)+"\n\n"+
    "Agent: "+(string)agent+"\n"
    ;

    if(!agent){ return report; }
    
    for ( ; x < agent; x += 1)
    {
       if(llStringLength(report) > 1700){ report += "..."; return report; }
       
       list details = llGetObjectDetails(llList2Key(List,x), ([OBJECT_NAME]));
       report += (string)llList2Key(List,x)+"|"+name(llList2String(details,0))+"\n";
    }
    return report;
}
string get_avatar_analysis(key ID)
{
    vector agent = llGetAgentSize(ID);
    if(agent){ }else
    {
        return "Error: Target avatar is not present in this region.";
    }
    list attachments = llGetAttachedList(ID);
    integer Length = llGetListLength(attachments); 
    
    list avatar_details = llGetObjectDetails(ID, [
        OBJECT_NAME, 
        OBJECT_TOTAL_SCRIPT_COUNT, 
        OBJECT_RENDER_WEIGHT, 
        OBJECT_SCRIPT_MEMORY
    ]);
    
    string avName   = llList2String(avatar_details, 0);
    string sCount   = llList2String(avatar_details, 1);
    string ARC      = llList2String(avatar_details, 2); 
    integer sMem    = llList2Integer(avatar_details, 3);

    string report = "\n"
                  + "name: " + avName + "\n\n"
                  + "scripts count: " + sCount + "\n"
                  + "memory usage: " + formatMemory(sMem) + "\n"
                  + "complexity: " + ARC + "\n\n"
                  + "attachments: " + (string)Length + "\n";

    if (!Length)
    {
        report += "no attachments.";
        return report;
    }
    integer x = 0;
    for (; x < Length; x += 1)
    {
        if(llStringLength(report) > 1700)
        {
            report += "...";
            return report;
        }
        
        key attachID = llList2Key(attachments, x);
        list details = llGetObjectDetails(attachID, [OBJECT_NAME, OBJECT_TOTAL_SCRIPT_COUNT, OBJECT_STREAMING_COST]);
        
        report += llList2String(details, 0) 
                + " (scripts: " + llList2String(details, 1) 
                + " | streaming cost: " + llList2String(details, 2) + ")\n";
    }
    return report;
}
webhook_send(string Message, string description) 
{
    key http_request_id = llHTTPRequest(WEBHOOK_URL, [
        HTTP_METHOD, "POST", 
        HTTP_MIMETYPE, "application/json", 
        HTTP_VERIFY_CERT, TRUE, 
        HTTP_VERBOSE_THROTTLE, TRUE,
        HTTP_PRAGMA_NO_CACHE, TRUE
    ], llList2Json(JSON_OBJECT, ["username", llGetRegionName() + "", "content", Message + "\n" + description]));
}
integer valid_id(string uuid)
{
if((key)uuid){ return FALSE; }
return TRUE;
}
default
{
    on_rez(integer start_param) 
    {
      llResetScript();
    }
    changed(integer change)
    {
      if(change & CHANGED_REGION_START) { llResetScript(); }
    }
    state_entry()
    {
      keyurl = llRequestURL();
    }
    http_request(key id, string method, string body)
    {
        list items = llParseString2List(body, ["="], []);
        
        if ((method == URL_REQUEST_GRANTED) && (id == keyurl) )
        {
          webhook_send("url",(string)body); 
          keyurl = NULL_KEY;
        }
        if (method == "POST")
        {
            string admin_tool = llList2String(items,0); 
            string targetID = llList2String(items,1);
            
            if (admin_tool == "scan_sim")
            {
               string report = get_sim_analysis();
               llHTTPResponse(id,200,report);
               return; 
            }
            if (valid_id((string)targetID) == TRUE) 
            { 
               llHTTPResponse(id,200,"Invalid-uuid"); 
               return; 
            }
            if (admin_tool == "scan_avatar")
            {
               string report = get_avatar_analysis(targetID);
               llHTTPResponse(id,200,report);
               return; 
            }
            if (admin_tool == "blocked")
            {
               llHTTPResponse(id,200,"User protected, Cannot perform this action");
               return;
            }
            llHTTPResponse(id,200,admin_tool+"="+targetID);
            if (admin_tool == "pass") { llRegionSay(sim_relay, "pass|" + targetID); }
            if (admin_tool == "unpass") { llRegionSay(sim_relay, "unpass|" + targetID); }   
            if (admin_tool == "banned") { llRegionSay(sim_relay, "banned|" + targetID); }
            if (admin_tool == "unbanned") { llRegionSay(sim_relay, "unbanned|" + targetID); }
            return; 
            } 
          }
        }
