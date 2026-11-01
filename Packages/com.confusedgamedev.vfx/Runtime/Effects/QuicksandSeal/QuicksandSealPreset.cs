using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Sand-Gathering Sigil. Defaults match the site's quicksand-seal catalog entry.</summary>
    [CreateAssetMenu(fileName = "QuicksandSealPreset", menuName = "ConfusedGameDev/VFX/Sand-Gathering Sigil Preset")]
    public sealed class QuicksandSealPreset : VfxGroundPreset
    {
        [Header("Ground Controls")]
        [Tooltip("Sand ridges, each with its sliding packet. The seal beneath stays.")]
        [Range(1, 6)] public int quantity = 3;

        public QuicksandSealPreset() : base(new Color(0xdf / 255f, 0xba / 255f, 0x7c / 255f))
        {
        }

        public override int Quantity => quantity;
    }
}
