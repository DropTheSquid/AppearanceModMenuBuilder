class VanillaBreatherSpec extends BreatherSpecBase config(Game);

enum eVisorState
{
	unchanged,
	show,
	hide
};

public function bool LoadBreather(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eVisorState visorState;

	LogInternal("LoadBreather");
	GetVanillaBreatherMesh(class'AMM_Utilities'.static.GetPawnType(target), appearance.BreatherMesh, visorState);

	if (visorState == eVisorState.Show)
	{
		class'AMM_Utilities'.static.GetVanillaVisorMesh(class'AMM_Utilities'.static.GetPawnType(target), appearance.VisorMesh);
	}
	else if (visorState == eVisorState.hide)
	{
		appearance.VisorMesh.Mesh = None;
		appearance.VisorMesh.Materials.Length = 0;
	}

	// TODO I don't think in vanilla that the breather has the ability to hide the head, which kinda seems like an oversight, but whatever

	return true;
}

private static function GetVanillaBreatherMesh(BioPawnType pawnType, out AppearanceMesh breatherMesh, out eVisorState visorState)
{
	local Array<BioFacePlateMeshSpec> breatherMeshSpecs;
	local Array<MaterialInterface> breatherMaterialSpecs;

	breatherMeshSpecs = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_aFacePlateMeshSpec;
	breatherMaterialSpecs = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apFacePlateMaterial;

	if (breatherMeshSpecs.Length == 0 || breatherMaterialSpecs.Length == 0)
	{
		// this will be the case for Wrex, and is fine and expected
		breatherMesh.Mesh = None;
        breatherMesh.Materials.Length = 0;
		visorState = eVisorState.unchanged;
		return;
	}

	//  this is an array, I think there can theoretically be more than one breather spec, indexed by a property on the appearance settings
	// but I have never seen it actually used, so I think I am going to ignore it.
	breatherMesh.Mesh = breatherMeshSpecs[0].m_pMesh;
	// there is a very weird thing in vanilla where the m_bHidesVisor on the breather spec
	// means actively un hide it if it is false. so we need to follow that here
	visorState = breatherMeshSpecs[0].m_bHidesVisor ? eVisorState.hide : eVisorState.show;
	
	// Ashley has a vanilla bug where her visor gets hidden. It is fixed in LE1CP, but not in all other places. I can programatically fix it here. 
	if (PathName(breatherMesh.Mesh) ~= "BIOG_HMF_HGR_LGT_R.BRT.HMF_BRT_LGT_MDL")
	{
		visorState = eVisorState.show;
	}


	// similarly, this is an array, but I am not sure if it is for a visor with multiple materials or to index into different visor specs, as above
	// I am going to pretend it only ever deals with a single spec with one material.
	breatherMesh.Materials[0] = breatherMaterialSpecs[0];

	// the game only lists the first material of his breather mesh, but this causes issues if you swap to his default from one of the other 2 material breathers
	// where it uses the second material from the old one. This should fix it by loading the second material in that case.
	if (PathName(breatherMesh.Mesh) ~= "BIOG_HMM_HGR_MED_R.BRTb.HMM_BRTb_MED_MDL" && PathName(breatherMesh.Materials[0]) ~= "BIOG_HMM_HGR_MED_R.BRTb.HMM_BRT_MEDb_Mat_1a")
	{
		breatherMesh.Materials[1] = MaterialInterface(DynamicLoadObject("BIOG_HMM_HGR_MED_R.BRTb.HMM_BRTb_MED_MAT_2a", class'MaterialInterface'));
	}
}


