using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Prismatic Crystal Block. A bright contact line flashes as small plates take a hit, then the light scatters and it ends on its own.</summary>
    public sealed class PrismParryEffect : VfxBurstEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return PrismParryMeshes.LayerCounts(density);
        }
    }
}
