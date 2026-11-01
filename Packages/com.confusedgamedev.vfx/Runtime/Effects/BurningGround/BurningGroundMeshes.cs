using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class BurningGroundMeshes
    {
        public const int MaxParticles = 1024;

        private const uint Seed = 91870;

        public static Mesh CreateAura()
        {
            return VfxGroundMeshes.CreateFlat("BurningGroundAura", 4.8f);
        }

        public static Mesh CreateSigil()
        {
            return VfxGroundMeshes.CreateFlat("BurningGroundSigil", 4.5f);
        }

        public static Mesh CreateParticles()
        {
            return VfxGroundMeshes.CreateParticles("BurningGroundParticles", MaxParticles, Seed);
        }
    }
}
