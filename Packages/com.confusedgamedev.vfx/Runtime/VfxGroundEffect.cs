using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Base of the ground effects: a sigil and its layers, running until Stop().</summary>
    public abstract class VfxGroundEffect : VfxEffect
    {
        protected static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int EmitterTimeId = Shader.PropertyToID("_EmitterTime");
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");

        protected abstract int MaxParticles { get; }

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            block.SetFloat(ParticleCountId, Mathf.Max(1, Mathf.RoundToInt(MaxParticles * parameters.density)));
            block.SetFloat(EmitterTimeId, EffectTime - EndProgress * parameters.stopDuration);
            if (parameters is VfxGroundPreset ground)
            {
                block.SetFloat(QuantityId, ground.Quantity);
            }
        }
    }
}
