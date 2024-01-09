using System;
using System.Globalization;
using Perfolizer.Common;
using Perfolizer.Mathematics.Common;
using Perfolizer.Mathematics.Distributions.ContinuousDistributions;
using Perfolizer.Mathematics.QuantileEstimators;
using static System.Math;

namespace Efficiency
{
    public class TrimmingStrategy
    {
        public string Name { get; }
        public Func<int, Probability> GetTrimmingPercentage { get; }

        public TrimmingStrategy(string name, Func<int, Probability> getTrimmingPercentage)
        {
            Name = name;
            GetTrimmingPercentage = getTrimmingPercentage;
        }
    }

    public class NewTrimmedQuantileEstimator : IQuantileEstimator
    {
        private readonly TrimmingStrategy trimmingStrategy;

        public NewTrimmedQuantileEstimator(TrimmingStrategy trimmingStrategy)
        {
            this.trimmingStrategy = trimmingStrategy;
        }

        private double GetTrimmingPercentage(int sampleSize)
        {
            return trimmingStrategy.GetTrimmingPercentage(sampleSize);
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

        private double GetBetaMode(double a, double b)
        {
            if (a > 1 && b > 1)
                return (a - 1) / (a + b - 2);
            if (a <= 1 && b > 1)
                return 0;
            if (a > 1 && b <= 1)
                return 1;
            return 0.5;
        }

        public double GetBetaHdiLeft(double a, double b, double size)
        {
            var mode = GetBetaMode(a, b);
            if (mode > 0.5)
            {
                var reverseLeft = GetBetaHdiLeft(b, a, size);
                var reverseRight = reverseLeft + size;
                return 1 - reverseRight;
            }

            var d = new BetaDistribution(a, b);
            if (size > mode && d.Pdf(size) < d.Pdf(0))
                return 0;
            return Uniroot(x => d.Pdf(x) - d.Pdf(x + size), Max(0, mode - size), Min(mode, 1 - size));
        }

        public double GetQuantile(Sample sample, Probability probability)
        {
            int n = sample.Count;
            double p = probability;
            double intervalSize = 1 - GetTrimmingPercentage(n);
            double a = (n + 1) * probability;
            double b = (n + 1) * (1 - probability);

            var distributionThd = new BetaDistribution((n + 1) * probability, (n + 1) * (1 - probability));

            double thdLeft = GetBetaHdiLeft(a, b, intervalSize);
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
                result += sample.SortedValues[i] * weight;
                current = next;
            }


            return result;
        }


        public bool SupportsWeightedSamples => false;

        public string Alias => "THD-" + trimmingStrategy.Name;
    }
}