using Epam.Library.Bll.Contracts;
using Epam.Library.Common.DependencyInjection;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;
using System;
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
            _newspaperBll = DependencyInjection.NewspaperBll;
            _catalogueBll = DependencyInjection.CatalogueBll;

            _newspaperIDs = new List<int>();
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _newspaperIDs.ForEach(a => _newspaperBll.Remove(a));
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(null, "Add-True", 0, null, false, "Test", "Test", DateTime.Now.Year, null, null, DateTime.Now);
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
                Assert.Throws<AddException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Remove_True()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(null, "Remove True", 0, null, false, "Test", "Test", DateTime.Now.Year, null, null, DateTime.Now);
            _newspaperBll.Add(newspaper);

            int id = GetId(newspaper).Value;

            int preCount = GetCount();

            // Act
            bool isRemoved = _newspaperBll.Remove(id);

            int postCount = GetCount();

            if (!isRemoved || preCount == postCount)
            {
                _newspaperIDs.Add(id);
            }

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsTrue(isRemoved);
                Assert.AreEqual(preCount - 1, postCount);
            });
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
                Assert.Throws<RemoveException>(test);
                Assert.AreEqual(preCount, GetCount());
            });
        }

        [Test]
        public void Get()
        {
            // Arrange
            Newspaper newspaper = new Newspaper(null, "Get", 0, null, false, "Test", "Test", DateTime.Now.Year, null, null, DateTime.Now);
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
            Assert.Throws<GetException>(test);
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

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange
            Newspaper[] newspapers = new Newspaper[]
            {
                new Newspaper(null, "GpoupsByPublishYear One", 0, null, false, "Test", "Test", DateTime.Now.Year - 5, null, null, DateTime.Now.AddYears(-5)),
                new Newspaper(null, "GpoupsByPublishYear Two", 0, null, false, "Test", "Test", DateTime.Now.Year - 2, null, null, DateTime.Now.AddYears(-2)),
            };

            List<int> ids = new List<int>();

            foreach (var item in newspapers)
            {
                _newspaperBll.Add(item);

                ids.Add(GetId(item).Value);
            }

            _newspaperIDs.AddRange(ids);

            // Act
            int result = _newspaperBll.GetAllGroupsByPublishYear().Count();

            // Assert
            Assert.IsTrue(result >= 2);
        }

        private int GetCount()
        {
            return _newspaperBll.Search(null).Count();
        }

        private int? GetId(Newspaper newspaper)
        {
            return _newspaperBll.Search(null)
                .Where(a => a.Equals(newspaper))
                .LastOrDefault()
                ?.Id.Value;
        }
    }
}
