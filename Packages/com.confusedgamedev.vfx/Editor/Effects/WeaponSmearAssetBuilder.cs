using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class WeaponSmearAssetBuilder
    {
        [VfxBuilder("WeaponSmear")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Gleaming Blade Trail Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<WeaponSmearEffect, WeaponSmearPreset>("WeaponSmear", new[]
            {
                new VfxAssetBuilder.Layer("Blade", WeaponSmearMeshes.CreateBlade()),
                new VfxAssetBuilder.Layer("Halo", WeaponSmearMeshes.CreateHalo()),
                new VfxAssetBuilder.Layer("Edge", WeaponSmearMeshes.CreateEdge())
            }, out _);
            VfxAssetBuilder.Save(root, "WeaponSmear");
        }
    }
}
