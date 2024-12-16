class com.bioware.masseffect.controls.marquee.ChoiceInfoScroller extends com.bioware.masseffect.controls.TextScrollMarquee
{
   function ChoiceInfoScroller()
   {
      super();
      // calculate an actually accurate slope of height per line, not just the height of a single line
      var lines1 = 1000;
      var lines2 = 5000;
      this.detailText.htmlText = this.getTestLines(lines1);
      this.detailText.autoSize = true;

      // this.detailText.text = this.getTestLines(lines1);
      // var steps1 = this.detailText.textHeight;
      var steps1 = this.scrollContentHeight;

      this.detailText.htmlText = this.getTestLines(lines2);
      this.detailText.autoSize = true;

      // this.detailText.text = this.getTestLines(lines2);
      // var steps2 = this.detailText.textHeight;
      var steps2 = this.scrollContentHeight;

      this._stepHeight = (steps2 - steps1) / (lines2 - lines1);
      // this.detailText.text = "";
      this.detailText.htmlText = "";
   }
   function getTestLines(nCount)
   {
      var testString = "";
      var i = 0;
      for (i = 0; i < nCount; i++)
      {
         testString += i.toString() + "Ay";
         if (i != nCount - 1)
         {
            testString += "\n";
         }
      }
      return testString;
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
   function set requireTxt(s)
   {
   }
   function get requireTxt()
   {
      return null;
   }
   function set inventoryTxt(s)
   {
   }
   function get inventoryTxt()
   {
      return null;
   }
   function set costTxt(s)
   {
   }
   function get costTxt()
   {
      return null;
   }
   function set HideCost(bVal)
   {
   }
   function get HideCost()
   {
      return false;
   }
   function moveToStep(nStepNum)
   {
      /*
      // the vanilla implementation of this from the parent class needlessly rounds it to the nearest whole number percentage, so if there are more than 100 steps it fails, and there are innacuracies even below that
      // this correctly calculates the fraction it should be scrolled to
      // we also need to account for the fact that the last page of content does not get scrolled off, which means adjusting the step size to be slightly larger to account for fewer steps
      var windowLines = Math.round(this.scrollWindowHeight / this.stepHeight);
      var totalLines = Math.round(this.scrollContentHeight / this.stepHeight);
      var modifiedStepHeight = this.stepHeight * (1 + (windowLines / totalLines));
      var scrollFraction = (nStepNum * modifiedStepHeight) / this.scrollContentHeight;

      // this.LogFromAS("moveToStep height test",this.detailText.textHeight,this.scrollContentHeight);
      // var scrollFraction = nStepNum / (totalLines - windowLines);
      this.LogFromAS("moveToStep", nStepNum, this.stepHeight, modifiedStepHeight, windowLines, totalLines, scrollFraction);
      */

      // we know the number of steps
      // var windowLines = Math.round(this.scrollWindowHeight / this.stepHeight);
      // var totalLines = Math.round(this.scrollContentHeight / this.stepHeight);
      //  = int(steps);
      
      // var scrollableLines = totalLines - windowLines + 1;

      // we know the min scroll fraction is 0, and the max is 1 - (window lines/total lines)
      // var maxScrollFraction = 1;// - (windowLines / totalLines);
      //so the fractional step size is the divided by the number of steps

      //  - this.scrollBar.num_stepsPerPage
      var scrollFraction = 1 / (this.scrollBar.num_steps - 1) * nStepNum;
      // this.LogFromAS("moveToStep", nStepNum, windowLines, totalLines, scrollableLines, maxScrollFraction, scrollFraction);

      this.moveContentTo(scrollFraction,true);
   }
   // function testGetHeight(num)
   // {
   //    var text = this.getTestLines(num);

   //    this.detailText.htmlText = text;
   //    this.detailText.autoSize = true;
   //    var htmlContentHeight = this.scrollContentHeight;
   //    var htmlTextHeight = this.detailText.textHeight;

   //    this.detailText.text = text;
   //    this.detailText.autoSize = true;
   //    var contentHeight = this.scrollContentHeight;
   //    var textHeight = this.detailText.textHeight;

   //    this.LogFromAS("height test",num,htmlContentHeight, htmlTextHeight, contentHeight, textHeight);
   // }

   // function testHeights()
   // {
   //    var originalText = this.detailText.htmlText;
   //    this.testGetHeight(1);
   //    this.testGetHeight(10);
   //    this.testGetHeight(100);
   //    this.testGetHeight(1000);
   //    this.testGetHeight(5000);
   //    this.testGetHeight(10000);
   //    this.detailText.htmlText = originalText;
   // }

   function CalculateScrollbarSteps(nContent, nWindow)
   {
      // this.testHeights();
      // nContent is the content height (or width if horizontal)
      // nWindow is the window height
      var windowLines = Math.round(nWindow / this.stepHeight);
      var totalLines = Math.round(nContent / this.stepHeight);
      // var scrollableLines = totalLines - windowLines + 1;
      // this.LogFromAS("CalculateScrollbarSteps", nWindow, nContent, windowLines, totalLines, this.stepHeight, scrollableLines);
      // and here we account for reducing the number of steps by the number of lines that display in the window
      this.scrollBar.setSteps(totalLines - windowLines + 1,windowLines,true,false);
   }
}
