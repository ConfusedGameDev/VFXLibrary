using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Rift-Shattering Slashes. Defaults match the site's dimensional-rend catalog entry.</summary>
    [CreateAssetMenu(fileName = "DimensionalRendPreset", menuName = "ConfusedGameDev/VFX/Rift-Shattering Slashes Preset")]
    public sealed class DimensionalRendPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Replaces the shared size: the site runs this effect from 0.25 to 4.")]
        [Range(0.25f, 4f)] public float cutSize = 2f;

        [Tooltip("Slashes in one cast. The flung slices are set by density.")]
        [Range(1, 32)] public int quantity = 18;

        [Tooltip("Distance between slashes. Their length, count and timing do not change.")]
        [Range(0.5f, 4f)] public float spread = 2f;

        [Tooltip("Triangular windows of shifted background.")]
        [Range(0, 32)] public int panelCount = 9;

        public DimensionalRendPreset() : base(new Color(0x72 / 255f, 0x9d / 255f, 0xff / 255f), 3.4f)
        {
            density = 0.3f;
        }

        public override int Quantity => quantity;

        public override float Spread => spread;
    }
}
