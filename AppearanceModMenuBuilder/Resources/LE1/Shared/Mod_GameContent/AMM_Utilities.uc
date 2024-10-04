class AMM_Utilities extends Object;

struct AppearanceMeshPaths
{
	var string MeshPath;
	var Array<string> MaterialPaths;
};
struct AppearanceMesh
{
    var SkeletalMesh Mesh;
    var array<MaterialInterface> Materials;
};
struct pawnAppearance
{
    var AppearanceMesh bodyMesh;
    var AppearanceMesh HelmetMesh;
    var AppearanceMesh VisorMesh;
    var AppearanceMesh BreatherMesh;
	var bool hideHair;
    var bool hideHead;
};

struct SpecLists
{
	var OutfitSpecListBase outfitSpecs;
	var HelmetSpecListBase helmetSpecs;
	var BreatherSpecListBase breatherSpecs;
};

public static function SpecLists GetSpecLists(BioPawn target, AMM_Pawn_Parameters params)
{
	local SpecLists lists;

	lists.outfitSpecs = OutfitSpecListBase(params.GetOutfitSpecList(target));
	lists.helmetSpecs = HelmetSpecListBase(params.GetHelmetSpecList(target));
	lists.breatherSpecs = BreatherSpecListBase(params.GetBreatherSpecList(target));

	return lists;
}

public static function BioPawnType GetPawnType(BioPawn targetPawn)
{
    local BioPawnType pawnType;
    
    pawnType = BioPawnType(targetPawn.ActorType);
    if (pawnType == None)
    {
        pawnType = BioPawnType(targetPawn.m_oBehavior.m_oActorType);
    }
    return pawnType;
}

public static function bool IsPawnArmorAppearanceOverridden(BioPawn targetPawn)
{
    local BioPawnType pawnType;
    
    pawnType = GetPawnType(targetPawn);
    if (pawnType == None)
    {
        LogInternal("Why does this pawn not have a pawnType???" @ PathName(targetPawn), );
        return FALSE;
    }
    // this is nasty, but basically, the first is the 'default' behavior of this pawn, such as true for most NPCs on the Normandy (except the ones that are inexplicably broken)
    // The second is overridden occasionally to put Shepard in casual clothes on the Normandy, as well as squadmates and Shep in Casual Hubs
    // If either is set to true, consider it overridden
    return pawnType.m_bIsArmorOverridden || targetPawn.m_oBehavior.m_bArmorOverridden;
}

public static function UpdatePawnMaterialParameters(BioPawn targetPawn, bool applyingDefaultOutfit)
{

    local BioMorphFace morphFace;
    
    // LogInternal("UpdatePawnMaterialParameters"@PathName(TargetPawn)@targetPawn.Tag);
    // GetCurrentSkinTone(targetPawn.Mesh);

    EnsureMICs(targetPawn);
    // the order of application matters a lot here:
    // first, we copy the head materials (skin only) to the body, ensuring that the body skin kinda matches the head even if the others don't have anything to copy over
    ApplyHeadMaterialsToBody(targetPawn);
    // next, we apply the BioMaterialOverrides. If this is a default outfit, we apply all of them. 
    // if it is any other outfit, we only apply the skin params
    ApplyBioMaterialOverride(targetPawn, GetPawnType(targetPawn).m_oMaterialOverrides, !applyingDefaultOutfit);
    ApplyBioMaterialOverride(targetPawn, BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType).m_pMaterialParameters, !applyingDefaultOutfit);
    // finally, if there is a morph head, we apply those params. For this one, we want skin params only unless if it the default outfit
    ApplyMorphHeadParamsToPawn(targetPawn, GetMorphHead(targetPawn), !applyingDefaultOutfit);
}

public static function bool LoadEquipmentOnly(string tag, out BioPawnType pawnType, out int armorType, out int meshVariant, out int materialVariant)
{
    if (!GetActorType(tag, pawnType))
    {
        LogInternal("could not get actor type for"@tag);
        return false;
    }

    if (!LoadEquipmentFromSaveRecord(tag, ArmorType, meshVariant, materialVariant))
    {
        LogInternal("failed to load equipment");
        return false;
    }
    return true;
}

public static function bool GetActorType(string tag, out BioPawnType actorType)
{
    local Bio2DA characters2DA;
    local array<name> rowNames;
    local int i;
    local string actorTypePath;

    characters2DA = Bio2DA(FindObject("BIOG_2DA_Characters_X.Characters_Character", class'Bio2DA'));
    if (characters2DA == None)
    {
        LogInternal("failed to load the characters 2DA");
        return false;
    }
    rowNames = characters2DA.GetRowNames();
    i = rowNames.Find(name(tag));
    if (i == -1)
    {
        LogInternal("failed to find a row named"@tag);
        return false;
    }
    if (!characters2DA.GetStringEntryIN(i, 'ActorType', actorTypePath))
    {
        LogInternal("failed to find a column value"@tag);
        return false;
    }

    actorType = BioPawnType(DynamicLoadObject(actorTypePath, class'BioPawnType'));
    if (actorType == None)
    {
        LogInternal("failed to load actorType");
    }

    return actorType != None;
}

