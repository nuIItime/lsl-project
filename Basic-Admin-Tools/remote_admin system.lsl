>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
CLI_admin_control.py
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

import urllib.parse

import urllib.request

def submitInformation(url,parameters):
    encodedParams = urllib.parse.urlencode(parameters).encode("utf-8")
    req = urllib.request.Request(url)
    net = urllib.request.urlopen(req,encodedParams)
    print(net.read())
    return(net.read())

enter_url = input("enter url : ")

print("""

select option

[1] scan
[2] kick
[3] banned-estate
[4] banned-parcel
[5] unbanned-estate
[6] unbanned-parcel
[7] request url

""")

option = input("enter option : ")

parameters = {'authentication':'random'}
info = submitInformation(enter_url,parameters)

authentication = input("enter authentication : ")
parameters = {'authentication':authentication}
info = submitInformation(enter_url,parameters)

if (option == "1"):

     parameters = {'scan':'avatar'}
     info = submitInformation(enter_url,parameters)

if (option == "2"):

     uuid = input("enter uuid : ")

     parameters = {'kick':uuid}
     info = submitInformation(enter_url,parameters)

if (option == "3"):

     uuid = input("enter uuid : ")

     parameters = {'banned-estate':uuid}
     info = submitInformation(enter_url,parameters)

if (option == "4"):

     uuid = input("enter uuid : ")

     parameters = {'banned-parcel':uuid}
     info = submitInformation(enter_url,parameters)

if (option == "5"):

     uuid = input("enter uuid : ")

     parameters = {'unbanned-estate':uuid}
     info = submitInformation(enter_url,parameters)

if (option == "6"):

     uuid = input("enter uuid : ")

     parameters = {'unbanned-parcel':uuid}
     info = submitInformation(enter_url,parameters)
     
if (option == "7"):

     parameters = {'request':'url'}
     info = submitInformation(enter_url,parameters)
     
else:

     exit()


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

