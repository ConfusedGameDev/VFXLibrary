using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class EnergyVortexMeshes
    {
        public const int MaxParticles = 768;

        private const uint Seed = 183740;

        public static Mesh CreateGround()
        {
            return VfxVortexMeshes.CreateGround("EnergyVortexGround");
        }

        public static Mesh CreateDust()
        {
            return VfxVortexMeshes.CreateDust("EnergyVortexDust", Seed);
        }

        public static Mesh CreateColumn()
        {
            return VfxVortexMeshes.CreateColumn("EnergyVortexColumn", 18, 18, 5);
        }

        public static Mesh CreateParticles()
        {
            return VfxVortexMeshes.CreateParticles("EnergyVortexParticles", MaxParticles, Seed);
        }

        public static Mesh CreateDebris()
        {
            return VfxVortexMeshes.CreateDebris("EnergyVortexDebris", Seed);
        }
    }
}
