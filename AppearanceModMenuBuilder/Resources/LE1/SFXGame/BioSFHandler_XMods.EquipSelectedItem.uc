public final function EquipSelectedItem(int nItemIndex, int nSlotIndex)
{
    local int I;
    local int nMappedSlot;
    local int nXModIndex;
    local BioWorldInfo oBWI;
    local float fPreviousShieldRatio;
    
    nXModIndex = nSlotIndex - 1;
    if (nXModIndex < 0)
    {
        return;
    }
    if (m_stEquippedItemInfo.m_lstXMods.Length <= nXModIndex)
    {
        LogInternal(Class @ GetFuncName() @ "Attempting to swap an xmod over an out-of-bounds slot index.", );
        return;
    }
    nMappedSlot = 0;
    for (I = 0; I < nXModIndex; I++)
    {
        if (m_stEquippedItemInfo.m_lstXMods[I].m_nType == m_stEquippedItemInfo.m_lstXMods[nXModIndex].m_nType)
        {
            nMappedSlot++;
        }
    }
    switch (m_eCurrentItemSlot)
    {
        case GuiEquipSlots.EQUIP_SLOT_Pistol:
            m_oInvInterface.SelectQuickslotItem(0);
            break;
        case GuiEquipSlots.EQUIP_SLOT_Shotgun:
            m_oInvInterface.SelectQuickslotItem(1);
            break;
        case GuiEquipSlots.EQUIP_SLOT_Assault:
            m_oInvInterface.SelectQuickslotItem(2);
            break;
        case GuiEquipSlots.EQUIP_SLOT_Sniper:
            m_oInvInterface.SelectQuickslotItem(3);
            break;
        case GuiEquipSlots.EQUIP_SLOT_BioAmp:
            m_oInvInterface.SelectEquipmentItem(4);
            break;
        case GuiEquipSlots.EQUIP_SLOT_Armor:
            m_oInvInterface.SelectEquipmentItem(1);
            fPreviousShieldRatio = m_oInvInterface.GetShieldRatio();
            break;
        case GuiEquipSlots.EQUIP_SLOT_OmniTool:
            m_oInvInterface.SelectEquipmentItem(3);
            break;
        case GuiEquipSlots.EQUIP_SLOT_Grenades:
            m_oInvInterface.SelectEquipmentItem(2);
            break;
        default:
            LogInternal(Class @ GetFuncName() @ "Attempting to install an XMod onto a mistaken item.", );
            break;
    }
    if (m_stEquippedItemInfo.m_lstXMods[nXModIndex].m_nType > -1 && m_stEquippedItemInfo.m_lstXMods[nXModIndex].m_oXMod != None)
    {
        m_oInvInterface.UninstallXMod(m_stEquippedItemInfo.m_lstXMods[nXModIndex].m_nType, nMappedSlot);
    }
    if (nItemIndex > -1)
    {
        LogInternal("Xmod name to equip: " @ m_oInvInterface.EquippableItemsList[nItemIndex].ItemName @ " invindex: " @ m_oInvInterface.EquippableItemsList[nItemIndex].InvIndex, );
        m_oInvInterface.EquippableItemsList[nItemIndex].itemRef.bJunkItem = FALSE;
        m_oInvInterface.InstallXMod(m_oInvInterface.EquippableItemsList[nItemIndex].InvIndex, m_stEquippedItemInfo.m_lstXMods[nXModIndex].m_nType);
    }
    if (m_eCurrentItemSlot == GuiEquipSlots.EQUIP_SLOT_Armor)
    {
        m_oInvInterface.SetShieldRatio(fPreviousShieldRatio);
    }
    PopulateForCharacter(FALSE);
    if (m_eCurrentItemSlot == GuiEquipSlots.EQUIP_SLOT_Armor && m_oInvGuiHandler.m_oLastSpawnedPawn != None)
    {
        oBWI = BioWorldInfo(oWorldInfo);
        oBWI.m_UIWorld.UpdateAppearance(m_oInvGuiHandler.m_oLastSpawnedPawn);
        // added by AMM so that the appearance gets updated after changing mods; without this, helmets have a bad habit of disappearing
        oBWI.m_UIWorld.TriggerEvent('re_AMM_update_Appearance', oWorldInfo);
    }
}