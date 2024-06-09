Class HelmetSpecListBase extends Object
    config(Game)
	abstract;

struct HelmetSpecItem
{
	// always required
    var int Id;
	// you must provide either this
    var string specPath;
	// or HelmetMesh plus any of the below for non default
    var AppearanceMeshPaths HelmetMesh;
    var AppearanceMeshPaths VisorMesh;
	var bool suppressVisor;
    var bool suppressBreather;
    var bool hideHair;
    var bool hideHead;
    // var int BreatherSpec;
    // var string comment;
};

var config array<HelmetSpecItem> helmetSpecs;

public function bool DelegateToHelmetSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local HelmetSpecBase deletageSpec;

	if (GetHelmetSpecById(appearanceIds.helmetAppearanceId, deletageSpec))
	{
		if (deletageSpec.LoadHelmet(target, specLists, appearanceIds, appearance))
		{
			return true;
		}
		LogInternal("Warning: failed to apply helmet by id"@appearanceIds.helmetAppearanceId);
	}
	return false;
}

public function bool GetHelmetSpecById(int Id, out HelmetSpecBase helmetSpec)
{
	local HelmetSpecItem item;
	local Class<HelmetSpecBase> helmetSpecClass;
    local SimpleHelmetSpec simpleSpec;

	if (GetHelmetSpecItemById(id, item))
	{
		if (item.specPath != "")
		{
			helmetSpecClass = Class<HelmetSpecBase>(DynamicLoadObject(item.specPath, Class'Class', TRUE));
			if (helmetSpecClass == None)
			{
				helmetSpec = HelmetSpecBase(DynamicLoadObject(item.specPath, Class'HelmetSpecBase', TRUE));
				if (helmetSpec == None)
				{
					LogInternal("Warning: Could not get helmet spec instance"@item.specPath);
					return false;
				}
				return helmetSpec != None;
			}
			helmetSpec = new helmetSpecClass;
			if (helmetSpec == None)
			{
				LogInternal("Warning: Could not get helmet spec from class"@item.specPath);
				return false;
			}
			return helmetSpec != None;
		}
		simpleSpec = new Class'SimpleHelmetSpec';
		simpleSpec.helmetMesh = item.helmetMesh;
		simpleSpec.VisorMesh = item.VisorMesh;
		simpleSpec.bSuppressVisor = item.suppressVisor;
		simpleSpec.bSuppressBreather = item.suppressBreather;
		simpleSpec.bHideHair = item.hideHair;
		simpleSpec.bHideHead = item.hideHead;
		// simpleSpec.breatherTypeOverride = item.BreatherSpec;
		helmetSpec = simpleSpec;
		if (helmetSpec == None)
		{
			LogInternal("Warning: Could not make simple helmet spec with mesh"@item.HelmetMesh.MeshPath);
			return false;
		}
		return true;
	}
	LogInternal("Warning: Could not get helmetSpec by id"@Id);
	return false;
}

public function bool GetHelmetSpecItemById(int Id, out HelmetSpecItem item)
{
    local int index;
    local string sComment;
    
    // Go from the end of the list to the start in order to find the highest mounted version in case of a conflict
    for (index = helmetSpecs.Length - 1; index >= 0; index--)
    {
        if (helmetSpecs[index].Id == Id)
        {
            item = helmetSpecs[index];
            return TRUE;
        }
    }
    return FALSE;
}