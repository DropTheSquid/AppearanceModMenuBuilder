class AMM_AppearanceUpdater extends AMM_AppearanceUpdater_Base
    config(Game);

var Pawn_Parameter_Handler paramHandler;

public function UpdatePawnAppearance(BioPawn target, string source)
{
	local AMM_Pawn_Parameters params;

	LogInternal("dlc appearance update for target"@target@"from source"@source);
	// test that this is having an effect which will be overwritten by native appearance update
	if (paramHandler.GetPawnParams(target, params))
	{
		LogInternal("found params for pawn"@target@target.Tag@params);
	}
	else
	{
		LogInternal("did not find params for pawn"@target@target.Tag);
	}
	TestReplaceMesh(target);
	// target.Mesh.SetScale(0.6);
}

private function TestReplaceMesh(BioPawn target)
{
	local AppearanceMesh appearanceMesh;
	local Array<string> matStrings;

	// human male naked mesh; don't worry about it
	class'AMM_Utilities'.static.LoadSkeletalMesh("BIOG_HMM_ARM_NKD_R.NKDa.HMM_ARM_NKDa_MDL", AppearanceMesh.Mesh);

	// reasonable materials for that mesh
	matStrings.AddItem("BIOG_HMM_ARM_NKD_R.NKDa.HMM_ARM_NKDa_MAT_1a");
	class'AMM_Utilities'.static.LoadMaterials(matStrings, AppearanceMesh.Materials);
	class'AMM_Utilities'.static.ReplaceMesh(target, target.Mesh, AppearanceMesh);
}

defaultproperties
{
    Begin Object Class=Pawn_Parameter_Handler Name=paramHandlerInstance
    End Object
    paramHandler = paramHandlerInstance
}
