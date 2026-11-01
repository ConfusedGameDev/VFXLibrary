using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class FireVortexTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<FireVortexPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FF884B"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(1.7f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.4f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(VfxVortexMeshes.LayerCounts(FireVortexMeshes.MaxParticles, 0, 0.5f), Is.EqualTo(new Vector4(402f, 82f, 28f, 0f)));
        }

        [Test]
        public void Column_HasTheSourcesBlades()
        {
            Mesh mesh = FireVortexMeshes.CreateColumn();

            Assert.That(mesh.vertexCount, Is.EqualTo(3234));

            Object.DestroyImmediate(mesh);
        }
    }
}
