using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class GroundFogTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<GroundFogPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("A6C9CA"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.5f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.2f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Clouds_HaveOneQuadPerSlot()
        {
            Mesh mesh = GroundFogMeshes.CreateClouds();

            Assert.That(mesh.vertexCount, Is.EqualTo(128 * 4));

            Object.DestroyImmediate(mesh);
        }
    }
}
