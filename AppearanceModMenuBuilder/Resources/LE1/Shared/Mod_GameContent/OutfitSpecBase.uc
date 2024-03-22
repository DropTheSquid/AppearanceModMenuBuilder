class OutfitSpecBase extends Object
    abstract;

// loads (but does not apply) an outfit, returning true if it was succesful and false otherwise
// the out param holds the loaded outfit meshes and parameters about how to alter the pawn's appearance
public function bool LoadOutfit(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance);

// allow you to take full control of altering the pawn's appearance if you return true
// public function bool HandlePawnUpdate(PawnAppearanceIds appearanceIds, BioPawn target)
// {
// 	return false;
// }