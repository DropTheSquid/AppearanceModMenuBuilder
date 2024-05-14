Class ModSeqAct_UpdatePawnAppearance extends SequenceAction;

public event function Activated()
{
    local Object target;
    local BioPawn targetPawn;

    foreach Targets(target)
    {
        targetPawn = BioPawn(target);
		if (targetPawn != None)
		{
			// input 1: turn armor override on
			if (InputLinks[1].bHasImpulse == TRUE)
			{
				targetPawn.m_oBehavior.m_bArmorOverridden = true;
			}
			// input 2: turn armor override off
			else if (InputLinks[2].bHasImpulse == TRUE)
			{
				targetPawn.m_oBehavior.m_bArmorOverridden = false;
			}
			// input 0: just update the appearance without modifying anything else
			if (InputLinks[0].bHasImpulse == TRUE)
			{
				Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(targetPawn, "ModSeqAct_UpdatePawnAppearance");
			}
		}
		
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
	 InputLinks = ({
                   LinkDesc = "Update", 
                   LinkAction = 'None', 
                   LinkedOp = None, 
                   QueuedActivations = 0, 
                   ActivateDelay = 0.0, 
                   bHasImpulse = FALSE, 
                   bDisabled = FALSE
                  }, 
                  {
                   LinkDesc = "ArmorOverrideOn", 
                   LinkAction = 'None', 
                   LinkedOp = None, 
                   QueuedActivations = 0, 
                   ActivateDelay = 0.0, 
                   bHasImpulse = FALSE, 
                   bDisabled = FALSE
                  }, 
                  {
                   LinkDesc = "ArmorOverrideOff", 
                   LinkAction = 'None', 
                   LinkedOp = None, 
                   QueuedActivations = 0, 
                   ActivateDelay = 0.0, 
                   bHasImpulse = FALSE, 
                   bDisabled = FALSE
                  }
                 )
    OutputLinks = ({
                    Links = (), 
                    LinkDesc = "Done", 
                    LinkAction = 'None', 
                    LinkedOp = None, 
                    ActivateDelay = 0.0, 
                    bHasImpulse = FALSE, 
                    bDisabled = FALSE
                   }
                  )
    VariableLinks = ({
                      LinkedVariables = (), 
                      LinkDesc = "Target", 
                      ExpectedType = Class'SeqVar_Object', 
                      LinkVar = 'None', 
                      PropertyName = 'Targets', 
                      CachedProperty = None, 
                      MinVars = 1, 
                      MaxVars = 255, 
                      bWriteable = FALSE, 
                      bModifiesLinkedObject = FALSE, 
                      bAllowAnyType = FALSE
                     }
                    )
}