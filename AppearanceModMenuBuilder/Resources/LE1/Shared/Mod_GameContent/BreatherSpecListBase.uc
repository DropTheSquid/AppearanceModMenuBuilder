Class BreatherSpecListBase extends Object
    config(Game)
	abstract;

struct BreatherSpecItem
{
	// always required
    var int Id;
	// you must provide either this
    var string specPath;
	// or BreatherMesh plus any of the below for non default
    var AppearanceMeshPaths BreatherMesh;
	var AppearanceMeshPaths VisorMeshOverride;
    var bool hideHair;
    var bool hideHead;
};

var config array<BreatherSpecItem> breatherSpecs;

public function bool DelegateToBreatherSpec(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local BreatherSpecBase deletageSpec;

	if (GetBreatherSpecById(appearanceIds.breatherAppearanceId, deletageSpec))
	{
		if (deletageSpec.LoadBreather(target, specLists, appearanceIds, appearance))
		{
			return true;
		}
		LogInternal("Warning: failed to apply breather by id"@appearanceIds.breatherAppearanceId);
	}
	return false;
}

public function bool GetBreatherSpecById(int Id, out BreatherSpecBase breatherSpec)
{
	local BreatherSpecItem item;
	local Class<BreatherSpecBase> breatherSpecClass;
    local SimpleBreatherSpec simpleSpec;

	if (GetBreatherSpecItemById(id, item))
	{
		if (item.specPath != "")
		{
			// LogInternal("dynamic loading spec" @ item.specPath, );
			breatherSpecClass = Class<BreatherSpecBase>(DynamicLoadObject(item.specPath, Class'Class', TRUE));
			if (breatherSpecClass == None)
			{
				breatherSpec = BreatherSpecBase(DynamicLoadObject(item.specPath, Class'BreatherSpecBase', TRUE));
				if (breatherSpec == None)
				{
					LogInternal("Warning: Could not get breather spec instance"@item.specPath);
					return false;
				}
				return breatherSpec != None;
			}
			breatherSpec = new breatherSpecClass;
			// LogInternal("breather spec loaded" @ breatherSpec, );
			if (breatherSpec == None)
			{
				LogInternal("Warning: Could not get breather spec from class"@item.specPath);
				return false;
			}
			return breatherSpec != None;
		}
		simpleSpec = new Class'SimpleBreatherSpec';
		simpleSpec.breatherMesh = item.breatherMesh;
		simpleSpec.OverrideVisorMesh = item.VisorMeshOverride;
		// simpleSpec.bSuppressVisor = item.suppressVisor;
		simpleSpec.bHideHair = item.hideHair;
		simpleSpec.bHideHead = item.hideHead;
		// simpleSpec.breatherTypeOverride = item.BreatherSpec;
		breatherSpec = simpleSpec;
		if (breatherSpec == None)
		{
			LogInternal("Warning: Could not make simple breather spec with mesh"@item.BreatherMesh.MeshPath);
			return false;
		}
		return true;
	}
	LogInternal("Warning: Could not get breatherSpec by id"@Id);
	return false;
}

public function bool GetBreatherSpecItemById(int Id, out BreatherSpecItem item)
{
    local int index;
    local string sComment;
    
    // Go from the end of the list to the start in order to find the highest mounted version in case of a conflict
    for (index = breatherSpecs.Length - 1; index >= 0; index--)
    {
        if (breatherSpecs[index].Id == Id)
        {
            item = breatherSpecs[index];
            return TRUE;
        }
    }
    return FALSE;
}