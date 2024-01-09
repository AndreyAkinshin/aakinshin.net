using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using Perfolizer.Mathematics.QuantileEstimators;

namespace Simulation;

public static class Program
{
    /// <param name="estimators">Comma-separated list of target quantile estimators</param>
    /// <param name="sampleSizes">Comma-separated list of target sample sizes</param>
    /// <param name="iterations">The number of iterations</param>
    /// <param name="seedBase">The seed base for sample generation</param>
    public static void Main(
        string estimators = "hf7,hd,thd-sqrt",
        string sampleSizes = "2..100,110,120,130,140,150,200,250,300,350,400,450,500,1000,1500,2000",
        int iterations = 200_000_000,
        int seedBase = 0
    )
    {
        PrepareEnvironment();
        Simulator.Simulate(ParseQuantileEstimators(estimators), ParseSampleSizes(sampleSizes), iterations, seedBase);
    }

    private static void PrepareEnvironment()
    {
        CultureInfo.CurrentCulture = DefaultCultureInfo.Instance;
        CultureInfo.CurrentUICulture = DefaultCultureInfo.Instance;
        
        var directory = Path.Combine(Directory.GetCurrentDirectory(), "data");
        if (!Directory.Exists(directory))
            Directory.CreateDirectory(directory);
        Directory.SetCurrentDirectory(directory);
    }

    private static int[] ParseSampleSizes(string value)
    {
        return value.Split(',').SelectMany(ParseSampleSize).ToArray();
    }

    private static IEnumerable<int> ParseSampleSize(string value)
    {
        if (value.Contains(".."))
        {
            var split = value.Split("..");
            var first = int.Parse(split[0]);
            var last = int.Parse(split[1]);
            for (var i = first; i <= last; i++)
                yield return i;
        }
        else
        {
            yield return int.Parse(value);
        }
    }

    private static IQuantileEstimator[] ParseQuantileEstimators(string value)
    {
        return value.Split(',').Select(ParseQuantileEstimator).ToArray();
    }

    private static IQuantileEstimator ParseQuantileEstimator(string value)
    {
        return value switch
        {
            "hf7" => SimpleQuantileEstimator.Instance,
            "hd" => HarrellDavisQuantileEstimator.Instance,
            "thd-sqrt" => TrimmedHarrellDavisQuantileEstimator.SqrtInstance,
            _ => throw new InvalidDataException($"Unknown quantile estimator alias: {value}")
        };
    }
}