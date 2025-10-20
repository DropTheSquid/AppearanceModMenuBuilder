class OriginalBreatherSpec extends BreatherSpecBase;

public function bool LoadBreather(BioPawn target, SpecLists specLists, out PawnAppearanceIds appearanceIds, out pawnAppearance appearance)
{
	local eHelmetDisplayState helmetDisplayState;
	local BreatherSpecBase delegateBreatherSpec;
    local HelmetSpecBase helmetDelegateSpec;
    local AMM_OriginalOutfit originalOutfit;

    if (Class'AMM_OriginalOutfit'.static.GetOutfit(target, originalOutfit))
    {
        appearance.BreatherMesh = originalOutfit.originalBreather;
    }
    else
    {
        delegateBreatherSpec = new Class'VanillaBreatherSpec';
        return delegateBreatherSpec.LoadBreather(target, specLists, appearanceIds, appearance);
    }
	return true;
}