using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Runic Crystal Missiles. Defaults match the site's arcane-missile catalog entry.</summary>
    [CreateAssetMenu(fileName = "ArcaneMissilePreset", menuName = "ConfusedGameDev/VFX/Runic Crystal Missiles Preset")]
    public sealed class ArcaneMissilePreset : VfxPreset
    {
        [Header("Missile Controls")]
        [Range(1, 6)] public int quantity = 3;
        [Range(0.5f, 3f)] public float spread = 1f;

        public ArcaneMissilePreset()
        {
            color = new Color(0xc9 / 255f, 0x9a / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
