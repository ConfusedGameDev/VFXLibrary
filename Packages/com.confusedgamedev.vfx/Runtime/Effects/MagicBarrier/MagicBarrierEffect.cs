using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Runic Mesh Barrier. Runs until Stop(), then breaks apart while its patterns hold still.</summary>
    public sealed class MagicBarrierEffect : VfxEffect
    {
        private static readonly int ParticleCountId = Shader.PropertyToID("_ParticleCount");
        private static readonly int EmitterTimeId = Shader.PropertyToID("_EmitterTime");

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            block.SetFloat(ParticleCountId, Mathf.Max(1, Mathf.RoundToInt(MagicBarrierMeshes.MaxParticles * parameters.density)));
            block.SetFloat(EmitterTimeId, EffectTime - EndProgress * parameters.stopDuration);
        }
    }
}