public static function bool GetHenchRecord(coerce name tag, out HenchmanSaveRecord record)
{
    local BioWorldInfo BWI;
    local SFXSaveGame SaveGame;
    local int i;

    BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    if (BWI.CurrentGame != None)
    {
        SaveGame = BWI.CurrentGame.GetME2SaveGame();
    }
    if (SaveGame == None || !SaveGame.bIsValid)
    {
        LogInternal("could not get save game"@SaveGame);
        return FALSE;
    }
    for (i = 0; i < SaveGame.HenchmanRecords.Length; i++)
    {
        if (SaveGame.HenchmanRecords[i].Tag == Tag)
        {
            Record = SaveGame.HenchmanRecords[i];
            return TRUE;
        }
    }

    return FALSE;
}

public static function bool EnsureHenchRecordExists(coerce name tag, out HenchmanSaveRecord record)
{
    local BioWorldInfo BWI;
    local BioPawn spawnedPawn;
    local BioSPGame gameInfo;

    if (GetHenchRecord(tag, record))
    {
        return true;
    }

    // no record found; make one instead
    BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    gameInfo = BioSPGame(BWI.Game);
    spawnedPawn = gameInfo.SpawnHenchman(Name(Tag), BWI.m_playerSquad.m_playerPawn, -60000.0, -60000.0, FALSE);
    spawnedPawn.Destroy();

    return GetHenchRecord(tag, record);
}

public static function bool LoadEquipmentFromSaveRecord(coerce name tag, out int armorType, out int meshVariant, out int materialVariant)
{
    local HenchmanSaveRecord Record;
    local int manufacturerId;
    local int itemId;
    local byte sophistication;

    if (!EnsureHenchRecordExists(tag, record))
    {
        return false;
    }

    // EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR value is 1, hardcode that if needed
    manufacturerId = record.Equipment[int(EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR)].Manufacturer;
    itemId = record.Equipment[int(EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR)].ItemId;
    sophistication = record.Equipment[int(EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR)].sophistication;
    if (!LoadEquipmentAndGetAttributes(tag, ItemId, manufacturerID, sophistication, armorType, meshVariant, materialVariant))
    {
        LogInternal("failed to load equipment");
        return false;
    }
    return TRUE;
}

public static function bool LoadEquipmentAndGetAttributes(name tag, int itemId, int manufacturerId, byte sophistication, out int armorType, out int meshVariant, out int materialVariant)
{
    local string squadMateGPL;
    local Bio2DANumberedRows items2DA;
    local BioItem item;
    local BioItemArmor armor;
    local BioMaterialOverride matOverrides;
    local BioAppearanceItemSophisticated sophisticatedAppearance;
    local int i;
    local int j;
    local BioAppearanceItemSophisticatedVariant currentVariant;
    local BioGamePropertyContainer props;
    local BioGameProperty prop;
    local BioGameEffect effect;
    local BioGameEffectAttributeInt intEffect;
    local BioGameEffectAttributeFloat floatEffect;
    local BioGameEffectAddItemProperty propEffect;
    local BioGameEffectAttribute attributeEffect;

    squadMateGPL = GetGamePropertyLabel(tag, itemId, armorType);
    // items2DA = Bio2DANumberedRows(FindObject("BIOG_2DA_Equipment_X.Items_ItemEffectLevels", class'Bio2DANumberedRows'));
    if (squadMateGPL == "")
    {
        LogInternal("could not get squadmate GPL");
        return false;
    }

    armor = BioItemArmor(Class'BioItemImporter'.static.LoadGameItem(itemId, sophistication, 'None', class'AMM_AppearanceUpdater'.static.GetDlcInstance(), ManufacturerID));
    if (armor != None)
    {
        props = armor.m_oGameProperties;
        for (i = 0; i < props.m_aGameProperties.Length; i++)
        {
            prop = props.m_aGameProperties[i];
            // we really only care about the property that is relevant to this squadmate
            if (prop.m_nmGamePropertyName == name(squadMateGPL))
            {
                for (j = 0; j < prop.m_aGameEffects.Length; j++)
                {
                    intEffect = BioGameEffectAttributeInt(prop.m_aGameEffects[j]);
                    if (intEffect == None)
                    {
                        continue;
                    }
                    if (intEffect.m_attributeName == 'm_modelVariant')
                    {
                        meshVariant = intEffect.m_value;
                    }
                    if (intEffect.m_attributeName == 'm_materialConfig')
                    {
                        materialVariant = intEffect.m_value;
                    }
                }
            }
            // or if it is an appearance override. those matter
            if (prop.m_nmGamePropertyName == 'GP_Manf_Armor_AppearanceOverride')
            {
                for (j = 0; j < prop.m_aGameEffects.Length; j++)
                {
                    intEffect = BioGameEffectAttributeInt(prop.m_aGameEffects[j]);
                    if (intEffect == None)
                    {
                        continue;
                    }
                    if (intEffect.m_nmGameEffectName == 'GE_Armor_AppearanceOverride')
                    {
                        ArmorType = intEffect.m_value;
                        break;
                    }
                }
            }
            // TODO handle GP_HelmetAppr_PlayerFemale type properties
        }
    }
    return true;
}

