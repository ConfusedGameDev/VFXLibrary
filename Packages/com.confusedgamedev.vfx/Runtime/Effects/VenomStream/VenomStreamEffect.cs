using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Corrosive Venom Jet. Teardrop slugs of venom race to the target and splash there, and the last of them finish after it stops.</summary>
    public sealed class VenomStreamEffect : VfxBeamEffect
    {
        private static readonly int QuantityId = Shader.PropertyToID("_Quantity");

        protected override int MaxParticles => VenomStreamMeshes.MaxParticles;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            block.SetFloat(QuantityId, ((VenomStreamPreset)parameters).quantity);
        }
    }
}
