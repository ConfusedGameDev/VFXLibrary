using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Vortex Lightning Strike. A one-shot that ends on its own.</summary>
    public sealed class ThunderStrikeEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return ThunderStrikeMeshes.LayerCounts(density);
        }
    }
}
