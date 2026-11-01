using System.Collections.Generic;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class FireExplosionMeshes
    {
        public const int MaxParticles = 256;

        private const uint Seed = 119431;

        private static readonly int[] Maxima = { 256 };
        private static readonly float[] Weights = { 1f };

        /// <summary>Instances per layer for a density, split the way the source splits its budget.</summary>
        public static Vector4 LayerCounts(float density)
        {
            return VfxBurstMeshes.LayerCounts(MaxParticles, 0, density, Maxima, Weights);
        }

        public static Mesh CreateVolume()
        {
            var builder = new VfxMeshBuilder();
            var seeds = new List<Vector4>();
            var layout = new Layout();
            for (int id = 0; id < 18; id++)
            {
                builder.AddSphere(24, 18, Vector3.one, layout.Lobes[id]);
                while (seeds.Count < builder.VertexCount)
                {
                    seeds.Add(layout.LobeSeeds[id]);
                }
            }

            Mesh mesh = builder.Build("FireExplosionVolume", VfxBurstMeshes.EffectBounds);
            mesh.SetUVs(3, seeds);
            return mesh;
        }

        public static Mesh CreateHalo()
        {
            var builder = new VfxMeshBuilder();
            var layout = new Layout();
            for (int id = 0; id < 19; id++)
            {
                int lobe = id;
                Vector4 center = id < 18 ? layout.Lobes[id] : new Vector4(0f, 1.15f, 0f, 1.9f);
                builder.AddPatch(1, 1, (u, v) => Vector3.zero, center, lobe);
            }
            return builder.Build("FireExplosionHalo", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateGround()
        {
            var builder = new VfxMeshBuilder();
            builder.AddPatch(1, 1, (u, v) => Vector3.zero, default, 0f);
            for (int id = 1; id < 5; id++)
            {
                builder.AddPatch(4, 128, (u, v) => Vector3.zero, default, id);
            }
            return builder.Build("FireExplosionGround", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateTrails()
        {
            var builder = new VfxMeshBuilder();
            var layout = new Layout();
            for (int id = 0; id < 11; id++)
            {
                builder.AddPatch(4, 32, (u, v) => Vector3.zero, layout.TrailSeeds[id]);
            }
            return builder.Build("FireExplosionTrails", VfxBurstMeshes.EffectBounds);
        }

        public static Mesh CreateEmbers()
        {
            return VfxMeshes.CreateQuads("FireExplosionEmbers", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed, 0));
        }

        // One random stream feeds every piece, in the order the source draws from it.
        private sealed class Layout
        {
            public readonly Vector4[] Lobes = new Vector4[18];
            public readonly Vector4[] LobeSeeds = new Vector4[18];
            public readonly Vector4[] TrailSeeds = new Vector4[11];
            private uint state = Seed;

            public Layout()
            {
                for (int id = 0; id < 18; id++)
                {
                    bool lower = id < 8;
                    bool middle = id < 15;
                    double angle = id * 2.399963 + Next() * 0.35;
                    double radius = lower ? 1.12 + Next() * 0.2 : middle ? 0.75 + Next() * 0.25 : 0.35;
                    double height = lower ? 0.61 + Next() * 0.13 : middle ? 1.22 + Next() * 0.18 : 1.75 + Next() * 0.2;
                    double size = lower ? 0.69 + Next() * 0.18 : middle ? 0.65 + Next() * 0.18 : 0.65 + Next() * 0.15;
                    Lobes[id] = new Vector4((float)(System.Math.Cos(angle) * radius), (float)height, (float)(System.Math.Sin(angle) * radius), (float)size);
                    LobeSeeds[id] = new Vector4((float)Next(), (float)Next(), (float)Next(), id);
                }

                // The halo and ground patches draw seeds their shaders never read.
                for (int i = 0; i < (19 + 5) * 3; i++)
                {
                    Next();
                }

                for (int id = 0; id < TrailSeeds.Length; id++)
                {
                    TrailSeeds[id] = new Vector4(id, (float)Next(), (float)Next(), (float)Next());
                }
            }

            private double Next()
            {
                state = unchecked(state * 1664525u + 1013904223u);
                return state / 4294967296.0;
            }
        }
    }
}
