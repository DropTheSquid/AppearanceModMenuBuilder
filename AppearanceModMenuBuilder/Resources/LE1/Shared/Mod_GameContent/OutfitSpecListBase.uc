Class OutfitSpecListBase extends Object
    config(Game)
	abstract;

// Types
struct OutfitSpecItem
{
	// always mandatory
    var int Id;
	// below this, you must provide either the specPath
    var string specPath;
	// or this along with any of the others if non default
	var AppearanceMeshPaths BodyMesh;
	// intended for outfits that include the helmet/hood, so it will never show a helmet along with it
	// a breather can still be shown if not suppressed
    var bool suppressHelmet;
    var bool suppressBreather;
	// along with the above, the outfit can hide the hair or head
    var bool hideHair;
    var bool hideHead;
	// the default helmet spec to use. Will be applied if the helmet spec is 0 or -1
	// usually to give armor a matching helmet
    var int HelmetSpec;
	// you can make your outfit spec delegate to a different one when a helmet is requested
	// this allows you to use a different mesh and do a hood down/hood up type outfit controlled by the helmet visibility
	var int HelmetOnBodySpec;
	// same as above, but allows a different outfit if the helmet is full with breather
	var int HelmetFullBodySpec;
};

// Variables
var config array<OutfitSpecItem> outfitSpecs;

public function bool DelegateToOutfitSpecById(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local OutfitSpecBase deletageSpec;

	if (GetOutfitSpecById(appearanceIds.bodyAppearanceId, deletageSpec))
	{
		if (deletageSpec.LoadOutfit(target, specLists, appearanceIds, appearance))
		{
			return true;
		}
		LogInternal("Warning: failed to apply outfit by id"@appearanceIds.bodyAppearanceId);
	}
	return false;
}

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
			if (outfitSpec == None)
			{
				LogInternal("Warning: Could not get outfit spec from class"@item.specPath);
				return false;
			}
			return OutfitSpec != None;
		}
		simpleSpec = new Class'SimpleOutfitSpec';
		simpleSpec.bodyMesh = item.bodyMesh;
		simpleSpec.bSuppressHelmet = item.suppressHelmet;
		simpleSpec.bSuppressBreather = item.suppressBreather;
		simpleSpec.bHideHair = item.hideHair;
		simpleSpec.bHideHead = item.hideHead;
		simpleSpec.helmetTypeOverride = item.HelmetSpec;
		simpleSpec.HelmetOnBodySpec = item.HelmetOnBodySpec;
		simpleSpec.HelmetFullBodySPec = item.HelmetFullBodySpec;
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
