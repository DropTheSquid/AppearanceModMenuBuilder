using LegendaryExplorerCore.Kismet;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Unreal;
using MassEffectModBuilder;
using MassEffectModBuilder.DLCTasks;
using MassEffectModBuilder.LEXHelpers;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    internal class BuildUIWorldTask : IModBuilderTask
    {
        const string UIWorldFileName = "BIOG_UIWorld.pcc";
        public void RunModTask(ModBuilderContext context)
        {
            // I am getting the vanilla version of BIOG_UIWorld and copying it into my mod, then programatically modifying it
            if (!PackageHelpers.TryGetHighestMountedOfficialFile(UIWorldFileName, context.Game, out var packagePath) || packagePath == null)
            {
                throw new Exception($"Could not find basegame file {UIWorldFileName}");
            }
            // this is how I would get the Mello/other mod version if installed
            //if (MELoadedFiles.TryGetHighestMountedFile(context.Game, UIWorldFileName, out string packagePath))
            //{

            //}
            var destinationPath = Path.Combine(context.CookedPCConsoleFolder, UIWorldFileName);
            File.Copy(packagePath, destinationPath);

            var pcc = MEPackageHandler.OpenMEPackage(destinationPath);

            // add the basegame class I need in
            var mergeClassTask = new AddMergeClassesToFile("SFXGame.pcc", "AMM_AppearanceUpdater_Base", _ => pcc);
            mergeClassTask.RunModTask(context);

            // add the new class I need
            var AddClassTask = new AddClassesToFile(_ => pcc, LooseClassCompile.GetClassFromFile(@"Resources\LE1\Shared\Mod_GameContent\ModSeqAct_UpdatePawnAppearance.uc", ["Mod_GameContent"]));
            AddClassTask.RunModTask(context);

            var mainSeq = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence");

            // adds a new remote event to this file/sequence
            ExportEntry AddRemoteEvent(string eventName, string? comment = null)
            {
                // create the remote event
                var newRE = SequenceObjectCreator.CreateSequenceObject(pcc, "SeqEvent_RemoteEvent");
                // add it to the sequence
                KismetHelper.AddObjectToSequence(newRE, mainSeq);
                // set the event name
                newRE.WriteProperty(new NameProperty(eventName, "EventName"));
                // optionally write a comment
                if (!string.IsNullOrWhiteSpace(comment))
                {
                    KismetHelper.SetComment(newRE, comment);
                }
                return newRE;
            }

            ExportEntry FindRemoteEvent(string expectedEventName, string? ifp = null, bool canFail = false)
            {
                bool IsDesiredRemoteEvent(ExportEntry entry)
                {
                    if (entry.ClassName != "SeqEvent_RemoteEvent")
                    {
                        return false;
                    }
                    var eventNameProp = entry.GetProperty<NameProperty>("EventName");
                    if (eventNameProp?.Value.Name == expectedEventName)
                    {
                        return true;
                    }
                    return false;
                }
                if (!string.IsNullOrEmpty(ifp))
                {
                    var candidate = pcc.FindExport(ifp);
                    if (candidate == null)
                    {
                        Console.WriteLine($"Warning: could not find remote event at ifp {ifp}; searching by eventName instead");
                    }
                    else
                    {
                        if (IsDesiredRemoteEvent(candidate))
                        {
                            return candidate;
                        }
                        else
                        {
                            Console.WriteLine($"Warning: Export at ifp {ifp} was not the remote event for {expectedEventName}");
                        }
                    }
                }
                foreach (var export in pcc.Exports)
                {
                    if (IsDesiredRemoteEvent(export))
                    {
                        return export;
                    }
                }
                if (canFail)
                {
                    return null;
                }
                throw new Exception($"Could not find remote event {expectedEventName}");
            }

            ExportEntry AddPawnAppearanceUpdateSeqAct(ExportEntry triggeringRE, params ExportEntry[] targets)
            {
                // create a new SequenceObject, add it to the parent sequence
                var newSeqAct = SequenceObjectCreator.CreateSequenceObject(pcc, "ModSeqAct_UpdatePawnAppearance");
                KismetHelper.AddObjectToSequence(newSeqAct, mainSeq);
                // link a remote event to trigger this
                KismetHelper.CreateOutputLink(triggeringRE, "Out", newSeqAct);
                // link it to one or more targets
                foreach (var target in targets)
                {
                    KismetHelper.CreateVariableLink(newSeqAct, "Target", target);
                }

                return newSeqAct;
            }

            // add a sequence action to update whenever the character record changes is set up/changes characters
            AddPawnAppearanceUpdateSeqAct(
                FindRemoteEvent("SetupCharRec", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_16"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_5"));

            // same for inventory
            var inventoryUpdateSeqAct = AddPawnAppearanceUpdateSeqAct(
                FindRemoteEvent("SetupInventory", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_12"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_0"));

            // also connect the ForceTexture RemoteEvent to trigger inventory appearance update
            var RE_ForceTexture = FindRemoteEvent("ForceTexture", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_19");
            KismetHelper.CreateOutputLink(RE_ForceTexture, "Out", inventoryUpdateSeqAct);

            // and Character Creation, which has several different pawns for no good reason
            var charCreateSeqAct = AddPawnAppearanceUpdateSeqAct(
                FindRemoteEvent("SetupCharCreate", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_22"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_8"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_31"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_33"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_30"));

            // new remote event to trigger appearance update for character creation on demand
            var RE_UpdateCC = AddRemoteEvent("re_amm_update_cc", "updates the character create pawn(s)");
            KismetHelper.CreateOutputLink(RE_UpdateCC, "Out", charCreateSeqAct);

            // new remote event to trigger the camera position update for inventory setup
            var cameraInterp = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqAct_Interp_2") 
                ?? throw new Exception("Could not find camera interp in UI world to hook up to");
            var RE_UpdateCamera = AddRemoteEvent("re_AMM_UpdateCameraPosition", "updates the camera position");
            KismetHelper.CreateOutputLink(RE_UpdateCamera, "Out", cameraInterp, 0);

            // new remote events to update the preview pawn's armor override state
            var RE_ArmorOverrideOn = AddRemoteEvent("re_AMM_ArmorOverrideOn", "updates the preview pawn's armor override to true");
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOn, "Out", inventoryUpdateSeqAct, 1);
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOn, "Out", inventoryUpdateSeqAct, 0);

            var RE_ArmorOverrideOff = AddRemoteEvent("re_AMM_ArmorOverrideOff", "updates the preview pawn's armor override to false");
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOff, "Out", inventoryUpdateSeqAct, 2);
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOff, "Out", inventoryUpdateSeqAct, 0);

            // new remote event to just update inventory/AMM preview pawn appearance
            var RE_Update = AddRemoteEvent("re_AMM_update_Appearance", "updates the preview pawn's appearance in AMM");
            KismetHelper.CreateOutputLink(RE_Update, "Out", inventoryUpdateSeqAct, 0);

            // hide the ugly black rectangle under the pawn's feet
            var pedestalStaticMesh = pcc.FindExport("TheWorld.PersistentLevel.InterpActor_2.StaticMeshComponent_3")
                ?? throw new Exception("Could not find pedestal static mesh in UI world to hide");
            pedestalStaticMesh.WriteProperty(new BoolProperty(true, "HiddenGame"));

            pcc.Save();
        }
    }
}
