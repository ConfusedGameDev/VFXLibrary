using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class FrostFieldTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<FrostFieldPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("9BDFFF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.7f));
            Assert.That(preset.stopDuration, Is.EqualTo(1f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Particles_HaveOneQuadPerSlot()
        {
            Mesh mesh = FrostFieldMeshes.CreateParticles();

            Assert.That(mesh.vertexCount, Is.EqualTo(512 * 4));

            Object.DestroyImmediate(mesh);
        }
    }
}