public static function string GetGamePropertyLabel(name tag, int itemId, out int armorWeight)
{
    switch (tag)
    {
        // TODO handle player here? we should not ever end up here so not a big deal
        case 'hench_humanFemale':
            return "GP_ArmorAppr_HenchFemale"$GetArmorWeight(itemId, armorWeight);
        case 'hench_humanMale':
            return "GP_ArmorAppr_HenchMale"$GetArmorWeight(itemId, armorWeight);
        case 'hench_Quarian':
            armorWeight = 2;
            return "GP_ArmorAppr_HenchQuarianL";
        case 'hench_Turian':
            return "GP_ArmorAppr_HenchTurian"$GetArmorWeight(itemId, armorWeight);
        case 'hench_Krogan':
            return "GP_ArmorAppr_HenchKrogan"$GetArmorWeight(itemId, armorWeight);
        case 'hench_Asari':
            return "GP_ArmorAppr_HenchAsari"$GetArmorWeight(itemId, armorWeight);
        default:
            return "";

    }
}

public static function string GetArmorWeight(int itemId, out int armorWeight)
{
    switch (itemId)
    {
        // HumanL
        case 287:
        // QuarianL
        case 290:
        // TurianL
        case 288:
            armorWeight = 2;
            return "L";
        // HumanM
        case 249:
        // TurianM
        case 284:
        // KroganM
        case 285:
            armorWeight = 3;
            return "M";
        // HumanH
        case 291:
        // KroganH
        case 293:
        default:
            armorWeight = 4;
            return "H";
    }
}

// private static function GetCurrentSkinTone(SkeletalMeshComponent SMC)
// {
//     local LinearColor skinTone;
//     local int i;
//     local int j;
//     local MaterialInstanceConstant MIC;
//     local VectorParameterValue vect;

//     // LogInternal("GetMaterial"@SMC.GetMaterial(0));
//     // LogInternal("Material[0]"@SMC.Materials[0]);
//     // LogInternal("GetBaseMaterial(0)"@SMC.GetBaseMaterial(0));

//     if (SMC.GetMaterial(0).GetVectorParameterValue('SkinTone', skinTone))
//     {
//         LogInternal("current skinTone GetMaterial(0) GetVectorParameterValue"@skinTone.R@skintone.G@skintone.B);
//     }
//     // if (SMC.Materials[0].GetVectorParameterValue('SkinTone', skinTone))
//     // {
//     //     LogInternal("current skinTone Materials[0] GetVectorParameterValue"@skinTone.R@skintone.G@skintone.B);
//     // }
//     //  if (SMC.GetBaseMaterial(0).GetVectorParameterValue('SkinTone', skinTone))
//     // {
//     //     LogInternal("current skinTone GetBaseMaterial(0) GetVectorParameterValue"@skinTone.R@skintone.G@skintone.B);
//     // }

//     LogInternal("Looking for value");
//     MIC = MaterialInstanceConstant(SMC.GetMaterial(i));
//     while (MIC != None)
//     {
//         LogInternal("looking at MIC"@PathName(MIC));
//         for (j = 0; j < MIC.VectorParameterValues.Length; j++)
//         {
//             vect = MIC.VectorParameterValues[j];
//             if (vect.ParameterName == 'SkinTone')
//             {
//                 skinTone = vect.ParameterValue;
//                 LogInternal("current skinTone GetMaterial(0) Nested Loop"@skinTone.R@skintone.G@skintone.B);
//                 return;
//             }
//         }
//         MIC = MaterialInstanceConstant(MIC.Parent);
//     }
//     // for (i = 0; i < SMC.GetNumElements(); i++)
//     // {
//     //     MIC = MaterialInstanceConstant(SMC.GetMaterial(i));
//     //     LogInternal("Looking for value");
        
//     // }
//     LogInternal("failed to get param directly on SMC material");
// }

