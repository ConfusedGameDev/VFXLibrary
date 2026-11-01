using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Windswept Meadow. Opaque painted grass and white flowers grow in, sway until Stop(), then shrink away.</summary>
    public sealed class PainterlyGrassEffect : VfxGroundEffect
    {
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");

        protected override int MaxParticles => PainterlyGrassMeshes.MaxParticles;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            block.SetVector(LayerCountsId, PainterlyGrassMeshes.LayerCounts(parameters.density));
        }
    }
}
