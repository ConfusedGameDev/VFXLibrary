using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Darkchain Sigil Rupture. Defaults match the site's darkchain-detonation catalog entry.</summary>
    [CreateAssetMenu(fileName = "DarkchainDetonationPreset", menuName = "ConfusedGameDev/VFX/Darkchain Sigil Rupture Preset")]
    public sealed class DarkchainDetonationPreset : VfxBurstPreset
    {
        public DarkchainDetonationPreset() : base(new Color(0x83 / 255f, 0x00 / 255f, 0xff / 255f), 5.15f)
        {
        }
    }
}