public static function ApplyBioMaterialOverride(BioPawn target, BioMaterialOverride override, bool skinParamsOnly)
{
    local VectorParameterValue vectorParam;
    local ScalarParameterValue scalParam;
    local TextureParameterValue texParam;
    local ColorParameter colorParam;
    local ScalarParameter scalParam2;
    local TextureParameter texParam2;

    // LogInternal("Applying BioMaterialOverride"@PathName(override)@skinParamsOnly);
    if (override != None)
    {
        foreach override.m_aColorOverrides(colorParam, )
        {
            if (skinParamsOnly && vectorParam.ParameterName != 'skinTone' && vectorParam.ParameterName != 'SkinLightScattering')
            {
                continue;
            }
            vectorParam.ParameterName = colorParam.nName;
            vectorParam.ParameterValue = colorParam.cValue;
            // LogInternal("Setting"@vectorParam.ParameterName@"from mat override"@vectorParam.ParameterValue.R@vectorParam.ParameterValue.G@vectorParam.ParameterValue.B);
            ApplyVectorParameterToAllMICs(vectorParam, target);
        }
        if (!skinParamsOnly)
        {
            foreach override.m_aScalarOverrides(scalParam2, )
            {
                scalParam.ParameterName = scalParam2.nName;
                scalParam.ParameterValue = scalParam2.sValue;
                ApplyScalarParameterToAllMICs(scalParam, target);
            }
            foreach override.m_aTextureOverrides(texParam2, )
            {
                texParam.ParameterName = texParam2.nName;
                texParam.ParameterValue = texParam2.m_pTexture;
                ApplyTextureParameterToAllMICs(texParam, target);
            }
        }
    }
}

public static function BioMorphFace GetMorphHead(BioPawn targetPawn)
{
    local BioMorphFace morphFace;
    local BioPawnType pawnType;
    
    // LogInternal("trying to get morphHead for target"@PathName(targetPawn)@targetPawn.Tag);
    morphFace = targetPawn.m_oBehavior.m_oAppearanceType.m_oMorphFace;
    // LogInternal("targetPawn.m_oBehavior.m_oAppearanceType.m_oMorphFace"@PathName(targetPawn.m_oBehavior.m_oAppearanceType.m_oMorphFace));
    if (morphFace == None)
    {
        pawnType = Class'AMM_Utilities'.static.GetPawnType(targetPawn);
        // LogInternal("PawnType"@PathName(pawnType));
        if (pawnType != None)
        {
            morphFace = pawnType.m_oMorphFace;
            // LogInternal("pawnType morphHead"@PathName(morphFace));
        }
    }
    return morphFace;
}

public static function ApplyMorphHeadParamsToPawn(BioPawn targetPawn, BioMorphFace morphHead, bool skinParamsOnly)
{
    local VectorParameterValue vectorParam;
    local ScalarParameterValue scalParam;
    local TextureParameterValue texParam;
    local int i;
    local ColorParameter colorParam;
    local ScalarParameter scalParam2;
    local TextureParameter texParam2;

    if (morphHead != None)
    {
        ApplyBioMaterialOverride(targetPawn, morphHead.m_oMaterialOverrides, skinParamsOnly);
    }
}

