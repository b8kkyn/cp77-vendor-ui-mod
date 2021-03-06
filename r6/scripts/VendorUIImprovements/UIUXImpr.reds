module VendorUIImprovements.UIUXImpr

@wrapMethod(gameuiInventoryGameController)
private final func GetEquipmentAreaPaperdollLocation(equipmentArea: gamedataEquipmentArea) -> PaperdollPositionAnimation {
  if VuiMod.Get().OptionFixDropdownPosition {
    switch equipmentArea {
      /* VuiMod Start */
      case gamedataEquipmentArea.AbilityCW:
      case gamedataEquipmentArea.CardiovascularSystemCW:
      case gamedataEquipmentArea.EyesCW:
      case gamedataEquipmentArea.FrontalCortexCW:
      case gamedataEquipmentArea.ImmuneSystemCW:
      case gamedataEquipmentArea.IntegumentarySystemCW:
      case gamedataEquipmentArea.LegsCW:
      case gamedataEquipmentArea.MusculoskeletalSystemCW:
      case gamedataEquipmentArea.NervousSystemCW:
      /* VuiMod End */
      case gamedataEquipmentArea.Weapon:
      case gamedataEquipmentArea.ArmsCW:
      case gamedataEquipmentArea.HandsCW:
      case gamedataEquipmentArea.SystemReplacementCW:
        return PaperdollPositionAnimation.Right;
      case gamedataEquipmentArea.OuterChest:
      case gamedataEquipmentArea.InnerChest:
      case gamedataEquipmentArea.Face:
      case gamedataEquipmentArea.Head:
        return PaperdollPositionAnimation.Left;
      case gamedataEquipmentArea.Outfit:
      case gamedataEquipmentArea.Feet:
      case gamedataEquipmentArea.Legs:
      case gamedataEquipmentArea.Consumable:
      case gamedataEquipmentArea.Gadget:
      case gamedataEquipmentArea.QuickSlot:
        return PaperdollPositionAnimation.LeftFullBody;
    };

    return PaperdollPositionAnimation.Center;
  } else {
    return wrappedMethod(equipmentArea);
  }
}

@wrapMethod(InventoryItemModeLogicController)
private final func IsEquipmentAreaClothing(equipmentArea: gamedataEquipmentArea) -> Bool {
  if VuiMod.Get().OptionFixInventoryFilter {
    return Equals(equipmentArea, gamedataEquipmentArea.Head) || Equals(equipmentArea, gamedataEquipmentArea.Face) || Equals(equipmentArea, gamedataEquipmentArea.OuterChest) || Equals(equipmentArea, gamedataEquipmentArea.InnerChest) || Equals(equipmentArea, gamedataEquipmentArea.Legs) || Equals(equipmentArea, gamedataEquipmentArea.Feet) || Equals(equipmentArea, gamedataEquipmentArea.Outfit);
  } else {
    return wrappedMethod(equipmentArea);
  }
}

@wrapMethod(InventoryItemModeLogicController)
protected cb func OnItemChooserItemChanged(e: ref<ItemChooserItemChanged>) -> Bool {
  if VuiMod.Get().OptionFixInventoryFilter {
    let itemsToSkip: array<ItemID>;
    let itemViewMode: ItemViewModes = ItemViewModes.Mod;

    if !TDBID.IsValid(e.slotID) {
      itemViewMode = ItemViewModes.Item;
    };

    if Equals(e.itemEquipmentArea, gamedataEquipmentArea.Consumable) || Equals(e.itemEquipmentArea, gamedataEquipmentArea.QuickSlot) {
      if Equals(e.itemEquipmentArea, gamedataEquipmentArea.Consumable) {
        this.m_currentHotkey = EHotkey.DPAD_UP;
      } else {
        if Equals(e.itemEquipmentArea, gamedataEquipmentArea.QuickSlot) {
          this.m_currentHotkey = EHotkey.RB;
        };
      };

      ArrayPush(itemsToSkip, this.itemChooser.GetSelectedItem().GetItemID());

      this.SetEquipmentArea(e.itemEquipmentArea);
      this.UpdateAvailableHotykeyItems(this.m_currentHotkey, itemsToSkip);

      this.SelectFilterButton(ItemFilterCategory.AllItems); /* VuiMod */
    } else {
      this.m_currentHotkey = EHotkey.INVALID;

      this.SetEquipmentArea(e.itemEquipmentArea);
      this.RefreshAvailableItems(itemViewMode);
    };

    (inkWidgetRef.GetController(this.m_itemGridScrollControllerWidget) as inkScrollController).SetScrollPosition(0.00);
  } else {
    return wrappedMethod(e);
  }
}

@wrapMethod(VendorItemVirtualController)
private final func UpdateControllerData() -> Void {
  if VuiMod.Get().OptionAddOwnedLabel {
    let applyDLCAddedIndicator: Bool;

    if this.m_data.IsVendorItem {
      this.m_itemViewController.Setup(this.m_data.ItemData, ItemDisplayContext.Vendor, this.m_data.IsEnoughMoney, VuiMod.Get().CheckPlayerHasItem(this.m_data.ItemData)); /* VuiMod */
      applyDLCAddedIndicator = InventoryItemData.GetGameItemData(this.m_data.ItemData).HasTag(n"DLCAdded") && this.m_data.IsDLCAddedActiveItem;
      this.m_itemViewController.SetDLCNewIndicator(applyDLCAddedIndicator);
    } else {
      this.m_itemViewController.Setup(this.m_data.ItemData, ItemDisplayContext.VendorPlayer);
    };

    this.m_itemViewController.SetComparisonState(this.m_data.ComparisonState);
    this.m_itemViewController.SetBuybackStack(this.m_data.IsBuybackStack);
  } else {
    wrappedMethod();
  }
}

@wrapMethod(InventoryItemDisplayController)
protected func UpdateIndicators() -> Void {
  if VuiMod.Get().OptionAddOwnedLabel {
    let localData: ref<gameItemData>;

    if IsDefined(this.m_labelsContainerController) {
      this.m_labelsContainerController.Clear();
    };

    if this.m_owned && (Equals(this.m_itemDisplayContext, ItemDisplayContext.VendorPlayer) || Equals(this.m_itemDisplayContext, ItemDisplayContext.Vendor)) { /* VuiMod */
      if IsDefined(this.m_labelsContainerController) {
        this.m_labelsContainerController.Add(ItemLabelType.Owned);
      };
    };

    if this.m_isBuybackStack {
      this.m_labelsContainerController.Add(ItemLabelType.Buyback);
    };

    if this.m_isDLCNewItem {
      this.m_labelsContainerController.Add(ItemLabelType.DLCNew);
    };

    localData = InventoryItemData.GetGameItemData(this.m_itemData);
    if IsDefined(localData) {
      inkWidgetRef.SetVisible(this.m_questItemMaker, localData.HasTag(n"Quest") || localData.HasTag(n"UnequipBlocked"));
    } else {
      inkWidgetRef.SetVisible(this.m_questItemMaker, false);
    };
  } else {
    wrappedMethod();
  }
}

@wrapMethod(FullscreenVendorGameController)
private final func RequestAutoSave(opt delay: Float) -> Void {
  if !VuiMod.Get().OptionDisableVendorAutoSave {
    wrappedMethod(delay);
  }
}
