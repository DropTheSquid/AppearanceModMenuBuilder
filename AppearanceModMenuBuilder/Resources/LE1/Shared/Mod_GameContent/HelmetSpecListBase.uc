Class HelmetSpecListBase
    config(Game);

// Types
struct HelmetSpecItem 
{
	// always required
    var int Id;
	// you must provide either this
    var string specPath;
	// or most of the below
    var AppearanceMeshPaths HelmetMesh;
    var AppearanceMeshPaths VisorMesh;
    // var bool suppressBreather;
    // var bool hideHair;
    // var bool hideHead;
    // var int BreatherSpec;
    // var string comment;
};

// Variables
var config array<HelmetSpecItem> helmetSpecs;

// Functions
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

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}