private static final function EnsureMICs(BioPawn targetPawn)
{
    local SkeletalMeshComponent MeshCmpt;
    local int MaterialIndex;
    local MaterialInterface CurrentMaterial;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', MeshCmpt)
    {
        if (MeshCmpt != None)
        {
            for (MaterialIndex = 0; MaterialIndex < MeshCmpt.GetNumElements(); MaterialIndex++)
            {
                // GetBaseMaterial returns from SMC Materials array or falls back to SM material
                CurrentMaterial = MeshCmpt.GetBaseMaterial(MaterialIndex);
                if (CurrentMaterial != None)
                {
                    if (CurrentMaterial.Outer == targetPawn)
                    {
                        MIC = MaterialInstanceConstant(CurrentMaterial);
                    }
                    else
                    {
                        MIC = None;
                    }
                    if (MIC == None)
                    {
                        MIC = new (targetPawn) Class'MaterialInstanceConstant';
                        if (MIC != None)
                        {
                            MIC.SetParent(CurrentMaterial);
                            MeshCmpt.SetMaterial(MaterialIndex, MIC);
                        }
                    }
                }
            }
        }
    }
}
private static final function ApplyHeadMaterialsToBody(BioPawn targetPawn)
{
    local int i;
    local LinearColor skinTone;
    local bool skinToneSet;
    local LinearColor SkinLightScattering;
    local bool skinLightScatteringSet;
    local MaterialInstanceConstant MIC;
    local VectorParameterValue vect;
    
    if (targetPawn.m_oHeadMesh == None)
    {
        return;
    }
    for (i = 0; i < targetPawn.m_oHeadMesh.GetNumElements(); i++)
    {
        MIC = MaterialInstanceConstant(targetPawn.m_oHeadMesh.GetBaseMaterial(i));
        if (MIC != None)
        {
            if (!skinToneSet && MIC.GetVectorParameterValue('skinTone', skinTone))
            {
                skinToneSet = TRUE;
            }
            if (!skinLightScatteringSet && MIC.GetVectorParameterValue('SkinLightScattering', SkinLightScattering))
            {
                skinLightScatteringSet = TRUE;
            }
        }
    }
    if (skinToneSet)
    {
        // LogInternal("Setting skintone from head mats"@skinTone.R@skintone.G@skintone.B);
        vect.ParameterName = 'skinTone';
        vect.ParameterValue = skinTone;
        ApplyVectorParameterToAllMICs(vect, targetPawn);
    }
    if (skinLightScatteringSet)
    {
        // LogInternal("Setting SkinLightScattering from head mats"@SkinLightScattering.R@SkinLightScattering.G@SkinLightScattering.B);
        vect.ParameterName = 'SkinLightScattering';
        vect.ParameterValue = SkinLightScattering;
        ApplyVectorParameterToAllMICs(vect, targetPawn);
    }
}
private static final function ApplyVectorParameterToAllMICs(VectorParameterValue vect, BioPawn targetPawn)
{
    local SkeletalMeshComponent smc;
    local int i;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', smc)
    {
        if (smc == targetPawn.m_oHeadMesh)
        {
            continue;
        }
        if (smc != None)
        {
            for (i = 0; i < smc.GetNumElements(); i++)
            {
                MIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
                if (MIC != None)
                {
                    MIC.SetVectorParameterValue(vect.ParameterName, vect.ParameterValue);
                }
            }
        }
    }
}
private static final function ApplyScalarParameterToAllMICs(ScalarParameterValue scal, BioPawn targetPawn)
{
    local SkeletalMeshComponent smc;
    local int i;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', smc)
    {
        if (smc == targetPawn.m_oHeadMesh)
        {
            continue;
        }
        if (smc != None)
        {
            for (i = 0; i < smc.GetNumElements(); i++)
            {
                MIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
                if (MIC != None)
                {
                    MIC.SetScalarParameterValue(scal.ParameterName, scal.ParameterValue);
                }
            }
        }
    }
}
private static final function ApplyTextureParameterToAllMICs(TextureParameterValue tex, BioPawn targetPawn)
{
    local SkeletalMeshComponent smc;
    local int i;
    local MaterialInstanceConstant MIC;
    
    foreach targetPawn.ComponentList(Class'SkeletalMeshComponent', smc)
    {
        if (smc == targetPawn.m_oHeadMesh)
        {
            continue;
        }
        if (smc != None)
        {
            for (i = 0; i < smc.GetNumElements(); i++)
            {
                MIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
                if (MIC != None)
                {
                    MIC.SetTextureParameterValue(tex.ParameterName, tex.ParameterValue);
                }
            }
        }
    }
}

public static function bool LoadAppearanceMesh(AppearanceMeshPaths meshPaths, out AppearanceMesh AppearanceMesh, optional bool allowNone = false)
{
	if (class'AMM_Utilities'.static.LoadSkeletalMesh(meshPaths.meshPath, AppearanceMesh.Mesh, allowNone)
		&& class'AMM_Utilities'.static.LoadMaterials(meshPaths.MaterialPaths, AppearanceMesh.Materials))
	{
		return true;
	}
	return false;
}

public static function bool LoadSkeletalMesh(string skeletalMeshPath, out SkeletalMesh Mesh, optional bool allowNone = false)
{
	if (allowNone && (skeletalMeshPath == "" || skeletalMeshPath ~= "None"))
	{
		return true;
	}
    Mesh = SkeletalMesh(DynamicLoadObject(skeletalMeshPath, Class'SkeletalMesh'));
    if (Mesh == None)
    {
        LogInternal("WARNING: failed to load mesh" @ skeletalMeshPath, );
        return FALSE;
    }
    return TRUE;
}

public static function bool LoadMaterials(array<string> materialPaths, out array<MaterialInterface> Materials)
{
    local string materialString;
    local MaterialInterface material;
    
    Materials.Length = 0;
    foreach materialPaths(materialString, )
    {
        material = MaterialInterface(DynamicLoadObject(materialString, Class'MaterialInterface'));
        if (material == None)
        {
            LogInternal("WARNING failed to Load material" @ materialString, );
            return FALSE;
        }
        Materials.AddItem(material);
    }
    return TRUE;
}

public static function ApplyMaterialOverrides(SkeletalMeshComponent smc, MaterialInstanceConstant mic)
{
	local int i;
	local int j;
	local MaterialInstanceConstant targetMIC;

	if (mic == None)
	{
		return;
	}

	for (i = 0; i < smc.GetNumElements(); i++)
	{
		targetMIC = MaterialInstanceConstant(smc.GetBaseMaterial(i));
		if (targetMIC != None)
		{
			for (j = 0; j < mic.VectorParameterValues.Length; j++)
			{
				targetMIC.SetVectorParameterValue(mic.VectorParameterValues[j].ParameterName, mic.VectorParameterValues[j].ParameterValue);
			}
            // TODO also apply scalar params from here?
		}
	}
}

