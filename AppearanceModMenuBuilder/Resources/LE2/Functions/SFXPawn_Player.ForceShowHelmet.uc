public final function ForceShowHelmet(bool bShowHelmet)
{
    local AppearanceUpdater AppearanceUpdater;
    
    AppearanceUpdater = Class'AppearanceUpdater'.static.GetInstance();
    AppearanceUpdater.ForceShowHelmet(Self, bShowHelmet);
}