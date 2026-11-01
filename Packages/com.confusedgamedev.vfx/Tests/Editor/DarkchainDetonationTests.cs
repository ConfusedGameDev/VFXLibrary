using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class DarkchainDetonationTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<DarkchainDetonationPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("8300FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(5.15f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(DarkchainDetonationMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(128f, 64f, 0f, 0f)));
        }

        [Test]
        public void Layout_FollowsTheSourceBounds()
        {
            int links = DarkchainDetonationMeshes.LinkCount();

            Assert.That(links, Is.InRange(12 * 16, 12 * 48));

            Mesh mesh = DarkchainDetonationMeshes.CreateChainBody();
            Assert.That(mesh.vertexCount, Is.EqualTo(links * 4));
            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void Motion_ReachesItsBeats()
        {
            Assert.That(DarkchainMotion.At(0f).radius, Is.EqualTo(0f));
            Assert.That(DarkchainMotion.At(3f).radius, Is.GreaterThan(0.5f));
            Assert.That(DarkchainMotion.At(3.64f).radius, Is.LessThan(DarkchainMotion.At(3.4f).radius));
            Assert.That(DarkchainMotion.At(3.7f).orbAlive, Is.EqualTo(0f));
            Assert.That(DarkchainMotion.At(10f).waveRadius, Is.EqualTo(10.6f).Within(0.001f));
        }
    }
}
