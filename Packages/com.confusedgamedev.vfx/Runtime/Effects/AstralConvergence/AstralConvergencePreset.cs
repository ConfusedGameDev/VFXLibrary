using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Astral Ring Detonation. Defaults match the site's astral-convergence catalog entry.</summary>
    [CreateAssetMenu(fileName = "AstralConvergencePreset", menuName = "ConfusedGameDev/VFX/Astral Ring Detonation Preset")]
    public sealed class AstralConvergencePreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Star beams thrown out by the burst. The orbits and constellation stay.")]
        [Range(1, 20)] public int quantity = 10;

        public AstralConvergencePreset() : base(new Color(0xc1 / 255f, 0xb8 / 255f, 0xff / 255f), 3.4f)
        {
        }

        public override int Quantity => quantity;
    }
}
