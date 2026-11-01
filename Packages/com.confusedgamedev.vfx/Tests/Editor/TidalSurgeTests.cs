using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class TidalSurgeTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<TidalSurgePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("66CDDD"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.duration, Is.EqualTo(3.2f));
            Assert.That(preset.stopDuration, Is.EqualTo(0f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.OneShot));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void LayerCounts_SplitTheBudgetLikeTheSource()
        {
            Assert.That(TidalSurgeMeshes.LayerCounts(0.5f), Is.EqualTo(new Vector4(244f, 0f, 0f, 0f)));
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = TidalSurgeMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(1738));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
