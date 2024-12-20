class com.bioware.masseffect.controls.vlistcontrols.ChoiceVListItem extends com.bioware.masseffect.controls.VListItem
{
   var _data;
   var info;
   var m_disabled = false;
   var m_Nested = false;
   var _skipNextSelectionAnimation = false;
   function ChoiceVListItem()
   {
      super();
   }
   function LogFromAS()
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
      flash.external.ExternalInterface.call("ExLog", concatArgs);
   }
   function updateItemFromData(p_data)
   {
      this.SetLeftText(p_data.LeftText);
      this.SetCenterText(p_data.CenterText);
      this.SetRightText(p_data.RightText);
      this.SetSecondaryText(p_data.SecondaryText);
      this.Disabled = p_data.Disabled;
      this.Nested = p_data.Nested;
   }
   function set Disabled(bVal)
   {
      this.m_disabled = bVal;
      if (this.active)
      {
         if (bVal)
         {
            // in the transition between normal to inFinish
            if (this._currentframe >= 4 && this._currentframe < 13)
            {
               // transition it to the same point in the animation but grey version
               this.gotoAndPlay(this._currentframe + 22);
            }
            // at the end of the "in" animation
            else
            {
               this.gotoAndStop("inGreyFinish");
            }
         }
         else
         {
            // in the transition between normalGrey to inGreyFinish
            if (this._currentframe >= 26 && this._currentframe < 35)
            {
               // transition it to the same point in the animation but non grey version
               this.gotoAndPlay(this._currentframe - 22);
            }
            // at the end of the "in" animation
            else
            {
               this.gotoAndStop("inFinish");
            }
         }
      }
      else
      {
         this.gotoAndStop(this.NormalFrame);
      }
   }
   function get Disabled()
   {
      return this.m_disabled;
   }
   function set Nested(bVal)
   {
      this.m_Nested = bVal;
      this.info.nestedPlus._visible = bVal;
   }
   function get Nested()
   {
      return this.m_Nested;
   }
   function SetLeftText(s_text)
   {
      this.info.leftTxt.text = s_text;
   }
   function SetCenterText(s_text)
   {
      this.info.centerTxt.text = s_text;
   }
   function SetRightText(s_text)
   {
      this.info.rightTxt.text = s_text;
   }
   function SetSecondaryText(s_text)
   {
      this.info.secondaryTxt.text = s_text;
   }
   function onRollOut()
   {
      super.onRollOut();
      if(!com.bioware.masseffect.controls.VListItem.SuppressEvents)
      {
         this.dispatchEvent({type:"onUnHover",data:this._data});
      }
   }
   function onRollOver()
   {
      super.onRollOver();
      if(!com.bioware.masseffect.controls.VListItem.SuppressEvents)
      {
         this.dispatchEvent({type:"onHover",data:this._data});
      }
   }
   function skipNextSelectionAnimation()
   {
      this.LogFromAS("ChoiceVListItem skipNextSelectionAnimation", this.data.index);
      this._skipNextSelectionAnimation = true;
   }
   function get active()
   {
      return this._active;
   }
   function set active(p_active)
   {
      this.LogFromAS("ChoiceVListItem set active", this.data.index, p_active);
      if(this._active == p_active)
      {
         return;
      }
      this._active = p_active;
      if(this.SelectedFrame != null && this.UnSelectedFrame != null)
      {
         if(this._active)
         {
            this.gotoAndPlay(this.SelectedFrame);
         }
         else
         {
            this.gotoAndPlay(this.UnSelectedFrame);
         }
      }
      if(this._active)
      {
         if(!com.bioware.masseffect.controls.VListItem.SuppressEvents)
         {
            this.dispatchEvent({type:"onChange",data:this._data});
         }
         MovieClip(super).useHandCursor = true;
      }
      this._skipNextSelectionAnimation = false;
   }
   function get NormalFrame()
   {
      return !!this.m_disabled ? "normalGrey" : "normal";
   }
   function get SelectedFrame()
   {
      if (this._skipNextSelectionAnimation)
      {
         return !!this.m_disabled ? "inGreyFinish" : "inFinish";
      }
      return !!this.m_disabled ? "inGrey" : "in";
   }
   function get UnSelectedFrame()
   {
      if (this._skipNextSelectionAnimation)
      {
         return !!this.m_disabled ? "outGreyFinish" : "outFinish";
      }
      return !!this.m_disabled ? "outGrey" : "out";
   }
   function get PressFrame()
   {
      return !!this.m_disabled ? "pressGrey" : "press";
   }
}
