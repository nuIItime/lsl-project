/*
-------------------------------------
notecard configuration format sample.
-------------------------------------
Avatar/jack/parts=outfit # Load every outfit in that directory, Useful for universal multilayer's.
Avatar/jack/parts # Load every content in that directory.
Avatar/jack/parts=attach # Optional
Avatar/jack/parts=detach # Optional
delay=1 # Useful for slowing down fast load.
-------------------------------------
Avatar/jack/parts=attach
delay=1
Avatar/jack/parts=detach
-------------------------------------
Avatar/jack/shape&skin=outfit
delay=1
Avatar/jack/parts
delay=1
AO/jack/default
-------------------------------------
*/

integer ichannel = 1001;
integer search = FALSE;
integer attach_option;
integer cur_page = 1;
integer chanhandlr;
integer detach_all;
integer intLine1;
integer page0;
integer page1;
integer num;

key keyConfigQueryhandle;
key keyConfigUUID;

string note_name;
string select;

random(){ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, "");}
list order_buttons(list buttons)
{
return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
dialog_songmenu(integer page)
{
integer slist_size;
if(search==FALSE){slist_size=llGetInventoryNumber(INVENTORY_NOTECARD);}
if(search==TRUE){slist_size=num;}
integer pag_amt = llCeil((float)slist_size / 9.0);
if(page > pag_amt) page = 1;
else if(page < 1) page = pag_amt;
cur_page = page; integer songsonpage;
if(page == pag_amt)
songsonpage = slist_size % 9;
if(songsonpage == 0)
songsonpage = 9; integer fspnum = (page*9)-9; list dbuf; integer i;
for(; i < songsonpage; ++i){dbuf += [(string)(fspnum+i)+"'゜"];}
llDialog(llGetOwner(),"page - "+(string)page+"\n\n"+make_list(fspnum,i),order_buttons(dbuf + ["<<<", "[  ☰  ]", ">>>"]),ichannel);
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
    list items = llParseString2List(llLinksetDataRead("temp-"+(string)(a+i)),["|"],[]);
    string z = llDeleteSubString(llList2String(items,0),40,1000);
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
    string z = llDeleteSubString(name,40,1000);
    inventory += (string)(i+a)+". "+z+"\n";
    }
  }return inventory;
}
readnote(string notename)
{
    note_name = notename;
    if (llGetInventoryKey(note_name) == NULL_KEY)
    { 
    llOwnerSay("error could not find notecard"); 
    }else{
    intLine1 = 0;
    if(detach_all == TRUE){detach_attachment();}
    keyConfigQueryhandle = llGetNotecardLine(note_name, intLine1); 
    keyConfigUUID = llGetInventoryKey(note_name);
    }
}
match(string a,string b,integer c){if(~llSubStringIndex(llToLower(b),llToLower(a))){llLinksetDataWrite("temp-"+(string)num,b); num = num + 1;}}
search_engine(string search)
{
  num=0;
  integer x;
  for( ; x < llGetInventoryNumber(INVENTORY_NOTECARD); x += 1)
  {
  match(search,llGetInventoryName(INVENTORY_NOTECARD,x),x);
  } 
  dialog5();
}
detach_attachment()
{
   llOwnerSay("detaching all. ");
   llOwnerSay("@detach=n");
   llSleep(.2);
   llOwnerSay("@detach=force");
   llSleep(.2);
   llOwnerSay("@remoutfit=force");
   llSleep(.1);
   llOwnerSay("@detach=y");
}
attachment(string a)
{
  if(attach_option == TRUE)
  { 
  llOwnerSay("@attachover:"+a+"=force");
  llOwnerSay("attaching = "+a);
  }else{
  llOwnerSay("@detach:"+a+"=force");
  llOwnerSay("detaching = "+a);
  }
}
dialog0(){random(); dialog_songmenu(cur_page);}
dialog1()
{
if(llGetInventoryKey(select) == NULL_KEY){ dialog2();return;} random();
llDialog(llGetOwner(),llDeleteSubString(select,25,1000),["[ add ]","[ replace ]","[ detach ]","[  ❌  ]","[  ☰  ]","[  ←  ]"],ichannel);
}
dialog2(){random(); search = FALSE; llDialog(llGetOwner(),"menu\n\n",["[  🔍  ]","[  📋  ]","[  ⚠️  ]","[  ❌  ]"],ichannel);}
dialog3(){random(); search = FALSE; llDialog(llGetOwner(),"confirmation.\n\nDo you want to detach everything?",["[ yes ]","[ no ]"],ichannel);}
dialog4(){random(); search = TRUE; llLinksetDataDeleteFound("temp-",""); llTextBox(llGetOwner(),"search",ichannel);}
dialog5(){random(); if(!num){llOwnerSay("Could not find anything"); dialog2(); return;} cur_page = 1; dialog_songmenu(cur_page);}
default
{
    on_rez(integer start_param)
    {
    llResetScript();
    }
    touch_start(integer total_number)
    {
    if (llDetectedKey(0) == llGetOwner()){ dialog2(); }
    }
    listen(integer chan, string sname, key skey, string text)
    {  
    if(skey == llGetOwner()) 
    {
        if(text == "[ replace ]"){attach_option=TRUE; detach_all=TRUE; readnote(select); dialog1(); return;}
        if(text == "[ detach ]"){attach_option=FALSE; detach_all=FALSE; readnote(select); dialog1(); return;}
        if(text == "[ add ]"){attach_option=TRUE; detach_all=FALSE; readnote(select); dialog1(); return;} 
        if(text == "[  ⚠️  ]"){dialog3(); return;}

        if(text == "[ yes ]"){detach_attachment(); dialog2(); return;}
        if(text == "[ no ]"){dialog2(); return;}
        
        if(text == "[  📋  ]"){cur_page = 1; dialog0();return;}
        if(text == "[  🔍  ]"){dialog4(); return;}
        if(text == "[  ☰  ]"){dialog2();return;}
        if(text == "[  ←  ]"){dialog0();return;}
        
        if(text == "..."){dialog2();return;}
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
           select = llLinksetDataRead("temp-"+llList2String(items,0)); 
           dialog1(); 
           return;
           }
        }
        if(search == TRUE){ if(text){search_engine(text);return;}dialog2();}
        }
  }
  dataserver(key keyQueryId, string strData)
  {
  if (keyQueryId == keyConfigQueryhandle)
  {
     if (strData == EOF){ llOwnerSay("done loading notecard."); }else
     {
         keyConfigQueryhandle = llGetNotecardLine(note_name, ++intLine1);
         strData = llStringTrim(strData, STRING_TRIM_HEAD);
         if (llGetSubString (strData, 0, 0) != "#")
         {
               list items = llParseString2List(strData,["="],[]); 
               if(llList2String(items,0) != "delay")
               {
                  if(llList2String(items,1) == "outfit")
                  {
                     if(attach_option != TRUE){ attachment(llList2String(items,0));}else
                     {
                     llOwnerSay("@addoutfit:"+llList2String(items,0)+"=force");
                     llOwnerSay("addoutfit = "+llList2String(items,0));
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
               if(attach_option == TRUE){ llSleep((float)llList2String(items,1)); }
               }
            }
         }
      }
   }
}
