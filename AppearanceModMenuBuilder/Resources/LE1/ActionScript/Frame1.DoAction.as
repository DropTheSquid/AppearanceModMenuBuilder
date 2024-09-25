function LogFromAS(func, message)
{
   flash.external.ExternalInterface.call("LogEx",func,message.toString());
}
// TODO there is a typo here
function EmitScrollabelState(bSCrollable)
{
   flash.external.ExternalInterface.call("IsScrollableEx",bSCrollable);
}
function SetTitle(title)
{
   TitleTxt.text = title;
   SubtitleHeader._y = TitleTxt._y + TitleTxt._height + 7.8;
   SubtitleTxt._y = SubtitleHeader._y + 13;
}
function SetSubtitle(subtitle)
{
   SubtitleTxt.text = subtitle;
}
function SetControllerLayout(nLayout)
{
   xConnection._xController.setControllerLayout(nLayout);
}
function SetActionButtonText(actionButtonText)
{
   xConnection._xController.setButtonText("A",actionButtonText);
   ActionBtn.textMC.textBox.text = actionButtonText;
}
function SetAuxButtonText(auxButtonText)
{
   xConnection._xController.setButtonText("X",auxButtonText);
   AuxBtn.textMC.textBox.text = auxButtonText;
}
function SetAux2ButtonText(aux2ButtonText)
{
   xConnection._xController.setButtonText("Y",aux2ButtonText);
   Aux2Btn.textMC.textBox.text = aux2ButtonText;
}
function SetTopButtonText(topButtonText)
{
   com.TextFieldEx.SetText(SelectButton.Text.TextInput, topButtonText);
   TopBtn.textMC.textBox.text = topButtonText;
}
function SetBackButtonText(backButtonText)
{
   xConnection._xController.setButtonText("B",backButtonText);
}
function SetActionButtonActive(bActive)
{
   bActionButtonActive = bActive;
   xConnection._xController.setButtonActive("A",bActive);
   if(!bUsingGamepad)
   {
      buttonManager.setElementVisible(BUTTON_PC_ACTION,bActionButtonActive);
   }
}
function SetAuxButtonActive(bActive)
{
   bAuxButtonActive = bActive;
   xConnection._xController.setButtonActive("X",bActive);
   if(!bUsingGamepad)
   {
      buttonManager.setElementVisible(BUTTON_PC_AUX,bAuxButtonActive);
   }
}
function SetAux2ButtonActive(bActive)
{
   bAux2ButtonActive = bActive;
   xConnection._xController.setButtonActive("Y",bActive);
   if(!bUsingGamepad)
   {
      buttonManager.setElementVisible(BUTTON_PC_AUX2,bAux2ButtonActive);
   }
}
function SetTopButtonActive(bActive)
{
   bTopButtonActive = bActive;
   if(bUsingGamepad)
   {
      SelectButton._visible = bTopButtonActive;
   }
   if(!bUsingGamepad)
   {
      buttonManager.setElementVisible(BUTTON_PC_TOP,bTopButtonActive);
   }
}
function SetRightPaneTitleText(titleText)
{
   rightPane.InputLocation.text = titleText;
}
function SetHeaderVisibility(bVisible)
{
   if(bVisible)
   {
      SubtitleHeader._alpha = 100;
   }
   else
   {
      SubtitleHeader._alpha = 0;
   }
}
function SetBackButtonActive(bActive)
{
   bBackButtonActive = bActive;
   xConnection._xController.setButtonActive("B",bActive);
   if(!bUsingGamepad)
   {
      buttonManager.setElementVisible(BUTTON_PC_BACK,bBackButtonActive);
   }
}
function SetControllerButtonText(sButton, sText)
{
   xConnection._xController.setButtonText(sButton,sText);
}
function SetControllerButtonActive(sButton, bActive)
{
   xConnection._xController.setButtonActive(sButton,bActive);
}
function SetRightPaneText(sText)
{
   rightPane.text = sText;
   if(screenshotResource == "" && rightPane._currentframe == 2)
   {
      rightPane.gotoAndStop(1);
   }
   else if(screenshotResource != "" && rightPane._currentframe == 1)
   {
      rightPane.gotoAndStop(2);
   }
   else
   {
      rightPane.update();
   }
}
function updateRightPane()
{
   this.subject.detailText.text = this.text;
   this.subject.detailText.autoSize = "center";
   SetupPCScrollBar.call(this.parent);
}
function SetupPCScrollBar()
{
   if(rightPane._currentframe == 1)
   {
      scrollHeight = 510.4;
      scrollMinY = 53.25;
   }
   else
   {
      scrollHeight = 330;
      scrollMinY = 228.45;
   }
   var _loc2_ = rightPane.subject.detailText._height;
   rightPane.subject._y = scrollMinY;
   lineH = 16.4;
   totalLines = int(_loc2_ / lineH);
   linesPerPage = int(scrollHeight / lineH);
   scrollMaxY = scrollMinY - (totalLines - linesPerPage) * lineH;
   if(DetailScrollbar != undefined)
   {
      delete DetailScrollbar;
   }
   DetailScrollbar = new com.PCScrollBar(rightPane.scrollbar,rightPane.scrollbar.bar,rightPane.scrollbar.sliderNew,rightPane.scrollbar.ResScrlUp,rightPane.scrollbar.ResScrlDown,scrollBarMC.scrollbarVisibleBg,false,1);
   if(totalLines <= linesPerPage)
   {
      DetailScrollbar._visible = false;
      EmitScrollabelState(false);
   }
   else
   {
      DetailScrollbar._visible = true;
      DetailScrollbar.setSteps(totalLines - (linesPerPage - 1),linesPerPage - 1,true,true);
      DetailScrollbar.onScroll = function()
      {
         rightPane.subject._y = scrollMinY - (scrollMinY - scrollMaxY) * (DetailScrollbar.getCurrentPercent() / 100);
      };
      rightPane.subject._y = scrollMinY;
      EmitScrollabelState(true);
   }
   scrollDetailsReset();
}
function SetRightPaneVisibility(bVisible, bFade)
{
   if(!bVisible)
   {
      if(bFade)
      {
         fadeOut(rightPane);
      }
      else
      {
         rightPane._alpha = 0;
      }
   }
   else if(bFade)
   {
      fadeIn(rightPane);
   }
   else
   {
      rightPane._alpha = 100;
   }
}
function initMenu()
{
   if(!bInitted)
   {
      this.onMouseMove = function()
      {
         itemSlider.useMouseInput(true);
      };
      itemSlider = new com.PCItemSlider(this,185,188.7,35,numBlocksPerPage);
      itemSlider.setMouseFunctions(activateItem,deactivateItem,hoverItem,unhoverItem);
      itemSlider.setFunctions(SelectBlock,doubleClickItem,300,itemSlider.DOUBLECLICK_BASED);
      itemSlider.setSounds(szHoverSound,undefined);
      itemSlider.setupScrollBar(scrollbar);
      mcLoader = new MovieClipLoader();
      mcLoader.addListener(this);
      rightPane.update = updateRightPane;
      rightPane.parent = this;
      bInitted = true;
   }
}
function activateItem()
{
   var _loc2_ = flash.external.ExternalInterface.call("ItemActiveEx",this.slotIndex);
   if(!_loc2_)
   {
      if(this.state == entryStateDisabled)
      {
         this.gotoAndStop("graySelected");
      }
      else if(this.state == entryStateGreen)
      {
         this.gotoAndStop("normalInstalled");
      }
      else
      {
         this.gotoAndStop("selected");
      }
   }
}
function deactivateItem()
{
   var _loc2_ = flash.external.ExternalInterface.call("ItemInactiveEx",this.slotIndex);
   if(!_loc2_)
   {
      if(this.state == entryStateDisabled)
      {
         this.gotoAndStop("grayNormal");
      }
      else if(this.state == entryStateGreen)
      {
         this.gotoAndStop("normalInstalled");
      }
      else
      {
         this.gotoAndStop("normal");
      }
   }
}
function hoverItem()
{
   var _loc2_ = flash.external.ExternalInterface.call("ItemHoveredEx",this.slotIndex);
   if(!_loc2_)
   {
      if(this.state == entryStateDisabled)
      {
         this.gotoAndPlay("grayGrow");
      }
      else if(this.state == entryStateGreen)
      {
         this.gotoAndPlay("installedGrow");
      }
      else
      {
         this.gotoAndPlay("grow");
      }
   }
}
function unhoverItem()
{
   var _loc2_ = flash.external.ExternalInterface.call("ItemUnhoveredEx",this.slotIndex);
   if(!_loc2_)
   {
      if(this.state == entryStateDisabled)
      {
         this.gotoAndPlay("grayShrink");
      }
      else if(this.state == entryStateGreen)
      {
         this.gotoAndPlay("installedShrink");
      }
      else
      {
         this.gotoAndPlay("shrink");
      }
   }
}
function doubleClickItem(itemIndex)
{
   flash.external.ExternalInterface.call("ItemDoubleClickedEx",itemIndex);
}
function actionOnPress()
{
   flash.external.ExternalInterface.call("ActionButtonPressedEx",itemSlider.getActive());
}
function auxOnPress()
{
   flash.external.ExternalInterface.call("AuxButtonPressedEx",itemSlider.getActive());
}
function backOnPress()
{
   flash.external.ExternalInterface.call("BackButtonPressedEx");
}
function aux2OnPress()
{
   flash.external.ExternalInterface.call("Aux2ButtonPressedEx",itemSlider.getActive());
}
function topButtonOnPress()
{
   flash.external.ExternalInterface.call("TopButtonPressedEx",itemSlider.getActive());
}
function SelectBlock(BlockIndex)
{
   getURL("FSCommand:" add com.UnrealMessages.PlaySound,"SaveLoadMove");
   flash.external.ExternalInterface.call("ItemSelectedEx",BlockIndex);
}
function updateScreenShot(p_resource, p_frame)
{
   screenshotFrame = p_frame;
   screenshotResource = p_resource;
   if(screenshotResource == "" && rightPane._currentframe == 2)
   {
      rightPane.gotoAndStop(1);
   }
   else if(screenshotResource != "" && rightPane._currentframe == 1)
   {
      rightPane.gotoAndStop(2);
   }
   rightPane.screenShotLoader.screenshots.unloadMovie();
   rightPane.screenShotLoader.screenshots.removeMovieClip();
   rightPane.screenShotLoader.createEmptyMovieClip("screenshots",1);
   rightPane.screenShotLoader.screenshots._visible = true;
   rightPane.screenShotLoader.screenshots._alpha = 0;
   mcLoader.loadClip(p_resource,rightPane.screenShotLoader.screenshots);
}
function onLoadInit(mc)
{
   rightPane.screenShotLoader.screenshots.gotoAndStop(screenshotFrame);
   rightPane.screenShotLoader._height = rightPane.screenshot._height;
   rightPane.screenShotLoader._width = rightPane.screenshot._width;
   fadeInScreenshot();
}
function fadeInScreenshot()
{
   fadeIn(rightPane.screenShotLoader.screenshots);
}
function fadeOut(p_target)
{
   p_target.onEnterFrame = function()
   {
      var _loc1_ = (- p_target._alpha) / 2;
      if(_loc1_ > -1)
      {
         _loc1_ = -1;
      }
      p_target._alpha += _loc1_;
      if(p_target._alpha <= 0)
      {
         p_target._alpha = 0;
         delete p_target.onEnterFrame;
      }
   };
}
function fadeIn(p_target)
{
   p_target.onEnterFrame = function()
   {
      var _loc1_ = (100 - p_target._alpha) / 2;
      if(_loc1_ < 1)
      {
         _loc1_ = 1;
      }
      p_target._alpha += _loc1_;
      if(p_target._alpha >= 100)
      {
         p_target._alpha = 100;
         delete p_target.onEnterFrame;
      }
   };
}
function setupController()
{
   if(!bControlsInitted)
   {
      xConnection.injectController(xControllerMC,true,true,true,true,Aux,Aux2,Back,Action,true,false,true,false,false,false,"Left ThumbStick","Right ThumbStick",false,false,"Left Trigger","Right Trigger",false,false,"Left Bumper","Right Bumper");
      keyListener.onKeyDown = function()
      {
         switch(Key.getCode())
         {
            case com.XInput.ButtonA:
               actionOnPress();
               break;
            case com.XInput.ButtonB:
               backOnPress();
               break;
            case com.XInput.ButtonX:
               auxOnPress();
               break;
            case com.XInput.ButtonY:
               aux2OnPress();
               break;
            case com.XInput.DPadDown:
            case 40:
               itemSlider.useMouseInput(false);
               itemSlider.moveActive(1);
               CheckArrows();
               break;
            case com.XInput.DPadUp:
            case 38:
               itemSlider.useMouseInput(false);
               itemSlider.moveActive(-1);
               CheckArrows();
               break;
            case 27:
               itemSlider.useMouseInput(false);
               backOnPress();
               break;
            case 34:
               var _loc2_ = rightPane.hitTest(_root._xmouse,_root._ymouse,true);
               var _loc3_ = itemSlider.contenthold.hitTest(_root._xmouse,_root._ymouse,false) || scrollbar.hitTest(_root._xmouse,_root._ymouse,false);
               flash.external.ExternalInterface.call("OnScrollWheelEX",1,_loc3_,_loc2_);
               break;
            case 33:
               _loc2_ = rightPane.hitTest(_root._xmouse,_root._ymouse,true);
               _loc3_ = itemSlider.contenthold.hitTest(_root._xmouse,_root._ymouse,false) || scrollbar.hitTest(_root._xmouse,_root._ymouse,false);
               flash.external.ExternalInterface.call("OnScrollWheelEX",0,_loc3_,_loc2_);
         }
      };
      Key.addListener(keyListener);
      bControlsInitted = true;
      InputEnabled = true;
   }
   xConnection._xController.setButtonActive("A",false);
   xConnection._xController.setButtonActive("B",false);
   xConnection._xController.setButtonActive("X",false);
   xConnection._xController.setButtonActive("Y",false);
   RefreshButtonHelp(bUsingGamepad);
}
function StartSlotList(nNumSlots)
{
   itemSlider.reset();
   itemSlider.createBlocks(nNumSlots,"DataBlock");
}
function AddOrUpdateMenuItem(nIndex, leftText, centerText, rightText, state, showPlus)
{
   var _loc7_ = itemSlider.getBlock(nIndex);
   _loc7_.slotIndex = nIndex;
   _loc7_.LeftText.LeftTxt.text = leftText;
   _loc7_.CenterText.centerText.text = centerText;
   _loc7_.RightText.RightText.text = rightText;
   _loc7_.state = state;
   _loc7_.Plus._visible = showPlus;
   itemSlider.RefreshBlockState(nIndex);
}
function SetListSelectedIndex(nIndex)
{
   itemSlider.setActive(nIndex);
   CheckArrows();
}
function GetListScrollPosition()
{
   return itemSlider.scrollBar.getCurrentStep();
}
function SetListScrollPosition(nIndex, bInstant)
{
   if(bInstant)
   {
      itemSlider.moveToInstantaneous(nIndex);
   }
   itemSlider.moveTo(nIndex);
}
function MoveListScrollBar(nSteps)
{
   itemSlider.scrollBar.doScrollBy(- nSteps);
}
function SetListVisible(bVisible)
{
   itemSlider.setVisible(bVisible);
}
function MoveDetailScrollBar(nSteps)
{
   DetailScrollbar.doScrollBy(- nSteps);
}
function scrollDetailsAnalog(val)
{
   val *= scrollAcc;
   scrollVel += val;
   if(Math.abs(scrollVel) > scrollMaxVel)
   {
      if(scrollVel > 0)
      {
         scrollVel = scrollMaxVel;
      }
      else
      {
         scrollVel = - scrollMaxVel;
      }
   }
}
function CheckArrows()
{
   xConnection._xController.setArrowActive("Up",itemSlider.getActive() > 0);
   xConnection._xController.setArrowActive("Down",itemSlider.getActive() < itemSlider.getSize() - 1);
}
function RefreshButtonHelp(usingGamepad)
{
   bUsingGamepad = usingGamepad;
   CheckArrows();
   if(usingGamepad)
   {
      xControllerMC._visible = true;
      buttonManager.setElementVisible(BUTTON_PC_ACTION,false);
      buttonManager.setElementVisible(BUTTON_PC_AUX,false);
      buttonManager.setElementVisible(BUTTON_PC_AUX2,false);
      buttonManager.setElementVisible(BUTTON_PC_TOP,false);
      buttonManager.setElementVisible(BUTTON_PC_BACK,false);
      SelectButton._visible = bTopButtonActive;
   }
   else
   {
      xControllerMC._visible = false;
      buttonManager.setElementVisible(BUTTON_PC_ACTION,bActionButtonActive);
      buttonManager.setElementVisible(BUTTON_PC_AUX,bAuxButtonActive);
      buttonManager.setElementVisible(BUTTON_PC_BACK,bBackButtonActive);
      buttonManager.setElementVisible(BUTTON_PC_AUX2,bAux2ButtonActive);
      buttonManager.setElementVisible(BUTTON_PC_TOP,bTopButtonActive);
      SelectButton._visible = false;
   }
   scrollDetailsReset();
}
function scrollDetailsReset()
{
   scrollVel = 0;
   if(scrollMaxY > scrollMinY)
   {
      delete rightPane.onEnterFrame;
      scrollMaxY = scrollMinY;
   }
   else
   {
      rightPane.onEnterFrame = function()
      {
         scrollFrameFunction();
      };
   }
}
function scrollFrameFunction()
{
   if(Math.abs(scrollVel) < scrollMinVel)
   {
      scrollVel = 0;
   }
   if(scrollVel != 0)
   {
      var _loc1_ = rightPane.subject;
      scrollVel *= scrollFriction;
      _loc1_._y -= scrollVel;
      if(_loc1_._y >= scrollMinY)
      {
         _loc1_._y = scrollMinY;
         scrollVel = 0;
      }
      else if(_loc1_._y <= scrollMaxY)
      {
         _loc1_._y = scrollMaxY;
         scrollVel = 0;
      }
      DetailScrollbar.setPositionPercent((scrollMinY - _loc1_._y) / (scrollMinY - scrollMaxY) * 100);
   }
}
_global.gfxExtensions = true;
_global.MI;
if(MI == null)
{
   MI = new com.MouseInput();
}
var ScrollBarHeight = 750;
var ScrollBarOffset = 120;
var LastClickTime = [0,0,0,0,0];
var numBlocksPerPage = 13;
var bInitted = false;
var bControlsInitted = false;
var bUsingGamepad = false;
var szHoverSound = "MainMenuChangeOption";
var keyListener = new Object();
var buttonManager;
var itemSlider;
var mcLoader;
var bActionButtonActive = false;
var bAuxButtonActive = false;
var bAux2ButtonActive = false;
var bBackButtonActive = false;
var bTopButtonActive = false;
var entryStateNormal = 0;
var entryStateDisabled = 1;
var entryStateGreen = 2;
var screenshotFrame = "";
var screenshotResource = "";
var scrollMinY;
var scrollHeight;
var DetailScrollbar;
var totalLines = 0;
var linesPerPage = 0;
var lineH = 0;
var scrollMaxY = 10000;
var scrollAcc = 4;
var scrollVel = 0;
var scrollMaxVel = 30;
var scrollFriction = 0.8;
var scrollMinVel = 1;
var scrollMagnitude = 0;
buttonManager = new com.PCActionButtonManager();
var BUTTON_PC_ACTION = buttonManager.addElementAndReturnID(ActionBtn,-1,function()
{
   ActionBtn.gotoAndStop(1);
}
,null,null,function()
{
   ActionBtn.gotoAndPlay("grow");
   getURL("FSCommand:" add com.UnrealMessages.PlaySound,szHoverSound);
}
,function()
{
   ActionBtn.gotoAndPlay("shrink");
}
,false,actionOnPress);
var BUTTON_PC_AUX = buttonManager.addElementAndReturnID(AuxBtn,-1,function()
{
   AuxBtn.gotoAndStop(1);
}
,null,null,function()
{
   AuxBtn.gotoAndPlay("grow");
   getURL("FSCommand:" add com.UnrealMessages.PlaySound,szHoverSound);
}
,function()
{
   AuxBtn.gotoAndPlay("shrink");
}
,false,auxOnPress);
var BUTTON_PC_AUX2 = buttonManager.addElementAndReturnID(Aux2Btn,-1,function()
{
   Aux2Btn.gotoAndStop(1);
}
,null,null,function()
{
   Aux2Btn.gotoAndPlay("grow");
   getURL("FSCommand:" add com.UnrealMessages.PlaySound,szHoverSound);
}
,function()
{
   Aux2Btn.gotoAndPlay("shrink");
}
,true,aux2OnPress);
var BUTTON_PC_TOP = buttonManager.addElementAndReturnID(TopBtn,-1,function()
{
   TopBtn.gotoAndStop(1);
}
,null,null,function()
{
   TopBtn.gotoAndPlay("grow");
   getURL("FSCommand:" add com.UnrealMessages.PlaySound,szHoverSound);
}
,function()
{
   TopBtn.gotoAndPlay("shrink");
}
,true,topButtonOnPress);
var BUTTON_PC_BACK = buttonManager.addElementAndReturnID(BackBtn,-1,function()
{
   BackBtn.gotoAndStop(1);
}
,null,null,function()
{
   BackBtn.gotoAndPlay("grow");
   getURL("FSCommand:" add com.UnrealMessages.PlaySound,szHoverSound);
}
,function()
{
   BackBtn.gotoAndPlay("shrink");
}
,true,backOnPress);
buttonManager.setElementToStealTabWhenDirectionalPressed(BUTTON_PC_ACTION);
this.onEnterFrame = function()
{
   initMenu();
   rightPane.screenshot._visible = false;
   rightPane.screenShotLoader._visible = true;
   rightPane.screenShotLoader.createEmptyMovieClip("screenshots",1);
   setupController();
   flash.external.ExternalInterface.call("ASLoadedEx");
   delete this.onEnterFrame;
};
