using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SpellIndicatorCircleMeshes
    {
        // Holds the largest radius. The margin keeps the edge antialiased at the four cardinal points.
        private static readonly Bounds Bounds = new Bounds(Vector3.zero, new Vector3(42f, 2f, 42f));

        public static Mesh CreateSurface()
        {
            return VfxMeshes.CreateQuads("SpellIndicatorCircleSurface", 1, Bounds, 2.04f);
        }
    }
}
