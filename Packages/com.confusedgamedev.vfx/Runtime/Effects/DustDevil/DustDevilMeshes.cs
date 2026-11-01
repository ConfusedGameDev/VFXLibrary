using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class DustDevilMeshes
    {
        public const int MaxParticles = 1024;

        public const int Billows = 22;

        private const uint Seed = 165366;

        public static Mesh CreateGround()
        {
            return VfxVortexMeshes.CreateGround("DustDevilGround");
        }

        public static Mesh CreateDust()
        {
            return VfxVortexMeshes.CreateDust("DustDevilDust", Seed);
        }

        public static Mesh CreateColumn()
        {
            return VfxVortexMeshes.CreateColumn("DustDevilColumn", 22, 20, 6, Billows);
        }

        public static Mesh CreateParticles()
        {
            return VfxVortexMeshes.CreateParticles("DustDevilParticles", MaxParticles, Seed);
        }

        public static Mesh CreateDebris()
        {
            return VfxVortexMeshes.CreateDebris("DustDevilDebris", Seed);
        }
    }
}
