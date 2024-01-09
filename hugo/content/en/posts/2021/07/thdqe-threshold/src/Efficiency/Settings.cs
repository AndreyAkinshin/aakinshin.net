namespace Efficiency
{
    public static class Settings
    {
        public const int MaxSampleSize = 40; // Default: 40
        public const int SampleSizeStep = 1; // Default: 1
        public const int ProbabilitiesStep = 1; // Default: 1
        public const int EfficiencyProbeCount = 99; // Default: 99

        public static readonly double[] TrimPercentages = {
            0.01, 0.05, 0.10, 0.20, 0.30, 0.40, 0.50
        };
    }
}