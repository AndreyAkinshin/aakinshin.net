[Fact]
public void Compare()
{
    Thread.CurrentThread.CurrentCulture = TestCultureInfo.Instance;
    Thread.CurrentThread.CurrentUICulture = TestCultureInfo.Instance;
    Directory.SetCurrentDirectory(@"W:\Temp\");
    
    Dump(new GumbelDistribution(), "gumbel");
    Dump(new NormalDistribution(0, 1), "normal");
    Dump(new BetaDistribution(10, 2), "beta");
    Dump(new UniformDistribution(0, 1), "uniform");
    Dump(new MixtureDistribution(new NormalDistribution(10, 1), new NormalDistribution(20, 1)), "bimodal");
}

private static void Dump(IDistribution distribution, string name, int n = 300)
{
    double[] x = distribution.Random(42).Next(n);
    double actual = distribution.Median;
    var p2Qe = new P2QuantileEstimator(0.5);
    var hdQe = HarrellDavisQuantileEstimator.Instance;
    var t7Qe = SimpleQuantileEstimator.Instance;

    using var writer = new StreamWriter($"{name}.csv");
    writer.WriteLine("index,x,P2,HarrellDavis,Type7,Actual");
    for (int i = 1; i <= n; i++)
    {
        var sample = new Sample(x.Take(i).ToList());
        p2Qe.AddValue(x[i - 1]);
        double p2 = p2Qe.GetQuantile();
        double hd = hdQe.GetMedian(sample);
        double t7  = t7Qe.GetMedian(sample);
        writer.WriteLine($"{i},{x[i - 1]},{p2},{hd},{t7},{actual}");
    }
}