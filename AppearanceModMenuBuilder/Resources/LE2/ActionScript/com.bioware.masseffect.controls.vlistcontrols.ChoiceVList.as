class com.bioware.masseffect.controls.vlistcontrols.ChoiceVList extends com.bioware.masseffect.controls.VList
{
   function ChoiceVList()
   {
      super();
   }
   function get listItemExportID()
   {
      return "ChoiceVListItem";
   }
   function addEntry(p_index, s_leftText, s_centerText, s_rightText, s_secondaryText, b_Disabled, b_Nested)
   {
      var _loc2_ = {
         index:p_index,
         LeftText:s_leftText,
         CenterText:s_centerText,
         RightText:s_rightText,
         SecondaryText:s_secondaryText,
         Disabled:b_Disabled,
         Nested:b_Nested
      };
      return this.addListEntry(p_index,_loc2_);
   }
}
