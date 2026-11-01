using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class WindVortexMeshes
    {
        public const int MaxParticles = 768;

        private const uint Seed = 156179;

        public static Mesh CreateGround()
        {
            return VfxVortexMeshes.CreateGround("WindVortexGround");
        }

        public static Mesh CreateDust()
        {
            return VfxVortexMeshes.CreateDust("WindVortexDust", Seed);
        }

        public static Mesh CreateColumn()
        {
            return VfxVortexMeshes.CreateColumn("WindVortexColumn", 16, 20, 6);
        }

        public static Mesh CreateParticles()
        {
            return VfxVortexMeshes.CreateParticles("WindVortexParticles", MaxParticles, Seed);
        }

        public static Mesh CreateDebris()
        {
            return VfxVortexMeshes.CreateDebris("WindVortexDebris", Seed);
        }
    }
}
