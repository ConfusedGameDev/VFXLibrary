using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Prismatic Crystal Block. Defaults match the site's prism-parry catalog entry.</summary>
    [CreateAssetMenu(fileName = "PrismParryPreset", menuName = "ConfusedGameDev/VFX/Prismatic Crystal Block Preset")]
    public sealed class PrismParryPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Plates under pressure, each with its prism facet. The contact line and sparks stay.")]
        [Range(1, 4)] public int quantity = 4;

        public PrismParryPreset() : base(new Color(0xff / 255f, 0xe3 / 255f, 0xa0 / 255f), 0.55f)
        {
        }

        public override int Quantity => quantity;
    }
}
