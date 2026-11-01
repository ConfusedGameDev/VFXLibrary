using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class PrismGuardTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<PrismGuardPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("73E3FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.startDuration, Is.EqualTo(0.3f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.65f));
            Assert.That(preset.Quantity, Is.EqualTo(7));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Body_HasNoInvalidVertices()
        {
            Mesh mesh = PrismGuardMeshes.CreateBody();

            Assert.That(mesh.vertexCount, Is.EqualTo(420));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }
    }
}
