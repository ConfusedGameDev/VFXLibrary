using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Rift-Shattering Slashes. Slashes of light tear the view into shifted slices, which burst outward and fade. Needs the camera's Opaque Texture.</summary>
    public sealed class DimensionalRendEffect : VfxBurstEffect
    {
        private static readonly int PanelCountId = Shader.PropertyToID("_PanelCount");

        protected override Vector4 LayerCounts(float density)
        {
            return DimensionalRendMeshes.LayerCounts(density);
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            var rend = (DimensionalRendPreset)parameters;
            block.SetFloat(EffectSizeId, rend.cutSize);
            block.SetFloat(PanelCountId, rend.panelCount);
        }
    }
}
