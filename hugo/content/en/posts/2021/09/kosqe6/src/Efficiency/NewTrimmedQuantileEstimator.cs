using System;
using System.Globalization;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.QuantileEstimators;
using static System.Math;

namespace Efficiency
{
    public class NewTrimmedQuantileEstimator : IQuantileEstimator
    {
        private readonly Probability trimPercentage;

        public NewTrimmedQuantileEstimator(Probability trimPercentage)
        {
            this.trimPercentage = trimPercentage;
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
            double intervalSize = 1 - trimPercentage;
            double a = (n + 1) * probability;
            double b = (n + 1) * (1 - probability);
            
            var distributionThd = new BetaDistribution((n + 1) * probability, (n + 1) * (1 - probability));


            double thdLeft = Uniroot(x =>
                Pow(x, a - 1) * Pow(1 - x, b - 1) - Pow(x + intervalSize, a - 1) * Pow(1 - x - intervalSize, b - 1),
                0 + 1e-7, 1 - intervalSize - 1e-7);
            if (double.IsNaN(thdLeft))
                thdLeft = p < 0.5 ? 0 : 1 - intervalSize;
            double thdRight = thdLeft + intervalSize;
            var thdL = distributionThd.Cdf(thdLeft);
            var thdR = distributionThd.Cdf(thdRight);

            double Cdf(double x)
            {
                    if (x <= thdLeft)
                        return 0;
                    if (x >= thdRight)
                        return 1;

                    return (distributionThd.Cdf(x) - thdL) / (thdR - thdL);
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
        

        public bool SupportsWeightedSamples => false;
        public string Alias => "THD" + (trimPercentage * 100).ToString(CultureInfo.InvariantCulture) + "%";
    }
}