using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class GoldenChainRainTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<GoldenChainRainPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FFD166"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(4.8f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));
            Assert.That(preset.Quantity, Is.EqualTo(8));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(GoldenChainRainMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(179f, 77f, 0f, 0f)));
        }

        [Test]
        public void Cracks_HasNoInvalidVertices()
        {
            Mesh mesh = GoldenChainRainMeshes.CreateCracks();

            Assert.That(mesh.vertexCount, Is.EqualTo(9216));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void Chips_KeepEightTimesTheirAllocation()
        {
            Mesh mesh = GoldenChainRainMeshes.CreateChips();

            Assert.That(mesh.vertexCount, Is.EqualTo(154 * 8 * 4));
            Object.DestroyImmediate(mesh);
        }
    }
}