public static function ApplyPawnAppearance(BioPawn target, pawnAppearance appearance)
{
	replaceMesh(target, target.Mesh, appearance.bodyMesh);
	if (target.m_oHairMesh != None)
    {
		// hide head also implies hiding the hair
        target.m_oHairMesh.SetHidden(appearance.hideHair || appearance.hideHead);
    }
    if (target.m_oHeadMesh != None)
    {
        target.m_oHeadMesh.SetHidden(appearance.hideHead);
    }

	if (target.m_oHeadGearMesh == None)
    {
        target.m_oHeadGearMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oHeadGearMesh.SetParentAnimComponent(target.Mesh);
        target.m_oHeadGearMesh.SetShadowParent(target.Mesh);
        target.m_oHeadGearMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oHeadGearMesh);
    }
	replaceMesh(target, target.m_oHeadGearMesh, appearance.HelmetMesh);
	target.m_oHeadGearMesh.SetHidden(appearance.HelmetMesh.Mesh == None);
	target.m_oHeadGearMesh.CastShadow = appearance.HelmetMesh.Mesh != None;

	if (target.m_oVisorMesh == None)
    {
        target.m_oVisorMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oVisorMesh.SetParentAnimComponent(target.Mesh);
        target.m_oVisorMesh.SetShadowParent(target.Mesh);
        target.m_oVisorMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oVisorMesh);
    }
    replaceMesh(target, target.m_oVisorMesh, appearance.VisorMesh);
    target.m_oVisorMesh.SetHidden(appearance.VisorMesh.Mesh == None);
	target.m_oVisorMesh.CastShadow = appearance.VisorMesh.Mesh != None;

	if (target.m_oFacePlateMesh == None)
    {
        target.m_oFacePlateMesh = new (target) Class'SkeletalMeshComponent';
        target.m_oFacePlateMesh.SetParentAnimComponent(target.Mesh);
        target.m_oFacePlateMesh.SetShadowParent(target.Mesh);
        target.m_oFacePlateMesh.SetLightEnvironment(target.Mesh.LightEnvironment);
        target.AttachComponent(target.m_oFacePlateMesh);
    }
    replaceMesh(target, target.m_oFacePlateMesh, appearance.BreatherMesh);
    target.m_oFacePlateMesh.SetHidden(appearance.BreatherMesh.Mesh == None);
	target.m_oFacePlateMesh.CastShadow = appearance.BreatherMesh.Mesh != None;

	// This call is very important to prevent all kinds of weirdness
	// for example bone melting and materials misbehaving, and possibly even crashing
	target.ForceUpdateComponents(FALSE, FALSE);
}

public static function replaceMesh(BioPawn targetPawn, SkeletalMeshComponent smc, AppearanceMesh AppearanceMesh)
{
    local int i;
    local MaterialInstanceConstant MIC;

	if (smc == None)
	{
		return;
	}
    smc.SetSkeletalMesh(AppearanceMesh.Mesh);

    for (i = 0; i < AppearanceMesh.Materials.Length; i++)
    {
		// reuse existing MICs when possible; it makes the game much more stable. I am not sure why

		// I need to do this entirely based around the methods I think. idk why, but that's the next thing to try
        MIC = MaterialInstanceConstant(smc.Materials[i]);
        if (MIC != None && MIC.outer == targetPawn)
        {
			MIC.ClearParameterValues();
            MIC.SetParent(AppearanceMesh.Materials[i]);
			// trying to do this even though it should already be there
			smc.SetMaterial(i, MIC);
        }
		else
		{
			// if they do not have a suitable MIC, make one and point it at the right parent.
			MIC = new (targetPawn) Class'BioMaterialInstanceConstant';
			MIC.SetParent(AppearanceMesh.Materials[i]);
			smc.SetMaterial(i, MIC);
		}
	}
}

public static function string GetArmorCode(EBioArmorType armorType)
{
    switch (armorType)
    {
        case EBioArmorType.ARMOR_TYPE_NONE:
            return "NKD";
        case EBioArmorType.ARMOR_TYPE_CLOTHING:
            return "CTH";
        case EBioArmorType.ARMOR_TYPE_LIGHT:
            return "LGT";
        case EBioArmorType.ARMOR_TYPE_MEDIUM:
            return "MED";
        case EBioArmorType.ARMOR_TYPE_HEAVY:
            return "HVY";
        default:
    }
    return "";
}

public static function string GetLetter(int num)
{
    switch (num + 1)
    {
        case 1:
            return "a";
        case 2:
            return "b";
        case 3:
            return "c";
        case 4:
            return "d";
        case 5:
            return "e";
        case 6:
            return "f";
        case 7:
            return "g";
        case 8:
            return "h";
        case 9:
            return "i";
        case 10:
            return "j";
        case 11:
            return "k";
        case 12:
            return "l";
        case 13:
            return "m";
        case 14:
            return "n";
        case 15:
            return "o";
        case 16:
            return "p";
        case 17:
            return "q";
        case 18:
            return "r";
        case 19:
            return "s";
        case 20:
            return "t";
        case 21:
            return "u";
        case 22:
            return "v";
        case 23:
            return "w";
        case 24:
            return "x";
        case 25:
            return "y";
        case 26:
            return "z";
        default:
    }
    return "";
}

