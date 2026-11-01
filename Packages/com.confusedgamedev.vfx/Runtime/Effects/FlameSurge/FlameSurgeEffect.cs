using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Surging Flame Tide. A one-shot that ends on its own; quantity sets the number of tongues.</summary>
    public sealed class FlameSurgeEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return FlameSurgeMeshes.LayerCounts(density);
        }
    }
}
