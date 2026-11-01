using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Surging Flame Tide. Defaults match the site's flame-surge catalog entry.</summary>
    [CreateAssetMenu(fileName = "FlameSurgePreset", menuName = "ConfusedGameDev/VFX/Surging Flame Tide Preset")]
    public sealed class FlameSurgePreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Rolling tongues of flame. The smoke and sparks stay.")]
        [Range(1, 10)] public int quantity = 5;

        public FlameSurgePreset() : base(new Color(0xff / 255f, 0x82 / 255f, 0x3e / 255f), 3f)
        {
        }

        public override int Quantity => quantity;
    }
}
