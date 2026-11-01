using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Bubbling Venom Sigil. Bubbles swell and burst on a three-lobed pool, throwing droplets and mist.</summary>
    public sealed class VenomPoolEffect : VfxGroundEffect
    {
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");

        protected override int MaxParticles => VenomPoolMeshes.MaxParticles;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);

            // Mist takes its share of the budget first, as the source allocates it last.
            int desired = Mathf.Max(1, Mathf.RoundToInt(MaxParticles * parameters.density));
            int mist = Mathf.Min(VenomPoolMeshes.MaxMist, Mathf.RoundToInt(desired * 0.0625f));
            block.SetFloat(ParticleCountId, desired - mist);
            block.SetVector(LayerCountsId, new Vector4(mist, 0f, 0f, 0f));
        }
    }
}
