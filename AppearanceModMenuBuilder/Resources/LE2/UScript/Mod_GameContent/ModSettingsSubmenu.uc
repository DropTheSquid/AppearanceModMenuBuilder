class ModSettingsSubmenu config(UI);

struct ModSettingItemData 
{
    var stringref srActionText;
    var string sActionText;
    var stringref srLeftText;
    var string sLeftText;
    var stringref srCenterText;
    var string sCenterText;
    var stringref srRightText;
    var string sRightText;
    var stringref srSecondaryText;
    var string sSecondaryText;
    var stringref srDescriptionTitleText;
    var string sDescriptionTitleText;
    var stringref srDescriptionText;
    var string sDescriptionText;
    // var array<PlotIntSetting> ApplySettingInts;
    // var array<int> ApplySettingBools;
    // var int DisplayConditional;
    // var int DisplayBool;
    // var PlotIntSetting DisplayInt;
    // var int EnableConditional;
    // var int EnableBool;
    // var PlotIntSetting EnableInt;
    // var array<string> Images;
    var string SubMenuClassName;
    var Class<ModSettingsSubmenu> SubmenuClass;
    var ModSettingsSubmenu submenuInstance;
    // var bool inlineSubmenu;
    var bool disabled;
    var bool hidden;
    // var array<string> displayVars;
    // var array<string> displayRequiredPackageExports;
    // var float sortPriority;
};

var config stringref srTitle;
var config string sTitle;
var config stringref srSubtitle;
var config string sSubtitle;
var config stringref defaultActionText;
var config array<ModSettingItemData> menuItems;
var transient int selectedIndex;
var transient int scrollIndex;
