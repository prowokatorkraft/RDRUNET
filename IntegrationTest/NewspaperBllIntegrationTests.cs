using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.IntegrationTest
{
    public class NewspaperBllIntegrationTests
    {
        private INewspaperBll _newspaperBll;
        private ICatalogueBll _catalogueBll;

        private List<int> _newspaperIDs;

        [OneTimeSetUp]
        public void InitClass()
        {
            _newspaperBll = NinjectForTests.NewspaperBll;
            _catalogueBll = NinjectForTests.CatalogueBll;

            _newspaperIDs = new List<int>();
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _newspaperIDs.ForEach(a => _newspaperBll.Remove(a, RoleType.admin));
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(null, "Add-True", null, false);
            int preCount = GetCount();
            int id;

            // Act
            var errors = _newspaperBll.Add(newspaper);
            _newspaperIDs.Add(id = GetId(newspaper).Value);
            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount + 1, postCount);
            });
        }

        [Test]
        public void Add_False()
        {
            // Arrange
            Newspaper newspaper = new Newspaper();
            int preCount = GetCount();

            // Act
            var errors = _newspaperBll.Add(newspaper);
            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsTrue(errors.Count() > 0);
                Assert.AreEqual(preCount, postCount);
            });
        }

        [Test]
        public void Add_Null_Exception()
        {
            // Arrange
            int preCoutn = GetCount();

            // Act
            TestDelegate test = () => _newspaperBll.Add(null);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Update_True()
        {
            // Arrange
            Newspaper newspaper1 = new Newspaper(null, "Add-True", null, false);
            Newspaper newspaper2 = new Newspaper(null, "Addtrue-True", null, false);
            int id;

            _newspaperBll.Add(newspaper1);
            _newspaperIDs.Add(id = GetId(newspaper1).Value);
            newspaper2.Id = id;

            int preCount = GetCount();

            // Act
            var errors = _newspaperBll.Update(newspaper2);

            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount, postCount);
                Assert.IsTrue(newspaper2.Equals(_newspaperBll.Get(newspaper2.Id.Value)));
            });
        }

        [Test]
        public void Update_False()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(-100, null, null, false);
            int preCount = GetCount();

            // Act
            var errors = _newspaperBll.Update(newspaper);
            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsTrue(errors.Count() > 0);
                Assert.AreEqual(preCount, postCount);
            });
        }

        [Test]
        public void Update_Null_Exception()
        {
            // Arrange
            int preCoutn = GetCount();

            // Act
            TestDelegate test = () => _newspaperBll.Update(null);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Update_IdNull_Exception()
        {
            // Arrange
            int preCoutn = GetCount();

            // Act
            TestDelegate test = () => _newspaperBll.Update(new Newspaper(null, null, null, false));

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Remove_True()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(null, "Remove True", null, false);
            _newspaperBll.Add(newspaper);

            int id = GetId(newspaper).Value;

            int preCount = GetCount();

            // Act
            _newspaperBll.Remove(id, RoleType.admin);

            int postCount = GetCount();

            if (preCount == postCount)
            {
                _newspaperIDs.Add(id);
            }

            // Assert
            Assert.AreEqual(preCount - 1, postCount);
        }

        [Test]
        public void Remove_Exception_False()
        {
            // Arrange
            int preCount = GetCount();

            // Act
            TestDelegate test = () => _newspaperBll.Remove(-30000);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCount, GetCount());
            });
        }

        [Test]
        public void Get()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(null, "Get", null, false);
            _newspaperBll.Add(newspaper);

            int id;
            _newspaperIDs.Add(id = GetId(newspaper).Value);

            // Act
            var element = _newspaperBll.Get(id);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsNotNull(element);
                Assert.AreEqual(newspaper, element);
            });
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange
            TestDelegate test = () => _newspaperBll.Get(-30000);

            // Assert
            Assert.Throws<LayerException>(test);
        }

        [TestCaseSource(typeof(NewspaperBllIntegrationTestCases), nameof(NewspaperBllIntegrationTestCases.Search))]
        public bool Search(Newspaper newspaper, SearchRequest<SortOptions, NewspaperSearchOptions> request)
        {
            // Arrange
            if (newspaper != null)
            {
                _newspaperBll.Add(newspaper);

                _newspaperIDs.Add(GetId(newspaper).Value);
            }

            // Act
            bool result = _newspaperBll.Search(request).Any(a => a.Equals(newspaper));

            // Assert
            return result;
        }

        private int GetCount()
        {
            return _newspaperBll.Search(null).Count();
        }

        private int? GetId(Newspaper newspaper)
        {
            return _newspaperBll.Search(null)
                .Where(a => a.Equals(newspaper))
                ?.Max(b => b.Id);
        }
    }
}