string WEBHOOK_URL = "XXXX";
string authentication;
string url;
integer limit_attempt = 3;
integer verified0 = FALSE;
integer verified1 = FALSE;
integer access = FALSE;
integer timeout = 20;
integer relay = 10;
integer attempt;
key keyurl;
webhook_send(string Message,string description) 
{
key http_request_id = llHTTPRequest(WEBHOOK_URL,[HTTP_METHOD,"POST",HTTP_MIMETYPE,
"application/json",HTTP_VERIFY_CERT, TRUE,HTTP_VERBOSE_THROTTLE,TRUE,
HTTP_PRAGMA_NO_CACHE,TRUE],llList2Json(JSON_OBJECT,
["username",llGetRegionName()+"","content",Message+"\n"+description]));
}
string AgentInfo(key avatar)
{ 
   if(llGetAgentInfo(avatar) & AGENT_ON_OBJECT)  return "sitting on object";
   if(llGetAgentInfo(avatar) & AGENT_AWAY)  return "afk";
   if(llGetAgentInfo(avatar) & AGENT_BUSY)  return "busy";
   if(llGetAgentInfo(avatar) & AGENT_CROUCHING)  return "crouching";
   if(llGetAgentInfo(avatar) & AGENT_FLYING)  return "flying";
   if(llGetAgentInfo(avatar) & AGENT_IN_AIR)  return "in air";
   if(llGetAgentInfo(avatar) & AGENT_MOUSELOOK)  return "mouse look";
   if(llGetAgentInfo(avatar) & AGENT_SITTING)  return "sitting";
   if(llGetAgentInfo(avatar) & AGENT_TYPING)  return "typing";
   if(llGetAgentInfo(avatar) & AGENT_WALKING)  return "walking";     
   if(llGetAgentInfo(avatar) & AGENT_ALWAYS_RUN)  return "running";
   return "standing";
}
string lookforagent() 
{
        list List = llGetAgentList(AGENT_LIST_REGION, []);
        integer Length = llGetListLength(List);
        list detect_list = [];     
        if (!Length)
        {
        return"no one detected";
        }
        else
        {
            integer x;
            for ( ; x < Length; x += 1)
            {
            list details = llGetObjectDetails(llList2Key(List, x), ([OBJECT_NAME,OBJECT_POS]));
            vector ovF = llList2Vector(details,1); float a = ovF.x; float b = ovF.y; float c = ovF.z;
            string position = "position : "+ (string)((integer)a)+", "+(string)((integer)b)+", "+(string)((integer)c);
            detect_list += (list)llList2String(details,0)+"\n"+"uuid : "+llList2String(List, x)+"\n"+position+"\n"+"status : "+AgentInfo(llList2Key(List, x))+"\n"+"\n";
            }
      }return (string)detect_list;
}
string valid_id(string uuid)
{ 
if((key)uuid)return "valid "+uuid;
return"invalid "+uuid;
}
random()
{
    verified0 = FALSE;
    verified1 = FALSE;
    access = FALSE;
    llSetTimerEvent(0);
    string generate_code = 
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9))+
    (string)((integer)llFrand(9));
    authentication = generate_code;
}
attempts(key id)
{
    if(attempt>limit_attempt)
    {
    llHTTPResponse(id,200,"too many attempts changing url.");
    llResetScript(); 
    }
    else
    {
    llHTTPResponse(id,200,"access denied.");
    random();
    attempt = attempt + 1;  
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
        if (change & CHANGED_REGION_START)         
        {
        llResetScript();
        }
    }
    state_entry()
    {
    random();
    keyurl = llRequestURL();
    }
    http_request(key id, string method, string body)
    {
    list items = llParseString2List(body, ["="], []);
    if ((method == URL_REQUEST_GRANTED) && (id == keyurl) )
    {
    webhook_send("url",(string)body); 
    url = body; keyurl = NULL_KEY;
    }
    else if (method == "POST")
    {
                if (body == "authentication=random")
                {
                    if(verified0 == FALSE)
                    {  
                    llHTTPResponse(id,200,"sending code.");
                    string generate_code = 
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9))+
                    (string)((integer)llFrand(9));
                    webhook_send("verification code",generate_code);
                    authentication = generate_code;
                    llSetTimerEvent(timeout);
                    verified0 = TRUE;
                    verified1 = TRUE;
                    return;
                    }
                }
                if(verified1 == TRUE)
                { 
                    if (llList2String(items,1) == authentication)
                    {  
                    llHTTPResponse(id,200,"access granted.");
                    verified0 = TRUE;
                    verified1 = FALSE;
                    access = TRUE;
                    attempt = 0;
                    return;
                    }
             }
      }
      if(access == TRUE)
      {
             if (body == "request=url")
             {  
                 llHTTPResponse(id,200,"requesting new url.");
                 llResetScript();
             }
             if (body == "scan=avatar")
             {  
                 llHTTPResponse(id,200,"scan complete.");
                 webhook_send("Avatar_Scan",lookforagent());
                 random();
                 return;
             }
             if (llList2String(items,0) == "kick")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 webhook_send("kick",llList2String(items,1));
                 llRegionSay(relay,"kick|"+llList2String(items,1));
                 random();
                 return;
             }
             if (llList2String(items,0) == "banned-parcel")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 webhook_send("banned",llList2String(items,1));
                 llRegionSay(relay,"banned|"+llList2String(items,1));
                 random();
                 return;
             }
             if (llList2String(items,0) == "unbanned-parcel")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 webhook_send("unbanned",llList2String(items,1));
                 llRegionSay(relay,"unbanned|"+llList2String(items,1));
                 random();
                 return;   
             }
             if (llList2String(items,0) == "banned-estate")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 webhook_send("banned",llList2String(items,1));
                 llManageEstateAccess(ESTATE_ACCESS_BANNED_AGENT_ADD,llList2String(items,1));
                 random();
                 return;
             }
             if (llList2String(items,0) == "unbanned-estate")
             {
                 llHTTPResponse(id,200,valid_id(llList2Key(items,1)));
                 webhook_send("unbanned",llList2String(items,1));
                 llManageEstateAccess(ESTATE_ACCESS_BANNED_AGENT_REMOVE,llList2String(items,1));
                 random();
                 return;
             }   
      }
      else
      {
      attempts(id);
      }
}
timer()
{
    random();
    }
}
