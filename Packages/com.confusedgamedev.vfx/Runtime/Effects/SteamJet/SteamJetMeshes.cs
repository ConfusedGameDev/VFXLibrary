using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SteamJetMeshes
    {
        public const int MaxParticles = 96;

        private const uint Seed = 211301;

        public static Mesh CreateClouds()
        {
            return VfxMeshes.CreateQuads("SteamJetClouds", MaxParticles, VfxBurstMeshes.EffectBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }
    }
}
