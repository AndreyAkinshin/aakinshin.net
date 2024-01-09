using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.QuantileEstimators;
using Perfolizer.Mathematics.Reference;
using static System.Math;

namespace Efficiency
{
    public class QuantileEstimatorSimulator
    {
        private readonly int iterationCount;

        private static int seed = 42;
        private static ThreadLocal<Random> Random { get; } = new(() => new Random(Interlocked.Increment(ref seed)));
        private int processedItems;

        public QuantileEstimatorSimulator(int iterationCount = Settings.IterationCount)
        {
            this.iterationCount = iterationCount;
        }

        public Result Run(
            IReadOnlyList<IQuantileEstimator> estimators,
            Probability[] probabilities,
            int[] sampleSizes,
            ReferenceDistribution[] referenceDistributions,
            Action<double> progressReportCallback = null
        )
        {
            var items = new List<Item>();
            foreach (var estimator in estimators)
            foreach (var probability in probabilities)
            foreach (var sampleSize in sampleSizes)
            foreach (var referenceDistribution in referenceDistributions)
                items.Add(new Item(estimator, probability, sampleSize, referenceDistribution));
            processedItems = 0;

            Parallel.ForEach(items, item =>
            {
                item.Process(iterationCount);
                int processedItemsSnapshot = Interlocked.Increment(ref processedItems);
                if (processedItemsSnapshot % 200 == 0)
                {
                    double progress = processedItemsSnapshot * 100.0 / items.Count;
                    progressReportCallback?.Invoke(progress);
                }
            });

            return new Result(items);
        }

        public class Result
        {
            public IReadOnlyList<Item> Items { get; }

            public Result(IReadOnlyList<Item> items)
            {
                Items = items;
            }

            public void SaveToJsonGz()
            {
                var models = Items.Select(item => item.ToModel()).ToArray();
                var serializeOptions = new JsonSerializerOptions
                {
                    Converters = { new DoubleJsonConverter() },
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                };
                
                foreach (var grouping in models.GroupBy(model => model.Estimator))
                {
                    var fileName = grouping.Key.Replace("%", "") + ".json.gz";
                    var content = JsonSerializer.Serialize(grouping.ToArray(), serializeOptions);
                    FileUtil.WriteAllTextCompressed(fileName, content);
                }
            }
        }

        public class Item
        {
            public IQuantileEstimator Estimator { get; }
            public Probability Probability { get; }
            public int SampleSize { get; }
            public ReferenceDistribution ReferenceDistribution { get; }
            public double[] Errors { get; private set; }

            public Item(IQuantileEstimator estimator, Probability probability, int sampleSize,
                ReferenceDistribution referenceDistribution)
            {
                Estimator = estimator;
                Probability = probability;
                SampleSize = sampleSize;
                ReferenceDistribution = referenceDistribution;
            }

            internal void Process(int iterationCount)
            {
                Errors = new double[iterationCount];

                var distribution = ReferenceDistribution.Distribution;
                var quantileTrueValue = distribution.Quantile(Probability);
                var randomGenerator = distribution.Random(Random.Value);

                for (int i = 0; i < iterationCount; i++)
                {
                    var sample = new Sample(randomGenerator.Next(SampleSize));
                    Errors[i] = Estimator.GetQuantile(sample, Probability) - quantileTrueValue;
                }
            }

            public ItemModel ToModel()
                => new ItemModel(Estimator.Alias, Probability, SampleSize, ReferenceDistribution.Key, Errors);
        }

        public class ItemModel
        {
            private static readonly Probability[] Percentiles = Enumerable
                .Range(0, 101)
                .Select(p => (Probability)(p / 100.0))
                .ToArray();
            
            public string Estimator { get; }
            public double Probability { get; }
            public int SampleSize { get; }
            public string Distribution { get; }
            public double Mse { get; }
            public double MedianSe { get; }
            public double[] ErrorPercentiles { get; }

            public ItemModel(string estimator, double probability, int sampleSize, string distribution, double[] errors)
            {
                Estimator = estimator;
                Probability = probability;
                SampleSize = sampleSize;
                Distribution = distribution;
                Mse = GetMse(errors);
                ErrorPercentiles = new HyndmanFanQuantileEstimator(HyndmanFanType.Type7)
                        .GetQuantiles(new Sample(errors), Percentiles);
            }

            public static double GetMse(double[] values)
            {
                double[] mses = new double[199];
                var data = new double[values.Length / 10];
                var random = Random.Value;
                if (random == null)
                    throw new InvalidCastException("random is null");
                
                for (int i = 0; i < mses.Length; i++)
                {
                    for (int j = 0; j < data.Length; j++)
                        data[j] = values[random.Next(values.Length)];
                    mses[i] = data.Select(x => x.Sqr()).Average();
                }
                return SimpleQuantileEstimator.Instance.GetMedian(new Sample(mses));
            }
        }
    }
}