public static function GetVanillaVisorMesh(BioPawnType pawnType, out AppearanceMesh visorMesh)
{
	local Array<SkeletalMesh> visorMeshSpecs;
	local Array<MaterialInterface> visorMaterialSpecs;

	visorMeshSpecs = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMesh;
	visorMaterialSpecs = pawnType.m_oAppearance.Body.m_oHeadGearAppearance.m_apVisorMaterial;

	if (visorMeshSpecs.Length == 0 || visorMaterialSpecs.Length == 0)
	{
		// this will be the case for Wrex, and is fine and expected
		visorMesh.Mesh = None;
        visorMesh.Materials.Length = 0;
		return;
	}

	// TODO this is an array, I think there can theoretically be more than one visor spec, indexed by a property on the appearance settings
	// but I have never seen it actually used, so I think I am going to ignore it.
	visorMesh.Mesh = visorMeshSpecs[0];
	// similarly, this is an array, but I am not sure if it is for a visor with multiple materials or to index into different visor specs, as above
	// I am going to pretend it only ever deals with a single spec with one material.
	visorMesh.Materials[0] = visorMaterialSpecs[0];
}

public static function eHelmetDisplayState GetHelmetDisplayState(PawnAppearanceIds appearanceIds, BioPawn target)
{
	local BioPawnType pawnType;
	local eHelmetDisplayState forceHelmetState;
	local AMM_Pawn_Parameters params;

	if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
		// this really shouldn't happen
		LogInternal("Warning: a very unexpected thing happened");
		return eHelmetDisplayState.off;
	}

	if (params.GiveFullHelmetControl || (appearanceIds.m_appearanceSettings.bOverridedefaultHeadgearVisibility && params.canChangeHelmetState))
	{
		// if the game has an override to breather and we are not ignoring it, use a full breather
		if (ShouldUseForcedBreather(target, params))
		{
			return eHelmetDisplayState.full;
		}

		if (GetMenuHelmetOverride(target, appearanceIds.m_appearanceSettings.helmetDisplayState, forceHelmetState))
		{
			return forceHelmetState;
		}

		// else use what the player has requested
		return appearanceIds.m_appearanceSettings.helmetDisplayState;
	}
	else
	{
		// use the default helmet state
		return params.defaultHelmetState;
	}
}

private static function bool GetMenuHelmetOverride(BioPawn target, eHelmetDisplayState desiredState, out eHelmetDisplayState result)
{
	local BioSFPanel panel;
	local AMM_AppearanceUpdater updaterInstance;
	local AMM_Pawn_Parameters params;
	local eMenuHelmetOverride menuOverride;

	// if we are not in AMM and working with a UI world pawn, move on
	if (target.GetPackageName() != 'BIOG_UIWORLD' || !class'AMM_AppearanceUpdater'.static.IsInAMM(panel))
	{
		return false;
	}

	updaterInstance = class'AMM_AppearanceUpdater'.static.GetDlcInstance();
	if (updaterInstance == None)
	{
		return false;
	}

	menuOverride = eMenuHelmetOverride(updaterInstance.menuHelmetOverride);

	switch (menuOverride)
	{
		case eMenuHelmetOverride.off:
            // it is forced to a specific state
			result = eHelmetDisplayState.off;
			return true;
		case eMenuHelmetOverride.on:
			result = eHelmetDisplayState.on;
			return true;
		case eMenuHelmetOverride.full:
			result = eHelmetDisplayState.full;
			return true;
		case eMenuHelmetOverride.offOrOn:
			if (desiredState == eHelmetDisplayState.Full)
			{
				result = eHelmetDisplayState.on;
			}
			else
			{
				result = desiredState;
			}
			return true;
		case eMenuHelmetOverride.onOrFull:
			if (desiredState == eHelmetDisplayState.off)
			{
				result = eHelmetDisplayState.on;
			}
			else
			{
				result = desiredState;
			}
			return true;
		case eMenuHelmetOverride.offOrFull:
			if (desiredState == eHelmetDisplayState.on)
			{
				result = eHelmetDisplayState.off;
			}
			else
			{
				result = desiredState;
			}
			return true;
		case eMenuHelmetOverride.unchanged:
		default:
			return false;
	}
}

