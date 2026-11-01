using UnityEngine;

namespace ConfusedGameDev.Vfx
{
    /// <summary>Frostcrystal Dart. Defaults match the site's ice-shard catalog entry.</summary>
    [CreateAssetMenu(fileName = "IceShardPreset", menuName = "ConfusedGameDev/VFX/Frostcrystal Dart Preset")]
    public sealed class IceShardPreset : VfxPreset
    {
        public IceShardPreset()
        {
            color = new Color(0xb3 / 255f, 0xdc / 255f, 0xff / 255f);
            playback = VfxPlayback.Looping;
            duration = 5f;
            startDuration = 0.35f;
            stopDuration = 0.8f;
        }
    }
}
