using MassEffectModBuilder.LEXHelpers;
using MassEffectModBuilder;
using LegendaryExplorerCore.Packages;
using System.Numerics;
using LegendaryExplorerCore.Unreal;
using LegendaryExplorerCore.Packages.CloningImportingAndRelinking;
using LegendaryExplorerCore.Kismet;
using LegendaryExplorerCore.Unreal.ObjectInfo;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    internal class BuildNor10_09_Files : IModBuilderTask
    {
        const string Nor10_09Rom_LayFileName = "BIOA_NOR10_09ROM_LAY.pcc";
        const string Nor10_09_LayFileName = "BIOA_NOR10_09_LAY.pcc";
        const string Nor10_09_ArtFileName = "BIOA_NOR10_09_ART.pcc";
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine($"Building {Nor10_09Rom_LayFileName}");

            // ensure this exists in the output
            Directory.CreateDirectory(Path.Combine(context.CookedPCConsoleFolder, "Nor10_09"));

            // I am getting the vanilla version of BIOA_NOR10_09ROM_LAY and copying it into my mod, then programatically modifying it
            if (!PackageHelpers.TryGetHighestMountedOfficialFile(Nor10_09Rom_LayFileName, context.Game, out var basegamePackagePath) || basegamePackagePath == null)
            {
                throw new Exception($"Could not find basegame file {Nor10_09Rom_LayFileName}");
            }
            var destinationPath = Path.Combine(context.CookedPCConsoleFolder, "Nor10_09", Nor10_09Rom_LayFileName);
            File.Copy(basegamePackagePath, destinationPath);

            var basegameRomPcc = MEPackageHandler.OpenMEPackage(destinationPath);

            BuildNor10_09ROM_LAYFile(basegameRomPcc);

            // now do the same with the Mello patched version
            var LE1WorkspaceRoot = Directory.GetParent(context.ModOutputPathBase)!.FullName;
            var melloSourceFilePath = Path.Combine(LE1WorkspaceRoot, @"ME¹LLO\DLC_MOD_MELLO\CookedPCConsole\Main-Core\NOR\BIOA_NOR10_09ROM_LAY.pcc");

            Directory.CreateDirectory(Path.Combine(context.ModOutputPathBase, $@"Compat\Mello\NOR10_09"));
            destinationPath = Path.Combine(context.ModOutputPathBase, $@"Compat\Mello\NOR10_09\{Nor10_09Rom_LayFileName}");

            File.Copy(melloSourceFilePath, destinationPath);

            var melloCompatPcc = MEPackageHandler.OpenMEPackage(destinationPath);

            BuildNor10_09ROM_LAYFile(melloCompatPcc);

            Console.WriteLine($"Building {Nor10_09_LayFileName}");

            // I am getting the vanilla version of BIOA_NOR10_09_LAY and copying it into my mod, then programatically modifying it
            if (!PackageHelpers.TryGetHighestMountedOfficialFile(Nor10_09_LayFileName, context.Game, out basegamePackagePath) || basegamePackagePath == null)
            {
                throw new Exception($"Could not find basegame file {Nor10_09_LayFileName}");
            }
            destinationPath = Path.Combine(context.CookedPCConsoleFolder, "Nor10_09", Nor10_09_LayFileName);
            File.Copy(basegamePackagePath, destinationPath);

            var layPcc = MEPackageHandler.OpenMEPackage(destinationPath);

            BuildNor10_09_LAYFile(layPcc);

            Console.WriteLine($"Building {Nor10_09_ArtFileName}");

            // I am getting the vanilla version of BIOA_NOR10_09_ART and copying it into my mod, then programatically modifying it
            if (!PackageHelpers.TryGetHighestMountedOfficialFile(Nor10_09_ArtFileName, context.Game, out basegamePackagePath) || basegamePackagePath == null)
            {
                throw new Exception($"Could not find basegame file {Nor10_09_ArtFileName}");
            }
            destinationPath = Path.Combine(context.CookedPCConsoleFolder, "Nor10_09", Nor10_09_ArtFileName);
            File.Copy(basegamePackagePath, destinationPath);

            var artPcc = MEPackageHandler.OpenMEPackage(destinationPath);

            BuildNor10_09_ArtFile(artPcc);
        }

        private static void BuildNor10_09_LAYFile(IMEPackage pcc)
        {
            // add the armor locker and port the lightmaps
            AddArmorLockerToLevel(pcc, true);

            // move desk, chair, lamp
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_3", new Vector3(-6450, 13338, -36832));
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_81", new Vector3(-6456, 13432, -36832));
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_82", new Vector3(-6398, 13439, -36758));

            pcc.Save();
        }

        private static void BuildNor10_09_ArtFile(IMEPackage pcc)
        {
            // move the screen that is for some reason in this file
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_1", new Vector3(-6454f, 13484f, -36702));

            pcc.Save();
        }


        private static void BuildNor10_09ROM_LAYFile(IMEPackage pcc)
        {
            // hide the screen over the desk that looks out of place with the lighting in this file
            var screen = pcc.FindExport("TheWorld.PersistentLevel.StaticMeshActor_1");
            screen.WriteProperty(new BoolProperty(true, "bHidden"));

            // move the desk, lamp, and chair over
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_3", new Vector3(-6455, 13338, -36832));
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_81", new Vector3(-6456, 13432, -36832));
            MoveStaticMeshActor(pcc, "TheWorld.PersistentLevel.StaticMeshActor_82", new Vector3(-6398, 13449, -36758));

            // port the armor locker in
            AddArmorLockerToLevel(pcc, false);

            pcc.Save();
        }

        private static void AddArmorLockerToLevel(IMEPackage pcc, bool portLightmaps)
        {
            // get the resource/donor file
            var armorLockerFile = MEPackageHandler.OpenMEPackage(@"Resources\LE1\NonStartup\ArmorLocker.pcc");
            var rop = new RelinkerOptionsPackage { Cache = new PackageCache() };

            var sequenceDonorEntry = armorLockerFile.FindExport("TheWorld.PersistentLevel.Main_Sequence.Armor_Station");
            var targetParent = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence");

            int numExports = pcc.ExportCount;

            EntryImporter.ImportAndRelinkEntries(EntryImporter.PortingOption.CloneAllDependencies, sequenceDonorEntry, pcc, targetParent, true, rop, out var newSequenceEntry);

            // add the new sequence to the parent sequence
            KismetHelper.AddObjectToSequence((ExportEntry)newSequenceEntry, targetParent, false);

            TryAddToPersistentLevel(pcc, pcc.Exports.Skip(numExports));

            //replace the lightmaps if applicable
            if (portLightmaps)
            {
                void replaceExport(string ifp)
                {
                    var source = armorLockerFile.FindExport(ifp);
                    var target = pcc.FindExport(ifp);

                    rop = new RelinkerOptionsPackage { Cache = new PackageCache() };

                    EntryImporter.ImportAndRelinkEntries(EntryImporter.PortingOption.ReplaceSingularWithRelink, source, pcc, target, true, rop, out _);
                }

                replaceExport("DirectionalMaxComponent0_3");
                replaceExport("NormalizedAverageColor0_3");
            }
        }

        private static void MoveStaticMeshActor(IMEPackage pcc, string ifp, Vector3 newPosition)
        {
            var sma = pcc.FindExport(ifp);
            sma.WriteProperty(new StructProperty("Vector", [
                    new FloatProperty(newPosition.X, "X"),
                        new FloatProperty(newPosition.Y, "Y"),
                        new FloatProperty(newPosition.Z, "Z")
                ],
                "Location", true));
        }

        // copied from LegendaryExplorer.Tools.PackageEditor.PackageEditorWindow
        private static bool TryAddToPersistentLevel(IMEPackage pcc, IEnumerable<IEntry> newEntries)
        {
            ExportEntry[] actorsToAdd = newEntries.OfType<ExportEntry>()
                .Where(exp => exp.Parent?.ClassName == "Level" && exp.IsA("Actor")).ToArray();
            int num = actorsToAdd.Length;
            if (num > 0 && pcc.AddToLevelActorsIfNotThere(actorsToAdd))
            {
                //MessageBox.Show(this,
                //    $"Added actor{(num > 1 ? "s" : "")} to PersistentLevel's Actor list:\n{actorsToAdd.Select(exp => exp.ObjectName.Instanced).StringJoin("\n")}");
                return true;
            }

            return false;
        }
    }
}
