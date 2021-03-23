using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.Reference;

namespace HarrellDavisEfficiency
{
    public class SymmetricDistributionSet : IReferenceDistributionSet
    {
        public static readonly IReferenceDistributionSet Instance = new SymmetricDistributionSet();

        public string Key => "SDS";
        public string Description => "A set of symmetric distributions";
        public ReferenceDistribution[] Distributions { get; }

        private SymmetricDistributionSet()
        {
            Distributions = new[]
            {
                new ReferenceDistribution("Beta(2,2)", "Beta distribution with a=b=2", new BetaDistribution(2, 2)),
                new ReferenceDistribution("Beta(3,3)", "Beta distribution with a=b=3", new BetaDistribution(3, 3)),
                new ReferenceDistribution("Beta(4,4)", "Beta distribution with a=b=4", new BetaDistribution(4, 4)),
                new ReferenceDistribution("Beta(5,5)", "Beta distribution with a=b=4", new BetaDistribution(5, 5)),
                new ReferenceDistribution("U(0,1)", "Uniform distribution on [0;1]", new UniformDistribution(0, 1)),
                new ReferenceDistribution("N(0,1)", "Normal with mu=0, sigma=1", new NormalDistribution()),
                new ReferenceDistribution("DE(0,1)", "Laplace (double exponential) with mu=0, b=1", new LaplaceDistribution(0, 1)),
                new ReferenceDistribution("Cauchy(0,1)", "Cauchy distribution with location=0, scale=1", new CauchyDistribution()),
                new ReferenceDistribution("T(2)", "Student's t with 2 degrees of freedom", new StudentDistribution(2)),
                new ReferenceDistribution("T(3)", "Student's t with 3 degrees of freedom", new StudentDistribution(3)),
                new ReferenceDistribution("T(4)", "Student's t with 4 degrees of freedom", new StudentDistribution(4)),
                new ReferenceDistribution("T(5)", "Student's t with 5 degrees of freedom", new StudentDistribution(5)),
            };
        }
    }

}