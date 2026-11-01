using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Dispersing Smoke Puff. Defaults match the site's smoke-puff catalog entry.</summary>
    [CreateAssetMenu(fileName = "SmokePuffPreset", menuName = "ConfusedGameDev/VFX/Dispersing Smoke Puff Preset")]
    public sealed class SmokePuffPreset : VfxBurstPreset
    {
        public SmokePuffPreset() : base(new Color(0xb1 / 255f, 0xaf / 255f, 0xc8 / 255f), 3.5f)
        {
        }
    }
}
