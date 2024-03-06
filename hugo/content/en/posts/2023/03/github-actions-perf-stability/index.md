---
title: Performance stability of GitHub Actions
description: Investigating the stability of performance measurements on GitHub Actions build agents using simple benchmarks.
thumbnail: macos_disk-light
date: 2023-03-21
tags:
- Mathematics
- Statistics
- Research
- Performance Analysis
- Statistical Analysis
features:
- math
---

Nowadays, [GitHub Actions](https://github.com/features/actions) is one of the most popular free CI systems.
It's quite convenient to use it to run unit and integration tests.
However, some developers try to use it to run benchmarks and performance tests.
Unfortunately, default GitHub Actions build agents do not provide
  a consistent execution environment from the performance point of view.
Therefore, performance measurements from different builds can not be compared.
This makes it almost impossible to set up reliable performance tests based
  on the default GitHub Actions build agent pool.

So, it's expected that the execution environments are not *absolutely* identical.
But how bad is the situation?
What's the maximum difference between performance measurements from different builds?
Is there a chance that we can play with thresholds and
  utilize GitHub Actions to detect at least major performance degradations?
Let's find out!

<!--more-->

### Benchmark design

I created a small [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet)-based project
  that performs simple CPU-bound, Memory-bound, and Disk-bound benchmarks
  (the full source code is available at the repository
    [GitHubActionsPerfStability](https://github.com/AndreyAkinshin/GitHubActionsPerfStability)):

```cs
public class Benchmarks
{
    private readonly byte[] data = new byte[100 * 1024 * 1024];

    [GlobalSetup]
    public void Setup()
    {
        new Random(1729).NextBytes(data);
    }

    [Benchmark]
    public double Cpu()
    {
        double pi = 0;
        for (var i = 1; i <= 500_000_000; i++)
            pi += 1.0 / i / i;
        pi = Math.Sqrt(pi * 6);
        return pi;
    }

    [Benchmark]
    public void Disk()
    {
        for (var i = 0; i < 10; i++)
        {
            var fileName = Path.GetTempFileName();
            File.WriteAllBytes(fileName, data);
            File.Delete(fileName);
        }
    }

    [Benchmark]
    public int Memory()
    {
        var random = new Random(1729);
        var sum = 0;
        for (int i = 0; i < 200_000_00; i++)
            sum += data[random.Next(data.Length)];
        return sum;
    }
}
```

These benchmarks are synthetic, and they don't measure anything useful.
But in the scope of this investigation, we are not interested in measuring anything useful,
  we are interested only in the reproducibility of obtained measurements across different builds.

I configured these benchmarks to run 100 iterations of each method.
These are not microbenchmarks, so each iteration contains a single method invocation.
Next, I executed [100 GitHub Actions builds](https://github.com/AndreyAkinshin/GitHubActionsPerfStability/actions)
  using the same revision.
Each build was performed on three operating systems: Windows, Linux, and macOS.

### Benchmark results

The full dataset with the benchmarking results is available [here]({{< self-github-link >}}img/data.csv)
  (the `buildId` column matches the numbers of
   the [original builds](https://github.com/AndreyAkinshin/GitHubActionsPerfStability/actions)).

Here is the summary plot for all builds
  (measurements from all builds were aggregated to a unified time series with 10000 observations;
   different builds are marked with different colors
     so that we can identify the transition moment between adjacent builds;
   six colors are reused across multiple builds):

{{< imgld summary >}}

And here is a shortened summary for the first 20 builds:

{{< imgld summary20 >}}

Below you can find separate plots for each configuration:

{{< imgld linux_cpu >}}
{{< imgld linux_disk >}}
{{< imgld linux_memory >}}
{{< imgld windows_cpu >}}
{{< imgld windows_disk >}}
{{< imgld windows_memory >}}
{{< imgld macos_cpu >}}
{{< imgld macos_disk >}}
{{< imgld macos_memory >}}

### Conclusions

As we can see, the stability of measurements heavily depends on the operating system and the benchmark bottleneck.
In the general case, we can not expect reproducibility of the performance measurements.
In the scope of this experiment, the worst result was obtained for `macos`/`Disk`:
  two subsequent builds on the same revision can have ranges of 1.5..2 seconds and 12..36 seconds.
CPU-bound benchmarks are much more stable than Memory/Disk-bound benchmarks,
  but the "average" performance levels still can be up to three times different across builds.

Based on this brief study, I *do not* recommend using the default GitHub Actions build agent pool
  for any kind of performance comparisons across multiple builds:
  such results can not be trusted in the general case.
If you want to get a reliable set of performance tests,
  it's better to have a dedicated pool of physical build agents with a unified hardware/software configuration
  using carefully prepared OS images.

Note that this study is a small experiment that aims to demonstrate a possible difference
  between GitHub Actions build agents in a simple case,
  but it *is not* a full-fledged study that fully explores the full range of possible performance distributions.
If you try to set up a set of benchmarks or performance tests,
  it is recommended to perform separate thoughtful research on the build environment consistency
  using your target workloads.
