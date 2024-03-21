class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

var Pawn_Parameter_Handler paramHandler;
var transient string outerWorldInfoPath;

public function UpdatePawnAppearance(BioPawn target, string source)
{
	local AMM_Pawn_Parameters params;
	local PawnAppearanceIds appearanceIds;
	local OutfitSpecListBase outfitList;
	local OutfitSpecBase outfitSpec;

	UpdateOuterWorldInfo();
	LogInternal("appearance update for target"@PathName(target)@Target.Tag@"from source"@source);
	if (paramHandler.GetPawnParams(target, params))
	{
		params.SpecialHandling(target);
		if (params.GetCurrentAppearanceIds(target, appearanceIds))
		{
			outfitList = params.GetOutfitSpecList(target);
			if (outfitList == None)
			{
				LogInternal("Warning: Could not get outfit list");
				return;
			}
			if (outfitList.GetOutfitSpecById(appearanceIds.bodyAppearanceId, outfitSpec))
			{
				outfitSpec.ApplyOutfit(target);
				// This call is very important to prevent all kinds of weirdness
				// for example bone melting and materials misbehaving, and possibly even crashing
				target.ForceUpdateComponents(FALSE, FALSE);
			}
		}
		else
		{
			LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		}
	}
}
private function UpdateOuterWorldInfo()
{
	local BioWorldInfo tempWorldInfo;

    tempWorldInfo = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    if (tempWorldInfo.GetPackageName() != 'BIOG_UIWorld')
    {
        outerWorldInfoPath = PathName(tempWorldInfo);
    }
}
public static function bool IsInCharacterCreator(out BioSFHandler_NewCharacter ncHandler)
{
	local AMM_AppearanceUpdater_Base instance;
	local BioWorldInfo BWI;
    local string path;

	if (GetInstance(instance))
	{
		path = AMM_AppearanceUpdater(instance).outerWorldInfoPath;
		BWI = BioWorldInfo(FindObject(path, Class'BioWorldInfo'));
		if (BWI != None)
		{
			ncHandler = BWI.m_UIWorld.m_oNCHandler;
			return ncHandler != None;
		}
		return false;
	}
	return false;
}

defaultproperties
{
    Begin Object Class=Pawn_Parameter_Handler Name=paramHandlerInstance
    End Object
    paramHandler = paramHandlerInstance
}
