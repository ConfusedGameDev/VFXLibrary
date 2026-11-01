using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Ringpulse Ray. Glowing packets swell along a ray while rings run forward over it.</summary>
    public sealed class PulseBeamEffect : VfxBeamEffect
    {
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");

        protected override int MaxParticles => PulseBeamMeshes.MaxParticles;

        protected override int SecondaryMaximum => PulseBeamMeshes.MaxRings;

        protected override float SecondaryWeight => 0.025f;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            block.SetFloat(QuantityId, ((PulseBeamPreset)parameters).quantity);
        }
    }
}
