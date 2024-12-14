class com.bioware.masseffect.controls.vlistcontrols.ChoiceVListItem extends com.bioware.masseffect.controls.VListItem
{
   var _data;
   var info;
   // var Action;
   // var Arrows;
   var m_disabled = false;
   var m_Nested = false;
   var enableLogging = true;
   function ChoiceVListItem()
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
   function updateItemFromData(p_data)
   {
      // this.LogFromAS("updateItemFromData", p_data.Nested);
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
      // this.LogFromAS("set Nested", bVal, this.info.nestedPlus);
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
   // function SetText(i_infoText, i_navText)
   // {
   //    this.info.infoTxt.text = i_infoText;
   //    this.Action.Text.text = i_navText;
   //    if(!this.m_disabled)
   //    {
   //       this.SetActionButtonVisible(i_navText != "" ? true : false);
   //    }
   // }
   // function SetTextVerticalAutoSize(alignment)
   // {
   //    this.info.infoTxt.verticalAutoSize = alignment;
   // }
   // function SetActionButtonVisible(i_val)
   // {
   //    this.Action._visible = i_val;
   // }
   // function get TopArrowVisible()
   // {
   //    return this.Arrows.ArrowUp._visible;
   // }
   // function set TopArrowVisible(i_val)
   // {
   //    this.Arrows.ArrowUp._visible = i_val;
   // }
   // function get BottomArrowVisible()
   // {
   //    return this.Arrows.ArrowDown._visible;
   // }
   // function set BottomArrowVisible(i_val)
   // {
   //    this.Arrows.ArrowDown._visible = i_val;
   // }
   // function get NestedArrowVisible()
   // {
   //    return this.info.ArrowNested._visible;
   // }
   // function set NestedArrowVisible(i_val)
   // {
   //    
   // }
   function get NormalFrame()
   {
      return !!this.m_disabled ? "normalGrey" : "normal";
   }
   function get SelectedFrame()
   {
      return !!this.m_disabled ? "inGrey" : "in";
   }
   function get UnSelectedFrame()
   {
      return !!this.m_disabled ? "outGrey" : "out";
   }
   function get PressFrame()
   {
      return !!this.m_disabled ? "pressGrey" : "press";
   }
   // function set MenuAdvanceSwapped(iVal)
   // {
   //    this.Action.mcButtonAorB.mcButtonA._alpha = !iVal ? 100 : 0;
   //    this.Action.mcButtonAorB.mcButtonB._alpha = !iVal ? 0 : 100;
   // }
}
