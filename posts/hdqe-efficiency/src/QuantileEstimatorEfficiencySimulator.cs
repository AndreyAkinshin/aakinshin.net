using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.QuantileEstimators;
using Perfolizer.Mathematics.Reference;

namespace HarrellDavisEfficiency
{
    public class QuantileEstimatorEfficiencySimulator
    {
        private readonly IQuantileEstimator baselineEstimator;
        private readonly int iterationCount;

        private static int seed = 42;
        private static ThreadLocal<Random> Random { get; } = new(() => new Random(Interlocked.Increment(ref seed)));
        private int processedItems;

        public QuantileEstimatorEfficiencySimulator(IQuantileEstimator baselineEstimator = null, int iterationCount = 500)
        {
            this.baselineEstimator = baselineEstimator ?? new HyndmanFanQuantileEstimator(HyndmanFanType.Type7);
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
                item.Process(iterationCount, baselineEstimator);
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

            public void SaveToCsv(string fileName)
            {
                using var writer = new StreamWriter(fileName);
                writer.WriteLine("estimator,quantile,n,distribution,efficiency");
                foreach (var item in Items)
                {
                    string estimator = item.Estimator.Alias;
                    var quantile = item.Probability;
                    int n = item.SampleSize;
                    string distribution = item.ReferenceDistribution.Key;
                    double efficiency = item.RelativeEfficiency;
                    writer.WriteLine($"{estimator},{quantile},{n},\"{distribution}\",{efficiency}");
                }
            }
        }

        public class Item
        {
            public IQuantileEstimator Estimator { get; }
            public Probability Probability { get; }
            public int SampleSize { get; }
            public ReferenceDistribution ReferenceDistribution { get; }
            public double RelativeEfficiency { get; private set; }

            private static readonly IQuantileEstimator EfficiencyEstimator = new WinsorizedHarrellDavisQuantileEstimator(0.1);

            public Item(IQuantileEstimator estimator, Probability probability, int sampleSize, ReferenceDistribution referenceDistribution)
            {
                Estimator = estimator;
                Probability = probability;
                SampleSize = sampleSize;
                ReferenceDistribution = referenceDistribution;
            }

            internal void Process(int iterationCount, IQuantileEstimator baselineEstimator)
            {
                var distribution = ReferenceDistribution.Distribution;
                double quantileTrueValue = distribution.Quantile(Probability);
                var randomGenerator = distribution.Random(Random.Value);
                double[] efficiencies = new double[19];

                for (int i = 0; i < efficiencies.Length; i++)
                {
                    double targetMse = 0, baselineMse = 0;
                    for (int iteration = 0; iteration < iterationCount; iteration++)
                    {
                        var sample = new Sample(randomGenerator.Next(SampleSize));
                        targetMse += (Estimator.GetQuantile(sample, Probability) - quantileTrueValue).Sqr();
                        baselineMse += (baselineEstimator.GetQuantile(sample, Probability) - quantileTrueValue).Sqr();
                    }
                    efficiencies[i] = baselineMse / targetMse;
                }
                RelativeEfficiency = EfficiencyEstimator.GetMedian(new Sample(efficiencies));
            }
        }
    }
}