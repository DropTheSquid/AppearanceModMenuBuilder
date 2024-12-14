class com.bioware.masseffect.controls.VList extends com.bioware.masseffect.controls.FocusControl
{
   var _listGlobalCoords;
   var _dataProvider;
   var listHolder;
   var addEventListener;
   var dispatchEvent;
   var _bPreventAnimNextMove;
   var _listAreaTop;
   var _fadeZoneTop;
   var _fadeZoneHeight;
   var _listAreaBottom;
   var _fadeZoneBottom;
   var scrollBar;
   var scrollBarMC;
   static var ITEM_VISIBLE = 1;
   static var ITEM_INVISIBLE_ABOVE = -1;
   static var ITEM_INVISIBLE_BELOW = -2;
   var NUM_VISIBLE = 5;
   var FADE_ITEMS = true;
   var _movementRefElementIndex = -1;
   var _selectedIndex = -1;
   var _topVisibleElementOffset = 0;
   var m_counter = 0;
   var LIST_ITEM_HEIGHT = 75;
   var DECAY = 3;
   var m_PlatformLayout = com.XPlatform.PC;
   var _scrollbarVisibleOveride = false;
   var _scrollbarVisibleOverideValue = false;
   var _isListMoving = false;
   var onListScrollFunction = undefined;
   function VList()
   {
      super();
      mx.events.EventDispatcher.initialize(this);
      this._listGlobalCoords = {x:0,y:0};
      this.localToGlobal(this._listGlobalCoords);
   }
   function onLoad()
   {
      this.configUI();
   }
   function configUI()
   {
      this._dataProvider = [];
      this.listHolder = this.createEmptyMovieClip("listHolder",this.getNextHighestDepth());
      this.addEventListener("onListAnimationComplete",mx.utils.Delegate.create(this,this.onListAnimationComplete));
   }
   function onListItemSelected(p_event)
   {
      this.selectedIndex = p_event.data.index;
   }
   function SetNumVisibleElements(i_nVisible)
   {
      this.NUM_VISIBLE = i_nVisible;
   }
   function onListAnimationComplete(p_event)
   {
   }
   function get listItemExportID()
   {
      return "VListItem";
   }
   function bubbleEvent(p_event)
   {
      this.dispatchEvent(p_event);
   }
   function addBubbleEvent(p_src, p_eventID)
   {
      p_src.addEventListener(p_eventID,mx.utils.Delegate.create(this,this.bubbleEvent));
   }
   function removeBubbleEvent(p_src, p_eventID)
   {
      p_src.removeEventListener(p_eventID,mx.utils.Delegate.create(this,this.bubbleEvent));
   }
   function get IsListMoving()
   {
      return this._isListMoving;
   }
   function set SnapNextListMovement(bPreventAnim)
   {
      this._bPreventAnimNextMove = bPreventAnim;
   }
   function get SnapNextListMovement()
   {
      return this._bPreventAnimNextMove;
   }
   function animateList()
   {
      this._isListMoving = true;
      delete this.listHolder.onEnterFrame;
      if(this._bPreventAnimNextMove)
      {
         this.moveList();
      }
      else
      {
         this.listHolder.onEnterFrame = mx.utils.Delegate.create(this,this.moveList);
      }
   }
   function moveList()
   {
      var _loc2_ = - this._movementRefElementIndex * this.LIST_ITEM_HEIGHT;
      var _loc3_ = false;
      var _loc4_ = 0;
      if(!this._bPreventAnimNextMove)
      {
         _loc4_ = (_loc2_ - this.listHolder._y) / this.DECAY;
         this.listHolder._y += _loc4_;
         if(Math.abs(_loc2_ - this.listHolder._y) < 1)
         {
            _loc3_ = true;
            this.listHolder._y = _loc2_;
            this.listHolder.onEnterFrame = null;
            delete this.listHolder.onEnterFrame;
         }
      }
      else
      {
         this.listHolder._y = _loc2_;
         _loc3_ = true;
      }
      this.recalculateListItemAlphaAndEnabled();
      if(_loc3_)
      {
         this._isListMoving = false;
         this.SnapNextListMovement = false;
         this.dispatchEvent({type:"onListAnimationComplete"});
      }
   }
   function recalculateListItemAlphaAndEnabled()
   {
      var _loc5_ = 0;
      var _loc6_ = undefined;
      var _loc2_ = {x:0,y:0};
      var _loc3_ = 100;
      var _loc4_ = 0;
      _loc5_ = 0;
      while(_loc5_ < this.m_counter)
      {
         _loc6_ = this._dataProvider[_loc5_];
         _loc2_.x = 0;
         _loc2_.y = 0;
         _loc6_.localToGlobal(_loc2_);
         _loc4_ = _loc2_.y + this.LIST_ITEM_HEIGHT;
         if(_loc2_.y < this._listAreaTop && _loc2_.y > this._fadeZoneTop)
         {
            var _loc7_ = Math.abs(_loc2_.y - this._listAreaTop);
            _loc3_ = 100 - Math.round(_loc7_ / this._fadeZoneHeight * 100);
         }
         else if(_loc4_ > this._listAreaBottom && _loc4_ < this._fadeZoneBottom)
         {
            var _loc8_ = Math.abs(_loc4_ - this._listAreaBottom);
            _loc3_ = 100 - Math.round(_loc8_ / this._fadeZoneHeight * 100);
         }
         else if(_loc4_ > this._fadeZoneBottom || _loc2_.y < this._fadeZoneTop)
         {
            _loc3_ = 0;
         }
         else
         {
            _loc3_ = 100;
         }
         if(this.FADE_ITEMS)
         {
            _loc6_._alpha = _loc3_;
         }
         _loc6_.enabled = _loc3_ > 50;
         _loc5_ = _loc5_ + 1;
      }
   }
   function recalculateListDimensions()
   {
      var _loc2_ = this._topVisibleElementOffset * this.LIST_ITEM_HEIGHT;
      this._listAreaTop = this._listGlobalCoords.y + _loc2_;
      this._listAreaBottom = this._listGlobalCoords.y + this.LIST_ITEM_HEIGHT * this.NUM_VISIBLE + _loc2_;
      this._fadeZoneHeight = this.LIST_ITEM_HEIGHT * 0.75;
      this._fadeZoneTop = this._listAreaTop - this._fadeZoneHeight;
      this._fadeZoneBottom = this._listAreaBottom + this._fadeZoneHeight;
   }
   function IsIndexVisible(i_nIndex)
   {
      var _loc2_ = com.bioware.masseffect.controls.VList.ITEM_VISIBLE;
      var _loc4_ = com.bioware.masseffect.controls.VListItem(this.getListItem(i_nIndex));
      var _loc3_ = {x:0,y:0};
      _loc4_.localToGlobal(_loc3_);
      var _loc5_ = _loc3_.y + this.LIST_ITEM_HEIGHT / 2 > this._listAreaBottom;
      var _loc6_ = _loc3_.y + this.LIST_ITEM_HEIGHT / 2 < this._listAreaTop;
      if(_loc5_)
      {
         _loc2_ = com.bioware.masseffect.controls.VList.ITEM_INVISIBLE_BELOW;
      }
      else if(_loc6_)
      {
         _loc2_ = com.bioware.masseffect.controls.VList.ITEM_INVISIBLE_ABOVE;
      }
      return _loc2_;
   }
   function get movementRefElementIndex()
   {
      return this._movementRefElementIndex;
   }
   function set movementRefElementIndex(p_index)
   {
      var _loc2_ = 0;
      var _loc4_ = 1;
      if(p_index != this._movementRefElementIndex)
      {
         this._movementRefElementIndex = p_index;
         this.animateList();
      }
   }
   function set selectedIndex(p_index)
   {
      if(p_index < 0 || p_index > this.m_counter)
      {
         return;
      }
      if(p_index != this._selectedIndex)
      {
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
      }
   }
   function get selectedIndex()
   {
      return this._selectedIndex;
   }
   function set dataProvider(p_data)
   {
      this._dataProvider = p_data;
   }
   function get dataProvider()
   {
      return this._dataProvider;
   }
   function get selectedItem()
   {
      return this._dataProvider[this._selectedIndex];
   }
   function set selectedItem(p_item)
   {
      this.selectedIndex = p_item.data.index;
   }
   function get length()
   {
      return this.m_counter;
   }
   function set length(p_length)
   {
      var _loc2_ = undefined;
      while(p_length > this.length)
      {
         this.addListEntry(this.m_counter,{index:this.m_counter});
      }
      while(p_length < this.length)
      {
         _loc2_ = this._dataProvider.pop();
         _loc2_.removeMovieClip();
         this.m_counter = this.m_counter - 1;
      }
      this.recalcScrollBar();
      this.recalcScrollbarVisibility();
   }
   function GetListCount()
   {
      return this.m_counter;
   }
   function getListItem(nIndex)
   {
      return this._dataProvider[nIndex];
   }
   function killMenu()
   {
      this.listHolder.removeMovieClip();
      this.listHolder = null;
      delete this.listHolder;
      this.listHolder = this.createEmptyMovieClip("listHolder",this.getNextHighestDepth());
      this.dataProvider = [];
      this.scrollBar._visible = false;
      this.m_counter = 0;
      this._movementRefElementIndex = -1;
      this._selectedIndex = -1;
   }
   function moveTo(index)
   {
      this.movementRefElementIndex = index;
   }
   function moveToPercent(percent)
   {
      if(percent < 0)
      {
         percent = 0;
      }
      if(percent > 100)
      {
         percent = 100;
      }
      this.moveTo(Math.round(percent / 100 * (this.m_counter - this.NUM_VISIBLE)));
   }
   function addListEntry(p_index, p_itemData)
   {
      var _loc2_ = com.bioware.masseffect.controls.VListItem(this.listHolder.attachMovie(this.listItemExportID,"item" + this.m_counter,p_index));
      if(p_index == 0)
      {
         this.LIST_ITEM_HEIGHT = _loc2_.MaxHeight;
      }
      this.m_counter = this.m_counter + 1;
      _loc2_._y = p_index * this.LIST_ITEM_HEIGHT + _loc2_.yOffset;
      _loc2_._x = _loc2_.xOffset;
      this.addBubbleEvent(_loc2_,"onChange");
      _loc2_.addEventListener("listItemSelected",mx.utils.Delegate.create(this,this.onListItemSelected));
      _loc2_.data = p_itemData;
      _loc2_.parentList = this;
      this._dataProvider.push(_loc2_);
      this.recalculateListDimensions();
      this.recalcScrollBar();
      this.recalcScrollbarVisibility();
      if(this.IsIndexVisible(p_index) != com.bioware.masseffect.controls.VList.ITEM_VISIBLE && this.FADE_ITEMS == true)
      {
         _loc2_._alpha = 0;
         _loc2_.enabled = false;
      }
      return _loc2_;
   }
   function addEntry(p_index, p_itemData)
   {
      return this.addListEntry(p_index,p_itemData);
   }
   function HasItemsOffTop()
   {
      return this.movementRefElementIndex > 0;
   }
   function HasItemsOffBottom()
   {
      return this.movementRefElementIndex + this.NUM_VISIBLE < this.GetListCount();
   }
   function RefreshListItems()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.GetListCount())
      {
         this._dataProvider[_loc2_].Refresh();
         _loc2_ = _loc2_ + 1;
      }
   }
   function set scrollbarVisibleOveride(i_val)
   {
      this._scrollbarVisibleOveride = i_val;
   }
   function get scrollbarVisibleOveride()
   {
      return this._scrollbarVisibleOveride;
   }
   function set scrollbarVisibleOverideValue(i_val)
   {
      this._scrollbarVisibleOverideValue = i_val;
   }
   function get scrollbarVisibleOverideValue()
   {
      return this._scrollbarVisibleOverideValue;
   }
   function recalcScrollbarVisibility()
   {
      if(this.scrollBar != undefined)
      {
         var _loc2_ = this.scrollBar._visible;
         this.scrollBar._visible = this.m_counter > this.NUM_VISIBLE;
         if(this._scrollbarVisibleOveride)
         {
            this.scrollBar._visible = this._scrollbarVisibleOverideValue;
         }
         if(_loc2_ && !this.scrollBar._visible)
         {
            this.LoseFocus();
         }
      }
   }
   function MoveScrollBar(Dir)
   {
      if(Dir > 0)
      {
         this.scrollBar.doScrollDown();
      }
      else
      {
         this.scrollBar.doScrollUp();
      }
   }
   function OnMouseWheelInput(Dir)
   {
      super.OnMouseWheelInput(Dir);
      if(this.scrollBar != null)
      {
         this.scrollBar.doScrollBy(Dir);
      }
   }
   function setupScrollBar(mcScrollBar)
   {
      if(this.scrollBar != undefined)
      {
         delete this.scrollBar;
      }
      this.scrollBarMC = mcScrollBar;
      this.scrollBar = new com.PCScrollBar(mcScrollBar,mcScrollBar.bar,mcScrollBar.sliderNew,mcScrollBar.ResScrlUp,mcScrollBar.ResScrlDown,mcScrollBar.scrollbarVisibleBg,false);
      mcScrollBar.tabEnabled = false;
      mcScrollBar.tabChildren = false;
      if(this.scrollBar.onScroll == undefined)
      {
         var supervisor = this;
         this.scrollBar.onScroll = function()
         {
            supervisor.scrollFunction();
         }
         ;
      }
      this.recalcScrollBar();
   }
   function recalcScrollBar()
   {
      if(this.scrollBar != undefined)
      {
         this.scrollBar.setSteps(this.m_counter - (this.NUM_VISIBLE - 1),this.NUM_VISIBLE - 1,true,true);
         this.repositionScrollBar();
      }
   }
   function scrollFunction()
   {
      if(this.scrollBar != undefined)
      {
         if(this.scrollBar.discreteScrolling)
         {
            this.moveTo(this.scrollBar.getCurrentStep());
         }
         else
         {
            this.moveToPercent(this.scrollBar.getCurrentPercent());
         }
      }
      if(this.onListScrollFunction != undefined)
      {
         this.onListScrollFunction.call(this);
      }
   }
   function repositionScrollBar()
   {
      if(this.scrollBar != undefined)
      {
         if(this._movementRefElementIndex > -1)
         {
            this.scrollBar.setPositionStep(this._movementRefElementIndex);
         }
      }
   }
   function SetPlatformLayout(nPlatformID)
   {
      this.m_PlatformLayout = nPlatformID;
      if(this.scrollBar != null || this.scrollBar != undefined)
      {
         this.scrollBar.SetLeftStickIcon(nPlatformID != com.XPlatform.PC);
         this.scrollBar.SetPlatformLayout(nPlatformID);
      }
   }
   function GiveFocus()
   {
      trace("VList : GiveFocus : scrollBar._visible = " + this.scrollBar._visible);
      if(this.scrollBar._visible)
      {
         super.GiveFocus();
      }
   }
   function onFocusGained()
   {
      this.dispatchEvent({type:"VList_OnFocusGained"});
   }
}
