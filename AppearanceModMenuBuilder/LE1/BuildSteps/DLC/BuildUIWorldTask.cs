﻿using LegendaryExplorerCore.Kismet;
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
            Console.WriteLine("Building BIOG_UIWorld.pcc");

            var destinationPath = Path.Combine(context.CookedPCConsoleFolder, UIWorldFileName);

            var LE1WorkspaceRoot = Directory.GetParent(context.ModOutputPathBase)!.FullName;

            string sourceFilePath;

            // if Mello is present in the mod library, base my version on this file
            if (Directory.Exists(Path.Combine(LE1WorkspaceRoot, "ME¹LLO")))
            {
                sourceFilePath = Path.Combine(LE1WorkspaceRoot, @"ME¹LLO\DLC_MOD_MELLO\CookedPCConsole\Main-Core\UIWorld\BIOG_UIWorld.pcc");
            }
            // otherwise, fall back to basegame version
            else
            {
                Console.WriteLine("Warning: Mello does not seem to be in the mod library. falling back to basegame version of UIWorld.");
                PackageHelpers.TryGetHighestMountedOfficialFile(UIWorldFileName, context.Game, out sourceFilePath);
            }

            if (string.IsNullOrWhiteSpace(sourceFilePath))
            {
                throw new Exception($"Could not find source file {UIWorldFileName}");
            }

            //Directory.CreateDirectory(Path.Combine(context.ModOutputPathBase, $@"Compat\Mello"));

            File.Copy(sourceFilePath, destinationPath);

            var UIWorld_AMM_file = MEPackageHandler.OpenMEPackage(destinationPath);

            BuildUIWorldFile(UIWorld_AMM_file, context);
        }

        private static void BuildUIWorldFile(IMEPackage pcc, ModBuilderContext context)
        {
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

            var InventoryPawnSeqVar = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_0");
            var CharRecPawnSeqVar = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_5");
            ExportEntry[] CharCreateSeqVars = [
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_8"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_31"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_32"),
                pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqVar_Object_30")
                ];

            // add a sequence action to update whenever the character record changes is set up/changes characters
            var charRecUpdateSequenceAct = AddPawnAppearanceUpdateSeqAct(
                // add a new RemoteEvent to update the character record pawn
                AddRemoteEvent("re_AMM_update_CharRec_Appearance", "updates the current character record pawn"),
                CharRecPawnSeqVar);

            // same for inventory
            var inventoryUpdateSeqAct = AddPawnAppearanceUpdateSeqAct(
                FindRemoteEvent("SetupInventory", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_12"),
                InventoryPawnSeqVar);

            // also connect the ForceTexture RemoteEvent to trigger inventory appearance update
            var RE_ForceTexture = FindRemoteEvent("ForceTexture", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_19");
            KismetHelper.CreateOutputLink(RE_ForceTexture, "Out", inventoryUpdateSeqAct);

            // and Character Creation, which has several different pawns for no good reason
            // new remote event to trigger appearance update for character creation on demand
            var charCreateSeqAct = AddPawnAppearanceUpdateSeqAct(
                AddRemoteEvent("re_amm_update_cc", "updates the character create pawn(s)"),
                CharCreateSeqVars);

            // and hook this up to the camera init re to catch the first appearance
            var RE_CCCameraInit = FindRemoteEvent("CharCreateInitCamera", "TheWorld.PersistentLevel.Main_Sequence.SeqEvent_RemoteEvent_18");
            KismetHelper.CreateOutputLink(RE_CCCameraInit, "Out", charCreateSeqAct);

            // new remote event to trigger the camera position update for inventory setup
            var cameraInterp = pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.SeqAct_Interp_2")
                ?? throw new Exception("Could not find camera interp in UI world to hook up to");
            var RE_UpdateCamera = AddRemoteEvent("re_AMM_UpdateCameraPosition", "updates the camera position");
            KismetHelper.CreateOutputLink(RE_UpdateCamera, "Out", cameraInterp, 0);

            // new remote events to update the preview pawn's armor override state
            var RE_ArmorOverrideOn = AddRemoteEvent("re_AMM_NonCombat", "updates the preview pawn's armor override to true and removes weapons");
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOn, "Out", inventoryUpdateSeqAct, 1);
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOn, "Out", inventoryUpdateSeqAct, 0);

            var RE_ArmorOverrideOff = AddRemoteEvent("re_AMM_Combat", "updates the preview pawn's armor override to false and adds weapons, if applicable");
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOff, "Out", inventoryUpdateSeqAct, 2);
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOff, "Out", inventoryUpdateSeqAct, 0);

            // also wire the above REs up to seqActs that shows/hides weapons weapons
            var HideWeaponsAct = SequenceObjectCreator.CreateSequenceObject(pcc, "BioSeqAct_HideAllWeapons");
            var ShowWeaponsAct = SequenceObjectCreator.CreateSequenceObject(pcc, "BioSeqAct_HideAllWeapons");
            KismetHelper.AddObjectToSequence(HideWeaponsAct, mainSeq);
            KismetHelper.AddObjectToSequence(ShowWeaponsAct, mainSeq);
            var seqVarFalse = SequenceObjectCreator.CreateSequenceObject(pcc, "SeqVar_Bool");
            var seqVarTrue = SequenceObjectCreator.CreateSequenceObject(pcc, "SeqVar_Bool");
            KismetHelper.AddObjectToSequence(seqVarFalse, mainSeq);
            KismetHelper.AddObjectToSequence(seqVarTrue, mainSeq);
            seqVarFalse.WriteProperty(new IntProperty(0, "bValue"));
            seqVarTrue.WriteProperty(new IntProperty(1, "bValue"));
            KismetHelper.CreateVariableLink(HideWeaponsAct, "ShouldHideWeapons", seqVarTrue);
            KismetHelper.CreateVariableLink(ShowWeaponsAct, "ShouldHideWeapons", seqVarFalse);
            KismetHelper.CreateVariableLink(ShowWeaponsAct, "Pawns", InventoryPawnSeqVar);
            KismetHelper.CreateVariableLink(HideWeaponsAct, "Pawns", InventoryPawnSeqVar);

            KismetHelper.CreateOutputLink(RE_ArmorOverrideOff, "Out", ShowWeaponsAct);
            KismetHelper.CreateOutputLink(RE_ArmorOverrideOn, "Out", HideWeaponsAct);

            // new remote event to just update inventory/AMM preview pawn appearance
            var RE_Update = AddRemoteEvent("re_AMM_update_Appearance", "updates the preview pawn's appearance in AMM");
            KismetHelper.CreateOutputLink(RE_Update, "Out", inventoryUpdateSeqAct, 0);

            // a few new things to force the character record pawn into casual appearance
            var RE_CharRecCasual = AddRemoteEvent("re_AMM_charRec_Casual", "updates the character record preview pawn's appearance to be casual");
            var RE_CharRecCombat = AddRemoteEvent("re_AMM_charRec_Combat", "updates the character record preview pawn's appearance to be combat");
            KismetHelper.AddObjectToSequence(RE_CharRecCasual, mainSeq);
            KismetHelper.AddObjectToSequence(RE_CharRecCombat, mainSeq);
            var charRecHideWeaponsAct = SequenceObjectCreator.CreateSequenceObject(pcc, "BioSeqAct_HideAllWeapons");
            var charRecShowWeaponsAct = SequenceObjectCreator.CreateSequenceObject(pcc, "BioSeqAct_HideAllWeapons");
            KismetHelper.AddObjectToSequence(charRecHideWeaponsAct, mainSeq);
            KismetHelper.AddObjectToSequence(charRecShowWeaponsAct, mainSeq);
            KismetHelper.CreateVariableLink(charRecHideWeaponsAct, "ShouldHideWeapons", seqVarTrue);
            KismetHelper.CreateVariableLink(charRecShowWeaponsAct, "ShouldHideWeapons", seqVarFalse);
            KismetHelper.CreateVariableLink(charRecShowWeaponsAct, "Pawns", CharRecPawnSeqVar);
            KismetHelper.CreateVariableLink(charRecHideWeaponsAct, "Pawns", CharRecPawnSeqVar);

            KismetHelper.CreateOutputLink(RE_CharRecCombat, "Out", charRecShowWeaponsAct);
            KismetHelper.CreateOutputLink(RE_CharRecCasual, "Out", charRecHideWeaponsAct);
            KismetHelper.CreateOutputLink(RE_CharRecCasual, "Out", charRecUpdateSequenceAct, 1);
            KismetHelper.CreateOutputLink(RE_CharRecCombat, "Out", charRecUpdateSequenceAct, 2);

            // connect the Done output of TheWorld.PersistentLevel.Main_Sequence.BioSeqAct_Delay_5 to the charRec appearance update
            KismetHelper.CreateOutputLink(pcc.FindExport("TheWorld.PersistentLevel.Main_Sequence.BioSeqAct_Delay_5"), "Finished", charRecUpdateSequenceAct, 0);

            // hide the ugly black rectangle under the pawn's feet
            var pedestalStaticMesh = pcc.FindExport("TheWorld.PersistentLevel.InterpActor_2.StaticMeshComponent_3")
                ?? throw new Exception("Could not find pedestal static mesh in UI world to hide");
            pedestalStaticMesh.WriteProperty(new BoolProperty(true, "HiddenGame"));

            // add a few things to set the character's rotation
            var RE_SetRotation = AddRemoteEvent("re_AMM_SetRotation", "updates the preview pawn's rotation");
            var setLocationAct = SequenceObjectCreator.CreateSequenceObject(pcc, "SeqAct_SetLocation");
            setLocationAct.WriteProperty(new BoolProperty(false, "bSetLocation"));
            KismetHelper.CreateVariableLink(setLocationAct, "Target", InventoryPawnSeqVar);
            KismetHelper.AddObjectToSequence(setLocationAct, mainSeq);
            KismetHelper.CreateOutputLink(RE_SetRotation, "Out", setLocationAct);

            // add some sequence to add/remove the idle animations depending on the zoom level
            //var RE_ZoomedIn = AddRemoteEvent("re_AMM_ZoomedIn", "removes some animations from the preview character when we zoom in");
            //var RE_ZoomedOut = AddRemoteEvent("re_AMM_ZoomedOut", "adds animations to the character when we zoom out");

            //ExportEntry AddAnimNode(string targetNode, ExportEntry targetPawn, float weight, float blendTime, int nTargetChild)
            //{
            //    var animNodeBlend = SequenceObjectCreator.CreateSequenceObject(pcc, "BioSeqAct_SetAnimNodeBlend");
            //    KismetHelper.CreateVariableLink(animNodeBlend, "Pawn", targetPawn);
            //    KismetHelper.AddObjectToSequence(animNodeBlend, mainSeq);

            //    animNodeBlend.WriteProperty(new NameProperty(targetNode, "nmTargetNode"));
            //    animNodeBlend.WriteProperty(new IntProperty(nTargetChild, "nTargetChild"));
            //    animNodeBlend.WriteProperty(new FloatProperty(weight, "fWeight"));
            //    animNodeBlend.WriteProperty(new FloatProperty(blendTime, "fBlendTime"));
            //    return animNodeBlend;
            //}

            //KismetHelper.CreateOutputLink(RE_ZoomedIn, "Out", AddAnimNode("AddWeightShifts", InventoryPawnSeqVar, 1.0f, 1.4f, 0));
            //KismetHelper.CreateOutputLink(RE_ZoomedIn, "Out", AddAnimNode("IdleZoomed", InventoryPawnSeqVar, 1.0f, 1.4f, 1));
            //KismetHelper.CreateOutputLink(RE_ZoomedIn, "Out", AddAnimNode("AddIdle", InventoryPawnSeqVar, 1.0f, 1.4f, 0));

            //KismetHelper.CreateOutputLink(RE_ZoomedOut, "Out", AddAnimNode("AddWeightShifts", InventoryPawnSeqVar, 1.0f, 0.5f, 1));
            //KismetHelper.CreateOutputLink(RE_ZoomedOut, "Out", AddAnimNode("IdleZoomed", InventoryPawnSeqVar, 1.0f, 0.5f, 0));
            //KismetHelper.CreateOutputLink(RE_ZoomedOut, "Out", AddAnimNode("AddIdle", InventoryPawnSeqVar, 1.0f, 0.5f, 1));


            pcc.Save();
        }
    }
}
