Class EquippedArmorOutfitSpec extends NonOverriddenVanillaOutfitSpec;

public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
    local AMM_Pawn_Parameters params;
    local BioWorldInfo BWI;
    // local AMM_AppearanceUpdater updater;
    local BioPawn partyMember;
    // local bool destroyAfter;
    local OutfitSpecBase delegateSpec;
    local int armorType;
    local int meshVariant;
    local int materialVariant;
	local AppearanceMeshPaths meshPaths;
	local array<string> meshMaterialPaths;
	local eHelmetDisplayState helmetDisplayState;
    local BIoPawnType pawnType;

	// updater = class'AMM_AppearanceUpdater'.static.GetDlcInstance();

    if (!class'AMM_AppearanceUpdater'.static.GetPawnParams(target, params))
	{
        LogInternal("EquippedArmorOutfitSpec could not get params");
		return false;
	}

    // if this is the player or not a squadmate or the target is currently in the party, defer to NonOverriddenVanillaOutfitSpec
    if (AMM_Pawn_Parameters_Player(params) != None 
        || AMM_Pawn_Parameters_Squad(params) == None 
        || AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember) && partyMember == target)
    {
        LogInternal("EquippedArmorOutfitSpec delegating to NonOverriddenVanillaOutfitSpec");
        delegateSpec = new Class'NonOverriddenVanillaOutfitSpec';
        return delegateSpec.LoadOutfit(target, specLists, appearanceIds, appearance);
    }

    // TODO if helmet is default, delegate to equipped helmet as well

    // first, try getting a pawn from the party and pulling params off of them
    if (AMM_Pawn_Parameters_Squad(params).GetPawnFromParty(params.Tag, partyMember))
    {
        // LogInternal("ArmorOverrideVanillaoutfitSpec got pawn from party"@PathName(partyMember));
        // destroyAfter = false;
        pawnType = class'AMM_Utilities'.static.GetPawnType(partyMember);
        if (!GetVariant(partyMember, armorType, meshVariant, materialVariant))
        {
            LogInternal("got a pawn but couldn't get params from them???");
            return false;
        }
    }
    else
    {
        LogInternal("pawn is not in party so we are trying to load the equipment");
        if (!LoadEquipmentOnly(params.Tag, pawnType, armorType, meshVariant, materialVariant))
        {
            return false;
        }
    }
    // else
    // {
    //     LogInternal("ArmorOverrideVanillaoutfitSpec trying to spawn a copy of them");
    //     BWI = class'AMM_AppearanceUpdater'.static.GetOuterWorldInfo();
    //     // spawn a copy of this pawn, grab their outfit info
    //     partyMember = BioSPGame(BWI.Game).SpawnHenchman(Name(params.Tag), BWI.m_playerSquad.m_playerPawn, 100, 100, true);
    //     LogInternal("ArmorOverrideVanillaoutfitSpec spawned"@PathName(partyMember));
    //     destroyAfter = true;
    // }

    // // do the expected GetVariant stuff, but on the partyMember rather than the target
    // if (!GetVariant(partyMember, armorType, meshVariant, materialVariant))
    // {
    //     if (destroyAfter)
    //     {
    //         partyMember.Destroy();
    //     }
    //     return FALSE;
    // }
	
	if (!GetOutfitStrings(
		pawnType,
		armorType, meshVariant, materialVariant,
		meshPaths))
	{
		return false;
	}

	if (!class'AMM_Utilities'.static.LoadAppearanceMesh(meshPaths, appearance.bodyMesh))
	{
		return false;
	}
	
	// get whether we should display the helmet based on a variety of factors
	helmetDisplayState = class'AMM_Utilities'.static.GetHelmetDisplayState(appearanceIds, target);
	if (helmetDisplayState != eHelmetDisplayState.off)
	{
		specLists.helmetSpecs.DelegateToHelmetSpec(target, specLists, appearanceIds, appearance);
	}
	return true;
}

private function bool LoadEquipmentOnly(string tag, out BioPawnType pawnType, out int armorType, out int meshVariant, out int materialVariant)
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

