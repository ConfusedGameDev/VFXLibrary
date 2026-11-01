using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class SpatialSmearMeshes
    {
        public static Mesh CreateRefraction()
        {
            return VfxBladeTrailMeshes.CreateRibbon("SpatialSmearRefraction");
        }

        public static Mesh CreateHalo()
        {
            return VfxBladeTrailMeshes.CreateRibbon("SpatialSmearHalo");
        }

        public static Mesh CreateEdge()
        {
            return VfxBladeTrailMeshes.CreateRibbon("SpatialSmearEdge");
        }
    }
}
