using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class DimensionalRendTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<DimensionalRendPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("729DFF"));
            Assert.That(preset.density, Is.EqualTo(0.3f));
            Assert.That(preset.cutSize, Is.EqualTo(2f));
            Assert.That(preset.panelCount, Is.EqualTo(9));
            Assert.That(preset.Spread, Is.EqualTo(2f));
            Assert.That(preset.duration, Is.EqualTo(3.4f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));
            Assert.That(preset.Quantity, Is.EqualTo(18));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(DimensionalRendMeshes.LayerCounts(0.3f), Is.EqualTo(new Vector4(38f, 0f, 0f, 0f)));
        }

        [Test]
        public void Cuts_HasNoInvalidVertices()
        {
            Mesh mesh = DimensionalRendMeshes.CreateCuts();

            Assert.That(mesh.vertexCount, Is.EqualTo(4608));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
