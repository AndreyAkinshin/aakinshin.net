using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.Reference;

namespace Efficiency
{
    public class LightAndHeavyDistributionSet : IReferenceDistributionSet
    {
        public static readonly IReferenceDistributionSet Instance = new LightAndHeavyDistributionSet();

        public string Key => "LHTDS";
        public string Description => "A set of light-tailed and heavy-tailed distributions";
        public ReferenceDistribution[] Distributions { get; }

        private LightAndHeavyDistributionSet()
        {
            Distributions = new[]
            {
                new ReferenceDistribution(new UniformDistribution(0, 1)),
                new ReferenceDistribution(new BetaDistribution(2, 10)),
                new ReferenceDistribution(new NormalDistribution()),
                new ReferenceDistribution(new WeibullDistribution(shape: 2)),
                new ReferenceDistribution(new ExponentialDistribution()),
                new ReferenceDistribution(new CauchyDistribution()),
                new ReferenceDistribution(new ParetoDistribution(1, 0.5)),
                new ReferenceDistribution(new LogNormalDistribution(stdDev: 3)),
                new ReferenceDistribution(new WeibullDistribution(shape: 0.5)),
                new ReferenceDistribution(new FrechetDistribution(location:0, scale:1, shape:3))
            };
        }
    }
}