using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class PlasmaBoltTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<PlasmaBoltPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("73E3FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.startDuration, Is.EqualTo(0.35f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void ContactPoint_IsTheTip()
        {
            Assert.That(PlasmaBoltEffect.ContactPoint(1f, 1f), Is.EqualTo(new Vector3(0f, 0f, 1.7f)));
        }

        [Test]
        public void ImpactMesh_HasThirtyParts()
        {
            Mesh mesh = PlasmaBoltMeshes.CreateImpact();

            // Twelve strips of 6 steps, twelve of 3 and six of 1.
            Assert.That(mesh.vertexCount, Is.EqualTo((12 * 7 + 12 * 4 + 6 * 2) * 2));

            Object.DestroyImmediate(mesh);
        }
    }
}
