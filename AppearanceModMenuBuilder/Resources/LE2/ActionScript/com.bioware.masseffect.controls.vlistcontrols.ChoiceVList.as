class com.bioware.masseffect.controls.vlistcontrols.ChoiceVList extends com.bioware.masseffect.controls.VList
{
   var _skipNextSelectionAnimation = false;
   function ChoiceVList()
   {
      super();
   }
   function get listItemExportID()
   {
      return "ChoiceVListItem";
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
   function addEntry(p_index, s_leftText, s_centerText, s_rightText, s_secondaryText, b_Disabled, b_Nested)
   {
      var data = {
         index:p_index,
         LeftText:s_leftText,
         CenterText:s_centerText,
         RightText:s_rightText,
         SecondaryText:s_secondaryText,
         Disabled:b_Disabled,
         Nested:b_Nested
      };
      var entry = this.addListEntry(p_index,data);
      this.addBubbleEvent(entry,"onHover");
      this.addBubbleEvent(entry,"onUnHover");
      return entry;
   }
   function skipNextSelectionAnimation()
   {
      this.LogFromAS("ChoiceVList skipNextSelectionAnimation");
      this._skipNextSelectionAnimation = true;
   }
   function set selectedIndex(p_index)
   {
      this.LogFromAS("ChoiceVList selectedIndex", p_index, this._selectedIndex);
      if(p_index < 0 || p_index > this.m_counter)
      {
         return;
      }
      if(p_index != this._selectedIndex)
      {
         if (this._skipNextSelectionAnimation)
         {
            this._dataProvider[this._selectedIndex].skipNextSelectionAnimation();
            this._dataProvider[p_index].skipNextSelectionAnimation()
         }
         var _loc2_ = 0;
         var _loc4_ = this.IsIndexVisible(p_index);
         if(_loc4_ != com.bioware.masseffect.controls.VList.ITEM_VISIBLE)
         {
            _loc2_ = this.movementRefElementIndex - p_index;
            if(_loc4_ == com.bioware.masseffect.controls.VList.ITEM_INVISIBLE_BELOW)
            {
               _loc2_ += this.NUM_VISIBLE - 1;
            }
            this.movementRefElementIndex = this.movementRefElementIndex - _loc2_;
            this.repositionScrollBar();
         }
         this._dataProvider[this._selectedIndex].active = false;
         this._selectedIndex = p_index;
         this._dataProvider[this._selectedIndex].active = true;
         this._skipNextSelectionAnimation = false;
      }
   }
   function get selectedIndex()
   {
      return this._selectedIndex;
   }
}
