using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class ArcaneMissileTests
    {
        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<ArcaneMissilePreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("C99AFF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.quantity, Is.EqualTo(3));
            Assert.That(preset.spread, Is.EqualTo(1f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.8f));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void ContactPoint_FollowsTheForemostGem()
        {
            // At time 0 the first gem sits at angle 0 with no forward offset, so its tip leads.
            Vector3 contact = ArcaneMissileEffect.ContactPoint(0f, 1f, 1, 1f, 1f);

            Assert.That(contact.z, Is.EqualTo(0.85f + 0.182f).Within(0.0001f));
            Assert.That(contact.y, Is.EqualTo(0.26f).Within(0.0001f));
            Assert.That(contact.x, Is.EqualTo(0f).Within(0.0001f));
        }

        [Test]
        public void Gems_AllocateEveryMissile()
        {
            Mesh mesh = ArcaneMissileMeshes.CreateGems();

            Assert.That(mesh.vertexCount, Is.EqualTo(ArcaneMissileMeshes.MaxMissiles * 24));

            Object.DestroyImmediate(mesh);
        }
    }
}
