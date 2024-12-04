public function CopyPawnAppearance(BioPawn SourcePawn)
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.CopyPawnAppearance(Self, SourcePawn);
}