private function bool GetActorType(string tag, out BioPawnType actorType)
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
    // now get the value of column 2 for row i (ActorType)
    if (!characters2DA.GetStringEntryIN(i, 'ActorType', actorTypePath))
    {
        LogInternal("failed to find a column value"@tag);
        // actorTypePath = "BIOG_Asari_Hench_C.hench_asari";
        return false;
    }

    LogInternal("trying to dynamic load"@actorTypePath);

    actorType = BioPawnType(DynamicLoadObject(actorTypePath, class'BioPawnType'));
    if (actorType == None)
    {
        LogInternal("failed to load actorType");
    }

    return actorType != None;
}

private function bool LoadEquipmentFromSaveRecord(coerce name tag, out int armorType, out int meshVariant, out int materialVariant)
{
    local BioWorldInfo BWI;
    local SFXSaveGame SaveGame;
    local int i;
    local HenchmanSaveRecord Record;
    local int manufacturerId;
    local int itemId;
    local byte sophistication;

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
            // EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR value is 1, hardcode that if needed
            manufacturerId = record.Equipment[int(EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR)].Manufacturer;
            itemId = record.Equipment[int(EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR)].ItemId;
            sophistication = record.Equipment[int(EBioEquipmentSlot.EQUIPMENT_SLOT_ARMOR)].sophistication;
            LogInternal("found squad record"@itemId@ManufacturerID@sophistication);
            if (!LoadEquipmentAndGetAttributes(tag, ItemId, manufacturerID, sophistication, armorType, meshVariant, materialVariant))
            {
                LogInternal("failed to load equipment");
                return false;
            }
            return TRUE;
        }
    }
    LogInternal("did not find squad record");
    return FALSE;
}

