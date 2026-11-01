using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    public static class WeaponSmearMeshes
    {
        public static Mesh CreateBlade()
        {
            return VfxBladeTrailMeshes.CreateRibbon("WeaponSmearBlade");
        }

        public static Mesh CreateHalo()
        {
            return VfxBladeTrailMeshes.CreateRibbon("WeaponSmearHalo");
        }

        public static Mesh CreateEdge()
        {
            return VfxBladeTrailMeshes.CreateRibbon("WeaponSmearEdge");
        }
    }
}
