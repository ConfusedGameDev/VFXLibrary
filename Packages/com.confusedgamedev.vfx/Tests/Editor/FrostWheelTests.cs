using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class FrostWheelTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<FrostWheelPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("A9DFFF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.35f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void ContactPoint_LeadsAlongForward()
        {
            Assert.That(FrostWheelEffect.ContactPoint(0f, 1f, 1f).z, Is.EqualTo(0.99f).Within(0.001f));
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = FrostWheelMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(57 * 9 + 9 * 24));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
