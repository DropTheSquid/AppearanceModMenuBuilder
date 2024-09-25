class com.PCScrollBar extends com.PCGuiWidgit
{
   var isHorizontal;
   var m_LeftStick;
   var mc_bg;
   var mc_sliderBounding;
   var mc_slider;
   var mc_scrollUp;
   var mc_scrollDown;
   var mc_scrollbarVisibleBackground;
   var dragLocked;
   var num_sliderMin;
   var _alpha;
   var hitTest;
   var func_onScroll;
   var num_steps;
   var num_stepsPerPage;
   var num_sliderPos;
   var m_PlatformID;
   var num_stepLen;
   var num_sliderLen;
   var num_boundingLen;
   var num_sliderMax;
   var discreteScrolling;
   var dragLockedDisabled;
   var mc_text = undefined;
   var bInDrag = false;
   var _SliderMaxLen = 15;
   var _SliderMinLen = 5;
   function PCScrollBar(bg, sliderBounding, slider, scrollUp, scrollDown, scrollbarVisibleBackground, isHoriz)
   {
      super();
      this.isHorizontal = isHoriz;
      this._SliderMaxLen = slider._height;
      this._SliderMinLen = Math.max(this._SliderMinLen,slider._height / 5);
      this.SetupScrollBar(bg,sliderBounding,slider,scrollUp,scrollDown,scrollbarVisibleBackground);
   }
   function SetLeftStickIcon(b_val)
   {
      this.m_LeftStick = b_val;
   }
   function SetupScrollBar(bg, sliderBounding, slider, scrollUp, scrollDown, scrollbarVisibleBackground)
   {
      this.mc_bg = bg;
      this.mc_sliderBounding = sliderBounding;
      this.mc_slider = slider;
      this.mc_scrollUp = scrollUp;
      this.mc_scrollDown = scrollDown;
      this.mc_scrollbarVisibleBackground = scrollbarVisibleBackground;
      this.mc_bg.tabEnabled = false;
      sliderBounding.tabEnabled = false;
      slider.tabEnabled = false;
      scrollUp.tabEnabled = false;
      scrollDown.tabEnabled = false;
      this.dragLocked = false;
      if(this.isHorizontal)
      {
         this.num_sliderMin = this.mc_sliderBounding._x;
      }
      else if(this.mc_sliderBounding == bg)
      {
         this.num_sliderMin = 0;
      }
      else
      {
         this.num_sliderMin = this.mc_sliderBounding._y;
      }
      this.setSteps(100,10,true,false);
      var owner = this;
      if(this.mc_scrollUp != null)
      {
         this.mc_scrollUp.onMouseDown = function()
         {
            if(this._visible && this._alpha > 0)
            {
               if(this.hitTest(_root._xmouse,_root._ymouse,true))
               {
                  owner.doScrollUp();
                  getURL("FSCommand:" add com.UnrealMessages.PlaySound,"MainMenuChangeOption");
               }
            }
         };
         this.SetupButtonAnims(this.mc_scrollUp);
      }
      if(this.mc_scrollDown != null)
      {
         this.mc_scrollDown.onMouseDown = function()
         {
            if(this._visible && this._alpha > 0)
            {
               if(this.hitTest(_root._xmouse,_root._ymouse,true))
               {
                  owner.doScrollDown();
                  getURL("FSCommand:" add com.UnrealMessages.PlaySound,"MainMenuChangeOption");
               }
            }
         };
         this.SetupButtonAnims(this.mc_scrollDown);
      }
      this.mc_sliderBounding.onPress = function()
      {
         owner.doPage();
         getURL("FSCommand:" add com.UnrealMessages.PlaySound,"MainMenuChangeOption");
      };
      this.mc_sliderBounding.onRollOver = function()
      {
         owner.ActivateRollOver();
      };
      this.mc_slider.onMouseDown = function()
      {
         if(this._visible && this._alpha > 0)
         {
            if(this.hitTest(_root._xmouse,_root._ymouse,true))
            {
               this.bInDrag = true;
               owner.doStartDrag();
               getURL("FSCommand:" add com.UnrealMessages.PlaySound,"MainMenuChangeOption");
            }
         }
      };
      this.mc_slider.onMouseUp = function()
      {
         if(this.bInDrag)
         {
            owner.doStopDrag();
         }
         this.bInDrag = false;
      };
      this.SetupButtonAnims(this.mc_slider);
      this.bDirty = false;
   }
   function SetupButtonAnims(mc)
   {
      var owner = this;
      mc.onRollOver = mc.onDragOver = function()
      {
         mc.gotoAndStop("hover");
         owner.ActivateRollOver();
      };
      mc.onRollOut = mc.onDragOut = function()
      {
         mc.gotoAndStop("normal");
      };
   }
   function SetText(mc)
   {
      this.mc_text = mc;
      this.UpdateText();
   }
   function set onScroll(func)
   {
      this.func_onScroll = func;
   }
   function set _visible(vis)
   {
      this.mc_bg._visible = vis;
      this.mc_sliderBounding._visible = vis;
      this.mc_slider._visible = vis;
      if(this.mc_scrollUp != null)
      {
         this.mc_scrollUp._visible = vis;
      }
      if(this.mc_scrollDown != null)
      {
         this.mc_scrollDown._visible = vis;
      }
      if(this.mc_scrollbarVisibleBackground != null)
      {
         this.mc_scrollbarVisibleBackground._visible = vis;
      }
   }
   function get _visible()
   {
      return this.mc_slider._visible;
   }
   function setSteps(steps, stepsPerPage, stretchSlider, dragLockedToSteps)
   {
      this.num_steps = int(steps);
      this.num_stepsPerPage = int(stepsPerPage);
      this.dragLocked = dragLockedToSteps;
      this.num_sliderPos = this.num_sliderMin;
      if(this.isHorizontal)
      {
         this.mc_slider._x = this.num_sliderPos;
      }
      else
      {
         this.mc_slider._y = this.num_sliderPos;
      }
      if(this.m_PlatformID == com.XPlatform.PC)
      {
         if(stretchSlider)
         {
            if(this.isHorizontal)
            {
               this.num_stepLen = this.mc_sliderBounding._width / (this.num_steps + this.num_stepsPerPage - 1);
               this.num_sliderLen = this.num_stepLen * this.num_stepsPerPage;
               if(this.num_sliderLen < this._SliderMinLen)
               {
                  this.num_sliderLen = this._SliderMinLen;
               }
               else if(this.num_sliderLen > this._SliderMaxLen)
               {
                  this.num_sliderLen = this._SliderMaxLen;
               }
               this.mc_slider._width = this.num_sliderLen;
               this.num_boundingLen = this.mc_sliderBounding._width - this.num_sliderLen;
            }
            else
            {
               this.num_stepLen = this.mc_sliderBounding._height / (this.num_steps + this.num_stepsPerPage - 1);
               this.num_sliderLen = this.num_stepLen * this.num_stepsPerPage;
               if(this.num_sliderLen < this._SliderMinLen)
               {
                  this.num_sliderLen = this._SliderMinLen;
               }
               else if(this.num_sliderLen > this._SliderMaxLen)
               {
                  this.num_sliderLen = this._SliderMaxLen;
               }
               this.mc_slider._height = this.num_sliderLen;
               this.num_boundingLen = this.mc_sliderBounding._height - this.num_sliderLen;
            }
         }
         else if(this.isHorizontal)
         {
            this.num_sliderLen = this.mc_slider._width;
            this.num_boundingLen = this.mc_sliderBounding._width - this.num_sliderLen;
         }
         else
         {
            this.num_sliderLen = this.mc_slider._height;
            this.num_boundingLen = this.mc_sliderBounding._height - this.num_sliderLen;
         }
      }
      else if(this.isHorizontal)
      {
         this.num_sliderLen = this.mc_slider._width;
         this.num_boundingLen = this.mc_sliderBounding._width - this.num_sliderLen;
      }
      else
      {
         this.num_sliderLen = this.mc_slider._height;
         this.num_boundingLen = this.mc_sliderBounding._height - this.num_sliderLen;
      }
      this.num_stepLen = this.num_boundingLen / (this.num_steps - 1);
      this.num_sliderMax = this.num_sliderMin + this.num_boundingLen;
   }
   function setPositionStep(currentStep)
   {
      currentStep = int(currentStep);
      if(currentStep <= 0)
      {
         this.num_sliderPos = this.num_sliderMin;
      }
      else if(currentStep >= this.num_steps - 1)
      {
         this.num_sliderPos = this.num_sliderMax;
      }
      else
      {
         this.num_sliderPos = this.num_sliderMin + currentStep * this.num_stepLen;
      }
      if(this.isHorizontal)
      {
         this.mc_slider._x = this.num_sliderPos;
      }
      else
      {
         this.mc_slider._y = this.num_sliderPos;
      }
      this.UpdateText();
   }
   function setCurrentStep(currentStep)
   {
      this.setPositionStep(currentStep);
      this.discreteScrolling = true;
      this.bDirty = true;
      this.func_onScroll.call(this);
      this.UpdateText();
   }
   function setPositionPercent(currentPercent)
   {
      this.num_sliderPos = this.num_sliderMin + this.num_boundingLen * (currentPercent / 100);
      if(this.isHorizontal)
      {
         this.mc_slider._x = this.num_sliderPos;
      }
      else
      {
         this.mc_slider._y = this.num_sliderPos;
      }
      if(this.dragLockedDisabled)
      {
         this.setPositionStep(this.getCurrentStep());
      }
      this.UpdateText();
   }
   function setCurrentPercent(currentPercent)
   {
      this.setPositionPercent(currentPercent);
      this.discreteScrolling = true;
      this.bDirty = true;
      this.func_onScroll.call(this);
      this.UpdateText();
   }
   function getCurrentStep()
   {
      var _loc2_ = Math.round((this.num_sliderPos - this.num_sliderMin) / this.num_stepLen);
      if(_loc2_ >= this.num_steps)
      {
         _loc2_ = this.num_steps - 1;
      }
      if(_loc2_ < 0)
      {
         _loc2_ = 0;
      }
      return _loc2_;
   }
   function getCurrentPercent()
   {
      return 100 * (this.num_sliderPos - this.num_sliderMin) / this.num_boundingLen;
   }
   function doScrollUp()
   {
      this.setCurrentStep(this.getCurrentStep() - 1);
   }
   function doScrollDown()
   {
      this.setCurrentStep(this.getCurrentStep() + 1);
   }
   function doScrollBy(i_nSteps)
   {
      this.setCurrentStep(this.getCurrentStep() - i_nSteps);
   }
   function doPage()
   {
      var _loc2_ = undefined;
      if(this.isHorizontal)
      {
         _loc2_ = this.mc_slider._xmouse * this.mc_slider._xscale / 100;
      }
      else
      {
         _loc2_ = this.mc_slider._ymouse * this.mc_slider._yscale / 100;
      }
      if(_loc2_ < 0)
      {
         this.setCurrentStep(this.getCurrentStep() - this.num_stepsPerPage);
      }
      else if(_loc2_ > this.num_sliderLen)
      {
         this.setCurrentStep(this.getCurrentStep() + this.num_stepsPerPage);
      }
      this.UpdateText();
   }
   function doStartDrag()
   {
      if(this.isHorizontal)
      {
         startDrag(this.mc_slider,0,this.num_sliderMin,this.mc_slider._y,this.num_sliderMax,this.mc_slider._y);
      }
      else
      {
         startDrag(this.mc_slider,0,this.mc_slider._x,this.num_sliderMin,this.mc_slider._x,this.num_sliderMax);
      }
      var owner = this;
      this.mc_slider.onMouseMove = function()
      {
         if(owner.isHorizontal)
         {
            owner.num_sliderPos = owner.mc_slider._x;
         }
         else
         {
            owner.num_sliderPos = owner.mc_slider._y;
         }
         owner.discreteScrolling = false;
         owner.bDirty = true;
         owner.func_onScroll.call(this);
         owner.UpdateText();
      };
   }
   function doStopDrag()
   {
      stopDrag();
      delete this.mc_slider.onMouseMove;
      if(this.dragLocked)
      {
         this.setCurrentStep(this.getCurrentStep());
      }
   }
   function UpdateText()
   {
      if(this.mc_text != undefined)
      {
         this.mc_text.text = int(this.getCurrentStep());
      }
   }
   function ActivateRollOver()
   {
      if(this.func_onRollOver != undefined)
      {
         this.func_onRollOver(this.num_RollOverIndex);
      }
   }
   function ProcessInput(KeyCode)
   {
      switch(KeyCode)
      {
         case 39:
         case com.XInput.DPadRight:
            this.setCurrentStep(this.getCurrentStep() + 1);
            break;
         case 37:
         case com.XInput.DPadLeft:
            this.setCurrentStep(this.getCurrentStep() - 1);
      }
      return false;
   }
   function SetPlatformLayout(nPlatformID)
   {
      this.m_PlatformID = nPlatformID;
      var _loc0_ = null;
      if((_loc0_ = nPlatformID) === com.XPlatform.XBox)
      {
         if(!this.m_LeftStick)
         {
            this.mc_slider.gotoAndStop("XboxRightStick");
         }
         else
         {
            this.mc_slider.gotoAndStop("XboxLeftStick");
         }
         this.CounterScale(this.mc_slider);
         this.setSteps(this.num_steps,this.num_stepsPerPage,false,false);
      }
   }
   function CounterScale(i_mc)
   {
      if(i_mc == undefined)
      {
         return undefined;
      }
      var _loc2_ = i_mc;
      var _loc3_ = i_mc._yscale / 100;
      _loc2_ = i_mc._parent;
      while(_loc2_ != _root)
      {
         _loc3_ *= 100 / _loc2_._yscale;
         _loc2_ = _loc2_._parent;
      }
      _loc3_ *= 100;
      i_mc._yscale = _loc3_;
      _loc3_ = i_mc._xscale / 100;
      _loc2_ = i_mc._parent;
      while(_loc2_ != _root)
      {
         _loc3_ *= 100 / _loc2_._xscale;
         _loc2_ = _loc2_._parent;
      }
      _loc3_ *= 100;
      i_mc._xscale = _loc3_;
   }
   function ProxyHitCheck()
   {
      var _loc2_ = null;
      _loc2_ = this.InternalProxyHitCheck(this.mc_slider);
      if(_loc2_ != null)
      {
         return _loc2_;
      }
      _loc2_ = this.InternalProxyHitCheck(this.mc_scrollUp);
      if(_loc2_ != null)
      {
         return _loc2_;
      }
      _loc2_ = this.InternalProxyHitCheck(this.mc_scrollDown);
      if(_loc2_ != null)
      {
         return _loc2_;
      }
      _loc2_ = this.InternalProxyHitCheck(this.mc_sliderBounding);
      if(_loc2_ != null)
      {
         return _loc2_;
      }
      _loc2_ = this.InternalProxyHitCheck(this.mc_scrollbarVisibleBackground);
      if(_loc2_ != null)
      {
         return _loc2_;
      }
      _loc2_ = this.InternalProxyHitCheck(this.mc_bg);
      return _loc2_;
   }
   function InternalProxyHitCheck(i_mc)
   {
      if(i_mc._visible && i_mc._alpha > 0)
      {
         if(i_mc.hitTest(_root._xmouse,_root._ymouse,true))
         {
            return i_mc;
         }
      }
      return null;
   }
}
