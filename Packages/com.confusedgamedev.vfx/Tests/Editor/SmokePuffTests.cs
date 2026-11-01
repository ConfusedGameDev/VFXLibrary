using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SmokePuffTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<SmokePuffPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("B1AFC8"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(3.5f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(SmokePuffMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(48f, 0f, 0f, 0f)));
        }

        [Test]
        public void Clouds_HaveOneQuadPerSlot()
        {
            Mesh mesh = SmokePuffMeshes.CreateClouds();

            Assert.That(mesh.vertexCount, Is.EqualTo(96 * 4));

            Object.DestroyImmediate(mesh);
        }
    }
}
