using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.Reference;

namespace HarrellDavisEfficiency
{
    public class RightSkewedUnimodalDistributionSet: IReferenceDistributionSet
    {
        public static readonly IReferenceDistributionSet Instance = new RightSkewedUnimodalDistributionSet();

        public string Key => "RSM2DS";
        public string Description => "A set of unimodal right-skewed distributions";
        public ReferenceDistribution[] Distributions { get; }

        private RightSkewedUnimodalDistributionSet()
        {
            Distributions = new[]
            {
                new ReferenceDistribution(new ExponentialDistribution()),
                new ReferenceDistribution(new BetaDistribution(2, 3)),
                new ReferenceDistribution(new BetaDistribution(2, 9)),
                new ReferenceDistribution(new GumbelDistribution()),
                new ReferenceDistribution(new ParetoDistribution(1, 0.5)),
                new ReferenceDistribution(new ParetoDistribution(1, 1)),
                new ReferenceDistribution(new ParetoDistribution(1, 10)),
                new ReferenceDistribution(new ParetoDistribution(1, 100)),
                new ReferenceDistribution(new WeibullDistribution(0.5)),
                new ReferenceDistribution(new WeibullDistribution(1)),
                new ReferenceDistribution(new WeibullDistribution(1.5)),
                new ReferenceDistribution(new WeibullDistribution(2)),
                new ReferenceDistribution(new FrechetDistribution(shape:0.5)),
                new ReferenceDistribution(new FrechetDistribution(shape:1)),
                new ReferenceDistribution(new FrechetDistribution(shape:5)),
                new ReferenceDistribution(new FrechetDistribution(shape:10)),
                new ReferenceDistribution(new LogNormalDistribution(stdDev: 0.5)),
                new ReferenceDistribution(new LogNormalDistribution(stdDev: 1.0)),
                new ReferenceDistribution(new LogNormalDistribution(stdDev: 1.5)),
                new ReferenceDistribution(new LogNormalDistribution(stdDev: 3)),
            };
        }
    }
}