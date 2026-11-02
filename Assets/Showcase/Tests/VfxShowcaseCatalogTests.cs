using System.Linq;
using ConfusedGameDev.Vfx.Showcase.Editor;
using NUnit.Framework;
using UnityEditor;

namespace ConfusedGameDev.Vfx.Showcase.Tests
{
    public class VfxShowcaseCatalogTests
    {
        private static VfxShowcaseCatalog Catalog => AssetDatabase.LoadAssetAtPath<VfxShowcaseCatalog>("Assets/Showcase/Data/ShowcaseCatalog.asset");

        [Test]
        public void Tables_CoverEveryFolder()
        {
            Assert.That(VfxShowcaseBuilder.Unclassified(), Is.Empty);
        }

        [Test]
        public void Catalog_ListsEveryEffectAndObjectOnce()
        {
            var effects = Catalog.categories.Where(category => !category.objects).SelectMany(category => category.items).ToList();
            var objects = Catalog.categories.Where(category => category.objects).SelectMany(category => category.items).ToList();

            Assert.That(effects.Count, Is.EqualTo(60));
            Assert.That(objects.Count, Is.EqualTo(46));
            Assert.That(effects.Concat(objects).Select(item => item.name), Is.Unique);
        }

        [Test]
        public void Catalog_HasAPrefabForEveryItemExceptImpactFrame()
        {
            var missing = Catalog.categories.SelectMany(category => category.items).Where(item => item.prefab == null);

            Assert.That(missing.Select(item => item.display), Is.EqualTo(new[] { VfxShowcaseDisplay.ImpactFrame }));
        }
    }
}
