using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Vitality Blossom. A one-shot that ends on its own; quantity sets the petals across its two rings.</summary>
    public sealed class RevivalBloomEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return RevivalBloomMeshes.LayerCounts(density);
        }
    }
}
