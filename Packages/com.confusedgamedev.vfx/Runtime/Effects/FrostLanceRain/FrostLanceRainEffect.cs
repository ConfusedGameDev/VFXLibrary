using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Falling Frost Spear Array. A one-shot that ends on its own; quantity sets the lances, spread moves where they land.</summary>
    public sealed class FrostLanceRainEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return FrostLanceRainMeshes.LayerCounts(density);
        }
    }
}
