using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class PainterlyGrassTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<PainterlyGrassPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("829544"));
            Assert.That(preset.density, Is.EqualTo(0.75f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.startDuration, Is.EqualTo(0.6f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(PainterlyGrassMeshes.LayerCounts(0.75f), Is.EqualTo(new Vector4(360f, 24f, 0f, 0f)));
            Assert.That(PainterlyGrassMeshes.LayerCounts(1f), Is.EqualTo(new Vector4(480f, 32f, 0f, 0f)));
        }

        [Test]
        public void Blades_BakeEveryClump()
        {
            Mesh mesh = PainterlyGrassMeshes.CreateBlades();

            Assert.That(mesh.vertexCount, Is.EqualTo(480 * 3 * 8));
            Assert.That(mesh.GetIndexCount(0), Is.EqualTo(480u * 3u * 18u));

            Object.DestroyImmediate(mesh);
        }
    }
}
