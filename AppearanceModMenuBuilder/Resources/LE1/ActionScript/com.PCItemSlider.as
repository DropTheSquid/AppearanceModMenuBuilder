class com.PCItemSlider
{
   var originX;
   var originY;
   var blockDistance;
   var blocksPerPage;
   var bUseMouseInput;
   var bZoomed;
   var contenthold;
   var zoomHolder;
   var hoverSound;
   var clickSound;
   var fadeToOut;
   var zoomedSlider;
   var zoomIndex;
   var zoomCachedTop;
   var toIndex;
   var toInstantY;
   var totalBlocks;
   var activeIndex;
   var hoverIndex;
   var selectFunction;
   var defaultActiveFunction;
   var defaultInactiveFunction;
   var scrollBar;
   var scrollBarMC;
   var defaultHoverFunction;
   var defaultUnhoverFunction;
   var actionFunction;
   var doubleclickTime;
   var typeBased;
   var lastClickedIndex;
   var blocks = new Array();
   var activeFunction = new Array();
   var inactiveFunction = new Array();
   var hoverFunction = new Array();
   var unhoverFunction = new Array();
   var blockSelectable = new Array();
   var clickFunction = undefined;
   var bDontUseFunctions = false;
   var lastClickedTime = 0;
   var CLICK_BASED = -1;
   var HYBRID_BASED = 0;
   var DOUBLECLICK_BASED = 1;
   function PCItemSlider(parent, ox, oy, bdistance, bperpage)
   {
      this.originX = ox;
      this.originY = oy;
      this.blockDistance = bdistance;
      this.blocksPerPage = bperpage;
      this.bUseMouseInput = true;
      this.bZoomed = false;
      var j = 0;
      while(eval("parent.contenthold" + j) != undefined)
      {
         j++;
      }
      parent.createEmptyMovieClip("contenthold" + j,parent.getNextHighestDepth());
      this.contenthold = eval("parent.contenthold" + j);
      this.contenthold._x = this.originX;
      this.contenthold._y = this.originY;
      this.zoomHolder = this.contenthold.createEmptyMovieClip("zoomHolder",this.contenthold.getNextHighestDepth());
      this.zoomHolder._x = 0;
      this.zoomHolder._y = 0;
      this.contenthold.tabEnabled = false;
      this.contenthold.tabChildren = false;
      this.reset();
      var supervisor = this;
      this.contenthold.onEnterFrame = function()
      {
         supervisor.contentholdEnterFrame();
      };
      this.hoverSound = undefined;
      this.clickSound = undefined;
   }
   function contentholdEnterFrame()
   {
      var _loc4_ = undefined;
      var _loc7_ = undefined;
      var _loc2_ = undefined;
      var _loc3_ = undefined;
      var _loc5_ = undefined;
      var _loc6_ = undefined;
      if(!this.fadeToOut && !this.isFadedIn())
      {
         if(!this.contenthold._visible)
         {
            this.contenthold._alpha = 0;
            this.contenthold._visible = true;
         }
         _loc7_ = 100 - this.contenthold._alpha;
         if(_loc7_ > 1 || _loc7_ < -1)
         {
            this.contenthold._alpha += _loc7_ / 2;
         }
         else
         {
            this.contenthold._alpha = 100;
         }
      }
      if(this.fadeToOut && !this.isFadedOut())
      {
         if(this.contenthold._alpha < 1)
         {
            this.contenthold._alpha = 0;
            this.contenthold._visible = false;
         }
         else
         {
            this.contenthold._alpha /= 2;
         }
      }
      if(this.bZoomed)
      {
         _loc6_ = this.zoomedSlider.getSize();
         if(_loc6_ >= this.blocksPerPage - 1 || this.zoomIndex < this.zoomCachedTop)
         {
            this.toIndex = this.zoomIndex;
         }
         else if(_loc6_ + this.zoomIndex - this.zoomCachedTop > this.blocksPerPage - 1)
         {
            this.toIndex = this.zoomCachedTop + (_loc6_ + this.zoomIndex - this.zoomCachedTop) - (this.blocksPerPage - 1);
         }
      }
      if(this.toIndex >= 0)
      {
         _loc4_ = this.originY - this.toIndex * this.blockDistance - this.contenthold._y;
         if(_loc4_ > 1 || _loc4_ < -1)
         {
            this.contenthold._y += _loc4_ / 2;
         }
         else
         {
            this.contenthold._y = this.originY - this.toIndex * this.blockDistance;
         }
      }
      else
      {
         this.contenthold._y = this.toInstantY;
      }
      if(this.bZoomed)
      {
         _loc6_ = this.zoomedSlider.getSize();
         if(_loc6_ > this.blocksPerPage - 1)
         {
            _loc6_ = this.blocksPerPage - 1;
         }
         _loc2_ = 0;
         while(_loc2_ < this.totalBlocks)
         {
            if(_loc2_ < this.zoomIndex + 1 || _loc2_ >= this.zoomIndex + this.blocksPerPage)
            {
               this.blocks[_loc2_]._y = _loc2_ * this.blockDistance;
            }
            else
            {
               _loc3_ = this.blocks[_loc2_]._y;
               _loc5_ = (_loc2_ + _loc6_) * this.blockDistance;
               _loc4_ = _loc5_ - _loc3_;
               if(_loc4_ > 1 || _loc4_ < -1)
               {
                  this.blocks[_loc2_]._y += _loc4_ / 2;
               }
               else
               {
                  this.blocks[_loc2_]._y = _loc5_;
               }
            }
            _loc2_ = _loc2_ + 1;
         }
         if(this.zoomedSlider.isFadedOut())
         {
            this.zoomedSlider.fadeIn();
         }
      }
      if(!this.bZoomed)
      {
         if(this.zoomedSlider != undefined && this.zoomedSlider.isFadedIn())
         {
            this.zoomedSlider.fadeOut();
         }
         _loc2_ = 1;
         while(_loc2_ < this.blocksPerPage)
         {
            _loc3_ = this.blocks[_loc2_ + this.zoomIndex]._y;
            _loc5_ = (_loc2_ + this.zoomIndex) * this.blockDistance;
            _loc4_ = _loc5_ - _loc3_;
            if(_loc4_ > 1 || _loc4_ < -1)
            {
               this.blocks[_loc2_ + this.zoomIndex]._y += _loc4_ / 2;
            }
            else
            {
               this.blocks[_loc2_ + this.zoomIndex]._y = _loc5_;
            }
            _loc2_ = _loc2_ + 1;
         }
      }
      _loc2_ = 0;
      while(_loc2_ < this.totalBlocks)
      {
         // loc3 is the y origin of the block
         _loc3_ = this.contenthold._y + this.blocks[_loc2_]._y;
         // this handles is being above the visible section by more than 1
         if(_loc3_ <= this.originY - this.blockDistance)
         {
            this.blocks[_loc2_]._visible = false;
         }
         // this handles it being below the visible area by more than 1
         else if(_loc3_ >= this.originY + this.blocksPerPage * this.blockDistance)
         {
            this.blocks[_loc2_]._visible = false;
         }
         // this is being just above the visible area and therefore fading out as it scrolls
         else if(_loc3_ < this.originY)
         {
            this.blocks[_loc2_]._visible = true;
            this.blocks[_loc2_]._alpha = 100 - (this.originY - _loc3_) * 100 / this.blockDistance;
            if (this.blocks[_loc2_]._alpha < 5)
            {
               this.blocks[_loc2_]._visible = false;
            }
         }
         // same but for below
         else if(_loc3_ > this.originY + (this.blocksPerPage - 1) * this.blockDistance)
         {
            this.blocks[_loc2_]._visible = true;
            this.blocks[_loc2_]._alpha = (this.originY + this.blocksPerPage * this.blockDistance - _loc3_) * 100 / this.blockDistance;
            if (this.blocks[_loc2_]._alpha < 5)
            {
               this.blocks[_loc2_]._visible = false;
            }
         }
         // in the visible area
         else
         {
            this.blocks[_loc2_]._visible = true;
            this.blocks[_loc2_]._alpha = 100;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function reset(startsInvisible)
   {
      var _loc2_ = undefined;
      if(this.bZoomed)
      {
         this.zoomOut();
      }
      _loc2_ = 0;
      while(_loc2_ < this.getSize())
      {
         this.blocks[_loc2_].removeMovieClip();
         _loc2_ = _loc2_ + 1;
      }
      delete this.blocks;
      delete this.blockSelectable;
      delete this.activeFunction;
      delete this.inactiveFunction;
      delete this.hoverFunction;
      delete this.unhoverFunction;
      this.contenthold._visible = !startsInvisible;
      this.fadeToOut = startsInvisible;
      this.totalBlocks = 0;
      this.activeIndex = -1;
      this.hoverIndex = -1;
      this.selectFunction(-1);
      this.toIndex = -1;
      this.toInstantY = this.originY;
      this.recalcScrollBar();
   }
   function setVisible(bVisible)
   {
      this.fadeToOut = !bVisible;
      this.contenthold._visible = bVisible;
   }
   function createBlocks(total, libraryObjName, startsInvisible)
   {
      var _loc2_ = undefined;
      this.reset(startsInvisible);
      this.totalBlocks = total;
      this.blocks = Array(total);
      this.blockSelectable = Array(total);
      this.activeFunction = Array(total);
      this.inactiveFunction = Array(total);
      this.hoverFunction = Array(total);
      this.unhoverFunction = Array(total);
      _loc2_ = 0;
      while(_loc2_ < total)
      {
         this.setupBlock(_loc2_,libraryObjName);
         _loc2_ = _loc2_ + 1;
      }
      this.recalcScrollBar();
   }
   function setupBlock(i, libraryObjName)
   {
      var supervisor = this;
      this.blocks[i] = this.contenthold.attachMovie(libraryObjName,"content" + i,this.contenthold.getNextHighestDepth(),{_y:i * this.blockDistance,_x:0,_visible:false});
      this.blocks[i]._visible = false;
      if(!this.bDontUseFunctions)
      {
         this.blocks[i].onRollOver = this.blocks[i].onDragOver = function()
         {
            supervisor.rolloverFunction(i);
         };
         this.blocks[i].onRollOut = this.blocks[i].onDragOut = function()
         {
            supervisor.rolloutFunction(i);
         };
         this.blocks[i].onPress = function()
         {
            supervisor.pressFunction(i);
         };
      }
      this.blocks[i].indexInList = i;
      this.blockSelectable[i] = true;
   }
   function RefreshAllBlockStates()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.totalBlocks)
      {
         RefreshBlockState(_loc2_);
         _loc2_ += 1;
      }
   }
   function RefreshBlockState(index)
   {
      if(index == this.activeIndex)
      {
         if(this.activeFunction[index] == undefined)
         {
            this.defaultActiveFunction.call(this.blocks[index]);
         }
         else
         {
            this.activeFunction[index].call(this.blocks[index]);
         }
      }
      else if(this.inactiveFunction[index] == undefined)
      {
         this.defaultInactiveFunction.call(this.blocks[index]);
      }
      else
      {
         this.inactiveFunction[index].call(this.blocks[index]);
      }
   }
   function fadeIn()
   {
      this.fadeToOut = false;
   }
   function fadeOut()
   {
      this.fadeToOut = true;
   }
   function isFadedIn()
   {
      return this.contenthold._visible && this.contenthold._alpha == 100;
   }
   function isFadedOut()
   {
      return !this.contenthold._visible;
   }
   function getSize()
   {
      return this.totalBlocks;
   }
   function getActive()
   {
      return this.activeIndex;
   }
   function getHovered()
   {
      return this.hoverIndex;
   }
   function getBlock(index)
   {
      if(index < 0 || index >= this.totalBlocks)
      {
         return null;
      }
      return this.blocks[index];
   }
   function getBlocksArray()
   {
      return this.blocks;
   }
   function getActiveBlock()
   {
      return this.getBlock(this.getActive());
   }
   function getContentHold()
   {
      return this.contenthold;
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
   function setupScrollBar(mcScrollBar)
   {
      if(this.scrollBar != undefined)
      {
         delete this.scrollBar;
      }
      this.scrollBarMC = mcScrollBar;
      this.scrollBar = new com.PCScrollBar(mcScrollBar,mcScrollBar.bar,mcScrollBar.sliderNew,mcScrollBar.ResScrlUp,mcScrollBar.ResScrlDown);
      if(this.scrollBar == undefined)
      {
         trace("ERROR! no scroll bar on item slider");
      }
      mcScrollBar.tabEnabled = false;
      mcScrollBar.tabChildren = false;
      this.recalcScrollBar();
   }
   function recalcScrollBar()
   {
      if(this.scrollBar != undefined)
      {
         var supervisor = this;
         this.scrollBar._visible = this.totalBlocks > this.blocksPerPage;
         this.scrollBar.setSteps(this.totalBlocks - (this.blocksPerPage - 1),this.blocksPerPage - 1,true,true);
         this.scrollBar.onScroll = function()
         {
            supervisor.scrollFunction();
         }
         ;
         this.repositionScrollBar();
      }
   }
   function scrollFunction()
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
   function repositionScrollBar()
   {
      if(this.scrollBar != undefined)
      {
         if(this.toIndex > -1)
         {
            this.scrollBar.setPositionStep(this.toIndex);
         }
         else
         {
            this.scrollBar.setPositionStep((this.originY - this.contenthold._y) / this.blockDistance);
         }
      }
   }
   function moveTo(index)
   {
      if(this.totalBlocks <= this.blocksPerPage || this.bZoomed)
      {
         return undefined;
      }
      if(index < 0)
      {
         index = 0;
      }
      if(index > this.totalBlocks - this.blocksPerPage)
      {
         index = this.totalBlocks - this.blocksPerPage;
      }
      this.toIndex = index;
      this.repositionScrollBar();
   }
   function moveToInstantaneous(index)
   {
      if(this.totalBlocks <= this.blocksPerPage || this.bZoomed)
      {
         return undefined;
      }
      if(index < 0)
      {
         index = 0;
      }
      if(index > this.totalBlocks - this.blocksPerPage)
      {
         index = this.totalBlocks - this.blocksPerPage;
      }
      this.toIndex = -1;
      this.toInstantY = this.originY - index * this.blockDistance;
      this.contenthold._y = this.toInstantY;
      this.repositionScrollBar();
   }
   function showIndex(index)
   {
      var _loc3_ = undefined;
      if(this.totalBlocks <= this.blocksPerPage || this.bZoomed)
      {
         return undefined;
      }
      if(index < 0)
      {
         index = 0;
      }
      if(index >= this.totalBlocks)
      {
         index = this.totalBlocks - 1;
      }
      _loc3_ = (this.originY - this.contenthold._y) / this.blockDistance;
      if(index < _loc3_)
      {
         this.moveTo(index);
      }
      else if(index - (this.blocksPerPage - 1) > _loc3_)
      {
         this.moveTo(index - (this.blocksPerPage - 1));
      }
   }
   function getTopIndex()
   {
      var _loc2_ = undefined;
      if(-1 == this.toIndex)
      {
         _loc2_ = Math.round((this.originY - this.contenthold._y) / this.blockDistance);
      }
      else
      {
         _loc2_ = this.toIndex;
      }
      return _loc2_;
   }
   function showIndexInstantaneous(index)
   {
      var _loc3_ = undefined;
      if(this.totalBlocks <= this.blocksPerPage || this.bZoomed)
      {
         return undefined;
      }
      if(index < 0)
      {
         index = 0;
      }
      if(index >= this.totalBlocks)
      {
         index = this.totalBlocks - 1;
      }
      _loc3_ = (this.originY - this.contenthold._y) / this.blockDistance;
      if(index < _loc3_)
      {
         this.moveToInstantaneous(index);
      }
      else if(index - (this.blocksPerPage - 1) > _loc3_)
      {
         this.moveToInstantaneous(index - (this.blocksPerPage - 1));
      }
   }
   function moveToPercent(percent)
   {
      if(this.totalBlocks <= this.blocksPerPage)
      {
         return undefined;
      }
      if(percent < 0)
      {
         percent = 0;
      }
      if(percent > 100)
      {
         percent = 100;
      }
      this.toIndex = -1;
      this.toInstantY = this.originY - percent * this.blockDistance * (this.totalBlocks - this.blocksPerPage) / 100;
   }
   function useMouseInput(useInput)
   {
      if(useInput == this.bUseMouseInput)
      {
         return undefined;
      }
      if(!useInput && this.hoverIndex > -1 && this.hoverIndex < this.totalBlocks)
      {
         this.rolloutFunction(this.hoverIndex);
      }
      this.bUseMouseInput = useInput;
      if(useInput)
      {
         var _loc3_ = undefined;
         var _loc4_ = undefined;
         if(this.toIndex < 0)
         {
            _loc4_ = Math.round((this.originY - this.contenthold._y) / this.blockDistance);
         }
         else
         {
            _loc4_ = this.toIndex;
         }
         _loc3_ = 0;
         while(_loc3_ < this.blocksPerPage)
         {
            if(_loc3_ + _loc4_ != this.activeIndex && this.blocks[_loc3_ + _loc4_].hitTest(_root._xmouse,_root._ymouse,true))
            {
               this.rolloverFunction(_loc3_ + _loc4_);
               break;
            }
            _loc3_ = _loc3_ + 1;
         }
      }
   }
   function isUsingMouseInput()
   {
      return this.bUseMouseInput;
   }
   function setActive(index)
   {
      if(this.activeIndex > -1 && this.activeIndex < this.totalBlocks && index != this.activeIndex)
      {
         if(this.inactiveFunction[this.activeIndex] == undefined)
         {
            this.defaultInactiveFunction.call(this.blocks[this.activeIndex]);
         }
         else
         {
            this.inactiveFunction[this.activeIndex].call(this.blocks[this.activeIndex]);
         }
      }
      if(index > -1 && index < this.totalBlocks && index != this.activeIndex)
      {
         if(this.activeFunction[index] == undefined)
         {
            this.defaultActiveFunction.call(this.blocks[index]);
         }
         else
         {
            this.activeFunction[index].call(this.blocks[index]);
         }
         this.activeIndex = index;
         this.showIndex(this.activeIndex);
         this.selectFunction(this.activeIndex);
         return undefined;
      }
      if(index < 0 || index >= this.totalBlocks)
      {
         this.activeIndex = -1;
         this.selectFunction(this.activeIndex);
      }
   }
   function moveActive(d)
   {
      if(d == 0 || this.bZoomed)
      {
         return undefined;
      }
      if(this.activeIndex < 0)
      {
         if(d > 0)
         {
            this.setActive(this.totalBlocks - 1);
         }
         else
         {
            this.setActive(0);
         }
      }
      else if(this.activeIndex + d < 0)
      {
         this.setActive(0);
      }
      else if(this.activeIndex + d >= this.totalBlocks - 1)
      {
         this.setActive(this.totalBlocks - 1);
      }
      else
      {
         this.setActive(this.activeIndex + d);
      }
   }
   function setSelectable(index, selectable)
   {
      if(index > -1 && index < this.totalBlocks)
      {
         this.blockSelectable[index] = selectable;
      }
   }
   function setMouseFunctions(activeFunc, inactiveFunc, hoverFunc, unhoverFunc)
   {
      this.defaultActiveFunction = activeFunc;
      this.defaultInactiveFunction = inactiveFunc;
      this.defaultHoverFunction = hoverFunc;
      this.defaultUnhoverFunction = unhoverFunc;
   }
   function setSpecialFunctions(index, activeFunc, inactiveFunc, hoverFunc, unhoverFunc)
   {
      if(index > -1 && index < this.totalBlocks)
      {
         this.activeFunction[index] = activeFunc;
         this.inactiveFunction[index] = inactiveFunc;
         this.hoverFunction[index] = hoverFunc;
         this.unhoverFunction[index] = unhoverFunc;
      }
   }
   function setToDefaultFunctions(index)
   {
      if(index > -1 && index < this.totalBlocks)
      {
         this.activeFunction[index] = undefined;
         this.inactiveFunction[index] = undefined;
         this.hoverFunction[index] = undefined;
         this.unhoverFunction[index] = undefined;
      }
   }
   function setUseFunctions(bUse)
   {
      this.bDontUseFunctions = !bUse;
   }
   function setSounds(newHoverSound, newClickSound)
   {
      this.hoverSound = newHoverSound;
      this.clickSound = newClickSound;
   }
   function setFunctions(selectFunc, actionFunc, doubleclickT, based)
   {
      this.selectFunction = selectFunc;
      this.actionFunction = actionFunc;
      this.doubleclickTime = doubleclickT;
      this.typeBased = based;
   }
   function setClickFunction(clickFunc)
   {
      this.clickFunction = clickFunc;
   }
   function rolloverFunction(index)
   {
      if(!this.bUseMouseInput)
      {
         return undefined;
      }
      if(!this.blockSelectable[index])
      {
         return undefined;
      }
      if ()
      switch(this.typeBased)
      {
         case this.CLICK_BASED:
            this.hoverIndex = index;
            if(index != this.activeIndex)
            {
               if(this.hoverSound != undefined)
               {
                  getURL("FSCommand:" add com.UnrealMessages.PlaySound,this.hoverSound);
               }
               this.setActive(index);
            }
            break;
         case this.DOUBLECLICK_BASED:
            this.hoverIndex = index;
            if(index != this.activeIndex)
            {
               if(this.hoverSound != undefined)
               {
                  getURL("FSCommand:" add com.UnrealMessages.PlaySound,this.hoverSound);
               }
               if(this.hoverFunction[index] == undefined)
               {
                  this.defaultHoverFunction.call(this.blocks[index]);
               }
               else
               {
                  this.hoverFunction[index].call(this.blocks[index]);
               }
            }
            break;
         case this.HYBRID_BASED:
            this.hoverIndex = index;
            if(index != this.activeIndex)
            {
               if(this.hoverSound != undefined)
               {
                  getURL("FSCommand:" add com.UnrealMessages.PlaySound,this.hoverSound);
               }
               if(this.hoverFunction[index] == undefined)
               {
                  this.defaultHoverFunction.call(this.blocks[index]);
               }
               else
               {
                  this.hoverFunction[index].call(this.blocks[index]);
               }
               this.selectFunction(index);
            }
      }
   }
   function rolloutFunction(index)
   {
      if(!this.bUseMouseInput)
      {
         return undefined;
      }
      if(!this.blockSelectable[index])
      {
         return undefined;
      }
      switch(this.typeBased)
      {
         case this.CLICK_BASED:
            this.hoverIndex = -1;
            this.setActive(-1);
            break;
         case this.DOUBLECLICK_BASED:
            this.hoverIndex = -1;
            if(index != this.activeIndex)
            {
               if(this.unhoverFunction[index] == undefined)
               {
                  this.defaultUnhoverFunction.call(this.blocks[index]);
               }
               else
               {
                  this.unhoverFunction[index].call(this.blocks[index]);
               }
            }
            break;
         case this.HYBRID_BASED:
            this.hoverIndex = -1;
            if(index != this.activeIndex)
            {
               if(this.unhoverFunction[index] == undefined)
               {
                  this.defaultUnhoverFunction.call(this.blocks[index]);
               }
               else
               {
                  this.unhoverFunction[index].call(this.blocks[index]);
               }
               this.selectFunction(this.activeIndex);
            }
      }
   }
   function pressFunction(index)
   {
      if(!this.bUseMouseInput)
      {
         return undefined;
      }
      if(!this.blockSelectable[index])
      {
         return undefined;
      }
      switch(this.typeBased)
      {
         case this.CLICK_BASED:
            this.activeIndex = index;
            if(this.clickSound != undefined)
            {
               getURL("FSCommand:" add com.UnrealMessages.PlaySound,this.clickSound);
            }
            this.actionFunction(index);
            if(this.clickFunction != undefined)
            {
               this.clickFunction(index);
            }
            break;
         case this.DOUBLECLICK_BASED:
         case this.HYBRID_BASED:
            var _loc3_ = getTimer();
            if(this.lastClickedIndex == index && _loc3_ - this.lastClickedTime < this.doubleclickTime)
            {
               this.lastClickedIndex = -1;
               this.lastClickedTime = 0;
               if(this.clickSound != undefined)
               {
                  getURL("FSCommand:" add com.UnrealMessages.PlaySound,this.clickSound);
               }
               this.setActive(index);
               this.actionFunction(index);
            }
            else
            {
               this.lastClickedIndex = index;
               this.lastClickedTime = _loc3_;
               if(index != this.activeIndex)
               {
                  if(this.clickSound != undefined)
                  {
                     getURL("FSCommand:" add com.UnrealMessages.PlaySound,this.clickSound);
                  }
                  this.setActive(index);
               }
            }
            if(this.clickFunction != undefined)
            {
               this.clickFunction(index);
            }
      }
   }
   function createSubSlider(deltaX, deltaY)
   {
      return new com.PCItemSlider(this.zoomHolder,deltaX,deltaY,this.blockDistance,this.blocksPerPage - 1);
   }
   function zoomIn(index, zSlider)
   {
      this.zoomOut();
      if(zSlider == undefined || index < 0 || index >= this.totalBlocks)
      {
         return undefined;
      }
      this.zoomedSlider = zSlider;
      this.bZoomed = true;
      this.zoomIndex = index;
      this.zoomHolder._y = (this.zoomIndex + 1) * this.blockDistance;
      if(this.toIndex < 0)
      {
         this.zoomCachedTop = Math.round((this.originY - this.contenthold._y) / this.blockDistance);
      }
      else
      {
         this.zoomCachedTop = this.toIndex;
      }
      if(this.scrollBar != undefined)
      {
         this.zoomedSlider.setupScrollBar(this.scrollBarMC);
      }
   }
   function zoomOut()
   {
      if(!this.bZoomed)
      {
         return undefined;
      }
      this.bZoomed = false;
      this.toIndex = this.zoomCachedTop;
      if(this.zoomedSlider.scrollBar != undefined)
      {
         delete this.scrollBar;
         this.setupScrollBar(this.scrollBarMC);
      }
   }
   function isZoomed()
   {
      return this.bZoomed;
   }
   function getZoomedIndex()
   {
      if(!this.bZoomed)
      {
         return -1;
      }
      return this.zoomIndex;
   }
}