private function bool LoadEquipmentAndGetAttributes(name tag, int itemId, int manufacturerId, byte sophistication, out int armorType, out int meshVariant, out int materialVariant)
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
    LogInternal("Squadmate GPL"@squadMateGPL);
    // items2DA = Bio2DANumberedRows(FindObject("BIOG_2DA_Equipment_X.Items_ItemEffectLevels", class'Bio2DANumberedRows'));
    if (squadMateGPL == "")
    {
        LogInternal("could not get squadmate GPL");
        return false;
    }


    armor = BioItemArmor(Class'BioItemImporter'.static.LoadGameItem(itemId, sophistication, 'None', self, ManufacturerID));
    if (armor != None)
    {
        LogInternal("loaded armor from" @ itemId @ manufacturerId @ sophistication @ armor, );
        LogInternal("armor type"@armor.m_eArmorType);
        // LogInternal("armor appearance"@armor.m_oAppearance);
        // LogInternal("armor skeletal mesh"@armor.GetSkeletalMesh());
        // matOverrides = armor.GetMaterialParameters();
        // LogInternal("matOverrides"@matOverrides@matOverrides.m_aColorOverrides.Length@matOverrides.m_aScalarOverrides.length@matOverrides.m_aTextureOverrides.Length);
        // TODO enumerate the material overrides
        // sophisticatedAppearance = BioAppearanceItemSophisticated(armor.m_oAppearance);
        // if (sophisticatedAppearance != None)
        // {
        //     for (i = 0; i < sophisticatedAppearance.m_variants.length; i++)
        //     {
        //         currentVariant = sophisticatedAppearance.m_variants[i];
        //         LogInternal("appearance variant"@i);
        //         LogInternal("Skel Mesh"@PathName(currentVariant.m_oModelMesh));
        //         LogInternal("materials"@currentVariant.m_aMaterials.Length);
        //         for (j = 0; j < currentVariant.m_aMaterials.Length; j++)
        //         {
        //             LogInternal("material"@j@PathName(currentVariant.m_aMaterials[j]));
        //         }
        //     }
        // }
        // go through the properties?
        props = armor.m_oGameProperties;
        // LogInternal("props"@PathName(props)@props.m_aGameProperties.Length);
        for (i = 0; i < props.m_aGameProperties.Length; i++)
        {
            prop = props.m_aGameProperties[i];
            // we really only care about the property that is relevant to this squadmate
            if (prop.m_nmGamePropertyName == name(squadMateGPL))
            {
                for (j = 0; j < prop.m_aGameEffects.Length; j++)
                {
                    // effect = prop.m_aGameEffects[j];
                    // LogInternal("Checking squad gpl Effect"@j@effect.class@effect.m_nmGameEffectName);
                    intEffect = BioGameEffectAttributeInt(prop.m_aGameEffects[j]);
                    if (intEffect == None)
                    {
                        continue;
                    }
                    if (intEffect.m_attributeName == 'm_modelVariant')
                    {
                        // LogInternal("got mesh variant"@intEffect.m_value);
                        meshVariant = intEffect.m_value;
                    }
                    if (intEffect.m_attributeName == 'm_materialConfig')
                    {
                        // LogInternal("got material variant"@intEffect.m_value);
                        materialVariant = intEffect.m_value;
                    }
                }
            }
            // or if it is an appearance override. those matter
            if (prop.m_nmGamePropertyName == 'GP_Manf_Armor_AppearanceOverride')
            {
                for (j = 0; j < prop.m_aGameEffects.Length; j++)
                {
                    // effect = prop.m_aGameEffects[j];
                    // LogInternal("Checking override Effect"@j@effect.class@effect.m_nmGameEffectName);
                    intEffect = BioGameEffectAttributeInt(prop.m_aGameEffects[j]);
                    if (intEffect == None)
                    {
                        continue;
                    }
                    if (intEffect.m_nmGameEffectName == 'GE_Armor_AppearanceOverride')
                    {
                        // LogInternal("got override"@intEffect.m_value);
                        ArmorType = intEffect.m_value;
                        break;
                    }
                }
            }
            // TODO handle GP_HelmetAppr_PlayerFemale type properties

            // LogInternal("prop"@i@PathName(prop)@prop.m_aGameEffects.Length);
            // LogInternal("ToLine"@prop.ToLine());
            // LogInternal("ToString"@prop.ToString());
            // for (j = 0; j < prop.m_aGameEffects.Length; j++)
            // {
            //     effect = prop.m_aGameEffects[j];
            //     LogInternal("Effect"@j@PathName(effect)@effect.m_nmGameEffectName);
            //     attributeEffect = BioGameEffectAttribute(effect);
            //     if (attributeEffect != None)
            //     {
            //         LogInternal("attribute name"@attributeEffect.m_attributeName);
            //         LogInternal("attribute index"@attributeEffect.m_nIndex);
            //         LogInternal("attribute type"@attributeEffect.m_type);
            //     }
            //     intEffect = BioGameEffectAttributeInt(effect);
            //     if (intEffect != None)
            //     {
            //         LogInternal("int value"@intEffect.m_value);
            //     }
            //     floatEffect = BioGameEffectAttributeFloat(effect);
            //     if (floatEffect != None)
            //     {
            //         LogInternal("float value"@floatEffect.m_value);
            //     }
            //     propEffect = BioGameEffectAddItemProperty(effect);
            //     if (propEffect != None)
            //     {
            //         LogInternal("prop id"@propEffect.m_nItemPropertyID);
            //     }
            // }
        }
    }
    LogInternal("got"@tag@armorType@meshVariant@materialVariant);
    return true;

    // TODO iterate through the 81k rows? :(
    // Items2DA.GetNumRows()
    // so, we need to find rows with item matching the manufacturer id:
    // and game property labels matching the gpl given above
    //      and one of the following game effect labels
    //      GE_Armor_ModelVariant_O (mesh variant int)
    //      GE_Armor_MatID_O (material variant int)
    // OR gpl of GP_Manf_Armor_AppearanceOverride, which is not very often present, but we need to handle when it is
}

private function string GetGamePropertyLabel(name tag, int itemId, out int armorWeight)
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

private function string GetArmorWeight(int itemId, out int armorWeight)
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

// path to get stuff:
// first, I need to go from the hench tag to their actorType (and default equipment) using BIOG_2DA_Characters_X.Characters_Character
// I need to load the actorType (might be slow?)
// I need to load the squad record from the current save file. if none, short circuit out and let it do vanilla outfit
// I need to grab which one is armor (should be easy by index, but it will take some time to figure out which it is)
// I need to look up that armor by id in BIOG_2DA_Equipment_X.Items_ItemEffectLevels
// from there, get the parameters and load it as normal