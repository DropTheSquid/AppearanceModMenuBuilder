class VanillaOutfitSpecBase extends OutfitSpecBase abstract;

public function bool ApplyOutfit(BioPawn target)
{
	local AppearanceMesh appearanceMesh;
	local int armorType;
    local int meshVariant;
    local int materialVariant;
	local string meshPath;
	local array<string> meshMaterialPaths;

	// this is for equipping their vanilla outfit
	// we will determine what outfit it should be based on the pawn's settings and then apply it
	if (!GetVariant(target, armorType, meshVariant, materialVariant))
    {
        return FALSE;
    }
	if (!GetOutfitStrings(
		class'AMM_Utilities'.static.GetPawnType(target),
		armorType, meshVariant, materialVariant,
		meshPath, meshMaterialPaths))
	{
		return false;
	}

	class'AMM_Utilities'.static.LoadSkeletalMesh(meshPath, AppearanceMesh.Mesh);
	class'AMM_Utilities'.static.LoadMaterials(meshMaterialPaths, AppearanceMesh.Materials);
	class'AMM_Utilities'.static.ReplaceMesh(target, target.Mesh, AppearanceMesh);

	return true;
}

protected function bool GetVariant(BioPawn targetPawn, out int armorType, out int meshVariant, out int materialVariant)
{
	// This is in the abstract base class, and needs to be overridden in child classes
    LogInternal("You have made a programming mistake; VanillaOutfitSpecBase.GetVariant should never be called", );
    return FALSE;
}

protected static function bool GetOutfitStrings(BioPawnType pawnType, int armorType, int meshVariant, int materialVariant, out string Mesh, out array<string> Materials)
{
    local ArmorTypes armor;
    local string meshPackageName;
    local string materialPackageName;
    local string prefix;
    local string meshCode;
    local int numMaterials;
    local string tempMaterial;
    local int i;
    
    armor = pawnType.m_oAppearance.Body.armor[armorType];
    meshPackageName = string(armor.m_meshPackageName);
    materialPackageName = string(armor.m_materialPackageName);
    if (meshPackageName == "None" || materialPackageName == "None")
    {
        LogInternal("No mesh or material package for armor type" @ armorType, );
        return FALSE;
    }
    prefix = pawnType.m_oAppearance.Body.AppearancePrefix;
    // For example, LGTa
    meshCode = GetArmorCode(byte(armorType)) $ GetLetter(meshVariant);
    numMaterials = armor.Variations[meshVariant].MaterialsPerVariation;
    Mesh = meshPackageName $ "." $ meshCode $ "." $ prefix $ "_" $ meshCode $ "_MDL";
    for (i = 0; i < numMaterials; i++)
    {
        tempMaterial = materialPackageName $ "." $ meshCode $ "." $ prefix $ "_" $ meshCode $ "_MAT_" $ materialVariant + 1 $ GetLetter(i);
        Materials.AddItem(tempMaterial);
    }
    return TRUE;
}

protected static function string GetArmorCode(EBioArmorType armorType)
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

protected static function string GetLetter(int num)
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