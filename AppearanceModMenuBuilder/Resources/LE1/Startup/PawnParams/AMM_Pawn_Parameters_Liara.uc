Class AMM_Pawn_Parameters_Liara extends AMM_Pawn_Parameters_Romanceable
	config(Game);

// These are intended to be set by mods that alter Liara such that she appears in armor on her recruitment mission and/or Virmire
// setting this to true indicates to AMM to treat this appearance as a combat appearance (thus using the combat appearance override if one is picked)
// and also to disable the setting that would let users force Liara into armor in these appearances so it won't override your appearance
var config bool LiaraWearsArmorOnTherum;
var config bool LiaraWearsArmorOnVirmire;

public function bool matchesPawn(BioPawn targetPawn)
{
	local string targetPath;

	targetPath = PathName(targetPawn);
	// there are two pawns in two scenes near the end that have the same tag as Liara for some reason. They should not be matched as Liara
	// HACK vanilla issue, would be resolved by the framework, but is also fairly harmless to leave in. 
    if (targetPath ~= "BIOA_END70C_Bridge_CIN.TheWorld:PersistentLevel.BioPawn_1" 
		|| targetPath ~= "BIOA_END70C_Bridge_CIN.TheWorld:PersistentLevel.BioPawn_7"
		|| targetPath ~= "BIOA_LOS00_Bridge_CIN.TheWorld:PersistentLevel.BioPawn_1"
		|| targetPath ~= "BIOA_LOS00_Bridge_CIN.TheWorld:PersistentLevel.BioPawn_7")
    {
        return false;
    }
    return Super.matchesPawn(targetPawn);
}

public function Object GetOverrideDefaultOutfitSpec(BioPawn targetPawn)
{
	local VanillaOutfitByIdSpec delegateSpec;

	if (IsOnTherum(TargetPawn) && ForceLiaraToWearArmorOnTherum()
		|| IsOnVirmire(TargetPawn) && ForceLiaraToWearArmorOnVirmire())
	{
		// if we are forcing Liara into armor, delegate to a spec for her default armor appearance (Gladiator Light)
		delegateSpec = new class'VanillaOutfitByIdSpec';
		delegateSpec.armorType = EBioArmorType.ARMOR_TYPE_LIGHT;
		delegateSpec.meshVariant = 0;
		delegateSpec.materialVariant = 6;
		return delegateSpec;
	}

	// otherwise, let it behave as normal

	return super.GetOverrideDefaultOutfitSpec(targetPawn);
}

public function string GetAppearanceType(BioPawn targetPawn)
{
	if (IsOnTherum(targetPawn))
	{
		if (LiaraWearsArmorOnTherum || ForceLiaraToWearArmorOnTherum())
		{
			return "combat";
		}
		return "casual";
	}

	if (IsOnVirmire(targetPawn))
	{
		if (LiaraWearsArmorOnVirmire || ForceLiaraToWearArmorOnVirmire())
		{
			return "combat";
		}
		return "casual";
	}

	return Super(AMM_Pawn_Parameters_Romanceable).GetAppearanceType(targetPawn);
}

private function bool IsOnTherum(BioPawn target)
{
	local BioWorldInfo BWI;

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
	if (target.GetPackageName() == 'BIOA_LAV70_07_DSG'
		|| (target.GetPackageName() == 'BIONPC_Liara' && InStr(PathName(BWI), "LAV") != -1))
	{
		return true;
	}

	return false;
}

private function bool IsOnVirmire(BioPawn target)
{
	local BioWorldInfo BWI;

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
	if (target.GetPackageName() == 'BIOA_JUG20_08_DSG'
		|| (target.GetPackageName() == 'BIONPC_Liara' && InStr(PathName(BWI), "JUG") != -1))
	{
		return true;
	}

	return false;
}

private function bool ForceLiaraToWearArmorOnTherum()
{
	local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;

	// ignore this setting if the bool is set
	if (LiaraWearsArmorOnTherum)
	{
		return false;
	}

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    globalVars = BWI.GetGlobalVariables();
    return globalVars.GetInt(1599) != 0;
}

private function bool ForceLiaraToWearArmorOnVirmire()
{
	local BioWorldInfo BWI;
    local BioGlobalVariableTable globalVars;

	// ignore this setting if the bool is set
	if (LiaraWearsArmorOnVirmire)
	{
		return false;
	}

    BWI = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo());
    globalVars = BWI.GetGlobalVariables();
    return globalVars.GetInt(1602) != 0;
}

defaultproperties
{
}