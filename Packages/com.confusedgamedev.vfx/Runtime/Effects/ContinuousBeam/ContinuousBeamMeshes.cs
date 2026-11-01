using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ContinuousBeamMeshes
    {
        public const int MaxParticles = 512;

        private const uint Seed = 45935;

        public static Mesh CreateBody()
        {
            return VfxMeshes.CreateBeamTube("ContinuousBeamBody", 0.045f, 12, 48);
        }

        public static Mesh CreateSheath()
        {
            return VfxMeshes.CreateBeamTube("ContinuousBeamSheath", 0.13f, 24, 64);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ContinuousBeamParticles", MaxParticles, VfxMeshes.BeamBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateFlares()
        {
            return VfxMeshes.CreateBeamFlares("ContinuousBeamFlares", 1f, 1.4f);
        }

        public static Mesh CreateDiscs()
        {
            return VfxMeshes.CreateBeamDiscs("ContinuousBeamDiscs");
        }
    }
}
