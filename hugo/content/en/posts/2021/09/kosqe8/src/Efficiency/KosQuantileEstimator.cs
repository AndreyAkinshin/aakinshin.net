using System;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.QuantileEstimators;
using static System.Math;

namespace Efficiency
{
    public class KosQuantileEstimator : IQuantileEstimator
    {
        public enum Type
        {
            Linear, Beta, Thd, ThdHf7
        }
        
        private readonly int k;
        private readonly Type type;
        
        public KosQuantileEstimator(int k, Type type)
        {
            this.k = k;
            this.type = type;
        }

        public static double Uniroot(Func<double, double> f, double left, double right)
        {
            var fl = f(left);
            var fr = f(right);
            if (fl < 0 && fr < 0 || fl > 0 && fr > 0)
                return double.NaN;
            
            while ((right - left) > 1e-7)
            {
                double m = (left + right) / 2;
                double fm = f(m);
                if (fl < 0 && fm < 0 || fl > 0 && fm > 0)
                {
                    fl = fm;
                    left = m;
                }
                else
                {
                    fr = fm;
                    right = m;
                }
            }
            return (left + right) / 2;
        }

        public double GetQuantile(Sample sample, Probability probability)
        {
            int n = sample.Count;
            double p = probability;
            double h = (n - 1) * p + 1;
            double k0 = Math.Min(n, k - 1);
            double a = (n + 1) * probability;
            double b = (n + 1) * (1 - probability);
            
            double left = (h - 1) / (n - 1) * (n - k0) / n;
            double right = left + k0 * 1.0 / n;
            var distributionBeta = new BetaDistribution((k0 + 1) * probability, (k0 + 1) * (1 - probability));
            var distributionThd = new BetaDistribution((n + 1) * probability, (n + 1) * (1 - probability));
            var thdHf7L = distributionThd.Cdf(left);
            var thdHf7R = distributionThd.Cdf(right);

            double thdLeft = Uniroot(x =>
                Pow(x, a - 1) * Pow(1 - x, b - 1) - Pow(x + k0 * 1.0 / n, a - 1) * Pow(1 - x - k0 * 1.0 / n, b - 1),
                0 + 1e-7, 1 - k0 * 1.0 / n - 1e-7);
            if (double.IsNaN(thdLeft))
                thdLeft = p < 0.5 ? 0 : 1 - k0 * 1.0 / n;
            double thdRight = thdLeft + k0 * 1.0 / n;
            var thdL = distributionThd.Cdf(thdLeft);
            var thdR = distributionThd.Cdf(thdRight);

            double Cdf(double x)
            {
                if (type == Type.Thd)
                {
                    if (x <= thdLeft)
                        return 0;
                    if (x >= thdRight)
                        return 1;

                    return (distributionThd.Cdf(x) - thdL) / (thdR - thdL);
                }
                
                if (x <= left)
                    return 0;
                if (x >= right)
                    return 1;

                var y = (x - left) / (right - left);
                return type switch
                {
                    Type.Linear => y,
                    Type.Beta => distributionBeta.Cdf(y),
                    Type.ThdHf7 => (distributionThd.Cdf(x) - thdHf7L) / (thdHf7R - thdHf7L),
                    _ => throw new ArgumentOutOfRangeException()
                };
            }

            double totalWeight = sample.TotalWeight;
            double result = 0;
            double current = 0;
            for (int i = 0; i < n; i++)
            {
                double next = current + sample.Weights[i] / totalWeight;
                var weight = Cdf(next) - Cdf(current);
                // if (weight < 1e-9)
                //     Console.WriteLine($"  W[{i}] = ");
                // else
                //     Console.WriteLine($"  W[{i}] = {weight:0.0000}");
                result += sample.SortedValues[i] * weight;
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
                case Type.Thd:
                    return "THD";
                case Type.ThdHf7:
                    return "THD-HF7-";
                default:
                    return "?";
            }
        }

        public bool SupportsWeightedSamples => false;
        public string Alias => "KOS" + "-" + GetKeyword() + k;
    }
}