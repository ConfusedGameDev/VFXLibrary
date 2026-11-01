using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Astral Ring Detonation. A one-shot that ends on its own; quantity sets the number of star beams.</summary>
    public sealed class AstralConvergenceEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return AstralConvergenceMeshes.LayerCounts(density);
        }
    }
}
