using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ArcaneMatrixTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ArcaneMatrixPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("BD9AFF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.7f));
            Assert.That(preset.stopDuration, Is.EqualTo(1f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.Quantity, Is.EqualTo(9));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = ArcaneMatrixMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(10 * 3 * 5 + 18 * (24 + 5 * 5)));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
