using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Shattering Frostburst. Defaults match the site's ice-shatter catalog entry.</summary>
    [CreateAssetMenu(fileName = "IceShatterPreset", menuName = "ConfusedGameDev/VFX/Shattering Frostburst Preset")]
    public sealed class IceShatterPreset : VfxBurstPreset
    {
        [Header("Burst Controls")]
        [Tooltip("Large crystals thrown outward. The small chips follow density.")]
        [Range(1, 18)] public int quantity = 9;

        public IceShatterPreset() : base(new Color(0xb8 / 255f, 0xe5 / 255f, 0xff / 255f), 2.8f)
        {
        }

        public override int Quantity => quantity;
    }
}
