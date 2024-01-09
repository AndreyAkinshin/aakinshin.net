using Perfolizer.Mathematics.QuantileEstimators;

namespace Efficiency
{
    public static class Settings
    {
        public const int MaxSampleSize = 15; // Default: 40
        public const int SampleSizeStep = 1; // Default: 1
        public const int ProbabilitiesStep = 1; // Default: 1
        public const int EfficiencyProbeCount = 19; // Default: 99

        public static readonly IQuantileEstimator[] Estimators =
        {
            new HarrellDavisQuantileEstimator(),
            new KosQuantileEstimator(2, KosQuantileEstimator.Type.Linear),
            new KosQuantileEstimator(3, KosQuantileEstimator.Type.Linear),
            new KosQuantileEstimator(4, KosQuantileEstimator.Type.Linear),
            new KosQuantileEstimator(5, KosQuantileEstimator.Type.Linear),
            new KosQuantileEstimator(6, KosQuantileEstimator.Type.Linear),
        };
    }
}