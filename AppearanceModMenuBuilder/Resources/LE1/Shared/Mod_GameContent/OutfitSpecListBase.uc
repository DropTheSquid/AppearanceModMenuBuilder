Class OutfitSpecListBase
    config(Game)
	abstract;

// Types
struct OutfitSpecItem 
{
	// always mandatory
    var int Id;
	// below this, you must provide either the specPath
    var string specPath;
	// or most of the below
	var AppearanceMeshPaths BodyMesh;
	// TODO implement these
    // var bool suppressHelmet;
    // var bool suppressBreather;
    // var bool hideHair;
    // var bool hideHead;
    // var int HelmetSpec;
    // var int BreatherSpec;
    // var EBioArmorType armorTypeOverride;
    // var int meshVariantOverride;
    // var int materialVariantOverride;
};

// Variables
var config array<OutfitSpecItem> outfitSpecs;

public function bool GetOutfitSpecById(int Id, out OutfitSpecBase OutfitSpec)
{
	local OutfitSpecItem item;
	local Class<OutfitSpecBase> outfitSpecClass;
    local SimpleOutfitSpec simpleSpec;

	if (GetOutfitSpecItemById(id, item))
	{
		if (item.specPath != "")
		{
			// LogInternal("dynamic loading spec" @ item.specPath, );
			outfitSpecClass = Class<OutfitSpecBase>(DynamicLoadObject(item.specPath, Class'Class', TRUE));
			if (outfitSpecClass == None)
			{
				OutfitSpec = OutfitSpecBase(DynamicLoadObject(item.specPath, Class'OutfitSpecBase', TRUE));
				if (outfitSpec == None)
				{
					LogInternal("Warning: Could not get outfit spec instance"@item.specPath);
					return false;
				}
				return OutfitSpec != None;
			}
			OutfitSpec = new outfitSpecClass;
			// LogInternal("outfit spec loaded" @ OutfitSpec, );
			// if (VanillaOverrideOutfitSpec(OutfitSpec) != None)
			// {
			// 	// LogInternal("apllying vanilla overrides" @ item.armorTypeOverride, );
			// 	VanillaOverrideOutfitSpec(OutfitSpec).armorType = item.armorTypeOverride;
			// 	VanillaOverrideOutfitSpec(OutfitSpec).meshVariant = item.meshVariantOverride;
			// 	VanillaOverrideOutfitSpec(OutfitSpec).materialVariant = item.materialVariantOverride;
			// }
			if (outfitSpec == None)
			{
				LogInternal("Warning: Could not get outfit spec from class"@item.specPath);
				return false;
			}
			return OutfitSpec != None;
		}
		simpleSpec = new Class'SimpleOutfitSpec';
		simpleSpec.bodyMesh = item.bodyMesh;
		// simpleSpec.bSuppressHelmet = item.suppressHelmet;
		// simpleSpec.bSuppressBreather = item.suppressBreather;
		// simpleSpec.bHideHair = item.hideHair;
		// simpleSpec.bHideHead = item.hideHead;
		// simpleSpec.helmetTypeOverride = item.HelmetSpec;
		// simpleSpec.breatherTypeOverride = item.BreatherSpec;
		OutfitSpec = simpleSpec;
		if (outfitSpec == None)
		{
			LogInternal("Warning: Could not make simple outfit spec with mesh"@item.BodyMesh.MeshPath);
			return false;
		}
		return true;
	}
	LogInternal("Warning: Could not get outfitSpec by id"@Id);
	return false;
}

// Functions
private function bool GetOutfitSpecItemById(int Id, out OutfitSpecItem item)
{
    local int index;
    
    // Go from the end of the list to the start in order to find the highest mounted version in case of a conflict
    for (index = outfitSpecs.Length - 1; index >= 0; index--)
    {
        if (outfitSpecs[index].Id == Id)
        {
            item = outfitSpecs[index];
            return TRUE;
        }
    }
	LogInternal("Warning: Could not get outfitSpecItem by id"@Id);
    return FALSE;
}
