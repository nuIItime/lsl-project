/*
-------------------------------------
notecard configuration format sample.
-------------------------------------
Avatar/jack/parts=outfit # Load every outfit in that directory, Useful for universal multilayer's.
Avatar/jack/parts # Load every content in that directory.
Avatar/jack/parts=attach # Optional
Avatar/jack/parts=detach # Optional
1=delay # Useful for slowing down fast load.
-------------------------------------
Avatar/jack/parts=attach
1=delay
Avatar/jack/parts=detach
-------------------------------------
Avatar/jack/shape&skin=outfit
1=delay
Avatar/jack/parts
1=delay
AO/jack/default
-------------------------------------
*/

integer ichannel = 1001;
integer attach_option;
integer notecard_line;
integer cur_page = 1;
integer chanhandlr;

integer page0;
integer page1;

integer automatic_detach;
integer search;
integer sync;

integer previous_list;
integer search_count;
integer outfit_list;

string search_sample = "\n\nsearch sample : coffee or coffee+tea\n";
string select;

list ignore_command =["delay","outfit"];

key key_notecard_query;

string search_status()
{
  if(search==TRUE)
  {
  return"[  🚫  ]";
  }
  return"[  🔍  ]";
}
random()
{ 
ichannel = llFloor(llFrand(1000000) - 100000); 
llListenRemove(chanhandlr); 
chanhandlr = llListen(ichannel, "", NULL_KEY, ""); 
}
dialog0()
{
random(); 
dialog_songmenu(cur_page);
}
dialog1()
{
  if(llGetInventoryKey(select) == NULL_KEY)
  {
  dialog2();
  }else{
  random();
  llDialog(llGetOwner(),"selection\n\n"+
  "name - "+llDeleteSubString(select,35,1000)+"\n\n"+
  "description\n"+llDeleteSubString(llGetInventoryDesc(select),120,1000)+"\n"
  ,["[ add ]","[ apply ]","[ detach ]",
  "[ sync ]","[ replace ]","[ detach all ]",
  "[  ❌  ]","[  ☰  ]","[  ←  ]"],ichannel);
  }
}
dialog2()
{
random(); 
llDialog(llGetOwner(),"menu\n\n",[search_status(),"[  📋  ]","[  ☢️  ]","[  ❌  ]","⋯","[  →  ]"],ichannel);
}
dialog3()
{
random(); 
llDialog(llGetOwner(),"confirmation.\n\nDo you want to detach everything?",["[ yes ]","[ no ]"],ichannel);
}
dialog4()
{
random(); 
llLinksetDataDeleteFound("search-",""); llTextBox(llGetOwner(),"search\n"+search_sample,ichannel);
}
dialog5()
{
  random();
  if(!search_count)
  {
  llOwnerSay("Could not find anything"); dialog2(); 
  }else{
  cur_page = 1; 
  search = TRUE; 
  dialog_songmenu(cur_page);
  }
}
dialog6()
{
random(); 
llDialog(llGetOwner(),"confirmation.\n\nDo you want to detach everything?",[" [ yes ] "," [ no ] "],ichannel);
}
list order_buttons(list buttons)
{
return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
dialog_songmenu(integer page)
{
  integer slist_size;
  if(search==FALSE){ slist_size=llGetInventoryNumber(INVENTORY_NOTECARD); }
  if(search==TRUE){ slist_size=search_count; }
  integer pag_amt = llCeil((float)slist_size / 9.0);
  if(page > pag_amt) page = 1;
  else if(page < 1) page = pag_amt;
  cur_page = page; integer songsonpage;
  if(page == pag_amt)
  songsonpage = slist_size % 9;
  if(songsonpage == 0)
  songsonpage = 9; integer fspsearch_count = (page*9)-9; list dbuf; integer i;
  for(; i < songsonpage; ++i){dbuf += [(string)(fspsearch_count+i)+"'゜"];}
  llDialog(llGetOwner(),"page - "+(string)page+"\n\n"+make_list(fspsearch_count,i),order_buttons(dbuf + ["<<<", "[  ☰  ]", ">>>"]),ichannel);
}
string make_list(integer a,integer b)
{
  string inventory;
  if(search == TRUE)
  {
    integer i;
    page0 = a; 
    page1 = (a+b);
    for(i = 0; i < b; ++i)
    {
    list items = llParseString2List(llLinksetDataRead("search-"+(string)(a+i)),["|"],[]);
    string z = llDeleteSubString(llList2String(items,0),39,1000);
    inventory += (string)(i+a)+". "+z+"\n";
    }
  }
  if(search == FALSE)
  {
    integer i;
    page0 = a;
    page1 = (a+b);
    for(i = 0; i < b; ++i)
    {
    string name = llGetInventoryName(INVENTORY_NOTECARD,a+i);
    string z = llDeleteSubString(name,39,1000);
    inventory += (string)(i+a)+". "+z+"\n";
    }
  }
  return inventory;
}
readnote(string notename)
{
    if(llGetInventoryKey(notename) == NULL_KEY)
    { 
    llOwnerSay("Error could not find or empty."); 
    }else{
    notecard_line = 0;
    key_notecard_query = llGetNotecardLine(notename,notecard_line);
    llOwnerSay("load = "+notename);
    }
}
match(string input,string item_name,string description)
{
    if(~llSubStringIndex(llToLower(item_name),llToLower(input)))
    {
    llLinksetDataWrite("search-"+(string)search_count,item_name); 
    search_count = search_count + 1;
    }
    else if(~llSubStringIndex(llToLower(description),llToLower(input)))
    {
    llLinksetDataWrite("search-"+(string)search_count,item_name); 
    search_count = search_count + 1;
    }else{
    return;
    }
}
search_engine(string input)
{
  search_count=0;
    
  list items = llParseString2List(input,["+"],[]);
  integer Length = llGetListLength(items);
  integer c;
  if (!Length)
  { 
     integer x;
     for( ; x < llGetInventoryNumber(INVENTORY_NOTECARD); x += 1)
     {
     string name = llGetInventoryName(INVENTORY_NOTECARD,x);
     match(input,name,llGetInventoryDesc(name));
     }
     dialog5(); 
     return;
  }
  for ( ; c < Length; c += 1)
  {
     integer x;
     for( ; x < llGetInventoryNumber(INVENTORY_NOTECARD); x += 1)
     {
     string name = llGetInventoryName(INVENTORY_NOTECARD,x);
     match(llList2String(items,c),name,llGetInventoryDesc(name));
     } 
  }
  dialog5();
}
detach_attachment()
{
  llOwnerSay("@detach=n");
  llSleep(.2);
  llOwnerSay("@detach=force");
  llOwnerSay("@remoutfit=force");
  llSleep(.2);
  llOwnerSay("@detach=y");
}
attachment(string a)
{
  if(attach_option == TRUE)
  { 
  llOwnerSay("@attachover:"+a+"=force");
  llOwnerSay("attaching = "+a);
  llLinksetDataWrite("previous-"+(string)previous_list,a);
  previous_list = previous_list + 1;
  }else{
  llOwnerSay("@detach:"+a+"=force");
  llOwnerSay("detaching = "+a);
  }
}
integer match_previous(string a)
{
  integer c;
  for ( ; c < outfit_list; c += 1)
  {
    string strData = llLinksetDataRead("outfit-"+(string)c);     
    if(strData == a)
    { 
    return FALSE; 
    }
  }
  return TRUE;
}
detach_previous_outfit()
{
  integer c;
  if (!previous_list)
  { 
  detach_attachment(); 
  return; 
  }
  for ( ; c < previous_list; c += 1)
  {
    string strData = llLinksetDataRead("previous-"+(string)c); 
    list items = llParseString2List(strData,["="],[]);
    if(match_previous(strData)==TRUE)
    {
      if (!llGetListLength(items))
      {
        llOwnerSay("@detach:"+strData+"=force");
        llOwnerSay("auto_detach = "+strData);
      }else{
        if(~llListFindList(ignore_command,[llList2String(items,1)])){ }else
        {
        llOwnerSay("@detach:"+llList2String(items,0)+"=force");
        llOwnerSay("auto_detach = "+llList2String(items,0));
        }
      }
    }
  }
  llLinksetDataDeleteFound("previous-","");
  previous_list = 0;
}
load_outfit()
{
  integer c;
  if(automatic_detach == TRUE)
  { 
  detach_previous_outfit(); 
  }
  for ( ; c < outfit_list; c += 1)
  {
        string strData = llLinksetDataRead("outfit-"+(string)c); 
        list items = llParseString2List(strData,["="],[]);
        if(llList2String(items,1) != "delay")
        {
          if(llList2String(items,1) == "outfit")
          {
            if(attach_option != TRUE)
            { 
            attachment(llList2String(items,0));
            }else{
            llOwnerSay("@addoutfit:"+llList2String(items,0)+"=force");
            llOwnerSay("add_outfit = "+llList2String(items,0));
            llLinksetDataWrite("previous-"+(string)previous_list,strData);
            previous_list = previous_list + 1;
            }
          }
          else if(llList2String(items,1) == "attach")
          {
            if(attach_option == TRUE)
            { 
            llOwnerSay("@attachover:"+llList2String(items,0)+"=force");
            llOwnerSay("auto_attach = "+llList2String(items,0));
            }
          }
          else if(llList2String(items,1) == "detach")
          {
            if(attach_option == TRUE)
            { 
            llOwnerSay("@detach:"+llList2String(items,0)+"=force");
            llOwnerSay("auto_detach = "+llList2String(items,0));
            }
          }else{
          attachment(strData); 
          }
        }else{
        if(attach_option == TRUE){ llSleep((float)llList2String(items,0)); }
        }
    }
    llLinksetDataDeleteFound("outfit-","");
    outfit_list = 0;
}
nuke()
{
llLinksetDataDeleteFound("previous-","");
llLinksetDataDeleteFound("outfit-","");
previous_list = 0;
outfit_list = 0;
}
default
{
    on_rez(integer start_param)
    {
    llResetScript();
    }
    state_entry()
    {
    llLinksetDataReset();
    }
    touch_start(integer total_search_countber)
    {
    if (llDetectedKey(0) == llGetOwner()){ dialog2(); }
    }
    listen(integer chan, string sname, key skey, string text)
    {
    if(skey == llGetOwner()) 
    {
        if(text == "[ replace ]"){attach_option=TRUE; automatic_detach=FALSE; nuke(); detach_attachment(); readnote(select); dialog1(); return;}
        if(text == "[ detach ]"){attach_option=FALSE; automatic_detach=FALSE; nuke(); readnote(select); dialog1(); return;}
        if(text == "[ add ]"){attach_option=TRUE; automatic_detach=FALSE; nuke(); readnote(select); dialog1(); return;}
        if(text == "[ apply ]"){attach_option=TRUE; automatic_detach=TRUE; readnote(select); dialog1(); return;}
        if(text == "[ sync ]"){sync=TRUE; nuke(); readnote(select); dialog1(); return;}
        if(text == "[  📋  ]"){cur_page = 1; dialog0();return;}
        
        if(text == " [ yes ] "){llOwnerSay("detaching all."); nuke(); detach_attachment(); dialog1(); return;}
        if(text == " [ no ] "){dialog1();return;}

        if(text == "[ yes ]"){llOwnerSay("detaching all."); nuke(); detach_attachment(); dialog2(); return;}
        if(text == "[ no ]"){dialog2();return;}

        if(text == "[  🚫  ]"){search = FALSE; dialog2();return;}
        if(text == " ⋯ "){dialog1();return;}
        if(text == "⋯"){dialog2();return;}

        if(text == "[ detach all ]"){dialog6();return;}
        if(text == "[  ☰  ]"){dialog2();return;}
        if(text == "[  ☢️  ]"){dialog3();return;}
        if(text == "[  🔍  ]"){dialog4();return;}
        if(text == "[  ←  ]"){dialog0();return;}
        if(text == "[  →  ]"){dialog1();return;}
        if(text == "[  ❌  ]"){return;}

        if(text == ">>>"){dialog_songmenu(cur_page+1);return;}
        if(text == "<<<"){dialog_songmenu(cur_page-1);return;}
        list items = llParseString2List(text, ["'"], []);
        if(llList2String(items,1) == "゜")
        {
           if(search == FALSE)
           {
           select = llGetInventoryName(INVENTORY_NOTECARD,(integer)llList2String(items,0));
           dialog1(); 
           return;
           }
           if(search == TRUE)
           {
           select = llLinksetDataRead("search-"+llList2String(items,0)); 
           dialog1();
           return;
           }
       }
       if(search == FALSE)
       {
            if(text)
            { 
            search_engine(text);
            }else{
            dialog2();
            }
         }  
      }
   }
   dataserver(key id, string data)
   {
   if(id == key_notecard_query)
   {
      if(data == EOF)
      { 
         if(sync==FALSE){ load_outfit(); } 
         llOwnerSay("finish loading.");
         sync=FALSE; 
         }else{
             key_notecard_query = llGetNotecardLine(select,++notecard_line);
             data = llStringTrim(data, STRING_TRIM_HEAD);
             if(sync==TRUE)
             {
               list items = llParseString2List(data,["="],[]);
               if(!llGetListLength(items))
               { 
                 llOwnerSay("syncing = "+data); 
               }else{
                 if(~llListFindList(ignore_command,[llList2String(items,1)])){ }else
                 { 
                 llOwnerSay("syncing = "+llList2String(items,0)); 
                 } 
               }
               llLinksetDataWrite("previous-"+(string)previous_list,data); 
               previous_list = previous_list + 1;
             }else{
             llLinksetDataWrite("outfit-"+(string)outfit_list,data);
             outfit_list = outfit_list + 1;
             }
          }
       }
    }
 }
