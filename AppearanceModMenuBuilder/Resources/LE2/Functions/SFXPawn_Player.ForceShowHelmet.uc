public final function ForceShowHelmet(bool bShowHelmet)
{
    local int Idx;
    local CustomizableElement Helmet;
    local string HelmetName;
    local string ChkName;
    
    if (bShowHelmet)
    {
        Idx = HelmetAppearances.Find('Id', HelmetID);
        if (Idx != -1)
        {
            Helmet = HelmetAppearances[Idx];
            HelmetName = bIsFemale ? Helmet.Mesh.Female : Helmet.Mesh.Male;
            if (HelmetName != "")
            {
                if (Helmet.Mesh.bHasBreather)
                {
                    OverrideHelmetID = HelmetID;
                    return;
                }
                else
                {
                    for (Idx = 0; Idx < HelmetAppearances.Length; Idx++)
                    {
                        ChkName = bIsFemale ? HelmetAppearances[Idx].Mesh.Female : HelmetAppearances[Idx].Mesh.Male;
                        if (ChkName == HelmetName && HelmetAppearances[Idx].Mesh.bHasBreather)
                        {
                            OverrideHelmetID = HelmetAppearances[Idx].Id;
                            return;
                        }
                    }
                }
            }
        }
        for (Idx = 0; Idx < HelmetAppearances.Length; Idx++)
        {
            ChkName = bIsFemale ? HelmetAppearances[Idx].Mesh.Female : HelmetAppearances[Idx].Mesh.Male;
            if (ChkName != "" && HelmetAppearances[Idx].Mesh.bHasBreather)
            {
                OverrideHelmetID = HelmetAppearances[Idx].Id;
                return;
            }
        }
        if (HelmetAppearances.Length > 0)
        {
            OverrideHelmetID = HelmetAppearances[0].Id;
            return;
        }
    }
    OverrideHelmetID = -1;
}