using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class PulseBeamMeshes
    {
        public const int MaxParticles = 512;
        public const int MaxRings = 12;

        private const uint Seed = 55122;

        public static Mesh CreateBody()
        {
            return VfxMeshes.CreateBeamTube("PulseBeamBody", 0.12f, 12, 48);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("PulseBeamParticles", MaxParticles, VfxMeshes.BeamBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateRings()
        {
            var ring = new VfxMeshBuilder();
            ring.AddPatch(5, 32, (u, v) =>
            {
                float a = u * Mathf.PI * 2f;
                float b = v * Mathf.PI * 2f;
                float r = 0.26f + 0.012f * Mathf.Cos(b);
                return new Vector3(0.012f * Mathf.Sin(b), r * Mathf.Sin(a), r * Mathf.Cos(a));
            });
            return VfxMeshBuilder.Instance("PulseBeamRings", ring, VfxMeshes.CreateSeeds(MaxRings, Seed, 1), VfxMeshes.BeamBounds);
        }

        public static Mesh CreateFlares()
        {
            return VfxMeshes.CreateBeamFlares("PulseBeamFlares", 1f, 1.4f);
        }

        public static Mesh CreateDiscs()
        {
            return VfxMeshes.CreateBeamDiscs("PulseBeamDiscs");
        }
    }
}
