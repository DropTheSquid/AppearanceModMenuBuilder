class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

var Pawn_Parameter_Handler paramHandler;

public function UpdatePawnAppearance(BioPawn target, string source)
{
	local AMM_Pawn_Parameters params;
	local PawnAppearanceIds appearanceIds;
	local OutfitSpecListBase outfitList;
	local OutfitSpecBase outfitSpec;

	LogInternal("appearance update for target"@PathName(target)@Target.Tag@"from source"@source);
	if (paramHandler.GetPawnParams(target, params))
	{
		LogInternal("found params for pawn"@target@target.Tag@params);
		LogInternal("appearanceType"@params.GetAppearanceType(target));
		if (params.GetCurrentAppearanceIds(target, appearanceIds))
		{
			LogInternal("appearanceIds"@appearanceIds.bodyAppearanceId@appearanceIds.helmetAppearanceId);
			outfitList = params.GetOutfitSpecList(target);
			if (outfitList == None)
			{
				LogInternal("Could not get outfit list");
			}
			// temp adding 1 for testing
			if (outfitList != none && outfitList.GetOutfitSpecById(appearanceIds.bodyAppearanceId + 1, outfitSpec))
			{
				LogInternal("Got outfit spec"@outfitSpec);
				outfitSpec.ApplyOutfit(target);
			}
		}
		else
		{
			LogInternal("Could not get appearance Ids");
		}
	}
	else
	{
		LogInternal("did not find params for pawn"@target@target.Tag);
	}
	// test that this is having an effect which will be overwritten by native appearance update
	//TestReplaceMesh(target);
	// target.Mesh.SetScale(0.6);
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
