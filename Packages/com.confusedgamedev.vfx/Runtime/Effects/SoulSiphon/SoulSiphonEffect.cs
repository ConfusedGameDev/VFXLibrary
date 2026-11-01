using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Dark Energy Siphon. Orbs of dark energy stream from the target back to the caster along three twisting strands.</summary>
    public sealed class SoulSiphonEffect : VfxBeamEffect
    {
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");

        protected override int MaxParticles => SoulSiphonMeshes.MaxParticles;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            block.SetFloat(QuantityId, ((SoulSiphonPreset)parameters).quantity);
        }
    }
}
