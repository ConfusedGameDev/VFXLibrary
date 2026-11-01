using UnityEditor;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Editor
{
    public static class BindingCurseAssetBuilder
    {
        [VfxBuilder("BindingCurse")]
        [MenuItem("Tools/ConfusedGameDev/VFX/Rebuild Hooked Binding Sigil Assets")]
        public static void Build()
        {
            GameObject root = VfxAssetBuilder.Create<BindingCurseEffect, BindingCursePreset>("BindingCurse", new[]
            {
                new VfxAssetBuilder.Layer("Sigil", BindingCurseMeshes.CreateSigil()),
                new VfxAssetBuilder.Layer("Body", BindingCurseMeshes.CreateBody()),
                new VfxAssetBuilder.Layer("Particles", BindingCurseMeshes.CreateParticles())
            }, out _);
            VfxAssetBuilder.Save(root, "BindingCurse");
        }
    }
}
