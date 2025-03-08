//creator lllegaimexican

vector  Offset = <0,0,0>;
vector Pos;
rotation Rot;
integer PrimCount;
integer Count;

integer fullPerms() {
    integer fullPerms  = PERM_COPY | PERM_MODIFY | PERM_TRANSFER;
    if ((llGetObjectPermMask(MASK_OWNER) & fullPerms) == fullPerms) return TRUE;
    llOwnerSay("Error: Object must be full perms to duplicate");
    return FALSE;
}

integer chkObject() {
   if(llGetInventoryNumber(INVENTORY_OBJECT)) return TRUE;
   llOwnerSay("Error: No Object.\nPlease drop an object in inventory with the creator name to duplicate");
   return FALSE;
}

integer chkCount() {
    llOwnerSay("Linkset Prim Count = "+(string)Count);
    if (Count>128) {
    llOwnerSay("Error: OverFill.\nTotal Linkset Prim Count is "+(string)Count+"\nOnly 128 prims may be duplicated due to SL limitations.\nManually separate "+(string)(Count-128)+" or more prims from the linkset.\nRun "+llGetScriptName()+" on both linksets then manually re-link.");
    return(FALSE);
    }
    return(TRUE);     
}

rezObject() {
    llRezObject(llGetInventoryName(INVENTORY_OBJECT, 0), Pos + Offset, ZERO_VECTOR, Rot, 0);
}

linkPrim(key id) {
    llCreateLink(id, TRUE);
    Count--;
    if (Count<=0) {shape(); return;}
    rezObject();
    if (!((Count-2)%5)) llOwnerSay((string)(Count-2)+" more prims to rez");
}

startRez() {
    if (Count<=0) {llOwnerSay("Error: No Tables Found"); return;}
    Rot=llGetRot();
    Pos=llGetPos();
    llRequestPermissions(llGetOwner(), PERMISSION_CHANGE_LINKS);
}

breakLink() {
    integer i;
    integer prim=PrimCount+2;
    list transparent = [];
    llOwnerSay("Creating new and deleting old");
    for(i=PrimCount;i>1; i--) transparent +=[PRIM_LINK_TARGET, PrimCount+i, PRIM_COLOR, ALL_SIDES, <1,1,1>, 0];
    llSetLinkPrimitiveParamsFast(1 ,[PRIM_COLOR, ALL_SIDES, <1,1,1>, 0]+transparent);
    llSetPrimitiveParams([PRIM_TEMP_ON_REZ,TRUE]);
    for(i=PrimCount;i>1; i--)llBreakLink(prim);
    llSetPrimitiveParams([PRIM_TEMP_ON_REZ,FALSE]);
    llBreakLink(1);
    llOwnerSay("Duplication Finished");
    llDie(); 
}

setTexture(integer copy, integer prim) {
    integer i;
    integer sides = llGetLinkNumberOfSides(prim);
    for(i=0;i<sides;i++) {
        llSetLinkPrimitiveParamsFast(copy,[PRIM_TEXTURE,i]+llGetLinkPrimitiveParams(prim,[PRIM_TEXTURE,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_TEXGEN,i]+llGetLinkPrimitiveParams(prim,[PRIM_TEXGEN,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_COLOR,i]+llGetLinkPrimitiveParams(prim,[PRIM_COLOR,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_BUMP_SHINY,i]+llGetLinkPrimitiveParams(prim,[PRIM_BUMP_SHINY,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_GLOW,i]+llGetLinkPrimitiveParams(prim,[PRIM_GLOW,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_NORMAL,i]+llGetLinkPrimitiveParams(prim,[PRIM_NORMAL,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_SPECULAR,i]+llGetLinkPrimitiveParams(prim,[PRIM_SPECULAR,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_ALPHA_MODE,i]+llGetLinkPrimitiveParams(prim,[PRIM_ALPHA_MODE,i]));
        llSetLinkPrimitiveParamsFast(copy,[PRIM_FULLBRIGHT,i]+llGetLinkPrimitiveParams(prim,[PRIM_FULLBRIGHT,i]));
    }
}

shape() {
    integer i;
    integer prim;
    llOwnerSay("shaping and positioning prims");
    for(i=1;i<=PrimCount; i++) {
    if(i==1) prim=1; else prim = i+PrimCount;
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_TYPE]+llGetLinkPrimitiveParams(prim,[PRIM_TYPE]));
    if(i!=1) llSetLinkPrimitiveParamsFast(i+1,[PRIM_ROT_LOCAL]+llGetLinkPrimitiveParams(prim,[PRIM_ROT_LOCAL]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_POS_LOCAL]+[Offset + llList2Vector(llGetLinkPrimitiveParams(prim,[PRIM_POS_LOCAL]),0)]);
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_SIZE]+llGetLinkPrimitiveParams(prim,[PRIM_SIZE]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_SLICE]+llGetLinkPrimitiveParams(prim,[PRIM_SLICE]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_PHYSICS_SHAPE_TYPE]+llGetLinkPrimitiveParams(prim,[PRIM_PHYSICS_SHAPE_TYPE]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_POINT_LIGHT]+llGetLinkPrimitiveParams(prim,[PRIM_POINT_LIGHT]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_MATERIAL]+llGetLinkPrimitiveParams(prim,[PRIM_MATERIAL]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_SIZE]+llGetLinkPrimitiveParams(prim,[PRIM_SIZE]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_PHYSICS]+llGetLinkPrimitiveParams(prim,[PRIM_PHYSICS]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_PHANTOM]+llGetLinkPrimitiveParams(prim,[PRIM_PHANTOM]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_TEXT]+llGetLinkPrimitiveParams(prim,[PRIM_TEXT]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_OMEGA]+llGetLinkPrimitiveParams(prim,[PRIM_OMEGA]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_FLEXIBLE]+llGetLinkPrimitiveParams(prim,[PRIM_FLEXIBLE]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_NAME]+llGetLinkPrimitiveParams(prim,[PRIM_NAME]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_DESC]+llGetLinkPrimitiveParams(prim,[PRIM_DESC]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_ALLOW_UNSIT]+llGetLinkPrimitiveParams(prim,[PRIM_ALLOW_UNSIT]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_SCRIPTED_SIT_ONLY]+llGetLinkPrimitiveParams(prim,[PRIM_SCRIPTED_SIT_ONLY]));
    llSetLinkPrimitiveParamsFast(i+1,[PRIM_SIT_TARGET]+llGetLinkPrimitiveParams(prim,[PRIM_SIT_TARGET]));
    setTexture(i+1,prim);
    }
    breakLink();
}
 
default
{
    on_rez(integer start) {
        llResetScript();
    }

    state_entry() {
        if(!chkObject()){llRemoveInventory(llGetScriptName()); return;} 
        Count = PrimCount = llGetNumberOfPrims();
        if (!chkCount()){llRemoveInventory(llGetScriptName()); return;} 
        startRez();
    }
    
    run_time_permissions(integer perm) {
        if (perm & PERMISSION_CHANGE_LINKS) rezObject();
        else llOwnerSay("Error: No permissions to link");
    }
    
    object_rez(key id){
        linkPrim(id);        
    }

}
