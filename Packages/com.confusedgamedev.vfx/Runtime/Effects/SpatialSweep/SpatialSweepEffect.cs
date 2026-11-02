using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Riftblade Sweep. A clear blade sweeps nearly a full turn, dragging and shearing the scene behind it. It ends on its own. Needs the camera Opaque Texture.</summary>
    public sealed class SpatialSweepEffect : VfxSweepEffect
    {
        protected override Vector4 LayerCounts(float density)
        {
            return SpatialSweepMeshes.LayerCounts(density);
        }
    }
}
