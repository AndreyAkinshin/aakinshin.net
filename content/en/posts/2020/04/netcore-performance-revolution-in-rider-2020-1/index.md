---
title: ".NET Core performance revolution in Rider 2020.1"
date: "2020-04-14"
tags:
- dotnet
- cs
- Rider
- Performance
- netcore
---

*This blog post was [originally posted](https://blog.jetbrains.com/dotnet/2020/04/14/net-core-performance-revolution-rider-2020-1/) on [JetBrains .NET blog](https://blog.jetbrains.com/dotnet/).*

Many <a href="https://www.jetbrains.com/rider/">Rider</a> users may know that <a href="https://www.codemag.com/Article/1811091/Building-a-.NET-IDE-with-JetBrains-Rider">the IDE has two main processes</a>: frontend (Java-application based on the IntelliJ platform) and backend (.NET-application based on ReSharper). Since the first release of Rider, we’ve used Mono as the backend runtime on Linux and macOS. A few years ago, we decided to migrate to .NET Core. After resolving hundreds of technical challenges, <strong>we are finally ready to present the .NET Core edition of Rider!</strong>

In this blog post, we want to share the results of some benchmarks that compare the Mono-powered and the .NET Core-powered editions of Rider. You may find this interesting if you are also thinking about migrating to .NET Core, or if you just want a high-level overview of the improvements to Rider in terms of performance and footprint, following the migration. (Spoiler: they’re huge!)

<!--more-->

<h2>Setup of our Performance Lab</h2>
Before we start to measure, we need to prepare. It's not easy to benchmark such a huge project, and we have dozens of different approaches for measuring performance. Since Rider is a desktop application, some approaches require physical access to the machine.

For example, some issues are monitor specific (like rendering lag on 4K-displays), while some others are laptop specific. Sometimes, performance can be affected by thermal throttling, which is hard to control without physical access. That's why we built a small performance laboratory with different kinds of hardware. Currently, our employees are working remotely, so the laboratory has temporarily been moved from the office to a home environment:
<blockquote class="twitter-tweet">
<p dir="ltr" lang="en">I finally finished setupping my home performance laboratory. It's time to run some benchmarks! <a href="https://t.co/o2C62STxwG">pic.twitter.com/o2C62STxwG</a></p>
— Andrey Akinshin (@andrey_akinshin) <a href="https://twitter.com/andrey_akinshin/status/1248259972254834691?ref_src=twsrc%5Etfw">April 9, 2020</a></blockquote>
<script src="https://platform.twitter.com/widgets.js" async="" charset="utf-8"></script>

For this blog post, we captured some manual performance measurements on the following hardware from the above picture:
<ul>
	<li>Mac mini, Intel Core i7-3615QM 2.30GHz. We have three such devices with different operating systems:
<ul>
	<li>Windows 10 (build 15063.1418)</li>
	<li>Ubuntu 18.04</li>
	<li>macOS 10.15</li>
</ul>
</li>
	<li>MacBook (Mid 2015, Intel Core i7-4870HQ 2.5GHz) with macOS 10.15.4</li>
	<li>Linux Desktop (Intel Core i7-6700 3.40GHz) with Deepin 15.11</li>
</ul>
Our main set of performance tests uses a full-featured instance of Rider, with all child processes and the user interface. We don't use any mock objects or emulations. Everything works exactly as it does on the computers of our users.

In this blog post, we will work with our three favorite benchmarks, which open an empty project, the <a href="https://github.com/OrchardCMS/Orchard">Orchard</a> solution (54 projects), and the <a href="https://github.com/nopSolutions/nopCommerce">nopCommerce</a> solution (40 projects). And with respect to the runtime versions, we use <em>Mono 6.8.0</em> and .<em>NET Core 3.1.3</em>.

Since we use complex integration benchmarks, we can't use <a href="https://github.com/dotnet/BenchmarkDotNet">BenchmarkDotNet</a>, <a href="https://openjdk.java.net/projects/code-tools/jmh/">JMH</a>, or other benchmarking libraries for measurements. Instead we use our own benchmark harness, and we use <a href="https://github.com/AndreyAkinshin/perfolizer">perfolizer</a> to analyze the performance data. The density plots in this post are drawn in <a href="https://www.r-project.org/">R</a> using the <a href="https://ggplot2.tidyverse.org/">ggplot2</a> package and the <a href="https://www.jstor.org/stable/2345597">Sheather &amp; Jones</a> bandwidth selector.

OK, now we are ready to benchmark!
<h2>Performance Measuring &amp; Improvements</h2>
We start with the test that opens a solution. Let's check the total time of this test on the Linux desktop:

{{< img dotnet-lin-perf-TotalTime >}}

Note that these results don’t mean that Rider takes 40-60 seconds to open a solution. These performance tests are synthetic, which means they include many waits and internal checks. The total duration of the test correlates with the actual time it takes for the solution to open, but it’s much longer. We use such tests to track the relative changes in performance between revisions. At the same time, it’s also useful to compare different runtimes.

As you can see, the total opening time improved <strong>20-30%</strong> after switching from Mono to .NET Core. That’s an impressive result given that we haven’t changed a single line in the source code!

Our benchmark harness is capable of measuring not only the total test time, but also individual metrics. Here is a plot that illustrates the difference in performance for a job that is responsible for adding solution assemblies to the internal Rider cache:

{{< img dotnet-lin-perf-Job.AddAssemblies >}}

Here we see a <strong>40-60%</strong> improvement! However, not all the metric plots look like this. Let's look at another metric that corresponds to the time it takes to load assembly metadata from the disk:

{{< img dotnet-lin-perf-AllMetadataLoadTime >}}

Here we can see that this metric has significantly degraded. We didn't have enough time for a detailed investigation, but we are definitely going to figure out why we got this result. The most important result for us right now is the improvement of the overall performance level, even though some sub metrics have degraded.

Now let's check out the same metrics on the MacBook:

{{< img dotnet-mac-perf-TotalTime >}}

{{< img dotnet-mac-perf-Job.AddAssemblies >}}

{{< img dotnet-mac-perf-AllMetadataLoadTime >}}

In general, the MacBook results look pretty much the same as the Linux results. However, if we look closely at the charts, we can see that the Linux results are actually better:

{{< img dotnet-lin_mac-perf-TotalTime >}}

Does this mean that .NET Core on Linux works faster than the same .NET Core on macOS? Of course not! The conditions of the experiment were inconsistent. The hardware of the Linux machine is more powerful than that of the MacBook.

To resolve this problem, we can compare different operating systems using Mac minis! We have three devices with equal hardware characteristics but different operating systems. Out of curiosity, we added Windows with .NET Framework 4.8 to this experiment (we haven’t yet released .NET Core edition for Windows, but we do already have internal experimental support). Let's repeat our measurements on this mini-farm of Mac mini's:

{{< img dotnet-minilin_minimac_miniwin-perf-TotalTime >}}

Here we can make the following observations:
<ul>
	<li>The difference between .NET Core and .NET Framework is not so dramatic as the difference between .NET Core and Mono. .NET Core is still a little bit faster, but it may be indistinguishable from .NET Framework in some cases. At least, however, we haven’t seen any regressions. This means that we can continue making the .NET Core edition Windows-compatible.</li>
	<li>If we compare Linux and macOS, the .NET Core edition works faster on Linux, and the Mono edition works faster on macOS. Of course, we can’t draw any general conclusions about runtimes based on a single experiment. However, such analysis is a good starting point for searching for OS-specific bottlenecks. We are definitely going to continue cross-OS benchmarking, which may help us find some interesting places for optimizations.</li>
</ul>
Total opening time is one of our most important metrics, but it's not the only one! Once a solution is opened, users start using thousands of Rider features. We are not going to present charts for each feature (they aren’t so exciting). Instead, we’ll describe the main categories that we identified:
<ul>
	<li>Features that work extremely fast on any runtime.
When a feature takes less than <strong>50-100ms</strong>, minor improvements will not affect user experience. Of course, we are interested in keeping the duration of such features low, but we don't actually care about minor speedups here.</li>
	<li>I/O-bound features.
It should come as no surprise that we didn't observe any significant changes in I/O-bound operations. When your main bottleneck is the disk read and write capabilities, it doesn't matter which runtime you use.</li>
	<li>Features that involve external processes.
Features like build, run, debug, and unit tests mostly depend on the performance of external processes, so they are not affected by the host runtime.</li>
	<li>Other features.
It's very hard to measure the "average" impact on the rest of the features, but it’s typically in the <strong>0-30%</strong> range, depending on the scenario.</li>
</ul>
However, in some features, we saw a tremendous uptick in speed! The most noticeable improvement was in the performance of NuGet restore. Before the migration, there was a limitation in the native NuGet client (see <a href="https://github.com/NuGet/NuGet.Client/blob/5.5.0.6473/src/NuGet.Core/NuGet.Common/NetworkProtocolUtility.cs#L32">the</a> <a href="https://github.com/NuGet/NuGet.Client/blob/5.5.0.6473/src/NuGet.Clients/NuGet.CommandLine/Commands/InstallCommand.cs#L67">source</a> <a href="https://github.com/NuGet/NuGet.Client/blob/5.5.0.6473/src/NuGet.Core/NuGet.Commands/RestoreCommand/RestoreRunner.cs#L216">code</a>): restore on Mono is single-threaded. Once we migrated to .NET Core, we automatically benefitted from NuGet-restore being multi-threaded.

We decided to measure the restore duration for the BenchmarkDotNet solution, and we took ten measurements on each runtime (the NuGet caches were cleared before each run):
<table>
<tbody>
<tr>
<td><strong>.NET Core</strong></td>
<td><strong>Mono</strong></td>
</tr>
<tr>
<td>16.9 sec</td>
<td>88.1 sec</td>
</tr>
<tr>
<td>18.2 sec</td>
<td>88.9 sec</td>
</tr>
<tr>
<td>17.3 sec</td>
<td>91.5 sec</td>
</tr>
<tr>
<td>17.0 sec</td>
<td>94.6 sec</td>
</tr>
<tr>
<td>15.5 sec</td>
<td>88.1 sec</td>
</tr>
<tr>
<td>15.8 sec</td>
<td>103.1 sec</td>
</tr>
<tr>
<td>15.7 sec</td>
<td>89.8 sec</td>
</tr>
<tr>
<td>17.4 sec</td>
<td>107.2 sec</td>
</tr>
<tr>
<td>16.5 sec</td>
<td>87.0 sec</td>
</tr>
<tr>
<td>16.4 sec</td>
<td>80.0 sec</td>
</tr>
</tbody>
</table>
In general, NuGet restore on .NET Core works 5.5-6.5 times faster!

Next, let's talk about the memory footprint.
<h2>Memory Footprint Reduction</h2>
One of the biggest complaints from our Linux and macOS users was about the amount of memory that is consumed by the Rider backend processes. For many years, we couldn't help these users, because most of the footprint problems were Mono-specific. It was almost impossible to fix them on our side. Is there a chance that migration to .NET Core has helped with this? Let's find out.

It's pretty hard to evaluate footprint changes in general. There are too many solution-specific issues and corner cases. Instead of a long list of charts, we decided to present measurements only for the five following solutions:
<ul>
	<li>(1) A solution with a single "Hello World" .NET Core project</li>
	<li>(2) Perfolizer (4 projects)</li>
	<li>(3) BenchmarkDotNet (19 projects)</li>
	<li>(4) A subset of the Rider solution without tests (162 projects) and with solution-wide analysis disabled</li>
	<li>(5) A subset of the Rider solution with tests (250 projects) and with solution-wide analysis enabled</li>
</ul>
For each solution, we did the following: opened the solution in Rider, waited for a steady-state (a moment when all the background initialization activities are finished), performed GC.Collect(), and measured the amount of allocated managed memory. For simplification, we’ve aggregated each distribution to a range that contains at least 95% of the measured values. Here are the results for the Linux desktop:
<table>
<tbody>
<tr>
<td><strong>Project</strong></td>
<td><strong>.NET Core</strong></td>
<td><strong>Mono</strong></td>
</tr>
<tr>
<td>(1)</td>
<td>75-80</td>
<td>150-160</td>
</tr>
<tr>
<td>(2)</td>
<td>90-100</td>
<td>170-180</td>
</tr>
<tr>
<td>(3)</td>
<td>180-190</td>
<td>330-340</td>
</tr>
<tr>
<td>(4)</td>
<td>560-640</td>
<td>800-840</td>
</tr>
<tr>
<td>(5)</td>
<td>1460-1500</td>
<td>1820-1860</td>
</tr>
</tbody>
</table>
This table doesn't cover all the corner cases, but it provides a pretty reliable high-level overview. In general, we saw a roughly <strong>40-50%</strong> improvement for small solutions and a roughly <strong>20-30%</strong> improvement for huge solutions. That’s another impressive result for a change that doesn't modify the source code.
<h2>Conclusion</h2>
It's pretty hard to evaluate performance and footprint changes in such a huge project after migration to another runtime. The metrics depend on many factors, such as the hardware used, the structure of a solution, and the use cases tested. If you ask for a short summarized conclusion, we can say that the total performance improvement ranges from <strong>0-30%</strong> for solution opening and some general features to <strong>550-650%</strong> for some individual features like NuGet restore. The total footprint improvement is roughly <strong>20-50%</strong> depending on the solution and the set of enabled features.

In case you are interested to know what’s next for us, here is our roadmap for the near future:
<ul>
	<li>We are going to migrate to .NET Core on Windows (currently we are still using .NET Framework; .NET Core is only enabled for Linux and macOS). It will take some time because not all of our features are ready for .NET Core (e.g., the current implementation of WinForms is not compatible with the new runtime), but we will do our best to finish the migration process this year.</li>
	<li>We are going to investigate cases where we have degradations after switching runtimes. It's a pretty interesting topic, but we just didn't have enough time for a thorough investigation ahead of this release.</li>
	<li>We are going to publish <a href="https://blog.jetbrains.com/dotnet/2020/04/27/socket-error-codes-depend-runtime-operating-system/"><strong>more blog posts about the technical challenges</strong></a> that we’ve resolved, about differences between .NET Core and Mono, and about our approaches to performance analysis. The goal of this post was to provide a high-level overview of the general impact of the migration, so we weren’t able to present a lot of interesting details. We will share those soon, though, so stay tuned!</li>
</ul>
Meanwhile, you can do your own performance research on your solutions. Here are a few tips that could help:
<ul>
	<li>You can add a status bar widget that displays the current runtime. Press <em>Ctrl+Shift+A</em> (or <em>Command+Shift+A</em> on macOS), find "<em>Registry...</em>", hit <em>Enter</em>, find <em>rider.enable.statusbar.runtimeIcon</em>, enable it, and restart Rider. After that, you will get a widget that displays the icon of .NET Core or Mono depending on the current runtime. While the .NET Core backend is publicly available, this status widget is not. Hence, it’s hidden in the registry, together with other experimental flags for the IDE. You’re now part of the secret group that wields the power of experimental flags!</li>
	<li>You can switch between runtimes with the Help menu (choose the "<em>Switch IDE Runtime to *</em>" action). Alternatively, you can switch using the runtime icon widget with a left-click.</li>
	<li>You can add a backend memory widget that displays the current amount of memory that is consumed by the backend process. Right-click on the status bar and choose "<em>Backend Memory Indicator</em>".</li>
</ul>
We would be happy to get your feedback about the .NET Core edition of Rider! We would particularly appreciate it if you shared how this change affects your solutions in terms of performance, footprint, and user experience. If you run into any problems or regressions, please file an issue in our <a href="https://youtrack.jetbrains.com/issues/RIDER">issue tracker</a> so we can investigate your issues and continue to improve our IDE!
