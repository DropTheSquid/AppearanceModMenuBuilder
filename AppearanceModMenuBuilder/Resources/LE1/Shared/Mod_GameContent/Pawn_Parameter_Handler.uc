Class Pawn_Parameter_Handler extends Object
    config(Game);

// Types
struct PawnParamSpec
{
    var string parameterPath;
	// TODO add more stuff here eventually so you can make a new instance from config only
};

// Variables
var config array<PawnParamSpec> pawnParamSpecs;
var array<AMM_Pawn_Parameters> pawnParamList;
var bool paramsPopulated;

// Functions
public function bool GetPawnParams(BioPawn target, out AMM_Pawn_Parameters params)
{
    local AMM_Pawn_Parameters currentParams;
    
    populatePawnParams();
    foreach pawnParamList(currentParams, )
    {
        if (currentParams.matchesPawn(target))
        {
            params = currentParams;
            return TRUE;
        }
    }
    return FALSE;
}
public function bool GetPawnParamsByTag(coerce string Tag, out AMM_Pawn_Parameters params)
{
    local AMM_Pawn_Parameters currentParams;
    local BioGlobalVariableTable globalVars;
    
	LogInternal("getting pawn params by tag"@Tag);
    populatePawnParams();
    if (Tag ~= "Player")
    {
		globalVars = BioWorldInfo(Class'Engine'.static.GetCurrentWorldInfo()).GetGlobalVariables();
        Tag = globalVars.GetBool(4639) ? "Human_Female" : "Human_Male";
		LogInternal("coerced player tag to"@tag);
    }
    foreach pawnParamList(currentParams, )
    {
		LogInternal("checking"@currentParams.Tag);
        if (currentParams.Tag ~= Tag)
        {
			LogInternal("found"@currentParams.Tag);
            params = currentParams;
            return TRUE;
        }
    }
	LogInternal("not found"@Tag);
    return FALSE;
}
private final function populatePawnParams()
{
    local PawnParamSpec currentSpec;
    local int index;
    local string tempString;
    local array<string> tempStrings;
    local Class<AMM_Pawn_Parameters> paramsClass;
    local AMM_Pawn_Parameters paramsInstance;
    
    if (!paramsPopulated)
    {
		LogInternal("populating params"@pawnParamSpecs.Length);
        for (index = 0; index < pawnParamSpecs.Length; index++)
        {
            currentSpec = pawnParamSpecs[index];
            if (currentSpec.parameterPath != "")
            {
				LogInternal("populating param"@index@currentSpec.parameterPath);
                paramsClass = Class<AMM_Pawn_Parameters>(DynamicLoadObject(currentSpec.parameterPath, Class'Class'));
                if (paramsClass != None)
                {
					LogInternal("Got class"@paramsClass);
                    paramsInstance = new paramsClass;
                }
                else
                {
                    paramsInstance = AMM_Pawn_Parameters(DynamicLoadObject(currentSpec.parameterPath, Class'AMM_Pawn_Parameters'));
					LogInternal("Got instance"@paramsInstance);
                }
                if (paramsInstance != None)
                {
                    pawnParamList.AddItem(paramsInstance);
                }
                continue;
            }
            LogInternal("You are trying to dynamically create pawn params. This is not implemented yet", );
            paramsInstance = new Class'AMM_Pawn_Parameters';
            // TODO populate the spec lists if things are added in directly.
        }
        paramsPopulated = TRUE;
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
}