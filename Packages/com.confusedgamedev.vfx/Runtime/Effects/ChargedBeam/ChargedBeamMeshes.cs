using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ChargedBeamMeshes
    {
        public const int MaxParticles = 768;
        public const int MaxStreams = 7;

        private const uint Seed = 64309;

        public static Mesh CreateLance()
        {
            var builder = new VfxMeshBuilder();
            for (int blade = 0; blade < 5; blade++)
            {
                int id = blade;
                builder.AddStrip(64, (h, side) => new Vector3(h, side, id));
            }
            return builder.Build("ChargedBeamLance", VfxMeshes.BeamBounds);
        }

        public static Mesh CreateCharge()
        {
            return VfxMeshes.CreateQuads("ChargedBeamCharge", MaxStreams, VfxMeshes.BeamBounds, segments: 32, seeds: VfxMeshes.CreateSeeds(MaxStreams, Seed, 1));
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ChargedBeamParticles", MaxParticles, VfxMeshes.BeamBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateFlares()
        {
            return VfxMeshes.CreateBeamFlares("ChargedBeamFlares", 2.1f, 2.6f);
        }

        public static Mesh CreateDiscs()
        {
            return VfxMeshes.CreateBeamDiscs("ChargedBeamDiscs");
        }
    }
}
