using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Billowing Airburst. Defaults match the site's billowing-airburst catalog entry.</summary>
    [CreateAssetMenu(fileName = "BillowingAirburstPreset", menuName = "ConfusedGameDev/VFX/Billowing Airburst Preset")]
    public sealed class BillowingAirburstPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Main smoke jets. Density only changes the decorative embers.")]
        [Range(2, 6)] public int quantity = 4;

        public BillowingAirburstPreset() : base(new Color(0xff / 255f, 0x7a / 255f, 0x24 / 255f), 2.4f)
        {
        }

        public override int Quantity => quantity;
    }
}
