using NUnit.Framework;
using UnityEngine;

namespace ConfusedGameDev.Vfx.Tests
{
    public class SpatialSmearTests
    {
        private const float Step = 1f / 60f;

        private static SpatialSmearEffect CreateEffect(Transform weapon)
        {
            var effect = new GameObject("SpatialSmear").AddComponent<SpatialSmearEffect>();
            effect.SetPreset(ScriptableObject.CreateInstance<SpatialSmearPreset>());
            effect.Play();
            effect.AttachWeapon(weapon, Vector3.zero, Vector3.up);
            return effect;
        }

        private static void Swing(SpatialSmearEffect effect, Transform weapon, int frames)
        {
            for (int i = 0; i < frames; i++)
            {
                weapon.Rotate(10f, 0f, 0f);
                effect.Tick(Step);
            }
        }

        private static void Release(SpatialSmearEffect effect, Transform weapon)
        {
            Object.DestroyImmediate(effect.Preset);
            Object.DestroyImmediate(effect.gameObject);
            Object.DestroyImmediate(weapon.gameObject);
        }

        [Test]
        public void Preset_MatchesSiteDefaults()
        {
            var preset = ScriptableObject.CreateInstance<SpatialSmearPreset>();

            Assert.That(ColorUtility.ToHtmlStringRGB(preset.color), Is.EqualTo("E9F5FF"));
            Assert.That(preset.density, Is.EqualTo(0.5f));
            Assert.That(preset.playback, Is.EqualTo(VfxPlayback.Looping));
            Assert.That(preset.startDuration, Is.EqualTo(0.001f));
            Assert.That(preset.stopDuration, Is.EqualTo(0.18f));

            Object.DestroyImmediate(preset);
        }

        [Test]
        public void Ribbon_KeepsOnlyTheLastPositions()
        {
            var weapon = new GameObject("Weapon").transform;
            SpatialSmearEffect effect = CreateEffect(weapon);

            Swing(effect, weapon, 5);
            Assert.That(effect.SampleCount, Is.EqualTo(5));

            Swing(effect, weapon, 40);
            Assert.That(effect.SampleCount, Is.InRange(10, 12));

            Release(effect, weapon);
        }

        [Test]
        public void Ribbon_RestartsAcrossATeleport()
        {
            var weapon = new GameObject("Weapon").transform;
            SpatialSmearEffect effect = CreateEffect(weapon);

            Swing(effect, weapon, 5);
            weapon.position += Vector3.right * 100f;
            Swing(effect, weapon, 1);
            Assert.That(effect.SampleCount, Is.EqualTo(1));

            Release(effect, weapon);
        }

        [Test]
        public void Ribbon_RunsOutAfterStop()
        {
            var weapon = new GameObject("Weapon").transform;
            SpatialSmearEffect effect = CreateEffect(weapon);

            Swing(effect, weapon, 5);
            effect.Stop();
            Swing(effect, weapon, 12);
            Assert.That(effect.State, Is.EqualTo(VfxState.Finished));
            Assert.That(effect.SampleCount, Is.EqualTo(0));

            Release(effect, weapon);
        }

        [Test]
        public void PreviewSwing_DrawsWithNoWeapon()
        {
            var effect = new GameObject("SpatialSmear").AddComponent<SpatialSmearEffect>();
            effect.SetPreset(ScriptableObject.CreateInstance<SpatialSmearPreset>());
            effect.Play();

            Assert.That(effect.UsesPreviewSwing, Is.True);

            for (int i = 0; i < 12; i++)
            {
                effect.Tick(Step);
            }
            Assert.That(effect.SampleCount, Is.GreaterThan(1));

            Object.DestroyImmediate(effect.Preset);
            Object.DestroyImmediate(effect.gameObject);
        }

        [Test]
        public void PreviewSwing_GivesWayToAWeapon()
        {
            var weapon = new GameObject("Weapon").transform;
            SpatialSmearEffect effect = CreateEffect(weapon);

            Assert.That(effect.UsesPreviewSwing, Is.False);

            Release(effect, weapon);
        }

        [Test]
        public void EndEditPreview_RestoresTheBakedMeshes()
        {
            var weapon = new GameObject("Weapon").transform;
            var baked = new Mesh();
            var effect = new GameObject("SpatialSmear").AddComponent<SpatialSmearEffect>();
            var filter = effect.gameObject.AddComponent<MeshFilter>();
            filter.sharedMesh = baked;
            effect.SetPreset(ScriptableObject.CreateInstance<SpatialSmearPreset>());

            effect.Play();
            Assert.That(filter.sharedMesh, Is.Not.SameAs(baked));

            effect.EndEditPreview();
            Assert.That(filter.sharedMesh, Is.SameAs(baked));

            effect.Play();
            Assert.That(filter.sharedMesh, Is.Not.SameAs(baked));

            Object.DestroyImmediate(baked);
            Release(effect, weapon);
        }

        [Test]
        public void AttachWeapon_RejectsAZeroLengthBlade()
        {
            var weapon = new GameObject("Weapon").transform;
            SpatialSmearEffect effect = CreateEffect(weapon);

            Assert.Throws<System.ArgumentException>(() => effect.AttachWeapon(weapon, Vector3.up, Vector3.up));

            Release(effect, weapon);
        }
    }
}
