using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Base of the vortices: a ground effect whose particle budget is split across three layers.</summary>
    public abstract class VfxVortexEffect : VfxGroundEffect
    {
        private static readonly int LayerCountsId = Shader.PropertyToID("_LayerCounts");

        /// <summary>Slots held by pieces that density never removes.</summary>
        protected virtual int FixedSlots => 0;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            block.SetVector(LayerCountsId, VfxVortexMeshes.LayerCounts(MaxParticles, FixedSlots, parameters.density));
        }
    }
}
