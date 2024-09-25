Class DefaultOutfitSpec extends OutfitSpecBase;

// var bool TestHandlingOn0;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local OutfitSpecBase delegateSpec;
    local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;
    local AMM_Pawn_Parameters params;

    // disabled, but can be reenabled for testing
    // if (TestHandlingOn0 && appearanceIds.bodyAppearanceId == 0)
    // {
    //     return CopyRealPawnAppearance(target, specLists, appearanceIds, appearance);
    // }

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
		return false;
	}

    BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    globalVars = BWI.GetGlobalVariables();

    // if the equipped armor mod setting is on and this is a squadmate (but not the player) in a combat appearance
    if (globalVars.GetInt(1601) == 1
        && AMM_Pawn_Parameters_Squad(params) != None
        && AMM_Pawn_Parameters_Player(params) == None
        && params.GetAppearanceType(target) ~= "combat")
    {
        // then use the Equipped armor spec
        delegateSpec = new Class'EquippedArmorOutfitSpec';
    }
    else
    {
        // otherwise, defer to vanilla behavior
        delegateSpec = new Class'VanillaOutfitSpec';
    }
    return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
}

// private function bool CopyRealPawnAppearance(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
// {
//     local BioPawn realWorldPawn;
//     local string currentPawnPath;
//     local BioPawn tempActor;

//     // if this target is not in the UI world, ignore it and do nothing
//     if (!(target.GetPackageName() == 'BIOG_UIWORLD'))
//     {
//         LogInternal("doing nothing to pawn"@PathName(target)@target.tag);
//         return false;
//     }

//     foreach class'AMM_AppearanceUpdater'.static.GetDlcInstance().handledPawns(currentPawnPath)
//     {
//         tempActor = BioPawn(FindObject(currentPawnPath, class'BioPawn'));
//         // LogInternal("checking actor"@PathName(tempActor)@tempActor.Tag);
//         if (BioPawn(tempActor) != None && tempActor.Tag == target.Tag && tempActor.GetPackageName() == target.UniqueTag)
//         {
// 			realWorldPawn = BioPawn(tempActor);
//             LogInternal("found real world pawn"@PathName(realWorldPawn)@realWorldPawn.Tag);
//             break;
//         }
//     }

//     if (realWorldPawn == None)
//     {
//         LogInternal("could not find real world pawn for target"@target.Tag);
//         return false;
//     }

//     LogInternal("Copying body mesh stuff over");
//     // now copy their mesh and stuff over
//     CopyMesh(realWorldPawn.Mesh, appearance.bodyMesh);
//     LogInternal("Copying headgear mesh stuff over");
//     CopyMesh(realWorldPawn.m_oHeadGearMesh, appearance.HelmetMesh);
//     LogInternal("Copying visor mesh stuff over");
//     CopyMesh(realWorldPawn.m_oVisorMesh, appearance.VisorMesh);
//     LogInternal("Copying faceplate mesh stuff over");
//     CopyMesh(realWorldPawn.m_oFacePlateMesh, appearance.BreatherMesh);
//     // LogInternal("copying face stuff");
//     // CopyMesh(realWorldPawn.HeadMe, appearance.BreatherMesh);
//     return true;
// }

// private function CopyMesh(SkeletalMeshComponent smc, out AppearanceMesh appMesh)
// {
//     local int i;

//     if (smc.HiddenGame)
//     {
//         return;
//     }
//     LogInternal("Mesh"@PathName(smc.SkeletalMesh));
//     appMesh.Mesh = smc.SkeletalMesh;
//     appMesh.Materials.Length = smc.GetNumElements();
//     for (i = 0; i < appMesh.Materials.Length; i++)
//     {
//         LogInternal("material"@i@PathName(smc.GetMaterial(i)));
//         appMesh.Materials[i] = smc.GetMaterial(i);
//     }
// }
