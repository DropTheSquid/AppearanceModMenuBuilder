class OutfitSpecBase extends Object
    abstract;

// loads (but does not apply) an outfit, returning true if it was succesful and false otherwise
// the out param holds the loaded outfit meshes and parameters about how to alter the pawn's appearance
public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance);

public function bool LocksHelmetSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    return false;
}

public function bool LocksBreatherSelection(BioPawn target, SpecLists specLists, PawnAppearanceIds appearanceIds)
{
    return false;
}