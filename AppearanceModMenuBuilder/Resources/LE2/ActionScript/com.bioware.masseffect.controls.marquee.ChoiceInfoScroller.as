class com.bioware.masseffect.controls.marquee.ChoiceInfoScroller extends com.bioware.masseffect.controls.TextScrollMarquee
{
   function ChoiceInfoScroller()
   {
      super();
      // calculate an actually accurate slope of height per line, not just the height of a single line
      var lines1 = 10;
      var lines2 = 100;

      // get the height for a lower number of lines
      this.detailText.htmlText = this.getTestLines(lines1);
      this.detailText.autoSize = true;
      var steps1 = this.scrollContentHeight;

      // and a higher number
      this.detailText.htmlText = this.getTestLines(lines2);
      this.detailText.autoSize = true;
      var steps2 = this.scrollContentHeight;

      // get the slope between these
      this._stepHeight = (steps2 - steps1) / (lines2 - lines1);
      // reset the text to be blank
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
      // the vanilla implementation needlessly rounds to the nearest percentage, which fails if you have more than 100 steps
      // this does not have that problem and makes sure you go between the top and bottomm in the right number of steps
      var scrollFraction = 1 / (this.scrollBar.num_steps - 1) * nStepNum;
      this.moveContentTo(scrollFraction,true);
   }

   function CalculateScrollbarSteps(nContent, nWindow)
   {
      // this.testHeights();
      // nContent is the content height (or width if horizontal)
      // nWindow is the window height
      var windowLines = Math.round(nWindow / this.stepHeight);
      var totalLines = Math.round(nContent / this.stepHeight);
      this.scrollBar.setSteps(totalLines - windowLines + 1,windowLines,true,false);
   }
}
