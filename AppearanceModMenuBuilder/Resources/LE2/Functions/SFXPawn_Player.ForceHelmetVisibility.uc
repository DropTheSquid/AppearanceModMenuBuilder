public function ForceHelmetVisibility(bool bHelmetVisible)
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.ForceHelmetVisibility(Self, bHelmetVisible);
}