using System.Linq;
using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.Reference;

namespace HarrellDavisEfficiency
{
    public class RightSkewedBimodalDistributionSet: IReferenceDistributionSet
    {
        public static readonly IReferenceDistributionSet Instance = new RightSkewedBimodalDistributionSet();

        public string Key => "RSM2DS";
        public string Description => "A set of bimodal right-skewed distributions";
        public ReferenceDistribution[] Distributions { get; }

        private static ReferenceDistribution Create(IContinuousDistribution distribution, double shift = 10) =>
            new ReferenceDistribution(new MixtureDistribution(distribution, new ShiftedDistribution(distribution, shift)));

        private RightSkewedBimodalDistributionSet()
        {
            Distributions = RightSkewedUnimodalDistributionSet.Instance
                .Distributions
                .Select(d => Create(d.Distribution))
                .ToArray();
        }
    }
}