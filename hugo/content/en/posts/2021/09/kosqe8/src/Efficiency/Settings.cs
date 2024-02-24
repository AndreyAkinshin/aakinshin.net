using System;
using Perfolizer.Mathematics.QuantileEstimators;

namespace Efficiency
{
    public static class Settings
    {
        public const int MinSampleSize = 5; // Default: 2
        public const int MaxSampleSize = 15; // Default: 40
        public const int SampleSizeStep = 5; // Default: 1
        public const int ProbabilitiesStep = 1; // Default: 1
        public const int IterationCount = 200_000; // Default: 100_000
        public const int BootstrapSampleSize = 500; // Default: 500
        public const int BootstrapAttempts = 1000; // Default: 1000

        public static readonly IQuantileEstimator[] Estimators =
        {
            new HyndmanFanQuantileEstimator(HyndmanFanType.Type7),
            new HarrellDavisQuantileEstimator(),
            new NewTrimmedQuantileEstimator(new TrimmingStrategy("SQRT", n => 1 - Math.Sqrt(n) / n)),
            new NewWinsorizedQuantileEstimator(new TrimmingStrategy("SQRT", n => 1 - Math.Sqrt(n) / n))
        };
    }
}