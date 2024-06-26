﻿namespace AppearanceModMenuBuilder.LE1.UScriptModels
{
    internal class LoadedSpecItem : SpecItemBase
    {
        public LoadedSpecItem(int id, string specPath) : base(id)
        {
            SpecPath = specPath;
        }

        public string SpecPath
        {
            get => GetString(nameof(SpecPath))!;
            set => SetString(nameof(SpecPath), value);
        }
    }
}
