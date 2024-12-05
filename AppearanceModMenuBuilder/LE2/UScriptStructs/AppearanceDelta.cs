using MassEffectModBuilder.Models;

namespace AppearanceModMenuBuilder.LE2.UScriptStructs
{
    public class AppearanceDelta : StructCoalesceValue
    {
        public abstract class ParameterDelta : StructCoalesceValue 
        {
            public string? ParameterName
            {
                get => GetString(nameof(ParameterName));
                set => SetString(nameof(ParameterName), value);
            }

            public bool? BRemove
            {
                get => GetBool(nameof(BRemove));
                set => SetBool(nameof(BRemove), value);
            }
        }
        public class TextureParameterDelta : ParameterDelta
        {
            public string? Texture
            {
                get => GetString(nameof(Texture));
                set => SetString(nameof(Texture), value);
            }
        }

        public class ColorDelta : StructCoalesceValue
        {
            public string? R
            {
                get => GetString(nameof(R));
                set => SetString(nameof(R), value);
            }

            public string? G
            {
                get => GetString(nameof(G));
                set => SetString(nameof(G), value);
            }

            public string? B
            {
                get => GetString(nameof(B));
                set => SetString(nameof(B), value);
            }

            public string? A
            {
                get => GetString(nameof(A));
                set => SetString(nameof(A), value);
            }
        }

        public class VectorParameterDelta : ParameterDelta
        {
            public ColorDelta? Value
            {
                get => GetStruct<ColorDelta>(nameof(Value));
                set => SetStruct(nameof(Value), value);
            }
        }

        public class ScalarParameterDelta : ParameterDelta
        {
            public string? Value
            {
                get => GetString(nameof(Value));
                set => SetString(nameof(Value), value);
            }
        }

        public class VectorDelta : StructCoalesceValue
        {
            public string? X
            {
                get => GetString(nameof(X));
                set => SetString(nameof(X), value);
            }

            public string? Y
            {
                get => GetString(nameof(Y));
                set => SetString(nameof(Y), value);
            }

            public string? Z
            {
                get => GetString(nameof(Z));
                set => SetString(nameof(Z), value);
            }
        }

        public class OffsetBoneDelta : StructCoalesceValue
        {
            public VectorDelta? Offset
            {
                get => GetStruct<VectorDelta>(nameof(Offset));
                set => SetStruct(nameof(Offset), value);
            }

            public string? BoneName
            {
                get => GetString(nameof(BoneName));
                set => SetString(nameof(BoneName), value);
            }

            public bool? BRemove
            {
                get => GetBool(nameof(BRemove));
                set => SetBool(nameof(BRemove), value);
            }
        }

        public class MorphFeatureDelta : StructCoalesceValue
        {
            public string? Offset
            {
                get => GetString(nameof(Offset));
                set => SetString(nameof(Offset), value);
            }

            public string? Feature
            {
                get => GetString(nameof(Feature));
                set => SetString(nameof(Feature), value);
            }

            public bool? BRemove
            {
                get => GetBool(nameof(BRemove));
                set => SetBool(nameof(BRemove), value);
            }
        }

        public class MeshDelta : StructCoalesceValue
        {
            public string? MeshOrSpecName
            {
                get => GetString(nameof(MeshOrSpecName));
                set => SetString(nameof(MeshOrSpecName), value);
            }

            public bool? BRemove
            {
                get => GetBool(nameof(BRemove));
                set => SetBool(nameof(BRemove), value);
            }
        }

        public MeshDelta? HairMesh
        {
            get => GetStruct<MeshDelta>(nameof(HairMesh));
            set => SetStruct(nameof(HairMesh), value);
        }

        public MeshDelta? HeadMesh
        {
            get => GetStruct<MeshDelta>(nameof(HeadMesh));
            set => SetStruct(nameof(HeadMesh), value);
        }

        public StructArrayCoalesceValue<VectorParameterDelta> VectorParameterDeltas
        {
            get => GetStructArray<VectorParameterDelta>(nameof(VectorParameterDelta)) ?? [];
            set => SetStructArray(nameof(VectorParameterDelta), value);
        }

        public StructArrayCoalesceValue<OffsetBoneDelta> OffsetBoneDeltas
        {
            get => GetStructArray<OffsetBoneDelta>(nameof(OffsetBoneDeltas)) ?? [];
            set => SetStructArray(nameof(OffsetBoneDeltas), value);
        }

        public StructArrayCoalesceValue<MorphFeatureDelta> MorphFeatureDeltas
        {
            get => GetStructArray<MorphFeatureDelta>(nameof(MorphFeatureDeltas)) ?? [];
            set => SetStructArray(nameof(MorphFeatureDeltas), value);
        }

        public StructArrayCoalesceValue<ScalarParameterDelta> ScalarParameterDeltas
        {
            get => GetStructArray<ScalarParameterDelta>(nameof(ScalarParameterDeltas)) ?? [];
            set => SetStructArray(nameof(ScalarParameterDeltas), value);
        }

        public StructArrayCoalesceValue<TextureParameterDelta> TextureParameterDeltas
        {
            get => GetStructArray<TextureParameterDelta>(nameof(TextureParameterDeltas)) ?? [];
            set => SetStructArray(nameof(TextureParameterDeltas), value);
        }
    }
}
