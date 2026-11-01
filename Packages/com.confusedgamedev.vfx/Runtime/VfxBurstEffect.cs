using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Base of the one-shot bursts: particle budgets, quantity and spread, and an optional timed ending.</summary>
    public abstract class VfxBurstEffect : VfxEffect
    {
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");
        private static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");
        private static readonly int SpreadId = Shader.PropertyToID("_Spread");

        /// <summary>Seconds before the end at which a shaped ending takes over. 0 for bursts without one.</summary>
        protected virtual float EndingSeconds => 0f;

        /// <summary>Instances per particle layer, in allocation order.</summary>
        protected abstract Vector4 LayerCounts(float density);

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            Vector4 counts = LayerCounts(parameters.density);
            block.SetVector(LayerCountsId, counts);
            block.SetFloat(ParticleCountId, counts.x);

            if (parameters is VfxBurstPreset burst)
            {
                block.SetFloat(QuantityId, burst.Quantity);
                block.SetFloat(SpreadId, burst.Spread);
            }

            float ending = EndingSeconds;
            if (ending > 0f)
            {
                float progress = Mathf.Clamp01((EffectTime - (parameters.duration - ending)) / ending);
                block.SetFloat(LifeEndId, progress);
                block.SetFloat(LifeStageId, progress > 0f ? 2f : 1f);
            }
        }
    }
}
