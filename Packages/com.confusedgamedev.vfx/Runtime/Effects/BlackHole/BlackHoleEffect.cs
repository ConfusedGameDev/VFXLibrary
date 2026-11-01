using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Luminous Vortex Black Hole. A lensing horizon and a painted accretion disk run until Stop(). Needs the camera's Opaque Texture.</summary>
    public sealed class BlackHoleEffect : VfxGroundEffect
    {
        protected override int MaxParticles => BlackHoleMeshes.MaxParticles;

        protected override void OnApplyParameters(MaterialPropertyBlock block, VfxPreset parameters)
        {
            base.OnApplyParameters(block, parameters);
            var hole = (BlackHolePreset)parameters;
            block.SetFloat(EffectSizeId, hole.holeSize);
            block.SetFloat(EffectDetailId, hole.holeDetail);
        }
    }
}
