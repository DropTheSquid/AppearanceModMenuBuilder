public event function Deactivated()
{
	local BioPawn TargetPawn;
	local array<string> matchingDescs;
	local bool shouldUpdateAppearance;
	local string tempString;
	local int i;
	local array<BioPawn> targetPawns;
	local SequenceVariable tempSeqVar;
	local bool overrideHelmet;
	local bool forceHelmet;
	local bool forceBreather;
	local bool setHelmetPreference;
	local bool helmetPreference;
	local SeqVarLink tempSeqVarLink;

	// entirely added. covers a wide variety of places where a pawn's appearance might need to be updated
	Super(SequenceOp).Deactivated();
	// first, find the list of Target variable links
	i = VariableLinks.Find('LinkDesc', "Target");
	if (i == -1)
	{
		return;
	}
	// and collect any valid target pawns this seq action links to
	foreach VariableLinks[i].LinkedVariables(tempSeqVar, )
	{
		if (SeqVar_Object(tempSeqVar) != None && BioPawn(SeqVar_Object(tempSeqVar).GetObjectValue()) != None)
		{
			targetPawns.AddItem(BioPawn(SeqVar_Object(tempSeqVar).GetObjectValue()));
		}
	}
	foreach VariableLinks(tempSeqVarLink, I)
    {
		switch (tempSeqVarLink.LinkDesc)
		{
			case "Armor Override":
			case "Tag":
			case "Active":
			case "Hidden":
			case "Helmet: Show Visor":
			case "m_oActorType":
				shouldUpdateAppearance = true;
				break;
			case "Helmet: Override":
				shouldUpdateAppearance = true;
				tempSeqVar = tempSeqVarLink.LinkedVariables[0];
				if (SeqVar_Bool(tempSeqVar) != None && SeqVar_Bool(tempSeqVar).bValue == 1)
				{
					overrideHelmet = true;
				}
				break;
			case "Helmet: Show Helmet":
				shouldUpdateAppearance = true;
				tempSeqVar = tempSeqVarLink.LinkedVariables[0];
				if (SeqVar_Bool(tempSeqVar) != None && SeqVar_Bool(tempSeqVar).bValue == 1)
				{
					forceHelmet = true;
				}
				break;
			case "Helmet: Show Face-plate":
				shouldUpdateAppearance = true;
				tempSeqVar = tempSeqVarLink.LinkedVariables[0];
				if (SeqVar_Bool(tempSeqVar) != None && SeqVar_Bool(tempSeqVar).bValue == 1)
				{
					forceBreather = true;
				}
				break;
			case "Helmet: Prefer Visible":
				shouldUpdateAppearance = true;
				tempSeqVar = tempSeqVarLink.LinkedVariables[0];
				if (SeqVar_Bool(tempSeqVar) != None)
				{
					setHelmetPreference = true;
					helmetPreference = SeqVar_Bool(tempSeqVar).bValue == 1;
				}
				break;
		}
	}
	if (setHelmetPreference)
	{
		foreach targetPawns(TargetPawn, )
		{
			Class'AMM_AppearanceUpdater_Base'.static.UpdateHelmetPreferenceStatic(TargetPawn, helmetPreference, false);
		}
	}
	if (overrideHelmet && !forceBreather)
	{
		foreach targetPawns(TargetPawn, )
		{
			Class'AMM_AppearanceUpdater_Base'.static.UpdateHelmetPreferenceStatic(TargetPawn, forceHelmet, true);
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