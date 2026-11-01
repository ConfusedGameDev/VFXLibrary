using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class FrostFieldMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 101057;

        public static Mesh CreateAura()
        {
            return VfxGroundMeshes.CreateFlat("FrostFieldAura", 4.8f);
        }

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("FrostFieldSigil", 4.5f);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("FrostFieldParticles", MaxParticles, Seed);
        }
    }
}
