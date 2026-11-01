using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>White-Hot Fireburst. A one-shot that ends on its own.</summary>
    public sealed class FireExplosionEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return FireExplosionMeshes.LayerCounts(density);
        }
    }
}
