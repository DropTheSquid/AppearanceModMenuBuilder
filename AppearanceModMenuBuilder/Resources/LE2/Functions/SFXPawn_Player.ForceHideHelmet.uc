public final function ForceHideHelmet(bool bHideHelmet)
{
    if (bHideHelmet)
    {
        OverrideHelmetID = 0;
    }
    else
    {
        OverrideHelmetID = -1;
    }
}