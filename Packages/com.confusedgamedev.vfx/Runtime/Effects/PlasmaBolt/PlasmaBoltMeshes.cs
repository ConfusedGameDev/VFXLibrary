using System;
using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class PlasmaBoltMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 18374;
        private const int CoreRings = 12;
        private const int CoreSides = 8;
        private const int ImpactParts = 30;

        private static readonly Bounds EffectBounds = VfxMeshes.ProjectileBounds;

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("PlasmaBoltParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateHalo()
        {
            return VfxMeshes.CreateQuads("PlasmaBoltHalo", 1, EffectBounds);
        }

        /// <summary>The volumetric tip. Its radius wobbles per vertex, as in the source.</summary>
        public static Mesh CreateCore()
        {
            var builder = new VfxMeshBuilder();
            for (int ring = 0; ring <= CoreRings; ring++)
            {
                for (int side = 0; side <= CoreSides; side++)
                {
                    float h = (float)ring / CoreRings;
                    float a = (float)side / CoreSides * Mathf.PI * 2f;
                    float r = 0.16f * Mathf.Pow(Mathf.Sin(h * Mathf.PI), 0.8f) * (1f + 0.32f * Mathf.Sin(ring * 2.7f + side * 1.9f));
                    builder.AddVertex(new Vector3((h * 2f - 1f) * 0.85f, Mathf.Cos(a) * r, Mathf.Sin(a) * r), new Vector2(h, (float)side / CoreSides));
                }
            }

            for (int ring = 0; ring < CoreRings; ring++)
            {
                for (int side = 0; side < CoreSides; side++)
                {
                    int n = ring * (CoreSides + 1) + side;
                    builder.AddIndices(n, n + 1, n + CoreSides + 1, n + 1, n + CoreSides + 2, n + CoreSides + 1);
                }
            }

            return builder.Build("PlasmaBoltCore", EffectBounds);
        }

        public static Mesh CreateTrails()
        {
            return Ribbons("PlasmaBoltTrails", 5, 1);
        }

        public static Mesh CreateEnvelope()
        {
            return Ribbons("PlasmaBoltEnvelope", 6, 2);
        }

        /// <summary>Twelve bolts, twelve forks and six sparks in one draw.</summary>
        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            for (int id = 0; id < ImpactParts; id++)
            {
                int steps = id < 12 ? 6 : id < 24 ? 3 : 1;
                builder.AddStrip(steps, (h, side) => new Vector3(h, side, 0f), part: id);
            }
            return builder.Build("PlasmaBoltImpact", EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("PlasmaBoltGlow", 1, EffectBounds, 2.4f);
        }

        // Each ribbon stores its height, id and side as a position. Role 1 is a short fork, flagged in UV1.
        private static Mesh Ribbons(string name, int ribbons, int roles)
        {
            var builder = new VfxMeshBuilder();
            for (int id = 0; id < ribbons; id++)
            {
                for (int role = 0; role < roles; role++)
                {
                    int ribbon = id;
                    builder.AddStrip(role > 0 ? 10 : 32, (h, side) => new Vector3(h, ribbon, side), new Vector4(role, 0f, 0f, 0f));
                }
            }
            return builder.Build(name, EffectBounds);
        }
    }
}
