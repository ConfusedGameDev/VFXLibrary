using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class AstralConvergenceTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<AstralConvergencePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("C1B8FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(3.4f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));
            Assert.That(preset.Quantity, Is.EqualTo(10));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(AstralConvergenceMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(256f, 0f, 0f, 0f)));
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = AstralConvergenceMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(2695));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
