using Perfolizer.Mathematics.QuantileEstimators;

namespace Efficiency
{
    public static class Settings
    {
        public const int MinSampleSize = 10; // Default: 2
        public const int MaxSampleSize = 30; // Default: 40
        public const int SampleSizeStep = 5; // Default: 1
        public const int ProbabilitiesStep = 1; // Default: 1
        public const int IterationCount = 5_000; // Default: 20000

        public static readonly IQuantileEstimator[] Estimators =
        {
            new HyndmanFanQuantileEstimator(HyndmanFanType.Type7),
            new HarrellDavisQuantileEstimator(),
            new NewTrimmedQuantileEstimator(0.5),
            new NewTrimmedQuantileEstimator(0.75),
            new NewTrimmedQuantileEstimator(0.90)
        };
    }
}