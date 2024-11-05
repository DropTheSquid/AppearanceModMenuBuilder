using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Textures;
using LegendaryExplorerCore.Unreal;
using LegendaryExplorerCore.Unreal.Classes;
using MassEffectModBuilder;

namespace AppearanceModMenuBuilder.LE1.BuildSteps.DLC
{
    internal class BuildMenuImages : IModBuilderTask
    {
        public void RunModTask(ModBuilderContext context)
        {
            Console.WriteLine("generating menu images");

            var imagesPackage = MEPackageHandler.CreateAndOpenPackage(Path.Combine(context.CookedPCConsoleFolder, "ModSetting_Images_AMM.pcc"), context.Game);

            // first, I need to read in all the images and make them textures in my file
            var textureFilePaths = Directory.GetFiles(@"Resources\LE1\NonStartup\menu images", "*.png");

            foreach (var filePath in textureFilePaths)
            {
                var name = Path.GetFileNameWithoutExtension(filePath).Replace(" ", "_") + "_I1";
                var exp = Texture2D.CreateTexture(imagesPackage, name, 1024, 512, PixelFormat.DXT5, false, null);

                var img = Image.LoadFromFile(filePath, PixelFormat.ARGB);
                var tex = new Texture2D(exp);
                tex.Replace(img, exp.GetProperties());
                // needed for it to not appear way too dark
                exp.WriteProperty(new BoolProperty(false, "SRGB"));
                Texture2D.CreateSWFForTexture(exp);
            }

            imagesPackage.Save();
        }
    }
}
