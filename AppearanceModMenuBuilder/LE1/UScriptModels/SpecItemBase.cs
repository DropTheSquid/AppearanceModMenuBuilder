﻿using MassEffectModBuilder.Models;

namespace AppearanceModMenuBuilder.LE1.UScriptModels
{
    public abstract class SpecItemBase : StructCoalesceValue
    {
        public SpecItemBase(int id)
        {
            Id = id;
        }

        public int Id
        {
            get => (int)GetInt(nameof(Id))!;
            set => SetInt(nameof(Id), value);
        }
    }
}
