using LegendaryExplorerCore.Packages;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    public class BuildStartupFile : IModBuilderTaskWithCustomContext<LE1CustomContext>
    {
        public override void RunModTask(ModBuilderCustomContext<LE1CustomContext> context)
        {
            Console.WriteLine("Building startup file");
            // make sure the startup file has a proper object referencer
            new InitializeStartup().RunModTask(context);
            // make sure the merge class is added to the startup file so that the game will not insta crash if the basegame changes are reverted
            new AddMergeClassesToStartup("SFXGame.pcc", "AMM_AppearanceUpdater_Base").RunModTask(context);
            // compile some classes into the startup file
            new AddClassesToFile(
                context => context.GetStartupFile(),
                [.. LooseClassCompile.GetClassesFromDirectories(@"Resources\LE1\Startup"),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Pawn_Parameters.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Utilities.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\OutfitSpecBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\helmetSpecBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\breatherSpecBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleOutfitSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\SimpleBreatherSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\AMM_Common.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\Pawn_Parameter_Handler.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\OutfitSpecListBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\HelmetSpecListBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\BreatherSpecListBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\ArmorOverrideVanillaOutfitSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\EquippedArmorOutfitSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\NonOverriddenVanillaOutfitSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaOutfitByIdSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaOutfitSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\DefaultOutfitSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaOutfitSpecBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\ArmorOverrideVanillaHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\EquippedArmorHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaHelmetByIdSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\DefaultHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\NonOverriddenVanillaHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaHelmetSpecBase.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\NoHelmetSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\VanillaBreatherSpec.uc", ["Mod_GameContent"]),
                    LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\NoBreatherSpec.uc", ["Mod_GameContent"])
                    ])
                .RunModTask(context);
            // add an instance of the handler class at a hardercoded location, add it to the object referencer
            var startup = context.GetStartupFile()!;
            var newExport = ExportCreator.CreateExport(startup, "AMM_AppearanceUpdater", "AMM_AppearanceUpdater", indexed: true);
            startup.GetOrCreateObjectReferencer().AddToObjectReferencer(newExport);
            startup.Save();

            // populate the outfit/headgear spec lists
            (new OutfitSpecListBuilder()).RunModTask(context);
        }
    }
}
