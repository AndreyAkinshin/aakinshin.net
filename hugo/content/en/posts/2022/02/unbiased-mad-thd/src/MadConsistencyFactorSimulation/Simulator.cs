using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Perfolizer.Common;
using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.QuantileEstimators;

namespace Simulation;

public static class Simulator
{
    /// <summary>
    /// Generates <paramref name="iterations"/> samples of size <paramref name="sampleSize"/>
    /// using the given random <paramref name="seed"/>,
    /// estimates the MAD for each sample using the given <paramref name="quantileEstimator"/>,
    /// returns the sum of all estimations.
    /// </summary>
    private static double CalculateMadSum(IQuantileEstimator quantileEstimator, int sampleSize, int iterations,
        int seed)
    {
        var generator = NormalDistribution.Standard.Random(seed);
        var data = new double[sampleSize];
        var deviations = new double[sampleSize];

        double CalcMad()
        {
            var median = quantileEstimator.GetMedian(new Sample(data));
            for (var i = 0; i < sampleSize; i++)
                deviations[i] = Math.Abs(data[i] - median);
            return quantileEstimator.GetMedian(new Sample(deviations));
        }

        double sum = 0;
        for (var iteration = 0; iteration < iterations; iteration++)
        {
            for (var i = 0; i < sampleSize; i++)
                data[i] = generator.Next();
            sum += CalcMad();
        }

        return sum;
    }

    private static double CalculateMadSumParallel(IQuantileEstimator quantileEstimator, int sampleSize, int iterations,
        int seedBase)
    {
        var tasks = new Task<double>[Environment.ProcessorCount];
        var taskIterations = iterations / tasks.Length;
        for (var i = 0; i < tasks.Length; i++)
        {
            var taskSeed = seedBase + sampleSize * tasks.Length + i;
            tasks[i] = Task.Factory.StartNew(() =>
                CalculateMadSum(quantileEstimator, sampleSize, taskIterations, taskSeed));
        }

        Task.WhenAll(tasks);

        var totalSum = tasks.Sum(t => t.Result);
        var totalIterations = taskIterations * tasks.Length;
        var averageMad = totalSum / totalIterations;
        return averageMad;
    }

    private static double CalculateMadConsistencyFactor(IQuantileEstimator estimator, int sampleSize, int iterations,
        int seedBase)
    {
        return 1.0 / CalculateMadSumParallel(estimator, sampleSize, iterations, seedBase);
    }

    public static void Simulate(IQuantileEstimator[] estimators, int[] sampleSizes, int iterations, int seedBase)
    {
        var logFileName = $"simulation-{DateTime.Now:yyyy-MM-dd-hh-mm-ss}.log";
        using var logWriter = new StreamWriter(logFileName);

        void Print(string message)
        {
            Console.WriteLine(message);
            logWriter.WriteLine(message);
            logWriter.Flush();
        }

        Print("Simulation started");
        Print($"LogFile: {logFileName}");

        var totalStopwatch = Stopwatch.StartNew();
        foreach (var estimator in estimators)
        {
            Print($"Estimator: {estimator.Alias}");
            var storage = new Storage(estimator.Alias.ToLowerInvariant());
            foreach (var sampleSize in sampleSizes)
            {
                var precalculatedFactor = storage.Get(sampleSize);
                if (precalculatedFactor != null)
                {
                    Print($"  {sampleSize}: {precalculatedFactor} (precalculated)");
                }
                else
                {
                    var factorStopwatch = Stopwatch.StartNew();
                    var factor = CalculateMadConsistencyFactor(estimator, sampleSize, iterations, seedBase);
                    factorStopwatch.Stop();
                    storage.Add(sampleSize, factor);
                    Print($"  {sampleSize}: {factor} (elapsed: {factorStopwatch.Elapsed})");
                }
            }
        }

        totalStopwatch.Stop();
        Print($"Simulation finished (total elapsed: {totalStopwatch.Elapsed})");
    }
}