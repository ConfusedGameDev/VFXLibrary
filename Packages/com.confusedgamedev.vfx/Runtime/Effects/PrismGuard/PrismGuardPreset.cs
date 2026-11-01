using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Prismatic Crystal Bulwark. Defaults match the site's prism-guard catalog entry.</summary>
    [CreateAssetMenu(fileName = "PrismGuardPreset", menuName = "ConfusedGameDev/VFX/Prismatic Crystal Bulwark Preset")]
    public sealed class PrismGuardPreset : VfxGroundPreset
    {
        [Header("Controls")]
        [Tooltip("Shield plates, each with its own prism facet.")]
        [Range(1, 7)] public int quantity = 7;

        public PrismGuardPreset() : base(new Color(0x73 / 255f, 0xe3 / 255f, 0xff / 255f))
        {
            startDuration = 0.3f;
            stopDuration = 0.65f;
        }

        public override int Quantity => quantity;
    }
}
