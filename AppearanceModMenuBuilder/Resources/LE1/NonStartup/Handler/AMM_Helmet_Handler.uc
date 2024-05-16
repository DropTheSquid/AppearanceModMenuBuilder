Class AMM_Helmet_Handler extends AMM_Handler_Helper;

public function string GetHelmetButtonText(BioPawn target, string appearanceType)
{
	local AMM_Pawn_Parameters params;
	local pawnAppearance noHelmetAppearance;
	local pawnAppearance helmetAppearance;
	local pawnAppearance fullHelmetAppearance;
	local bool hasDistinctHelmetAppearance;
	local bool HasDistinctFullHelmetAppearance;
	local bool HasDistinctBreatherAppearance;

	if (!_outermenu.paramHandler.GetPawnParams(target, params))
	{
		return "";
	}
	params.SpecialHandling(target);
	if (!GetAppearanceForHelmetType(target, params, eHelmetDisplayState.off, appearanceType, noHelmetAppearance)
		|| !GetAppearanceForHelmetType(target, params, eHelmetDisplayState.on, appearanceType, helmetAppearance)
		|| !GetAppearanceForHelmetType(target, params, eHelmetDisplayState.full, appearanceType, fullHelmetAppearance))
	{
		return "";
	}
	// check for differences between all of them
	HasDistinctHelmetAppearance = DoAppearancesDiffer(noHelmetAppearance, helmetAppearance);
	HasDistinctFullHelmetAppearance = DoAppearancesDiffer(helmetAppearance, fullHelmetAppearance);
	HasDistinctBreatherAppearance = DoAppearancesDiffer(noHelmetAppearance, fullHelmetAppearance);
	if (!HasDistinctHelmetAppearance && !HasDistinctFullHelmetAppearance)
	{
		// all are identical; we should not show this button
		return "";
	}
	// if helmet differs from none, but full does not differ from helmet
	// or full differs from none but not from helmet
	if ((HasDistinctHelmetAppearance && !HasDistinctFullHelmetAppearance)
		|| HasDistinctBreatherAppearance && !HasDistinctFullHelmetAppearance)
	{
		// there are two states; have a toggle button
		// "Toggle Helmet"
		return string($174544);
	}
	// the only remaining possibility is that all three are distinct
	// "Cycle Helmet"
	return string($210210248);
}

private function bool GetAppearanceForHelmetType(BioPawn Target, AMM_Pawn_Parameters params, eHelmetDisplayState helmetType, string appearanceType, out pawnAppearance appearance)
{
	local PawnAppearanceIds appearanceIds;
	local SpecLists specLists;

	if (params.GetAppearanceIds(appearanceType, appearanceIds))
	{
		specLists = params.GetSpecLists(target);
		if (specLists.outfitSpecs == None)
		{
			return false;
		}
		appearanceIds.m_appearanceSettings.helmetDisplayState = helmetType;
		if (specLists.outfitSpecs.DelegateToOutfitSpecById(target, specLists, appearanceIds, appearance))
		{
			return true;
		}
		return false;
	}
	else
	{
		LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		return false;
	}
}

private function bool DoAppearancesDiffer(pawnAppearance first, pawnAppearance second)
{
	if (first.hideHair != second.HideHair || first.hideHead != second.HideHead)
	{
		return true;
	}
	if (DoAppearanceMeshesDiffer(first.bodyMesh, second.bodyMesh)
		|| DoAppearanceMeshesDiffer(first.HelmetMesh, second.HelmetMesh)
		|| DoAppearanceMeshesDiffer(first.VisorMesh, second.VisorMesh)
		|| DoAppearanceMeshesDiffer(first.BreatherMesh, second.BreatherMesh))
	{
		return true;
	}
	return false;
}

private function bool DoAppearanceMeshesDiffer(AppearanceMesh first, AppearanceMesh second)
{
	local int i;
	if (first.Mesh != second.Mesh)
	{
		return true;
	}
	if (first.Materials.Length != second.Materials.Length)
	{
		return true;
	}
	for (i = 0; i < first.Materials.Length; i++)
	{
		if (first.Materials[i] != second.Materials[i])
		{
			return true;
		}
	}
	return false;
}