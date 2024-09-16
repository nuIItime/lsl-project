key keyurl;

default
{
    on_rez(integer start_param) 
    {
    llResetScript();
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
    llOwnerSay("url="+(string)body);  
    keyurl = NULL_KEY;
    }
    if (method == "POST")
    {
        if (llList2String(items,0) == "say")
        {
        string item = llReplaceSubString(llList2String(items,1), "+", " ", 200);
        llHTTPResponse(id,200,item);
        llSay(0,item);
        return;
        }
      }  
    }   
  }