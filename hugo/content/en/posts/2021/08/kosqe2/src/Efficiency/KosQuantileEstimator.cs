using System;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.QuantileEstimators;

namespace Efficiency
{
    public class KosQuantileEstimator : IQuantileEstimator
    {
        public enum Type
        {
            Linear, Beta
        }
        
        private readonly int k;
        private readonly Type type;
        
        public KosQuantileEstimator(int k, Type type)
        {
            this.k = k;
            this.type = type;
        }

        public double GetQuantile(Sample sample, Probability probability)
        {
            int n = sample.Count;
            double p = probability;
            double h = (n - 1) * p + 1;
            double k0 = Math.Min(n, k - 1);
            double left = (h - 1) / (n - 1) * (n - k0) / n;
            double right = left + k0 * 1.0 / n;

            var distributionBeta = new BetaDistribution((k0 + 1) * probability, (k0 + 1) * (1 - probability));

            double Cdf(double x)
            {
                if (x <= left)
                    return 0;
                if (x >= right)
                    return 1;

                var y = (x - left) / (right - left);
                return type switch
                {
                    Type.Linear => y,
                    Type.Beta => distributionBeta.Cdf(y),
                    _ => throw new ArgumentOutOfRangeException()
                };
            }

            double totalWeight = sample.TotalWeight;
            double result = 0;
            double current = 0;
            for (int i = 0; i < n; i++)
            {
                double next = current + sample.Weights[i] / totalWeight;
                result += sample.SortedValues[i] * (Cdf(next) - Cdf(current));
                current = next;
            }

            return result;
        }

        private string GetKeyword()
        {
            switch (type)
            {
                case Type.Linear:
                    return "L";
                case Type.Beta:
                    return "B";
                default:
                    return "?";
            }
        }

        public bool SupportsWeightedSamples => false;
        public string Alias => "KOS" + "-" + GetKeyword() + k;
    }
}