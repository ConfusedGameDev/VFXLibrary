using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class ArcRayMeshes
    {
        public const int MaxParticles = 768;

        private const uint Seed = 73496;

        public static Mesh CreateLightning()
        {
            var builder = new VfxMeshBuilder();
            for (int id = 11; id >= 0; id--)
            {
                // Faint branches come first so their halos cannot cover the main core.
                for (int branch = 3; branch >= 0; branch--)
                {
                    int arc = id;
                    builder.AddStrip(branch > 0 ? 24 : 96, (h, side) => new Vector3(h, arc, side), new Vector4(branch, 0f, 0f, 0f));
                }
            }
            return builder.Build("ArcRayLightning", VfxMeshes.BeamBounds);
        }

        public static Mesh CreateCorona()
        {
            var builder = new VfxMeshBuilder();
            foreach (float end in new[] { -1f, 1f })
            {
                for (int id = 8; id >= 0; id--)
                {
                    int arc = id;
                    builder.AddStrip(24, (h, side) => new Vector3(h, arc, side), new Vector4(end, 0f, 0f, 0f));
                }
            }
            return builder.Build("ArcRayCorona", VfxMeshes.BeamBounds);
        }

        public static Mesh CreateParticles()
        {
            return VfxMeshes.CreateQuads("ArcRayParticles", MaxParticles, VfxMeshes.BeamBounds, seeds: VfxMeshes.CreateSeeds(MaxParticles, Seed));
        }

        public static Mesh CreateFlares()
        {
            return VfxMeshes.CreateBeamFlares("ArcRayFlares", 1.8f, 2.5f);
        }
    }
}
