using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.QuantileEstimators;
using Perfolizer.Mathematics.Reference;

namespace Efficiency
{
    class Program
    {
        static void Main()
        {
            new Program().Run();
        }

        private void Run()
        {
            InitCulture();
            Simulate();
        }

        private void Simulate()
        {
            var estimators = new IQuantileEstimator[]
            {
                HarrellDavisQuantileEstimator.Instance,
                new WinsorizedHarrellDavisQuantileEstimator(0.01),
                new TrimmedHarrellDavisQuantileEstimator(0.01),
                new WinsorizedHarrellDavisQuantileEstimator(0.05),
                new TrimmedHarrellDavisQuantileEstimator(0.05),
            };

            var probabilities = Enumerable.Range(1, 99 / 2).Select(p => (Probability) (p * 2 / 100.0)).ToArray();
            int[] sampleSizes = Enumerable.Range(2, 39).ToArray();

            var sw = Stopwatch.StartNew();
            
            Run("LightAndHeavy", estimators, probabilities, sampleSizes,
                LightAndHeavyDistributionSet.Instance.Distributions);
            sw.Stop();
            Console.WriteLine($"Total Elapsed: {sw.Elapsed}");
        }

        private void Run(
            string name,
            IReadOnlyList<IQuantileEstimator> estimators,
            Probability[] probabilities,
            int[] sampleSizes,
            ReferenceDistribution[] referenceDistributions)
        {
            SavePdf(name, referenceDistributions);
            SaveDescription(name, referenceDistributions);
            RunAndSaveEfficiency(name, estimators, probabilities, sampleSizes, referenceDistributions);
        }

        private void RunAndSaveEfficiency(string name, IReadOnlyList<IQuantileEstimator> estimators,
            Probability[] probabilities,
            int[] sampleSizes, ReferenceDistribution[] referenceDistributions)
        {
            string fileName = $"{name}_Efficiency.csv";
            Console.WriteLine($"Start simulation for {name}");

            var simulator = new QuantileEstimatorEfficiencySimulator();
            var sw = Stopwatch.StartNew();
            var result = simulator.Run(estimators, probabilities, sampleSizes, referenceDistributions, progress =>
            {
                double elapsedSec = sw.Elapsed.TotalSeconds;
                double etaSec = elapsedSec * (100 - progress) / progress;
                Console.WriteLine($"Progress: {progress:N2}% Elapsed:{elapsedSec:N1}s ETA:{etaSec:N1}s");
            });
            sw.Stop();
            Console.WriteLine($"Elapsed: {sw.Elapsed.TotalSeconds:N1}s");

            result.SaveToCsv(fileName);
            Console.WriteLine($"Generated: {fileName}");
        }

        private void SavePdf(string name, ReferenceDistribution[] referenceDistributions)
        {
            string fileName = $"{name}_Pdf.csv";
            using var writer = new StreamWriter(fileName);
            writer.WriteLine("distribution,x,pdf");

            foreach (var referenceDistribution in referenceDistributions)
            {
                var distribution = referenceDistribution.Distribution;
                string distributionName = referenceDistribution.Key;

                double low = distribution.Quantile(0.01);
                double low2 = distribution.Quantile(0);
                if (low2 > -1)
                    low = low2;
                double high = distribution.Quantile(0.9);
                double high2 = distribution.Quantile(0.99);
                if (high2 - low < (high - low) * 3)
                    high = high2;
                high2 = distribution.Quantile(1);
                if (high2 < double.PositiveInfinity && high2 - low < (high - low) * 3)
                    high = high2;
                const int n = 1001;
                double[] xs = Enumerable.Range(0, n).Select(i => low + (high - low) / (n - 1) * i).ToArray();
                double[] pdfs = xs.Select(x => distribution.Pdf(x)).ToArray();
                double maxPdf = SimpleQuantileEstimator.Instance.GetQuantile(new Sample(pdfs), 0.99) * 10; // PDF Normalization
                for (int i = 0; i < xs.Length; i++)
                {
                    double x = xs[i], pdf = Math.Min(pdfs[i], maxPdf);
                    writer.WriteLine($"\"{distributionName}\",{x},{pdf}");
                }
            }

            Console.WriteLine($"Generated: {fileName}");
        }

        private void SaveDescription(string name, ReferenceDistribution[] referenceDistributions)
        {
            string fileName = $"{name}_Description.csv";
            using var writer = new StreamWriter(fileName);
            writer.WriteLine("distribution,description");
            foreach (var distribution in referenceDistributions)
                writer.WriteLine($"\"{distribution.Key}\",\"{distribution.Description}\"");
            Console.WriteLine($"Generated: {fileName}");

            string fileName2 = $"{name}_Description.md";
            using var writer2 = new StreamWriter(fileName2);
            foreach (var d in referenceDistributions)
            {
                writer2.WriteLine($"* **{d.Key}**: {d.Description}  ");
                writer2.WriteLine($"  `{d.Distribution}`");
            }

            Console.WriteLine($"Generated: {fileName2}");
        }

        private static void InitCulture()
        {
            var culture = (CultureInfo) CultureInfo.InvariantCulture.Clone();
            culture.NumberFormat.NumberDecimalSeparator = ".";
            culture.NumberFormat.NumberGroupSeparator = "";
            CultureInfo.CurrentCulture = culture;
        }
    }
}