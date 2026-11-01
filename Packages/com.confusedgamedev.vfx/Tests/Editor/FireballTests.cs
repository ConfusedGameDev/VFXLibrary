using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class FireballTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<FireballPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("FF823E"));
            Assert.That(preset.size, Is.EqualTo(1f));
            Assert.That(preset.speed, Is.EqualTo(1f));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.detail, Is.EqualTo(1f));
            Assert.That(preset.startDuration, Is.EqualTo(0.35f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Seeds_MatchSourceGenerator()
        {
            // First output of state = (state * 1664525 + 1013904223) mod 2^32, from state 9187.
            Vector4 first = FireballMeshes.CreateSeeds(1)[0];

            uint expected = unchecked(9187u * 1664525u + 1013904223u);
            Assert.That(expected, Is.EqualTo(3420993510u));
            Assert.That(first.x, Is.EqualTo((float)(expected / 4294967296.0)));
        }

        [Test]
        public void ContactPoint_LeadsAlongForward()
        {
            Vector3 contact = FireballEffect.ContactPoint(1f, 1f, 1f);

            Assert.That(contact.z, Is.GreaterThan(1f));
            Assert.That(Mathf.Abs(contact.x), Is.LessThan(0.05f));
            Assert.That(Mathf.Abs(contact.y), Is.LessThan(0.05f));
        }

        [Test]
        public void ParticleMesh_HasOneQuadPerSlot()
        {
            Mesh mesh = FireballMeshes.CreateParticles();

            Assert.That(mesh.vertexCount, Is.EqualTo(FireballMeshes.MaxParticles * 4));
            Assert.That(mesh.triangles.Length, Is.EqualTo(FireballMeshes.MaxParticles * 6));

            Object.DestroyImmediate(mesh);
        }
    }
}
