string filter_option = ".";
string select;
string pass;

integer ichannel = 472;
integer cur_page = 1;
integer chanhandlr;
integer option = 0;
integer page0;
integer page1;

random(){ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "", NULL_KEY, "");}
list order_buttons(list buttons)
{
return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}
dialog_songmenu(integer page)
{
integer slist_size = llLinksetDataCountKeys();
integer pag_amt = llCeil((float)slist_size / 9.0);
if(page > pag_amt) page = 1;
else if(page < 1) page = pag_amt;
cur_page = page; integer songsonpage;
if(page == pag_amt)
songsonpage = slist_size % 9;
if(songsonpage == 0)
songsonpage = 9; integer fspnum = (page*9)-9; list dbuf; integer i;
for(; i < songsonpage; ++i){dbuf += [(string)(i)+"'゜"];}
llDialog(llGetOwner(),"page - "+(string)page+"\n\n"+make_list(fspnum,i),order_buttons(dbuf + ["<<<", "[ main ]", ">>>"]),ichannel);
}
string unkn(string k){if("" == k){if(llLinksetDataReadProtected(select,pass) == ""){return "����";}else{return llLinksetDataReadProtected(select,pass);}}pass = ""; return k;}
string unk(string k,string a){if("" == llLinksetDataReadProtected(select,pass)){return "[ pass ]";}return a;}
string unknown(string k){if("" == k){return "����";}return k;}
string make_list(integer a,integer b)
{
  integer i; string inventory; page0 = a; page1 = (a+b);
  list items = llLinksetDataFindKeys(filter_option,a,(a+b));
  for(i = 0; i < b; ++i)
  {
  string z = llDeleteSubString(unknown(llList2String(items,i)),10,1000)+"⟺"+llDeleteSubString(unknown(llLinksetDataRead(llList2String(items,i))),29,1000);
  inventory += (string)(i)+". "+z+"\n";
  }return inventory;
}
dialog1()
{
random();
string a = llLinksetDataRead(select);
llDialog(llGetOwner(),llDeleteSubString(select,10,1000)+"⟺"+llDeleteSubString(unkn(llLinksetDataRead(select)),29,1000)
,[unk(a,"[ delete ]"),unk(a,"[ rewrite ]"),unk(a,"[ say ]"),"[  🞪  ]","[ main ]","[  ←  ]"],ichannel);
}
dialog2()
{
random();
llDialog(llGetOwner(),
"main menu\n\n"+
"memory = "+(string)llLinksetDataAvailable()+"\n"+
"list count = "+(string)llLinksetDataCountKeys()+"\n"+
"filter = ' "+filter_option+" '\n",["[ filter ]","[ list ]","[ write ]","[  🞪  ]","...","[ Dele ]"],ichannel);
}
dialog0(){random();dialog_songmenu(cur_page);}
dialog3(){random();llDialog(llGetOwner(),"main",["[ main ]","[ delete_f ]","[ delete_all ]"],ichannel);}
dialog5(){random();llDialog(llGetOwner(),"main",["[ main ]","[ unprotect ]","[ protected ]"],ichannel);}
dialog4(string a,string b){random();llTextBox(llGetOwner(),a+".\n"+b,ichannel);}
default
{
    on_rez(integer start_param)
    {
    llResetScript();
    }
    touch_start(integer total_number)
    {
    if (llDetectedKey(0) == llGetOwner()){dialog2();}
    }
    listen(integer chan, string sname, key skey, string text)
    {  
    if(skey == llGetOwner()) 
    {
        if (llGetFreeMemory() < 10000){llResetScript();}
        if(text == "[ say ]"){llOwnerSay("[ key : "+select+" ][ value : "+llLinksetDataReadProtected(select,pass)+" ]");dialog1();return;}
        if(text == "[ protected ]"){option = 6;dialog4("write","sample : name=data=pass");return;}  
        if(text == "[ unprotect ]"){option = 3;dialog4("write","sample : name=data");return;}  
        if(text == "[ delete ]"){llLinksetDataDeleteProtected(select,pass);dialog0();return;}
        if(text == "[ filter ]"){option = 1;dialog4("filter","default ' . '");return;}
        if(text == "[ delete_f ]"){option = 2;dialog4("data delete found","");return;}
        if(text == "[ rewrite ]"){option = 4;dialog4("rewrite data","");return;}  
        if(text == "[ delete_all ]"){llLinksetDataReset();dialog2();return;}
        if(text == "[ pass ]"){option = 5;dialog4("enter pass","");return;}   
        if(text == "[ list ]"){cur_page = 1; dialog0();return;}
        if(text == "[ write ]"){dialog5();return;}
        if(text == "[ main ]"){dialog2();return;}
        if(text == "[ Dele ]"){dialog3();return;}
        if(text == "[  ←  ]"){dialog0();return;}
        if(text == "[  🞪  ]"){llResetScript();}
        if(text == "..."){dialog2();return;}
        if(text == ">>>"){dialog_songmenu(cur_page+1);return;}
        if(text == "<<<"){dialog_songmenu(cur_page-1);return;}
        list items = llParseString2List(text, ["'"], []);
        if(llList2String(items,1) == "゜")
        {
        list a = llLinksetDataFindKeys(filter_option,page0,page1);
        select = llList2String(a,(integer)llList2String(items,0));
        dialog1();return;
        }
        if(option == 6)
        {
        list a = llParseString2List(text,["="], []);
        llLinksetDataWriteProtected(llList2String(a,0),llList2String(a,1),llList2String(a,2)); dialog2();
        }
        if(option == 3)
        {
        list a = llParseString2List(text,["="], []);
        llLinksetDataWrite(llList2String(a,0),llList2String(a,1)); dialog2();
        }
        if(option == 4){llLinksetDataWriteProtected(select,text,pass);dialog1();}
        if(option == 2){llLinksetDataDeleteFound(text,"");dialog2();}
        if(option == 1){filter_option = text;dialog2();} 
        if(option == 5){pass = text;dialog1();}
        }
        option = 0;
        return;
        }
    }
