using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Golden Chain Rain. Three waves of gold chains drive arrowheads into the ground, crack it, and dissolve.</summary>
    public sealed class GoldenChainRainEffect : VfxBurstEffect
    {
        private static readonly int MotionId = Shader.PropertyToID("_Motion0");

        protected override Vector4 LayerCounts(float density)
        {
            return GoldenChainRainMeshes.LayerCounts(density);
        }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            if (parameters is GoldenChainRainPreset preset)
            {
                block.SetVector(MotionId, new Vector4(preset.crackBloom, preset.crackBloomSpread, preset.textureDensity, 0f));
            }
        }
    }
}
