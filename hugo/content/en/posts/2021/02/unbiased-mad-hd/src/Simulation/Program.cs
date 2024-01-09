using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Perfolizer.Common;
using Perfolizer.Mathematics.Distributions;
using Perfolizer.Mathematics.QuantileEstimators;

namespace Simulation
{
    static class Program
    {
        private static double CalcSum(int n, IQuantileEstimator quantileEstimator, int seed, int iterations)
        {
            var generator = NormalDistribution.Standard.Random(seed);
            double[] src1 = new double[n];
            double[] src2 = new double[n];
            double sum = 0;
            for (int iter = 0; iter < iterations; iter++)
            {
                for (int i = 0; i < n; i++)
                    src1[i] = generator.Next();
                double median = quantileEstimator.GetMedian(new Sample(src1));
                for (int i = 0; i < n; i++)
                    src2[i] = Math.Abs(src1[i] - median);
                double mad = quantileEstimator.GetMedian(new Sample(src2));
                sum += mad;
            }

            return sum;
        }

        private static double Calc(int n, IQuantileEstimator quantileEstimator, int iterations = 200_000_000)
        {
            int cnt = Environment.ProcessorCount;
            var tasks = new Task<double>[cnt];
            for (int i = 0; i < tasks.Length; i++)
            {
                int seed = i;
                tasks[i] = Task.Factory.StartNew(() => CalcSum(n, quantileEstimator, seed, iterations / tasks.Length));
            }

            Task.WhenAll(tasks);
            double res = tasks.Sum(t => t.Result) / iterations;
            return res;
        }

        static void Main()
        {
            using var writer = new StreamWriter("simulation.csv");

            void Print(string message)
            {
                Console.WriteLine(message);
                writer.WriteLine(message);
                writer.Flush();
            }

            var ns = Enumerable
                .Range(2, 99)
                .Concat(new[] {150, 200, 250, 300, 350, 400, 450, 500, 1000, 1500, 2000})
                .ToArray();

            var sw = Stopwatch.StartNew();
            Print("n,factor");
            Print("1,NA");
            foreach (var n in ns)
            {
                var sw2 = Stopwatch.StartNew();
                var factor = Calc(n, HarrellDavisQuantileEstimator.Instance);
                sw2.Stop();

                Print($"{n},{factor}");
                Console.WriteLine("  Elapsed: " + sw2.Elapsed);
            }

            sw.Stop();

            Console.WriteLine("Total elapsed: " + sw.Elapsed);
        }
    }
}