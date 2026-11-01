using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class HealingFieldMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 82683;

        public static Mesh CreateAura()
        {
            return VfxGroundMeshes.CreateFlat("HealingFieldAura", 4.8f);
        }

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("HealingFieldSigil", 4.5f);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("HealingFieldParticles", MaxParticles, Seed);
        }
    }
}
