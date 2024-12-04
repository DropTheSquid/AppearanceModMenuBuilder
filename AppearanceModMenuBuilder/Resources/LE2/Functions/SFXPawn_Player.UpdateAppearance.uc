public function UpdateAppearance()
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.UpdateAppearance(Self);
}