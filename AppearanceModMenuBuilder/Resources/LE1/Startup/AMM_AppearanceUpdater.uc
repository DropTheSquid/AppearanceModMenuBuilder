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
	// LogInternal("appearance update for target"@PathName(target)@Target.Tag@"from source"@source);
	if (paramHandler.GetPawnParams(target, params))
	{
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
			}
		}
		else
		{
			LogInternal("Warning: Could not get appearance Ids from params"@params@target);
		}
	}
	// else
	// {
	// 	LogInternal("did not find params for pawn"@target@target.Tag);
	// }
	// test that this is having an effect which will be overwritten by native appearance update
	//TestReplaceMesh(target);
	// target.Mesh.SetScale(0.6);
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
private function TestReplaceMesh(BioPawn target)
{
	local AppearanceMesh appearanceMesh;
	local Array<string> matStrings;

	// Tali mesh edited to have 4 materials
	class'AMM_Utilities'.static.LoadSkeletalMesh("Qrn_Arm_MultiMaterial.LGTa.QRN_FAC_ARM_LGTa_MDL", AppearanceMesh.Mesh);

	// reasonable materials for that mesh
	matStrings.AddItem("Qrn_Arm_MultiMaterial.LGTa.QRN_FAC_ARM_LGTa_MAT_1a");
	matStrings.AddItem("Qrn_Arm_MultiMaterial.LGTa.QRN_FAC_ARM_LGTa_MAT_1b");
	matStrings.AddItem("Qrn_Arm_MultiMaterial.LGTa.QRN_FAC_ARM_LGTa_MAT_2a");
	matStrings.AddItem("Qrn_Arm_MultiMaterial.LGTa.QRN_FAC_ARM_LGTa_MAT_2b");
	class'AMM_Utilities'.static.LoadMaterials(matStrings, AppearanceMesh.Materials);
	class'AMM_Utilities'.static.ReplaceMesh(target, target.Mesh, AppearanceMesh);
}

defaultproperties
{
    Begin Object Class=Pawn_Parameter_Handler Name=paramHandlerInstance
    End Object
    paramHandler = paramHandlerInstance
}
