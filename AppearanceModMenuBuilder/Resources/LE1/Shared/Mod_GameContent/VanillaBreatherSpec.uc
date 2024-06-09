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
	// similarly, this is an array, but I am not sure if it is for a visor with multiple materials or to index into different visor specs, as above
	// I am going to pretend it only ever deals with a single spec with one material.
	breatherMesh.Materials[0] = breatherMaterialSpecs[0];
}


