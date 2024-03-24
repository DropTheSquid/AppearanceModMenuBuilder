class BreatherSpecBase extends Object
    abstract;

// loads (but does not apply) a breather, returning true if it was succesful and false otherwise
// the out param holds the loaded outfit meshes and parameters about how to alter the pawn's appearance
public function bool LoadBreather(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance);