private static function bool ShouldUseForcedBreather(BioPawn target, AMM_Pawn_Parameters params)
{
	local BioPawnType pawnType;
	local BioInterface_Appearance_Pawn appearance;
	local bool isHeadgearPreferenceOverridden;
	local bool helmetVisible;
	local bool faceplateVisible;
	local BioGlobalVariableTable globalVars;
	local BioSFPanel panel;

	// if this is a preview pawn in AMM, return false; we should ignore forced state there
	if (target.GetPackageName() == 'BIOG_UIWORLD' && class'AMM_AppearanceUpdater'.static.IsInAMM(panel))
	{
		return false;
	}

	if (params.bIgnoreForcedHelmet)
	{
		return false;
	}

	// first check if the mod setting lets us override things
	globalVars = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetGlobalVariables();
	if (globalVars.GetInt(1593) == 1)
	{
		return false;
	}

	pawnType = GetPawnType(target);
	appearance = BioInterface_Appearance_Pawn(target.m_oBehavior.m_oAppearanceType);
	isHeadgearPreferenceOverridden = !target.IsHeadGearVisiblePreferenceRelevant();
	if (!isHeadgearPreferenceOverridden)
	{
		// meaning, in this case, respect the preference set by the player in the Squad record menu
		return false;
	}
	helmetVisible = appearance.m_headGearVisibilityRunTimeOverride.m_a[2].m_bIsVisible;
	faceplateVisible = appearance.m_headGearVisibilityRunTimeOverride.m_a[1].m_bIsVisible;
	// force the breather only if the helmet and faceplate have been forced into visibility
	return helmetVisible && faceplateVisible;
}

// private static function eHelmetDisplayState GetVanillaHelmetState(BioPawn target)
// {
// 	local BioInterface_Appearance_Pawn appearance;
//     local BioPawnType pawnType;
//     local bool headgearVisibilityPreference;
//     local bool isHeadgearPreferenceOverridden;
// 	local bool helmetVisible;
// 	local bool faceplateVisible;

// 	pawnType = GetPawnType(target);
// 	appearance = BioInterface_Appearance_Pawn(target.m_oBehavior.m_oAppearanceType);
// 	isHeadgearPreferenceOverridden = !target.IsHeadGearVisiblePreferenceRelevant();

// 	if (!isHeadgearPreferenceOverridden)
// 	{
// 		// general visibility not overridden
// 		helmetVisible = appearance.m_headGearVisibilityOverride.m_a[2].m_bIsVisible;
// 		if (!helmetVisible)
// 		{
// 			return eHelmetDisplayState.off;
// 		}
// 		faceplateVisible = appearance.m_headGearVisibilityOverride.m_a[1].m_bIsVisible;
// 		return faceplateVisible ? eHelmetDisplayState.full : eHelmetDisplayState.on;
// 	}
// 	else
// 	{
// 		helmetVisible = appearance.m_headGearVisibilityRunTimeOverride.m_a[2].m_bIsVisible;
// 		if (!helmetVisible)
// 		{
// 			return eHelmetDisplayState.off;
// 		}
// 		faceplateVisible = appearance.m_headGearVisibilityRunTimeOverride.m_a[1].m_bIsVisible;
// 		return faceplateVisible ? eHelmetDisplayState.full : eHelmetDisplayState.on;
// 	}
// }


// private final function bool GetHelmetParams(BioPawn targetPawn)
// {
//     local BioInterface_Appearance_Pawn appearance;
//     local BioPawnType pawnType;
//     local bool headgearVisibilityPreference;
//     local bool isHeadgearPreferenceOverridden;

// 	pawnType = GetPawnType(targetPawn);
// 	appearance = BioInterface_Appearance_Pawn(targetPawn.m_oBehavior.m_oAppearanceType);
// 	isHeadgearPreferenceOverridden = !targetPawn.IsHeadGearVisiblePreferenceRelevant();
// 	// if headgear preference is not overridden
// 	if (!isHeadgearPreferenceOverridden)
// 	{
// 		if (!appearance.m_headGearVisibilityOverride.m_a[2].m_bIsVisible)
// 		{
// 			helmetState.state = ehelmetState.off;
// 			LogInfo("Helmet State not runtime overriden, but disabled on pawn");
// 			return TRUE;
// 		}
// 		helmetState.state = appearance.m_bHeadGearVisiblePreference ? ehelmetState.on : ehelmetState.off;
// 		LogInfo("Helmet State not overriden, preference is" @ (appearance.m_bHeadGearVisiblePreference ? "on" : "off"));
// 		return TRUE;
// 	}
// 	else
// 	{
// 		if (appearance.m_headGearVisibilityRunTimeOverride.m_a[2].m_bIsVisible)
// 		{
// 			helmetState.state = appearance.m_headGearVisibilityRunTimeOverride.m_a[1].m_bIsVisible ? ehelmetState.full : ehelmetState.on;
// 			LogInfo("Helmet State overriden, override is" @ (appearance.m_headGearVisibilityRunTimeOverride.m_a[1].m_bIsVisible ? "full" : "on"));
// 			return TRUE;
// 		}
// 		helmetState.state = ehelmetState.off;
// 		LogInfo("Helmet State overriden, override is off");
// 		return TRUE;
// 	}
    
//     return TRUE;
// }
