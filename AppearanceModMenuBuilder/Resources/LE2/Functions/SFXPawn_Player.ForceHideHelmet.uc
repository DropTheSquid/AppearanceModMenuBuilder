public final function ForceHideHelmet(bool bHideHelmet)
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.ForceHideHelmet(Self, bHideHelmet);
}