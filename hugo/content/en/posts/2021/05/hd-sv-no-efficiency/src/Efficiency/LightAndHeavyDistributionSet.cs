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
                new ReferenceDistribution(new BetaDistribution(2, 10)),
                new ReferenceDistribution(new UniformDistribution(0, 1)),
                new ReferenceDistribution(new NormalDistribution()),
                new ReferenceDistribution(new WeibullDistribution(shape: 2)),
                new ReferenceDistribution(new CauchyDistribution()),
                new ReferenceDistribution(new ParetoDistribution(1, 0.5)),
                new ReferenceDistribution(new LogNormalDistribution(stdDev: 3)),
                new ReferenceDistribution("Exp(1) + Outliers", "95% of Exp(1) and 5% of U(0, 10000)",
                    new MixtureDistribution(
                        new IContinuousDistribution[] {new ExponentialDistribution(), new UniformDistribution(0, 10_000)},
                        new[] {0.95, 0.05}
                    ))
            };
        }
    }
}