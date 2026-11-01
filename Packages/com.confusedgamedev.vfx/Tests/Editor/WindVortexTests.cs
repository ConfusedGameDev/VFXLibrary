using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class WindVortexTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<WindVortexPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("A4DFD1"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(1.7f));
            Assert.That(preset.stopDuration, Is.EqualTo(1.4f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(VfxVortexMeshes.LayerCounts(WindVortexMeshes.MaxParticles, 0, 0.5f), Is.EqualTo(new Vector4(302f, 61f, 21f, 0f)));
        }

        [Test]
        public void Column_HasTheSourcesBlades()
        {
            Mesh mesh = WindVortexMeshes.CreateColumn();

            Assert.That(mesh.vertexCount, Is.EqualTo(2352));

            Object.DestroyImmediate(mesh);
        }
    }
}
