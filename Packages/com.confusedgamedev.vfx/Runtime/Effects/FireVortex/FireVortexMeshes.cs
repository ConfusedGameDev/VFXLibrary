using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class FireVortexMeshes
    {
        public const int MaxParticles = 1024;

        private const uint Seed = 174553;

        public static Mesh CreateGround()
        {
            return VfxVortexMeshes.CreateGround("FireVortexGround");
        }

        public static Mesh CreateDust()
        {
            return VfxVortexMeshes.CreateDust("FireVortexDust", Seed);
        }

        public static Mesh CreateColumn()
        {
            return VfxVortexMeshes.CreateColumn("FireVortexColumn", 22, 20, 6);
        }

        public static Mesh CreateParticles()
        {
            return VfxVortexMeshes.CreateParticles("FireVortexParticles", MaxParticles, Seed);
        }

        public static Mesh CreateDebris()
        {
            return VfxVortexMeshes.CreateDebris("FireVortexDebris", Seed);
        }
    }
}
