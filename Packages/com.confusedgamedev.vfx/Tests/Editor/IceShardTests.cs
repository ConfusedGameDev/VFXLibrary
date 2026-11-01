using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class IceShardTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<IceShardPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("B3DCFF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.35f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Core_HasNoInvalidVertices()
        {
            Mesh mesh = IceShardMeshes.CreateCore();

            // Five lances of 2 steps by 6 sides, two triangles each, unwelded.
            Assert.That(mesh.vertexCount, Is.EqualTo(5 * 2 * 6 * 6));
            foreach (Vector3 vertex in mesh.vertices)
            {
                Assert.That(float.IsNaN(vertex.x + vertex.y + vertex.z), Is.False);
            }

            Object.DestroyImmediate(mesh);
        }

        [Test]
        public void ParticleMesh_HasOneOctahedronPerSlot()
        {
            Mesh mesh = IceShardMeshes.CreateParticles();

            Assert.That(mesh.vertexCount, Is.EqualTo(IceShardMeshes.MaxParticles * 24));

            Object.DestroyImmediate(mesh);
        }
    }
}
