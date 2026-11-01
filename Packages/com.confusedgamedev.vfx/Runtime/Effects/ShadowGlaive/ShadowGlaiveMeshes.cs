using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ShadowGlaiveMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 372168;

        private static readonly Bounds EffectBounds = VfxMeshes.ProjectileBounds;

        public static Mesh CreateTrail()
        {
            return VfxMeshes.CreateSchoolTrail("ShadowGlaiveTrail", 3);
        }

        /// <summary>The blade and three copies of it, told apart by their id and phase.</summary>
        public static Mesh CreateBody()
        {
            var builder = new VfxMeshBuilder();
            for (int k = 0; k < 4; k++)
            {
                builder.AddSurface(40, 6, (u, v) =>
                {
                    float a = (u - 0.5f) * 4.9f;
                    float b = v * Mathf.PI * 2f;
                    float bulge = Mathf.Sin(u * Mathf.PI);
                    float r = 0.72f + Mathf.Cos(b) * bulge * 0.18f;
                    return new Vector3(Mathf.Sin(a) * r, Mathf.Cos(a) * r - 0.2f, Mathf.Sin(b) * 0.16f * bulge);
                }, new Vector4(k * 0.5f, 0f, 0f, 0f), k);
            }
            builder.ComputeNormals();
            return builder.Build("ShadowGlaiveBody", EffectBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ShadowGlaiveParticles", MaxParticles, EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateImpact()
        {
            var builder = new VfxMeshBuilder();
            for (int i = 0; i < 3; i++)
            {
                int blade = i;
                builder.AddPatch(4, 24, (u, v) =>
                {
                    float a = (u - 0.5f) * 1.8f + blade * 0.25f;
                    float r = 0.55f + blade * 0.16f + v * 0.16f * Mathf.Sin(u * Mathf.PI);
                    return new Vector3((blade - 1) * 0.24f + u * 0.65f + v * 0.09f, Mathf.Cos(a) * r - 0.6f, Mathf.Sin(a) * r);
                }, part: i);
            }
            return builder.Build("ShadowGlaiveImpact", EffectBounds);
        }

        public static Mesh CreateGlow()
        {
            return VfxMeshes.CreateQuads("ShadowGlaiveGlow", 1, EffectBounds, 1.8f);
        }
    }
}
