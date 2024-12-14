class com.bioware.masseffect.views.ChoiceGUI extends com.bioware.masseffect.views.HistoryScreen
{
   var m_RightPanel;
   var m_ChoiceImageLoader;
   var rightPaneInfo;
   var m_ActiveScrollingWidget;
   var scrollbarList;
   var vList;
   var PCbutton1;
   var PCbutton2;
   var PCBackButton;
   var bUsingGamepad;
   var xControllerMC;
   var xConnection;
   var mainTitleTxt;
   var infoTitleTxt;
   var listCount;
   var numItems;
   var bControllsSetUp = false;
   var mouseListener = new Object();
   var PlatformId = 0;
   var _bShowOptionalPane = false;
   var m_InitialSelection = 0;
   var m_MenuAdvanceSwapped = false;
   var handleScrollEvents = true;
   var enableLogging = true;
   function ChoiceGUI()
   {
      super();
   }
   function LogFromAS()
	{
      if (this.enableLogging)
      {
         // takes any number of args
         var concatArgs = "";
         var i = 0;
         for (i = 0; i < arguments.length; i++)
         {
            if (concatArgs == "")
            {
               concatArgs = arguments[i].toString();
            }
            else
            {
               concatArgs = concatArgs + "," + arguments[i].toString();
            }
         }
         flash.external.ExternalInterface.call("LogFromAS", concatArgs);
      }
	}
   function setTitle(sTitle)
   {
      this.mainTitleTxt.html = true;
      this.mainTitleTxt.htmlText = sTitle;
   }
   function setSubtitle(sSubTitle)
   {
      this.infoTitleTxt.htmlText = true;
      this.infoTitleTxt.htmlText = sSubTitle;
   }
   function setAText(sAText)
   {
      this.PCbutton1.textMC.textBox.text = sAText;
      if(this.bControllsSetUp)
      {
         this.xConnection._xController.setButtonText("A",sAText);
      }
   }
   function setBText(sBText)
   {
      // this.PCbutton2.textMC.textBox.text = sBText;
      if(this.bControllsSetUp)
      {
         this.xConnection._xController.setButtonText("B",sBText);
      }
   }
   function setXText(sXText)
   {
      this.PCbutton2.textMC.textBox.text = sXText;
      if(this.bControllsSetUp)
      {
         this.xConnection._xController.setButtonText("X",sXText);
      }
   }
   function setYText(sYText)
   {
      this.PCbutton3.textMC.textBox.text = sYText;
      if(this.bControllsSetUp)
      {
         this.xConnection._xController.setButtonText("Y",sYText);
      }
   }
   function setAActive(bActive)
   {
      this.xConnection._xController.setButtonActive("A",bActive);
      this.PCbutton1._visible = bActive && !this.bUsingGamepad;
      this.PCbutton1.enabled = bActive;
   }
   function setBActive(bActive)
   {
      this.xConnection._xController.setButtonActive("B",bActive);
      this.PCBackButton._visible = bActive && !this.bUsingGamepad;
      this.PCBackButton.enabled = bActive;
   }
   function setXActive(bActive)
   {
      this.xConnection._xController.setButtonActive("X",bActive);
      this.PCbutton2._visible = bActive && !this.bUsingGamepad;
      this.PCbutton2.enabled = bActive;
   }
   function setYActive(bActive)
   {
      this.xConnection._xController.setButtonActive("Y",bActive);
      this.PCbutton3._visible = bActive && !this.bUsingGamepad;
      this.PCbutton3.enabled = bActive;
   }
   // TODO make various buttons active or not via functions
   function onLoad()
   {
      var listOwner = this.vList;
      var ignoreScroll = false;
      com.SFXScreen.RegisterCallback_HandleInputConfigurations(this,this.OnHandleInputConfigurations);
      this.m_RightPanel = _root.mcPanelRight;
      this.m_ChoiceImageLoader = com.bioware.masseffect.controls.TextureLoader(this.rightPaneInfo.screenShotLoader);
      this.m_ActiveScrollingWidget = com.bioware.masseffect.controls.marquee.ChoiceInfoScroller(this.rightPaneInfo.InfoType1);
      this.SwapRightPane(false);
      this.configUI();
      this.bControllsSetUp = false;
      this.setupController();
      this.vList.setupScrollBar(this.scrollbarList);
      this.vList.SetNumVisibleElements(8);
      this.SetPlatformLayout(com.XPlatform.PC);
      this.PCbutton1.addEventListener("SFXButton_onPress",mx.utils.Delegate.create(this,this.onButtonA));
      this.PCbutton2.addEventListener("SFXButton_onPress",mx.utils.Delegate.create(this,this.onButtonX));
      this.PCbutton3.addEventListener("SFXButton_onPress",mx.utils.Delegate.create(this,this.onButtonY));
      this.PCBackButton.addEventListener("SFXButton_onRelease",mx.utils.Delegate.create(this,this.onButtonB));
      this.mouseListener.onKeyDown = function()
      {
         if(!handleScrollEvents)
         {
            return undefined;
         }
         if(ignoreScroll)
         {
            ignoreScroll = false;
            return undefined;
         }
         switch(Key.getCode())
         {
            // page down
            case 34:
               ignoreScroll = true;
               if(listOwner.selectedIndex < listOwner.dataProvider.length - 1)
               {
                  listOwner.selectedIndex += 1;
                  fscommand(com.UnrealMessages.PlaySound,"SaveLoadMove");
               }
               break;
            // page up
            case 33:
               ignoreScroll = true;
               if(listOwner.selectedIndex > 0)
               {
                  listOwner.selectedIndex--;
                  fscommand(com.UnrealMessages.PlaySound,"SaveLoadMove");
                  break;
               }
         }
      };
      Key.addListener(this.mouseListener);
   }
   function SetPlatformLayout(iPlatformId)
   {
      this.PlatformId = iPlatformId;
      com.bioware.masseffect.controls.marquee.ChoiceInfoScroller(this.rightPaneInfo.InfoType1).PlatformLayout = iPlatformId;
      com.bioware.masseffect.controls.marquee.ChoiceInfoScroller(this.rightPaneInfo.InfoType2).PlatformLayout = iPlatformId;
      this.vList.SetPlatformLayout(iPlatformId);
      if(this.PlatformId == com.XPlatform.PC && !this.bUsingGamepad)
      {
         this.PCbutton1._visible = true;
         this.PCbutton2._visible = true;
         this.PCBackButton._visible = true;
         this.xControllerMC._visible = false;
      }
      else
      {
         this.PCbutton1._visible = false;
         this.PCbutton2._visible = false;
         this.PCBackButton._visible = false;
         this.xControllerMC._visible = true;
      }
   }
   function setupController()
   {
      if(!this.bControllsSetUp)
      {
         this.xConnection.injectController(this.xControllerMC,true,true,true,true,"X Button","Y Button","B Button","A Button",true,false,true,false,false,false,"Left ThumbStick","Right ThumbStick",false,false,"Left Trigger","Right Trigger",false,false,"Left Bumper","Right Bumper");
         this.xConnection.addEventListener("onButtonX",mx.utils.Delegate.create(this,this.onButtonX));
         this.xConnection.addEventListener("onButtonY",mx.utils.Delegate.create(this,this.onButtonY));
         this.xConnection.addEventListener("onButtonA",mx.utils.Delegate.create(this,this.onButtonA));
         this.xConnection.addEventListener("onButtonB",mx.utils.Delegate.create(this,this.onButtonB));
         this.xConnection.addEventListener("onDPadUp",mx.utils.Delegate.create(this,this.onDPadUp));
         this.xConnection.addEventListener("onDPadDown",mx.utils.Delegate.create(this,this.onDPadDown));
         this.xConnection.addEventListener("onDPadLeft",mx.utils.Delegate.create(this,this.onInvalidInput));
         this.xConnection.addEventListener("onDPadRight",mx.utils.Delegate.create(this,this.onInvalidInput));
         this.xConnection.addEventListener("onInvalidInput",mx.utils.Delegate.create(this,this.onInvalidInput));
         // this.vList.addEventListener("onChange",mx.utils.Delegate.create(this,this.updateChoiceView));
         this.bControllsSetUp = true;
      }
      this.xConnection._xController.setButtonActive("X",false);
      this.xConnection._xController.setButtonActive("Y",false);
      this.xConnection._xController.setButtonActive("A",true);
      this.xConnection._xController.setButtonActive("B",true);
   }
   // TODO leave this in place but also let me set things individually
   // function SetTitles(sTitle, sSubTitle, sAText, sBText)
   // {
   //    this.mainTitleTxt.html = true;
   //    this.infoTitleTxt.html = true;
   //    this.mainTitleTxt.htmlText = sTitle;
   //    this.infoTitleTxt.htmlText = sSubTitle;
   //    this.AButtonText = sAText;
   //    this.BButtonText = sBText;
   //    if(this.PlatformId == com.XPlatform.PC && !this.bUsingGamepad)
   //    {
   //       this.PCbutton1.textMC.textBox.text = this.AButtonText;
   //       this.PCbutton1._visible = this.AButtonText != "";
   //       this.PCbutton1.enabled = this.AButtonText != "";
   //       this.PCbutton2.textMC.textBox.text = this.BButtonText;
   //       this.PCbutton2._visible = this.BButtonText != "";
   //       this.PCbutton2.enabled = this.BButtonText != "";
   //    }
   //    if(this.bControllsSetUp == true)
   //    {
   //       this.xConnection._xController.setButtonText("A",sAText);
   //       this.xConnection._xController.setButtonText("B",sBText);
   //       if(sAText == "")
   //       {
   //          this.xConnection._xController.setButtonActive("A",false);
   //       }
   //       if(sBText == "")
   //       {
   //          this.xConnection._xController.setButtonActive("B",false);
   //       }
   //    }
   // }
   function SetupOptionalPane(bShowOptionalPane, sOptionalPaneTitleText, sOptionalPaneInventoryText)
   {
      this._bShowOptionalPane = bShowOptionalPane;
      if(this._bShowOptionalPane)
      {
         this.SwapRightPane(true);
         this.m_ActiveScrollingWidget.inventoryTxt = sOptionalPaneInventoryText;
      }
      else
      {
         this.SwapRightPane(false);
         this.m_ActiveScrollingWidget.inventoryTxt = "";
      }
   }
   function SwapRightPane(bAltView)
   {
      this.rightPaneInfo.InfoType2._alpha = !bAltView ? 0 : 100;
      this.rightPaneInfo.BGType2._alpha = !bAltView ? 0 : 100;
      this.rightPaneInfo.InfoType1._alpha = !!bAltView ? 0 : 100;
      this.rightPaneInfo.BGType1._alpha = !!bAltView ? 0 : 100;
      if(bAltView)
      {
         this.rightPaneInfo.BGType2.swapDepths(this.rightPaneInfo.BGType1);
         this.m_ActiveScrollingWidget = com.bioware.masseffect.controls.marquee.ChoiceInfoScroller(this.rightPaneInfo.InfoType2);
      }
      else
      {
         this.rightPaneInfo.BGType1.swapDepths(this.rightPaneInfo.BGType2);
         this.m_ActiveScrollingWidget = com.bioware.masseffect.controls.marquee.ChoiceInfoScroller(this.rightPaneInfo.InfoType1);
      }
   }
   function DisplayImageForChoice(/*p_ChoiceImageTitle, */p_sImageSource)
   {
      // this.rightPaneInfo.titleTxt.text = p_ChoiceImageTitle;
      this.m_ChoiceImageLoader.ImageResource = p_sImageSource;
      this.m_ChoiceImageLoader.Height = this.m_ChoiceImageLoader.imageBox._height;
      this.m_ChoiceImageLoader.Width = this.m_ChoiceImageLoader.imageBox._width;
   }
   function SetDescription(sDescription)
   {
      this.m_ActiveScrollingWidget.text = sDescription;
   }
   function SetRightTitle(sRightTitle)
   {
      this.rightPaneInfo.titleTxt.text = sRightTitle;
   }
   // leave this for compatiblity with native ChoiceGui handler
   // function SetInitialListSize(p_numItems)
   // {
   //    this.resetListState();
   //    this.listCount = 0;
   //    this.numItems = p_numItems;
   //    this.m_InitialSelection = 0;
   // }
   // better one that sets the initial state of all the items to be empty so they can be set up and updated in place
   function initializeList(p_numItems)
   {
      // this.LogFromAS("initializeList", p_numItems);
      this.resetListState();
      this.listCount = 0;
      this.numItems = p_numItems;
      // this.m_InitialSelection = 0;
      var index = 0;
      for (index = 0; index < this.numItems; index++)
      {
         this.addMenuEntry(index, "", "", "", "", false, false);
      }
   }
   // internal only; don't call this from UScript
   function addMenuEntry(p_index, s_leftText, s_centerText, s_rightText, s_secondaryText, b_Disabled, b_Nested)
   {
      // this.LogFromAS("addMenuEntry", p_index, s_leftText, s_centerText, s_rightText, s_secondaryText, b_Disabled, b_Nested);
      var _loc2_ = com.bioware.masseffect.controls.vlistcontrols.ChoiceVListItem(this.vList.addEntry(p_index, s_leftText, s_centerText, s_rightText, s_secondaryText, b_Disabled, b_Nested));

      this.listCount += 1;
      if(_loc2_ != null)
      {
         // _loc2_.SetText(p_ChoiceName,p_ActionText);
         // if(this.PlatformId == com.XPlatform.PC && !this.bUsingGamepad)
         // {
         //    _loc2_.SetActionButtonVisible(false);
         // }
         // if(p_DefaultSelection != false)
         // {
         //    this.m_InitialSelection = this.listCount - 1;
         // }
         // if(this.listCount == this.numItems)
         // {
         //    this.updateController();
         //    this.vList.selectedIndex = this.m_InitialSelection;
         //    _loc2_.BottomArrowVisible = false;
         // }
         // if(this.listCount == 1)
         // {
         //    _loc2_.TopArrowVisible = false;
         // }
         // _loc2_.MenuAdvanceSwapped = this.m_MenuAdvanceSwapped;
         // TODO set separate double click callback
         _loc2_.SetDoubleClickCallback(this,this.onItemDoubleClick);
      }
   }
   function updateMenuEntry(p_index, s_leftText, s_centerText, s_rightText, s_secondaryText, b_Disabled, b_Nested)
   {
      var item = this.vList.getListItem(p_index);
      if (item != null)
      {
         var o_data = {
            index:p_index,
            LeftText:s_leftText,
            CenterText:s_centerText,
            RightText:s_rightText,
            SecondaryText:s_secondaryText,
            Disabled:b_Disabled,
            Nested:b_Nested};
         item.data = o_data;
      }
   }
   function resetListState()
   {
      this.numItems = 0;
      this.listCount = 0;
      this.vList.killMenu();
   }
   // note that these don't filter out disabled; you need to do that in UScript; you can call onInvalidInput to play the error sound if you want, or you can do something else
   function onItemDoubleClick(p_event)
   {
      flash.external.ExternalInterface.call("OnItemDoubleClicked",this.vList.selectedIndex);
   }
   function onButtonA(p_event)
   {
      flash.external.ExternalInterface.call("ExActionPressed",this.vList.selectedIndex);
   }
   function onButtonB(p_event)
   {
      flash.external.ExternalInterface.call("ExBackPressed");
   }
   function onButtonX(p_event)
   {
      flash.external.ExternalInterface.call("ExAuxPressed",this.vList.selectedIndex);
   }
   function onButtonY(p_event)
   {
      flash.external.ExternalInterface.call("ExAux2Pressed",this.vList.selectedIndex);
   }
   function setSelectedIndex(index)
   {
      // check for out of bounds at the bottom
      if (index >= this.vList.GetListCount())
      {
         index = this.vList.GetListCount() - 1;
      }
      this.vList.selectedIndex = index;
   }
   function getSelectedIndex()
   {
      return this.vList.selectedIndex;
   }
   function getScrollPosition()
   {
      // technically, the index of the visible item at the top of the list
      return this.vList.movementRefElementIndex;
   }
   function setScrollPosition(pos, bSkipAnimate)
   {
      this.vList.SnapNextListMovement = bSkipAnimate;
      this.vList.movementRefElementIndex = pos;
      this.vList.recalcScrollBar();
   }
   // > 0 is down, < 0 is up
   function scrollList(dir)
   {
      this.vList.MoveScrollBar(dir);
   }
   function pageList(dir)
   {
      if (dir > 0)
      {
         this.vList.selectedIndex += 8;
      }
      else
      {
         this.vList.selectedIndex -= 8;
      }
   }
   // function isMouseOverList()
   // {

   // }
   function onDPadUp(p_event)
   {
      if(this.vList.selectedIndex > 0)
      {
         this.vList.selectedIndex -= 1;
         this.updateController();
      }
   }
   function onDPadDown(p_event)
   {
      if(this.vList.selectedIndex < this.vList.GetListCount() - 1)
      {
         this.vList.selectedIndex += 1;
         this.updateController();
      }
   }
   // This is used to update the right pane and buttons when a new item is selected
   // function updateChoiceView(p_event)
   // {
   //    this.DisplayImageForChoice(p_event.data.choiceImageTitle,p_event.data.choiceImage);
   //    this.SetDescription(p_event.data.choiceDescription);
   //    if(this.PlatformId == com.XPlatform.PC && !this.bUsingGamepad)
   //    {
   //       this.PCbutton1._visible = !p_event.data.Disabled;
   //       this.PCbutton1.enabled = !p_event.data.Disabled;
   //       if(!p_event.data.Disabled)
   //       {
   //          if(p_event.data.choiceAction == "" || p_event.data.choiceAction == undefined)
   //          {
   //             if(this.AButtonText == "" || this.AButtonText == undefined)
   //             {
   //                this.PCbutton1._visible = false;
   //             }
   //             else
   //             {
   //                this.PCbutton1._visible = true;
   //                this.PCbutton1.textMC.textBox.text = this.AButtonText;
   //             }
   //          }
   //          else
   //          {
   //             this.PCbutton1._visible = true;
   //             this.PCbutton1.textMC.textBox.text = p_event.data.choiceAction;
   //          }
   //       }
   //    }
   //    else
   //    {
   //       this.xConnection._xController.setButtonActive("A",!p_event.data.Disabled);
   //       if(!p_event.data.Disabled)
   //       {
   //          if(p_event.data.choiceAction == "" || p_event.data.choiceAction == undefined)
   //          {
   //             if(this.AButtonText == "" || this.AButtonText == undefined)
   //             {
   //                this.xConnection._xController.setButtonActive("A",false);
   //                this.xConnection._xController.setButtonText("A",this.AButtonText);
   //             }
   //             else
   //             {
   //                this.xConnection._xController.setButtonActive("A",true);
   //                this.xConnection._xController.setButtonText("A",this.AButtonText);
   //             }
   //          }
   //          else
   //          {
   //             this.xConnection._xController.setButtonActive("A",p_event.data.choiceAction != "");
   //             this.xConnection._xController.setButtonText("A",p_event.data.choiceAction);
   //          }
   //       }
   //    }
   //    if(this._bShowOptionalPane)
   //    {
   //       this.m_ActiveScrollingWidget.HideCost = p_event.data.choiceOptionalPanel_HideCost;
   //       this.m_ActiveScrollingWidget.costTxt = p_event.data.choiceOptionalPanelItemValue;
   //       flash.external.ExternalInterface.call("onExIntUpdateOptionValues",p_event.data.choiceResource);
   //    }
   //    fscommand(com.UnrealMessages.PlaySound,"SaveLoadMove");
   // }
   // TODO work out what this does
   // function UpdateInventoryValues(sInventoryText)
   // {
   //    this.m_ActiveScrollingWidget.inventoryTxt = sInventoryText;
   // }
   // TODO figure out how this works
   function ScrollInfoText(nScroll)
   {
      this.m_ActiveScrollingWidget.scrollByTime(nScroll >= 0 ? com.bioware.masseffect.controls.Marquee.SCROLL_CONTENT_DOWN : com.bioware.masseffect.controls.Marquee.SCROLL_CONTENT_UP,Math.abs(nScroll));
   }
   function StopInfoScroll()
   {
      this.m_ActiveScrollingWidget.StopMarquee();
   }
   function OnHandleInputConfigurations(bMenuAdvanceSwapped, bStickSouthpaw, bTriggerSouthpaw, bTriggersShouldersSwapped)
   {
      this.m_MenuAdvanceSwapped = bMenuAdvanceSwapped;
      if(this.xConnection._xController != undefined && this.xConnection._xController != null)
      {
         this.xConnection._xController.ResetButtonMappings();
         if(bMenuAdvanceSwapped)
         {
            this.xConnection._xController.SwapButtons("A","B");
         }
      }
   }
   function RefreshButtonHelp(usingGamepad)
   {
      this.bUsingGamepad = usingGamepad;
      if(this.PlatformId == com.XPlatform.PC && !this.bUsingGamepad)
      {
         // only make them visible if the button should be active
         this.PCbutton1._visible = this.xConnection._xController.getButtonActive("A");
         this.PCbutton2._visible = this.xConnection._xController.getButtonActive("X");
         this.PCbutton3._visible = this.xConnection._xController.getButtonActive("Y");
         this.PCBackButton._visible = this.xConnection._xController.getButtonActive("B");
         this.xControllerMC._visible = false;
      }
      else
      {
         this.PCbutton1._visible = false;
         this.PCbutton2._visible = false;
         this.PCbutton3._visible = false;
         this.PCBackButton._visible = false;
         this.xControllerMC._visible = true;
      }
   }
}
