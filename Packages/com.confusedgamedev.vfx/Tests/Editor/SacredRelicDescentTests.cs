using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SacredRelicDescentTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<SacredRelicDescentPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("F5CC75"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(13f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.45f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(SacredRelicDescentMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(120f, 16f, 48f, 0f)));
        }

        [Test]
        public void Relic_HasNoInvalidVertices()
        {
            Mesh mesh = SacredRelicDescentMeshes.CreateRelic();

            Assert.That(mesh.vertexCount, Is.EqualTo(24));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void Pulses_RunTwoSecondsApart()
        {
            Assert.That(SacredRelicDescentEffect.PulseAge(3f, 3f), Is.EqualTo(-1f));
            Assert.That(SacredRelicDescentEffect.PulseAge(3.85f, 3.85f), Is.EqualTo(0.5f).Within(1e-4f));
            Assert.That(SacredRelicDescentEffect.PulseAge(5.1f, 5.1f), Is.EqualTo(-1f));
            Assert.That(SacredRelicDescentEffect.PulseAge(11.4f, 11.4f), Is.EqualTo(0.05f).Within(1e-4f));
        }

        [Test]
        public void Pulses_DoNotStartAfterEmissionEnds()
        {
            Assert.That(SacredRelicDescentEffect.PulseAge(3.5f, 3f), Is.EqualTo(-1f));
        }

        [Test]
        public void WaveRadius_ReachesTheSpread()
        {
            Assert.That(SacredRelicDescentEffect.WaveRadius(1.6f, 1.5f), Is.EqualTo(13.5f).Within(1e-4f));
        }
    }
}
