using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SmokeColumnTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<SmokeColumnPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("AEB9CB"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.5f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.2f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Clouds_HaveOneQuadPerSlot()
        {
            Mesh mesh = SmokeColumnMeshes.CreateClouds();

            Assert.That(mesh.vertexCount, Is.EqualTo(128 * 4));

            Object.DestroyImmediate(mesh);
        }
    }
}
