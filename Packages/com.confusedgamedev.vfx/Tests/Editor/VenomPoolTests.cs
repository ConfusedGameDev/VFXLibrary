using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class VenomPoolTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<VenomPoolPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("ACDC6F"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.7f));
            Assert.That(preset.stopDuration, Is.EqualTo(1f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.Quantity, Is.EqualTo(7));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = VenomPoolMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(14 * 17 * 11));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
