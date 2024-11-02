list animations_stand 
=[
"stand0",
"stand1",
"stand2",
"stand3",
"stand4",
"stand5",
"stand6",
"stand7",
"stand8",
"stand9",
"stand10"
];

string turning_right_animation = "turning_right"; 
string turning_left_animation = "turning_left";
string Flying_Down_animation = "Flying Down";
string Flying_Up_animation = "Flying Up";
string Walk_animation = "Walk";

string message = 
"\n
movement control ASDW\n
[ E+C = menu ]
[ W+S+C = reset speed ]
[ W+S+E = increase speed ]
";

float self_destruct_time = 200;
float speed_rot = 0.02;
float speed_Pos = 0.2;
float event_timer = .01;
float coune;

vector panic_offset = <800,800,100>;
vector avoid_offset = <0,20,0>;
vector movementDirection;
vector avatar_offset;
vector gPointerPos;
vector previouspos;

rotation gPointerRot;

integer target_confirm = FALSE;
integer switch_mode = FALSE;
integer permission = FALSE;
integer avoid_mode = FALSE;
integer rotationDirection;
integer gesture_channel = 100;
integer ichannel = 10909;
integer chanhandlr;
integer a = FALSE;

key target;
key agent;

take_control_permissions()
{
llSetCameraParams([
CAMERA_ACTIVE,TRUE,
CAMERA_BEHINDNESS_ANGLE,5.0,
CAMERA_BEHINDNESS_LAG,0.1,
CAMERA_DISTANCE,7.0,
CAMERA_FOCUS_LAG,0.0,
CAMERA_FOCUS_OFFSET,<0.0,0.0,1.0>,
CAMERA_FOCUS_THRESHOLD,0.5,
CAMERA_PITCH,5.0]);

llTakeControls(
CONTROL_BACK|
CONTROL_FWD|
CONTROL_LEFT|
CONTROL_RIGHT|
CONTROL_ROT_LEFT|
CONTROL_ROT_RIGHT|
CONTROL_DOWN|
CONTROL_UP,
TRUE,FALSE);
}
string teleport_return(){if(previouspos != ZERO_VECTOR){return"[ return ]";}return"[ r̶e̶t̶u̶r̶n̶ ]";}
string movement(){if(switch_mode == FALSE){return"[ default ]";}return"[ offset ]";}
string follow(){if(target_confirm == FALSE){return"[ follow ]";}return"[ f̶o̶l̶l̶o̶w̶ ]";}
string deflect(){if(avoid_mode == TRUE){return"[ a̶v̶o̶i̶d̶ ]";}return"[ avoid ]";}
dialog_menu()
{
random(); llDialog(agent,"menu.",([movement(),"[ teleport ]",deflect(),"[ panic ]",teleport_return(),follow(),"[ exit ]","...","[ reset ]"]),ichannel);
}
random()
{
ichannel = llFloor(llFrand(1000000) - 100000); llListenRemove(chanhandlr); chanhandlr = llListen(ichannel, "",agent, "");
}
list CastDaRay(vector start, rotation direction)
{
list results = llCastRay(start,start+<5000,0.0,0.0>*direction,
[RC_REJECT_TYPES, RC_REJECT_AGENTS,RC_DETECT_PHANTOM,TRUE,
RC_DATA_FLAGS,RC_GET_NORMAL,RC_MAX_HITS,1]);
return results;
}
play_animation(string animation) 
{
if(permission == TRUE)
{  
    integer i;
    integer num = llGetInventoryNumber(INVENTORY_ANIMATION);
    for (i = 0; i < num; ++i) 
    {
      string name = llGetInventoryName(INVENTORY_ANIMATION, i); 
      if (name == animation){llStartAnimation(name);}else
      {
      llStopAnimation(name);
} } } }
runtime()
{ 
    if(avoid_mode == TRUE){if(switch_mode == FALSE){switch_mode = TRUE; gPointerPos = avoid_offset; dialog_menu(); return;}}
    if(switch_mode == FALSE)
    {
    list od = llGetObjectDetails(llGetKey(), [OBJECT_POS, OBJECT_ROT]);
    gPointerPos = llList2Vector(od, 0);gPointerRot = llList2Rot(od, 1);     
    gPointerPos += movementDirection * speed_Pos * 1 * gPointerRot;
    gPointerRot = llEuler2Rot(llRot2Euler(gPointerRot) + <0.0, 0.0, rotationDirection * speed_rot * PI>);
    llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_POSITION,gPointerPos,PRIM_ROTATION,gPointerRot]);
    }else{
    gPointerPos += movementDirection * speed_Pos * 1 * gPointerRot;  
    gPointerRot = llEuler2Rot(llRot2Euler(gPointerRot) + <0.0, 0.0, rotationDirection * speed_rot * PI>);
    llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,gPointerPos,PRIM_ROT_LOCAL,gPointerRot]);
}   } 
reset()
{
llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,avatar_offset]);
llTargetOmega(<0,0,0>,TWO_PI,0);
llSleep(1);  
llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_ROTATION,<0,0,0,0>]); 
}
avoid()
{
llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_ROTATION,<0,0,0,0>]); 
llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,<0,0,0>]);
llSleep(1); 
llTargetOmega(<0,0,.5>,TWO_PI,1.0);
llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,avoid_offset]);
llSleep(1);
if(target_confirm == FALSE){llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_POSITION,gPointerPos-avoid_offset]);}
llTargetOmega(<0,0,0>,TWO_PI,0);
}
follower()
{
  if(target_confirm == TRUE)
  {  
    list a = llGetObjectDetails(target, ([OBJECT_POS,OBJECT_PRIM_COUNT]));   
    if(llList2Integer(a,1) == 0){ }else
    {
    if(avoid_mode == TRUE){vector ovF = gPointerPos; llSetRegionPos((llList2Vector(a,0)-(<ovF.x,ovF.y,0>*llGetLocalRot())));}     
    if(avoid_mode == FALSE){llSetRegionPos(llList2Vector(a,0));} 
} } }
pilot()
{
  a = FALSE;  
  integer objectPrimCount = llGetObjectPrimCount(llGetKey());
  integer currentLinkNumber = llGetNumberOfPrims();
  for (; objectPrimCount < currentLinkNumber; --currentLinkNumber)
  {
  if(llGetLinkKey(currentLinkNumber)==agent){a = TRUE;}else{llUnSit(llGetLinkKey(currentLinkNumber));}
  }
  if(a == TRUE){coune = 0;return;} 
  if(a == FALSE){if(coune>self_destruct_time){llDie();}else{coune = coune + 1;}}
}
default
{
    state_entry()
    {
    llSitTarget(<0,0,1>,llGetLocalRot());
    llSetAlpha(1,ALL_SIDES);
    llVolumeDetect(TRUE);
    }
    run_time_permissions(integer perm)
    {
      if(perm & PERMISSION_TAKE_CONTROLS)
      {
      llSetTimerEvent(0);   
      take_control_permissions();
      vector  size = llGetAgentSize(agent)*0.65;
      if(permission == FALSE){llListen(gesture_channel,"",agent,""); llRegionSayTo(agent,0,message); permission = TRUE;} 
      avatar_offset = <0,0,size.z>; llStopAnimation("sit"); llSetAlpha(0, ALL_SIDES); llSetScale(<0,0,0>);
      play_animation(llList2String(animations_stand,(integer)llFrand(llGetListLength(animations_stand))));
      llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,avatar_offset]);
      llSetTimerEvent(event_timer);
      }
    }
    changed(integer change)
    { 
    if(permission == FALSE){if (change & CHANGED_LINK)
    {
       agent = llAvatarOnSitTarget();
       if (agent)
       {
       llRequestPermissions(agent,PERMISSION_TAKE_CONTROLS|PERMISSION_TRIGGER_ANIMATION|PERMISSION_CONTROL_CAMERA|PERMISSION_TRACK_CAMERA);
    }}}}
    listen(integer c,string n, key i, string m)
    {
    if(permission == TRUE)
    {  
      if(llGetOwnerKey(i)==agent)
      {
      if(c == gesture_channel){ if(m == "menu"){dialog_menu();return;}}
      if(m == "[ panic ]"){switch_mode = TRUE; gPointerPos = panic_offset; llSetLinkPrimitiveParamsFast(2, [PRIM_POS_LOCAL,panic_offset]);}
      if(m == "[ offset ]"){llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,avatar_offset]);switch_mode = FALSE; avoid_mode = FALSE; llSleep(.5);}
      if(m == "[ return ]"){if(previouspos != ZERO_VECTOR){llSetRegionPos(previouspos);}}
      if(m == "[ follow ]"){random(); llTextBox(agent,"enter uuid",ichannel); return;}
      if(m == "[ default ]"){switch_mode = TRUE; gPointerPos = avatar_offset;}  
      if(m == "[ f̶o̶l̶l̶o̶w̶ ]"){target_confirm = FALSE; target = "";}  
      if(m == "[ exit ]"){return;}
      if(m == "[ reset ]")
      {
         speed_Pos = 0.2; llRegionSayTo(agent,0,"restart take control.");
         llRequestPermissions(agent,PERMISSION_TAKE_CONTROLS|PERMISSION_TRIGGER_ANIMATION|PERMISSION_CONTROL_CAMERA|PERMISSION_TRACK_CAMERA);
      }
      if(m == "[ a̶v̶o̶i̶d̶ ]")
      {
         play_animation(llList2String(animations_stand,(integer)llFrand(llGetListLength(animations_stand)))); 
         switch_mode = FALSE; avoid_mode = FALSE; reset();
      }
      if(m == "[ avoid ]")
      {
         play_animation(llList2String(animations_stand,(integer)llFrand(llGetListLength(animations_stand)))); 
         avoid_mode = TRUE; avoid(); return;
      }  
      if(m == "[ teleport ]")
      {
        list results = CastDaRay(llGetCameraPos(),llGetCameraRot()); vector hit = llList2Vector(results,1);
        if(hit != ZERO_VECTOR){previouspos = llGetPos();llSetRegionPos(hit);}else{previouspos = llGetPos();llSetRegionPos(llGetCameraPos());}
      }
      if((key)m)
      {
        target_confirm = TRUE; target = m;
        if(avoid_mode == TRUE){gPointerPos = avoid_offset;}
        if(avoid_mode == FALSE){llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,avatar_offset]);}
      }
      dialog_menu(); return;
    }}}
    control(key name, integer levels, integer edges)
    {
      movementDirection = ZERO_VECTOR;
      rotationDirection = 0;
      if(levels == 48)
      {
        dialog_menu();llSleep(0.2);
        return;
      }
      if(levels == 35)
      {
        speed_Pos = 0.2;llRegionSayTo(agent,0,"reset speed");llSleep(0.2);
        return;
      }
      if(levels == 19)
      {
        speed_Pos = speed_Pos+1;llRegionSayTo(agent,0,"set speed "+(string)speed_Pos);llSleep(0.2);
        return;
      }
      if(~levels & edges)
      {
        play_animation(llList2String(animations_stand,(integer)llFrand(llGetListLength(animations_stand))));
        llSetLinkPrimitiveParamsFast(2, [PRIM_ROT_LOCAL,llEuler2Rot(<0 * DEG_TO_RAD,0* DEG_TO_RAD,0 * DEG_TO_RAD>)]);
        return;
      }
      if(levels & CONTROL_BACK)
      {
        movementDirection.x--; play_animation(Walk_animation);
        if(switch_mode == FALSE){llSetLinkPrimitiveParamsFast(2, [PRIM_ROT_LOCAL,llEuler2Rot(<0 * DEG_TO_RAD,0* DEG_TO_RAD, 180.0000 * DEG_TO_RAD>)]);}
        return;
      }
      if(levels == 257){movementDirection.x++; rotationDirection++; play_animation(Walk_animation); return;}      
      if(levels == 513){movementDirection.x++; rotationDirection--; play_animation(Walk_animation); return;} 
      if(levels & CONTROL_FWD){movementDirection.x++; play_animation(Walk_animation);}
      if(levels & CONTROL_DOWN){movementDirection.z--; play_animation(Flying_Down_animation);}
      if(levels & CONTROL_UP){movementDirection.z++; play_animation(Flying_Up_animation);}
      if(levels & CONTROL_LEFT){rotationDirection++; play_animation(turning_left_animation);}
      if(levels & CONTROL_RIGHT){rotationDirection--; play_animation(turning_right_animation);}
      if(levels & CONTROL_ROT_LEFT){rotationDirection++; play_animation(turning_left_animation);}
      if(levels & CONTROL_ROT_RIGHT){rotationDirection--; play_animation(turning_right_animation);}  
      } 
      timer()
      {
        if(permission == TRUE)
        {
        follower();  
        runtime();
        pilot();
    } } }