public event function Deactivated()
{
    local BioPawn TargetPawn;
    local array<string> matchingDescs;
    local bool shouldUpdateAppearance;
    local string tempString;
    local int I;
    local array<BioPawn> targetPawns;
    local SequenceVariable tempSeqVar;
    
	// entirely added. covers a wide variety of places where 
    Super(SequenceOp).Deactivated();
    I = VariableLinks.Find('LinkDesc', "Target");
    if (I == -1)
    {
        return;
    }
    foreach VariableLinks[I].LinkedVariables(tempSeqVar, )
    {
        if (SeqVar_Object(tempSeqVar) != None && BioPawn(SeqVar_Object(tempSeqVar).GetObjectValue()) != None)
        {
            targetPawns.AddItem(BioPawn(SeqVar_Object(tempSeqVar).GetObjectValue()));
        }
    }
    matchingDescs.AddItem("Armor Override");
    matchingDescs.AddItem("Tag");
    matchingDescs.AddItem("Hidden");
    matchingDescs.AddItem("Helmet: Override");
    matchingDescs.AddItem("Helmet: Show Visor");
    matchingDescs.AddItem("Helmet: Show Helmet");
    matchingDescs.AddItem("Helmet: Show Face-plate");
    matchingDescs.AddItem("Helmet: Prefer Visible");
	// active?
    foreach matchingDescs(tempString, )
    {
        if (VariableLinks.Find('LinkDesc', tempString) != -1)
        {
            shouldUpdateAppearance = TRUE;
            break;
        }
    }
    if (shouldUpdateAppearance)
    {
        foreach targetPawns(TargetPawn, )
        {
			Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(TargetPawn, "BioSeqAct_ModifyPropertyPawn.Deactivate");
        }
    }
}