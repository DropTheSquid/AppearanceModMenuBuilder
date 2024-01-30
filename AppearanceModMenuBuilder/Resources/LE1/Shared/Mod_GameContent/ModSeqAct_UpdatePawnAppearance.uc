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
            Class'AMM_AppearanceUpdater_Base'.static.UpdatePawnAppearanceStatic(targetPawn, "ModSeqAct_UpdatePawnAppearance");
        }
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
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