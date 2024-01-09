using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.QuantileEstimators;
using Perfolizer.Mathematics.Reference;
using Perfolizer.Mathematics.Sequences;

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
            SetupOutputDirectory();
            Simulate();
        }

        private void Simulate()
        {
            var estimators = Settings.Estimators;
            var probabilities = GenerateSequence(1, 99, Settings.ProbabilitiesStep)
                .Select(p => (Probability)(p / 100.0)).ToArray();
            int[] sampleSizes =
                GenerateSequence(Settings.MinSampleSize, Settings.MaxSampleSize, Settings.SampleSizeStep).ToArray();

            var sw = Stopwatch.StartNew();

            Run("LightAndHeavy", estimators, probabilities, sampleSizes,
                LightAndHeavyDistributionSet.Instance.Distributions);
            sw.Stop();
            Logger.WriteLine($"Total Elapsed: {TimeUtil.Format(sw.Elapsed)}");
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
            RunAndSave(name, estimators, probabilities, sampleSizes, referenceDistributions);
        }

        private void RunAndSave(string name, IReadOnlyList<IQuantileEstimator> estimators,
            Probability[] probabilities,
            int[] sampleSizes, ReferenceDistribution[] referenceDistributions)
        {
            string fileName = $"{name}_Errors.json.gz";
            Logger.WriteLine($"Start simulation for {name}");

            var simulator = new QuantileEstimatorSimulator();
            var sw = Stopwatch.StartNew();
            var result = simulator.Run(estimators, probabilities, sampleSizes, referenceDistributions, progress =>
            {
                double elapsedSec = sw.Elapsed.TotalSeconds;
                double etaSec = elapsedSec * (100 - progress) / progress;
                TimeSpan eta = TimeSpan.FromSeconds(etaSec);
                Logger.WriteLine($"Progress: {progress:N2}% Elapsed:{TimeUtil.Format(sw.Elapsed)} ETA:{TimeUtil.Format(eta)}");
            });
            sw.Stop();
            Logger.WriteLine($"Elapsed: {TimeUtil.Format(sw.Elapsed)}");

            Logger.WriteLine("Saving...");
            sw.Restart();
            sw.Start();
            result.SaveToJsonGz();
            sw.Stop();
            Logger.WriteLine($"Saving is completed in {TimeUtil.Format(sw.Elapsed)}");
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
                double maxPdf = SimpleQuantileEstimator.Instance.GetQuantile(new Sample(pdfs), 0.99) *
                                10; // PDF Normalization
                for (int i = 0; i < xs.Length; i++)
                {
                    double x = xs[i], pdf = Math.Min(pdfs[i], maxPdf);
                    writer.WriteLine($"\"{distributionName}\",{x},{pdf}");
                }
            }

            Logger.WriteLine($"Generated: {fileName}");
        }

        private void SaveDescription(string name, ReferenceDistribution[] referenceDistributions)
        {
            string fileName = $"{name}_Description.csv";
            using var writer = new StreamWriter(fileName);
            writer.WriteLine("distribution,description");
            foreach (var distribution in referenceDistributions)
                writer.WriteLine($"\"{distribution.Key}\",\"{distribution.Description}\"");
            Logger.WriteLine($"Generated: {fileName}");

            string fileName2 = $"{name}_Description.md";
            using var writer2 = new StreamWriter(fileName2);
            foreach (var d in referenceDistributions)
            {
                writer2.WriteLine($"* **{d.Key}**: {d.Description}  ");
                writer2.WriteLine($"  `{d.Distribution}`");
            }

            Logger.WriteLine($"Generated: {fileName2}");
        }

        private static void InitCulture()
        {
            var culture = (CultureInfo)CultureInfo.InvariantCulture.Clone();
            culture.NumberFormat.NumberDecimalSeparator = ".";
            culture.NumberFormat.NumberGroupSeparator = "";
            CultureInfo.CurrentCulture = culture;
        }

        private static void SetupOutputDirectory()
        {
            var directory = new DirectoryInfo(Directory.GetCurrentDirectory());
            while (directory != null && directory.Name != "src")
                directory = directory.Parent;

            directory = directory?.Parent;
            if (directory == null)
                throw new Exception("Can't setup output directory");

            if (Directory.Exists(Path.Combine(directory.FullName, "data")))
                Directory.Delete(Path.Combine(directory.FullName, "data"), true);
            directory = directory.CreateSubdirectory("data");
            Directory.SetCurrentDirectory(directory.FullName);
            Console.WriteLine("Output directory: " + directory.FullName);
        }

        private static int[] GenerateSequence(int from, int to, int step) =>
            new ArithmeticProgressionSequence(from, step)
                .GenerateEnumerable()
                .TakeWhile(value => value <= to)
                .Select(value => (int)Math.Round(value))
                .ToArray();
    }
}