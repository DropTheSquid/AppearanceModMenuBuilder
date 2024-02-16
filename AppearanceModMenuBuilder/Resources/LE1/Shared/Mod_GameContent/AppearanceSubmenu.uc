Class AppearanceSubmenu
    config(UI);

// Types
struct PlotIntSetting 
{
    var int Id;
    var int Value;
};
struct AppearanceItemData 
{
    var stringref srActionText;
    var string sActionText;
    var stringref srLeftText;
    var string sLeftText;
    var stringref srCenterText;
    var string sCenterText;
    var stringref srRightText;
    var string sRightText;
    var array<PlotIntSetting> ApplySettingInts;
    var array<int> ApplySettingBools;
    var int DisplayConditional;
    var int DisplayBool;
    var PlotIntSetting DisplayInt;
    var int EnableConditional;
    var int EnableBool;
    var PlotIntSetting EnableInt;
    var string SubMenuClassName;
    var Class<AppearanceSubmenu> SubmenuClass;
    var AppearanceSubmenu submenuInstance;
    var bool inlineSubmenu;
    var bool disabled;
    var bool hidden;
    var string comment;
    var array<string> displayVars;
    var array<string> displayRequiredPackageExports;
    var float sortPriority;
    var eGender gender;
    var array<string> aApplicableCharacters;
    var int applyOutfitId;
    var string pawnOverride;
    var array<string> aMenuParameters;
    var int applyHelmetId;
    var int applyBreatherId;
    var eAppearanceType appearanceType;
    // var eMenuHelmetOverride menuHelmetOverride;
    // var eMenuHelmetOverride applyHelmetOverride;
    // var eHelmetVisibilityPreference applyHelmetVisibilityPreference;
    
    structdefaultproperties
    {
        ApplySettingInts = ()
        displayVars = ()
        displayRequiredPackageExports = ()
        aApplicableCharacters = ()
        aMenuParameters = ()
    }
};
// enum eGender
// {
//     Either,
//     Male,
//     Female,
// };
enum eAppearanceType
{
    unchanged,
    casual,
    combat,
};
// enum eMenuHelmetOverride
// {
//     unchanged,
//     vanilla,
//     forcedOff,
//     forcedOn,
//     forcedFull,
// };
// enum eHelmetVisibilityPreference
// {
//     unchanged,
//     preferOn,
//     preferOff,
// };

// Variables
var config stringref srTitle;
var config string sTitle;
var config stringref srSubtitle;
var config string sSubtitle;
var config stringref defaultActionText;
var config array<AppearanceItemData> menuItems;
var transient int selectedIndex;
var transient int scrollIndex;
var transient array<string> inlineStack;
var config eAppearanceType appearanceType;
var transient array<string> MenuParameters;
var config string pawnOverride;
var config string menuAppearanceType;
// var config eMenuHelmetOverride menuHelmetOverride;
var config bool preloadPawn;

// Functions
public function bool OnRefreshMenu(Object outerMenu)
{
    return FALSE;
}
public function bool OnItemSelected(Object outerMenu, int selectionIndex)
{
    return FALSE;
}
public function bool OnActionButtonPressed(Object outerMenu, int selectionIndex)
{
    return FALSE;
}
public function bool OnAuxButtonPressed(Object outerMenu, int selectionIndex)
{
    return FALSE;
}
public function bool OnAux2ButtonPressed(Object outerMenu, int selectionIndex)
{
    return FALSE;
}
public function bool OnBackButtonPressed(Object outerMenu)
{
    return FALSE;
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
	preloadPawn = true
}