using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SteamJetTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<SteamJetPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("D1DFE8"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.5f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.2f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Clouds_HaveOneQuadPerSlot()
        {
            Mesh mesh = SteamJetMeshes.CreateClouds();

            Assert.That(mesh.vertexCount, Is.EqualTo(96 * 4));

            Object.DestroyImmediate(mesh);
        }
    }
}
