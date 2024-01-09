using Perfolizer.Mathematics.QuantileEstimators;

namespace Efficiency
{
    public static class Settings
    {
        public const int MaxSampleSize = 20; // Default: 40
        public const int SampleSizeStep = 1; // Default: 1
        public const int ProbabilitiesStep = 1; // Default: 1
        public const int EfficiencyProbeCount = 19; // Default: 99

        public static readonly IQuantileEstimator[] Estimators =
        {
            new HarrellDavisQuantileEstimator(),
            new TrimmedHarrellDavisQuantileEstimator(0.5, 1),
            new TrimmedHarrellDavisQuantileEstimator(0.5, 2),
            new TrimmedHarrellDavisQuantileEstimator(0.5, 3),
            // SfakianakisVerginis1QuantileEstimator.Instance,
            // SfakianakisVerginis2QuantileEstimator.Instance,
            // SfakianakisVerginis3QuantileEstimator.Instance,
            // NavruzOzdemirQuantileEstimator.Instance
        };
    }
}