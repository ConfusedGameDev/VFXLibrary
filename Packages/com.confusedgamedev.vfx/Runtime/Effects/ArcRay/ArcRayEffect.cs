using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Forked Lightning Stream. Jagged arcs with short forks join the ends, and small coronas crackle around both.</summary>
    public sealed class ArcRayEffect : VfxBeamEffect
    {
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");

        protected override int MaxParticles => ArcRayMeshes.MaxParticles;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            block.SetFloat(QuantityId, ((ArcRayPreset)parameters).quantity);
        }
    }
}
