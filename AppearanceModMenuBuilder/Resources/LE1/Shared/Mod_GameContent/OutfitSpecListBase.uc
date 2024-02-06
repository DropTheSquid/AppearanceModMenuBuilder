Class OutfitSpecListBase
    config(Game);

// Types
struct OutfitSpecItem 
{
	// always mandatory
    var int Id;
	// below this, you must provide either the specPath
    var string specPath;
	// or most of the below
    var string Mesh;
    var array<string> Materials;
    // var bool suppressHelmet;
    // var bool suppressBreather;
    // var bool hideHair;
    // var bool hideHead;
    // var int HelmetSpec;
    // var int BreatherSpec;
    // var EBioArmorType armorTypeOverride;
    // var int meshVariantOverride;
    // var int materialVariantOverride;
    
    // structdefaultproperties
    // {
    //     Materials = ()
    // }
};

// Variables
var config array<OutfitSpecItem> outfitSpecs;

// Functions
public function bool GetOutfitSpecItemById(int Id, out OutfitSpecItem item)
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
    return FALSE;
}