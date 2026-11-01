using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ThornCrownTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ThornCrownPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("88D49A"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.7f));
            Assert.That(preset.stopDuration, Is.EqualTo(1f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.Quantity, Is.EqualTo(4));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = ThornCrownMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(8 * (31 * 7 + 3 * (11 * 5 + 24)) + 7 * 11 * 5));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
